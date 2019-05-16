#include "xdebug.cppo"
open VarGen
open Printf
open Gen.Basic
open Globals
open Repairpure

module C = Cast
module CP = Cpure
module CF = Cformula
module Syn = Synthesis
module I = Iast

let pr_proc = Iprinter.string_of_proc_decl
let pr_iprog = Iprinter.string_of_program
let pr_ctx = Cprinter.string_of_list_failesc_context
let pr_formula = Cprinter.string_of_formula
let pr_struc_f = Cprinter.string_of_struc_formula

let filter_cand buggy_loc cand =
  match buggy_loc with
  | Some b_loc ->
    let cand_pos = Iast.get_exp_pos cand in
    let () = x_tinfo_hp (add_str "buggy pos" (Cprinter.string_of_pos)) b_loc no_pos in
    let () = x_tinfo_hp (add_str "cand pos" (Cprinter.string_of_pos)) cand_pos no_pos in
    let b_lnum = b_loc.start_pos.Lexing.pos_lnum in
    let cand_lnum = cand_pos.start_pos.Lexing.pos_lnum in
    b_lnum = cand_lnum
  | None ->
    let cand_pos = Iast.get_exp_pos cand in
    let b_loc = VarGen.proving_loc#get in
    let b_lnum = b_loc.start_pos.Lexing.pos_lnum in
    let cand_lnum = cand_pos.start_pos.Lexing.pos_lnum in
    b_lnum >= cand_lnum


let find_pre_cond ctx prog = match ctx with
  | Some r_ctx ->
    let () = x_tinfo_hp (add_str "ctx" pr_ctx) r_ctx no_pos in
    let ctx_f = CF.formula_of_list_failesc_context r_ctx in
    let pf = CF.get_pure ctx_f in
    let eq_vars = CP.pure_ptr_equations_aux false pf in
    let eq_vars_w_null = CP.pure_ptr_equations_aux true pf in
    let eq_null = List.filter (fun x -> not(List.mem x eq_vars)) eq_vars_w_null in
    let unfold_vars = List.map fst eq_null in
    let n_ctx = List.fold_left (fun ctx var ->
        Solver.unfold_failesc_context (prog, None) ctx var true no_pos
      ) r_ctx unfold_vars in
    let () = x_binfo_hp (add_str "n_ctx" pr_ctx) n_ctx no_pos in
    let n_ctx_f = CF.formula_of_list_failesc_context n_ctx in
    Some n_ctx_f
  | None -> None

let mk_candidate_iproc (iproc:I.proc_decl) args candidate =
  match iproc.proc_body with
    | None -> (iproc, args)
    | Some exp ->
      let loc = I.get_exp_pos candidate in
      let decl_vars = Synthesis.get_var_decls loc exp
                      |> List.map (fun sv -> let CP.SpecVar (a, b, _) = sv in
                                    (a,b)) in
      let args = args @ decl_vars in
      let fcode = create_fcode_exp args in
      let n_body = Some (replace_exp exp fcode candidate) in
      ({iproc with proc_body = n_body}, args)

let mk_candidate_iprog iprog (iproc:I.proc_decl) args candidate =
  let pr_proc = Iprinter.string_of_proc_decl in
  let pr_procs = pr_list pr_proc in
  let n_iproc, args = mk_candidate_iproc iproc args candidate in
  let () = x_binfo_hp (add_str "proc" pr_proc) n_iproc no_pos in
  let () = Syn.repair_pos := Some (I.get_exp_pos candidate) in
  let rec helper args = match args with
    | [] -> ""         | [(typ, name)] -> (string_of_typ typ) ^ " " ^ name
    | h::t -> let tail = helper t in
      let head = string_of_typ (fst h) ^ " " ^ (snd h) in
      head ^ "," ^ tail in
  let names, arg_str = args |> List.map snd, helper args in
  let arg_names = s_i_list names "," in
  let typ = type_of_exp candidate in
  let fcode = "HeapPred P(" ^ arg_str ^ ").\n"
              ^ "HeapPred Q(" ^ arg_str ^ ").\n"
              ^ (string_of_typ typ) ^ " fcode(" ^ arg_str ^ ")\n"
              ^ "requires P(" ^ arg_names ^ ")\n"
              ^ "ensures Q(" ^ arg_names ^ ");" in
  let () = x_tinfo_hp (add_str "fcode" pr_id) fcode no_pos in
  let n_prog = Parser.parse_hip_string "fcode" fcode in
  let procs = n_prog.I.prog_proc_decls in
  let hps = n_prog.I.prog_hp_decls in
  let () = x_tinfo_hp (add_str "hp" (pr_list Iprinter.string_of_hp_decl)) hps no_pos in
  let n_procs = List.map (fun x -> if x.I.proc_name = iproc.I.proc_name
                           then n_iproc else x) iprog.I.prog_proc_decls in
  let n_procs = n_prog.I.prog_proc_decls @ n_procs in
  let n_hps = n_prog.I.prog_hp_decls @ iprog.I.prog_hp_decls in
  (* report_error no_pos "to filter the fcode" *)
  {iprog with prog_hp_decls = n_hps;
              prog_proc_decls = n_procs}

let repair_one_candidate (proc_name: string) (iprog: I.prog_decl) =
  let () = x_tinfo_pp "marking" no_pos in
  let () = Syn.entailments := [] in
  let () = Syn.rel_num := 0 in
  let () = Syn.res_num := 0 in
  let () = Syn.repair_res := None in
  let () = Syn.syn_pre := None in
  let cprog, _ = Astsimp.trans_prog iprog in
  let () = Syn.unk_hps := cprog.Cast.prog_hp_decls in
  try
    (* to collect all constraints *)
    let () = Typechecker.check_prog_wrapper iprog cprog in
    (* to solve constraints -> synthesis -> repair result *)
    let () = x_binfo_pp "start synthesis process" no_pos in
    let iprog = !Syn.syn_iprog |> Gen.unsome in
    let prog = !Syn.syn_cprog |> Gen.unsome in
    let proc = C.find_proc prog proc_name in
    let _ = Synthesizer.synthesize_entailments iprog prog proc in
    !Synthesis.repair_res
  with _ ->
    let () = x_binfo_pp "error in other branch -> still start synthesis" no_pos in
    let iprog = !Syn.syn_iprog |> Gen.unsome in
    let prog = !Syn.syn_cprog |> Gen.unsome in
    let proc = C.find_proc prog proc_name in
    let _ = Synthesizer.synthesize_entailments iprog prog proc in
    !Synthesis.repair_res

let repair_iprog (iprog:I.prog_decl) =
  let start_time = get_time () in
  let pr_exps = pr_list Iprinter.string_of_exp in
  match (!Typechecker.repair_proc) with
  | (Some repair_proc) ->
    let p_name = Cast.unmingle_name repair_proc in
    let () = x_binfo_hp (add_str "proc_name: " pr_id) p_name no_pos in
    let () = Globals.start_repair := true in
    let r_iproc = List.find (fun x -> eq_str x.I.proc_name p_name) iprog.prog_proc_decls in
    let cands = get_stmt_candidates (Gen.unsome r_iproc.proc_body) in
    let () = x_binfo_hp (add_str "candidates: " pr_exps) cands no_pos in
    let cands = List.filter (filter_cand !repair_loc) cands in
    let () = x_binfo_hp (add_str "candidates: " pr_exps) cands no_pos in
    let cproc = !Syn.repair_proc |> Gen.unsome in
    let args = cproc.C.proc_args in
    let helper cand =
      let n_iprog = mk_candidate_iprog iprog r_iproc args cand in
      repair_one_candidate repair_proc n_iprog in
    let res = cands |> List.map helper |> List.filter (fun x -> x != None) in
    if res = [] then
      let () = x_binfo_pp "REPAIRING FAILED\n" no_pos in None
    else
      let r_time = get_time() -. start_time in
      let () = x_binfo_pp "REPAIRING SUCCESSFUL\n" no_pos in
      let () = x_binfo_hp (add_str "repair time" string_of_float) r_time no_pos in
      let () = x_binfo_hp (add_str "failed branches" string_of_int)
          !Syn.fail_branch_num no_pos in
      let () = x_binfo_hp (add_str "check_entail" string_of_int)
          !Syn.check_entail_num no_pos in
      List.hd res
  | _ -> None

let rec start_repair_wrapper iprog =
  let tmp = repair_iprog iprog in
  tmp
