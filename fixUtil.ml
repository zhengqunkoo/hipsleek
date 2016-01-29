#include "xdebug.cppo"
open VarGen

(* Created 21 Feb 2006 Simplify Iast to Cast *)
open Globals
open Gen.Basic
open Wrapper
open Others
open Exc.GTable
open Printf
open Gen.Basic
open Gen.BList
open Perm
open Mcpure_D
open Mcpure
open Label_only
open Typeinfer
open CvpermUtils
open HipUtil

module C = Cast
module E = Env
module Err = Error
module I = Iast
module IF = Iformula
module IP = Ipure
module CF = Cformula
module CFE = Cf_ext
(* module CFU = Cfutil *)
module CFS = Cfsolver
(* module GV = Globalvars *)
module CP = Cpure
module MCP = Mcpure
module H = Hashtbl
module TP = Tpdispatcher
module Chk = Checks
(* module PRED = Predicate *)
module LO = Label_only.LOne
module LP = CP.Label_Pure
open IastUtil

let wrap_prover prv f a =
  let () = y_tinfo_pp "Calling wrap_prover" in
  let old_prv = !Tpdispatcher.pure_tp in
  let () = Tpdispatcher.pure_tp := prv in
  try
    let res = f a in
     Tpdispatcher.pure_tp := old_prv;
    res
  with _ as e ->
    (Tpdispatcher.pure_tp := old_prv;
     raise e)

(* Use Omega since Z3 is less precise, e.g. norm/ex25m5d.slk *)
let omega_imply_raw a b = wrap_prover OmegaCalc (Tpdispatcher.imply_raw a) b

let unfold_base_case_formula (f: CF.formula) (vd: Cast.view_decl) (base_list: (CF.formula * CF.h_formula) list) =
  let vname = vd.Cast.view_name in
  let extra_pure = ref [] in
  let replace_hf hf = (match hf with
      | CF.ViewNode vn ->
        if (String.compare vn.CF.h_formula_view_name vname = 0) then
          let (base_f,_) = List.find (fun (b,v) -> v = hf) base_list in
          let subs = Cast.collect_subs_from_view_node vn vd in
          let () = Debug.ninfo_hprint (add_str "base_f" !CF.print_formula) base_f no_pos in
          let new_subs = match base_f with
            | CF.Exists fe ->
              let qvars = fe.CF.formula_exists_qvars in
              let vl = List.map (fun (_,sv) -> sv) subs in
              let qvars = List.filter (fun sv -> not(List.mem sv vl)) qvars in
              List.map (fun sv -> match sv with
                  | CP.SpecVar (t,n,p) -> (CP.SpecVar (t,fresh_any_name n,p),sv)) qvars
            | _ -> []
          in
          let subs = subs@new_subs in
          let () = Debug.ninfo_hprint (add_str "subs" (pr_list (pr_pair !CP.print_sv !CP.print_sv))) subs no_pos in
          let replacing_f = CF.subst_one_by_one subs base_f in
          let () = Debug.ninfo_hprint (add_str "replacing_f" !CF.print_formula) replacing_f no_pos in
          let (replacing_hf,extra_pf,_,_,_,_) = CF.split_components replacing_f in
          let extra_qvars = CF.get_exists replacing_f in
          let () = Debug.ninfo_hprint (add_str "extra_qvars" (pr_list !CP.print_sv)) extra_qvars no_pos in
          extra_pure := !extra_pure @ [(extra_pf, extra_qvars)];
          Some replacing_hf                  (* replace the heap part *)
        else (Some hf)
      | _ -> None) in
  let f_ef _ = None in
  let f_f _ = None in
  let f_m mp = Some mp in
  let f_a a = Some a in
  let f_pf pf = Some pf in
  let f_b bf= Some bf in
  let f_e e = Some e in
  let () = Debug.ninfo_hprint (add_str "f" !CF.print_formula) f no_pos in
  let new_f = CF.transform_formula (f_ef, f_f, replace_hf, (f_m, f_a, f_pf, f_b, f_e)) f in
  let () = Debug.ninfo_hprint (add_str "new_f" !CF.print_formula) new_f no_pos in
  let pos = CF.pos_of_formula new_f in
  let new_f = List.fold_left (fun f (mf,qv) ->
      let nf = CF.mkAnd_pure f mf pos in       (* add the pure part back *)
      CF.push_exists qv nf
    ) new_f !extra_pure in
  let () = Debug.ninfo_hprint (add_str "new_f_final" !CF.print_formula) new_f no_pos in
  new_f

let uniq lst =
  let unique_set = Hashtbl.create (List.length lst) in
  List.iter (fun x -> Hashtbl.replace unique_set x ()) lst;
  Hashtbl.fold (fun x () xs -> x :: xs) unique_set []

let compute_inv_baga ls_mut_rec_views cviews0 =
  (* let all_mutrec_vnames = List.concat ls_mut_rec_views in *)
  let cviews0 =
    if !Globals.gen_baga_inv then
      let () = x_binfo_pp "Generate baga inv\n" no_pos in
      (* let cviews0 = List.filter (fun cv -> *)
      (*     (not cv.Cast.view_is_prim) *)
      (*   ) cviews0 in *)
      let () = List.iter (fun cv ->
          (* Hashtbl.add *) Excore.map_baga_invs # replace x_loc cv.C.view_name Excore.EPureI.mk_false_disj;
          (* Hashtbl.add *) Excore.map_precise_invs # replace x_loc cv.C.view_name true
        ) cviews0 in
      let cviews0_with_index = Expure.add_index_to_views cviews0 in
      let ls_mut_rec_views1 = List.fold_left (fun ls cv ->
          if List.mem cv.C.view_name (List.flatten ls) then
            ls
          else if (List.mem cv.C.view_name (List.flatten ls_mut_rec_views)) then
            let mut_rec_views = List.find (fun mr_views ->
                List.mem cv.C.view_name mr_views) ls_mut_rec_views in
            ls@[mut_rec_views]
          else
            ls@[[cv.C.view_name]]
        ) [] cviews0_with_index in
      (* let map_baga_invs = Hashtbl.create 1 in *)
      (* moved to cpure.ml *)
      let () = List.iter (fun idl ->
          (* if !Globals.gen_baga_inv then *)
          let view_list_baga0 = List.filter (fun vd ->
              List.mem vd.Cast.view_name idl
            ) cviews0 in
          let view_list_baga = List.map (fun vd ->
              let new_un_struc_formula = List.map (fun (cf,lbl) ->
                  let num_svl = List.filter (fun sv -> (CP.is_int_typ sv || CP.is_num_typ sv)) vd.Cast.view_vars in
                  let abs_fnc = if !Globals.delay_eelim_baga_inv then CF.shape_abs else CF.wrap_exists in
                  let new_cf = (* CF.wrap_exists *) abs_fnc  num_svl cf in
                  let () = Debug.binfo_hprint (add_str "new_cf" Cprinter.string_of_formula) new_cf no_pos in
                  (new_cf,lbl)
                ) vd.Cast.view_un_struc_formula in
              {vd with Cast.view_un_struc_formula = new_un_struc_formula}
            ) view_list_baga0 in
          let view_list_num0 = List.filter (fun vd ->
              List.mem vd.Cast.view_name idl
            ) cviews0_with_index in
          let view_list_num = List.map (fun vd ->
              let new_un_struc_formula = List.map (fun (cf,lbl) ->
                  let baga_svl = List.filter (fun sv ->
                      not ((CP.is_int_typ sv) || (CP.is_num_typ sv))
                    ) vd.Cast.view_vars in
                  let baga_svl = [CP.mk_spec_var "self"]@baga_svl in
                  let new_cf = CF.wrap_exists baga_svl cf in
                  (new_cf,lbl)
                ) vd.Cast.view_un_struc_formula in
              {vd with Cast.view_un_struc_formula = new_un_struc_formula}
            ) view_list_num0 in
          let todo_unk = Wrapper.wrap_infer_inv Expure.fix_ef view_list_baga cviews0 in
          let () = x_binfo_pp ("Omega call after infer baga inv" ^ (string_of_int !Omega.omega_call_count) ^ " invocations") no_pos in
          let view_list_num_with_inv = x_add Fixcalc.compute_inv_mutrec (List.map (fun vd -> vd.Cast.view_name) view_list_num) view_list_num in


          let () = x_binfo_hp (add_str "fixcalc (view with inv)" (pr_list (fun vd -> pr_option Cprinter.string_of_mix_formula vd.Cast.view_fixcalc))) view_list_num_with_inv no_pos in
          let fixcalc_invs_inv = List.map (fun vd -> match vd.Cast.view_fixcalc with Some f -> f | None -> MCP.mkMTrue no_pos) view_list_num_with_inv in
          let num_invs_wrap_index = List.map (fun mf ->
              let pf = MCP.pure_of_mix mf in
              let idx = CP.mk_typed_spec_var Int "idx" in
              let pf_svl = CP.fv pf in
              let new_pf = if List.mem idx pf_svl then CP.wrap_exists_svl pf [idx] else pf in
              Excore.simplify_with_label Tpdispatcher.simplify new_pf
            ) fixcalc_invs_inv in
          let () = x_binfo_hp (add_str "fixcalc_invs_inv" (pr_list Cprinter.string_of_mix_formula)) fixcalc_invs_inv no_pos in
          (* WN : Need to check if supplied inv is a fixpoint! *)
          let infer_vs_user = List.combine view_list_num_with_inv num_invs_wrap_index in
          let num_invs = List.map (fun (vd,fixc) ->
              (* if not(CP.isConstTrue (MCP.pure_of_mix vd.Cast.view_user_inv)) then *)
              (*   vd.Cast.view_user_inv *)
              (* else *)
              (*   vd.Cast.view_x_formula *)
              let user_inv = MCP.pure_of_mix vd.Cast.view_user_inv in
              let better =
                if List.exists (fun sv -> (CP.type_of_spec_var sv) != Int) (CP.fv user_inv) then fixc (* user inv is not just numeric *)
                else if (omega_imply_raw fixc user_inv) then fixc
                else
                  (* to check view_form ==> usr_inv *)
                  let body = CF.project_body_num vd.Cast.view_un_struc_formula user_inv vd.Cast.view_vars in
                  let () = x_binfo_hp (add_str "fixc" Cprinter.string_of_pure_formula) fixc no_pos in
                  let () = x_binfo_hp (add_str "body" Cprinter.string_of_pure_formula) body no_pos in
                  let () = x_binfo_hp (add_str "user_inv" Cprinter.string_of_pure_formula) user_inv no_pos in
                  let () = x_winfo_pp "WARNING: TODO fixpt check" no_pos in
                  if ((* true *) omega_imply_raw body user_inv) then
                    let () = x_winfo_hp (add_str "User supplied is more precise" Cprinter.string_of_pure_formula) user_inv no_pos in
                    user_inv
                  else
                    let () = x_winfo_hp (add_str "User supplied is unsound" Cprinter.string_of_pure_formula) user_inv no_pos in
                    let () = x_winfo_hp (add_str "Using fixcalc version" Cprinter.string_of_pure_formula) fixc no_pos in
                    fixc
              in better
            )  infer_vs_user in
          let check_under_num_inv inv body =
            if CP.isConstTrue inv then
              let disjs = CP.split_disjunctions body in
              List.for_all (fun disj ->
                  let disj = Tpdispatcher.simplify disj in
                  CP.isConstTrue disj
                ) disjs
            else (omega_imply_raw inv) body
          in
          let precise_num_invs = List.map (fun (vd,fixc) ->
              (* if not(CP.isConstTrue (MCP.pure_of_mix vd.Cast.view_user_inv)) then *)
              (*   vd.Cast.view_user_inv *)
              (* else *)
              (*   vd.Cast.view_x_formula *)
              try
                let body = CF.project_body_num vd.Cast.view_un_struc_formula fixc vd.Cast.view_vars in
                (* let root = CP.mk_spec_var "self" in *)
                let ptrs_vars = List.filter (fun (CP.SpecVar(t,id,_)) -> (string_eq id "idx") || (is_node_typ t)) vd.Cast.view_vars in
                let body = CP.wrap_exists_svl body (* [root] *) ptrs_vars in
                let () = x_binfo_hp (add_str "body" Cprinter.string_of_pure_formula) body no_pos in
                let () = x_binfo_hp (add_str "num_inv" Cprinter.string_of_pure_formula) fixc no_pos in
                let is_precise_num = if x_add check_under_num_inv fixc body then
                    let () = x_binfo_pp ("Predicate " ^ vd.Cast.view_name ^ " has precise invariant\n") no_pos in
                    (true,fixc)
                  else
                    let () = y_binfo_pp ("Imprecise path ... " ^ vd.Cast.view_name) in
                    let idx = CP.mk_typed_spec_var Int "idx" in
                    let alter_num_inv =
                      let f1 = CF.project_body_num vd.Cast.view_un_struc_formula (CP.mkFalse no_pos) vd.Cast.view_vars in
                      let f1 = x_add_1 Excore.simplify_with_label Tpdispatcher.simplify_raw (CP.wrap_exists_svl f1 [idx]) in
                      let f2 = CF.project_body_num vd.Cast.view_un_struc_formula f1 vd.Cast.view_vars in
                      let f2 = x_add_1 Excore.simplify_with_label Tpdispatcher.simplify_raw (CP.wrap_exists_svl f2 [idx]) in
                      let f3 = CF.project_body_num vd.Cast.view_un_struc_formula f2 vd.Cast.view_vars in
                      let f3 = x_add_1 Excore.simplify_with_label Tpdispatcher.simplify_raw (CP.wrap_exists_svl f3 [idx]) in
                      let f3p = Excore.simplify_with_label TP.pairwisecheck_raw f3 in
                      let f4 = CF.project_body_num vd.Cast.view_un_struc_formula f3p vd.Cast.view_vars in
                      let f4 = x_add_1 Excore.simplify_with_label Tpdispatcher.simplify_raw (CP.wrap_exists_svl f4 [idx]) in
                      let f5 = x_add Fixcalc.widen f3 f4 in
                      f5
                    in
                    let () = x_binfo_hp (add_str "alter_num_inv" Cprinter.string_of_pure_formula) alter_num_inv no_pos in
                    let alter_body = CF.project_body_num vd.Cast.view_un_struc_formula alter_num_inv vd.Cast.view_vars in
                    let alter_body = x_add_1 Excore.simplify_with_label Tpdispatcher.simplify_raw (CP.wrap_exists_svl alter_body [idx]) in
                    if omega_imply_raw alter_num_inv alter_body then
                      let () = x_binfo_pp ("Predicate " ^ vd.Cast.view_name ^ " has precise invariant\n") no_pos in
                      (true,alter_num_inv)
                    else
                      let () = x_binfo_pp ("Predicate " ^ vd.Cast.view_name ^ " has over invariant\n") no_pos in
                      (false,fixc)
                in
                is_precise_num
              with _ ->
                let () = x_binfo_pp ("Predicate " ^ vd.Cast.view_name ^ " has over invariant (exc) \n") no_pos in
                (false,fixc)
            )  (List.combine view_list_num_with_inv num_invs) in
          let precise_list,num_invs = List.split precise_num_invs in
          let () = x_binfo_pp ("Omega call after infer num inv: " ^ (string_of_int !Omega.omega_call_count) ^ " invocations") no_pos in
          (* let baga_invs = List.map (fun vd -> Hashtbl.find Excore.map_baga_invs vd.Cast.view_name) view_list_baga in *)
          let baga_invs = List.map (fun vd -> Excore.map_baga_invs # find vd.Cast.view_name) view_list_num_with_inv in
          let fixcalc_invs = List.map (fun vd -> vd.Cast.view_fixcalc) view_list_baga in
          let fixcalc_invs_cviews0 = List.map (fun vd -> vd.Cast.view_fixcalc) cviews0 in
          let () = x_ninfo_hp (add_str "fixcalc_invs" (pr_list (pr_option Cprinter.string_of_mix_formula))) fixcalc_invs no_pos in
          (* let () = x_binfo_hp (add_str "fixcalc_invs_inv" (pr_list (pr_option Cprinter.string_of_mix_formula))) fixcalc_invs_inv no_pos in *)
          let () = x_binfo_hp (add_str "fixcalc_invs (cviews0)" (pr_list (pr_option Cprinter.string_of_mix_formula))) fixcalc_invs_cviews0 no_pos in
          let () = x_binfo_hp (add_str "num_invs" (pr_list Cprinter.string_of_pure_formula)) num_invs no_pos in
          let () = y_binfo_hp (add_str "precise_invs" (pr_list string_of_bool)) precise_list in
          let () = x_binfo_hp (add_str "baga_invs" (pr_list Excore.EPureI.string_of_disj)) baga_invs no_pos in
          let () = List.iter (fun (vd,inv) ->
              (* Hashtbl.add *) Excore.map_num_invs # replace x_loc vd.Cast.view_name ((CP.mk_self None)::vd.Cast.view_vars,inv)
            ) (List.combine view_list_baga0 num_invs) in
          let baga_num_invs = List.combine baga_invs num_invs in
          let combined_invs = List.map (fun (disj,pf) ->
              let disj1 = List.hd (Excore.EPureI.mk_epure pf) in
              let new_disj = List.map (fun disj2 -> Excore.EPureI.mk_star disj1 disj2) disj in
              new_disj
            ) baga_num_invs in
          let () = x_binfo_hp (add_str "combined_invs" (pr_list Excore.EPureI.string_of_disj)) combined_invs no_pos in
          let () = List.iter (fun (vd,inv) ->
              Excore.map_baga_invs # replace x_loc vd.Cast.view_name inv
            ) (List.combine view_list_baga0 combined_invs) in
          let () = x_binfo_pp ("Omega call after combine inv: " ^ (string_of_int !Omega.omega_call_count) ^ " invocations") no_pos in
          let unfold_cnt = new Gen.change_flag in
          let rec unfold precise old_invs =
            if unfold_cnt # exceed 10 then
              let () = x_winfo_pp "WARNING : Unfolding for baga-inv exceeded 10" no_pos in
              old_invs
            else
              let () = unfold_cnt # inc in
              (* let () = x_tinfo_hp (add_str "old_invs" (pr_list Excore.EPureI.string_of_disj)) old_invs no_pos in *)
              let new_invs = List.map (fun vd ->
                  let new_inv = (* if !Globals.delay_eelim_baga_inv && !Globals.gen_baga_inv then *)
                    (*   let inv = List.concat combined_invs in *)
                    (*   let () = Debug.info_hprint (add_str "computed_baga" (Excore.EPureI.string_of_disj)) inv no_pos in *)
                    (*   inv *)
                    (* else *)
                    Wrapper.wrap_infer_inv (x_add Cvutil.xpure_symbolic_baga3) cviews0 (Cast.formula_of_unstruc_view_f vd) in
                  let new_inv = List.map (fun (svl,pf) ->
                      let idx = CP.mk_typed_spec_var Int "idx" in
                      let new_pf_svl = CP.fv pf in
                      let new_pf = if List.mem idx new_pf_svl then CP.wrap_exists_svl pf [idx] else pf in
                      (svl,new_pf)
                    ) new_inv in
                  let () = Debug.ninfo_hprint (add_str "new_inv" Excore.EPureI.string_of_disj) new_inv no_pos in
                  new_inv
                ) view_list_baga0 in
              let () = Debug.ninfo_hprint (add_str "new_invs" (pr_list Excore.EPureI.string_of_disj)) new_invs no_pos in
              if List.length old_invs = 0 then
                let () = List.iter (fun (vd,new_inv) ->
                    Excore.map_baga_invs # replace x_loc vd.Cast.view_name new_inv
                  ) (List.combine view_list_baga0 new_invs) in
                unfold precise new_invs
              else if not precise then
                let () = List.iter (fun (vd,new_inv) ->
                    Excore.map_baga_invs # replace x_loc vd.Cast.view_name new_inv;
                    Excore.map_precise_invs # replace x_loc vd.Cast.view_name false
                  ) (List.combine view_list_baga0 new_invs) in
                new_invs
              else if List.for_all (fun (ante,cons) ->
                  Excore.EPureI.imply_disj ante cons) (List.combine old_invs new_invs) then
                old_invs
              else
                let () = List.iter (fun (vd,new_inv) ->
                    Excore.map_baga_invs # replace x_loc vd.Cast.view_name new_inv
                  ) (List.combine view_list_baga0 new_invs) in
                unfold precise new_invs
          in
          (* let precise_list = List.map (fun (vd, num_inv) -> *)
          (*     let is_precise_num = *)
          (*       let pr = Cprinter.string_of_mix_formula in *)
          (*       let () = x_tinfo_hp (add_str "precise? view_user_inv" pr) vd.Cast.view_user_inv no_pos in *)
          (*       let () = x_tinfo_hp (add_str "(2) view_x_formula" pr) vd.Cast.view_x_formula no_pos in *)
          (*       let () = x_tinfo_hp (add_str "view_fixcalc" (pr_option pr)) vd.Cast.view_fixcalc no_pos in *)
          (*       if not(CP.isConstTrue (MCP.pure_of_mix vd.Cast.view_user_inv)) then true *)
          (*       else if CP.isConstTrue num_inv then true *)
          (*       else *)
          (*         let body = CF.project_body_num vd.Cast.view_un_struc_formula num_inv vd.Cast.view_vars in *)
          (*         let root = CP.mk_spec_var "self" in *)
          (*         let body = CP.wrap_exists_svl body [root] in *)
          (*         let () = x_tinfo_hp (add_str "body" Cprinter.string_of_pure_formula) body no_pos in *)
          (*         let () = x_tinfo_hp (add_str "num_inv" Cprinter.string_of_pure_formula) num_inv no_pos in *)
          (*         omega_imply_raw num_inv body *)
          (*     in *)
          (*     in is_precise_num *)
          (* ) (List.combine view_list_baga0 num_invs) in *)
          (* WN : Looping at unfold with imprecise inv *)
          let () = x_tinfo_pp ("Omega call:unfold-start " ^ (string_of_int !Omega.omega_call_count) ^ " invocations") no_pos in
          let new_invs = unfold (List.for_all (fun a -> a) precise_list) combined_invs in
          let () = x_tinfo_pp ("Omega call:unfold-end " ^ (string_of_int !Omega.omega_call_count) ^ " invocations") no_pos in
          let () = Debug.ninfo_hprint (add_str "new_invs" (pr_list Excore.EPureI.string_of_disj)) new_invs no_pos in
          ()
          (* let new_invs_list = x_add_1 Expure.fix_ef view_list cviews0 in *)
          (* let new_invs_list = List.map (fun epd -> Excore.EPureI.to_cpure_disj epd) new_invs_list in *)
          (* let () = x_tinfo_hp (add_str "view invs" (pr_list (fun v -> *)
          (*     Cprinter.string_of_mix_formula v.Cast.view_user_inv))) view_list no_pos in *)
          (* let () = x_tinfo_hp (add_str "baga_invs" (pr_list Cprinter.string_of_ef_pure_disj)) new_invs_list no_pos in *)
          (* if user inv stronger than baga inv, invoke dis_inv_baga() *)
          (* let lst = List.combine view_list new_invs_list in *)
          (* let baga_stronger = List.for_all *)
          (*   (fun (vd,bi) -> *)
          (*       match vd.Cast.view_baga_inv with *)
          (*         | None -> true *)
          (*         | Some uv -> *)
          (*               let () = Debug.ninfo_hprint (add_str ("infered baga inv("^vd.Cast.view_name^")") (Cprinter.string_of_ef_pure_disj)) bi no_pos in *)
          (*               Excore.EPureI.imply_disj (Excore.EPureI.from_cpure_disj bi) uv *)
          (*   ) lst in *)
          (* let pr = pr_list (pr_pair (fun vd -> vd.Cast.view_name)  Cprinter.string_of_ef_pure_disj) in *)
          (* x_tinfo_hp pr lst no_pos; *)
          (* if (not baga_stronger) then ( *)
          (*     () *)
          (* x_tinfo_pp "not baga_stronger\n" no_pos; *)
          (* Globals.dis_inv_baga () *)
          (* ) else *)
          (*   () *)
          (* update with stronger baga invariant *)
          (* () *)
          (* let new_map = List.combine views_list new_invs_list in *)
          (* List.iter (fun (cv,inv) -> Hashtbl.add CP.map_baga_invs cv.C.view_name inv) new_map *)
        ) ls_mut_rec_views1 in
      let cviews1 = (* if !Globals.gen_baga_inv then *)
        List.map (fun cv ->
            if (List.exists (fun (f,_) ->
                let _,p,_,_,_,_ = Cformula.split_components f in
                (CP.is_AndList (Mcpure.pure_of_mix p))
              ) cv.Cast.view_un_struc_formula)
            then cv else
              let inv = (* Hashtbl.find *) Excore.map_baga_invs # find cv.C.view_name in
              let inv = List.fold_left (fun acc (b,f) ->
                  let fl = CP.split_disjunctions f in
                  acc@(List.map (fun f -> (b,f)) fl)
                ) [] inv in
              let precise = Excore.map_precise_invs # find cv.C.view_name in
              let () = x_binfo_hp (add_str ("infered baga inv("^cv.C.view_name^")") (Cprinter.string_of_ef_pure_disj)) inv (* (Excore.EPureI.pairwisecheck_disj inv) *) no_pos in
              let () = print_string_quiet "\n" in
              let user_inv = MCP.pure_of_mix cv.Cast.view_user_inv in
              let body = CF.project_body_num cv.Cast.view_un_struc_formula user_inv cv.Cast.view_vars in
              let is_sound = x_add omega_imply_raw body user_inv in
              let () = if not is_sound then
                  x_winfo_pp ((add_str "User supplied inv is not sound: " !CP.print_formula) user_inv) no_pos
                else () in
              let extra_pure = ref [] in
              let replace_hf hf base_f= None
              in
              let under_inv = if !Globals.under_infer_limit = -1 then
                  []
                else
                  let body_under = fst (List.split cv.Cast.view_un_struc_formula) in
                  let (ifs,bfs) = List.partition CF.is_inductive body_under in
                  let vnodes = List.fold_left (fun acc ifs -> acc@(CF.get_vnodes ifs))[] ifs in
                  let rec helper_unfold no bfs ifs =
                    if no = 0 then bfs
                    else
                      let tl = ref [] in
                      (* let new_bfs = [] in *)
                      let rec gen_base_list tl= 
                        if (List.length tl = List.length vnodes) then
                          let base_list = List.combine tl vnodes in
                          let () = Debug.ninfo_hprint (add_str "combined XXX" (pr_list (pr_pair !CF.print_formula !CF.print_h_formula))) base_list no_pos in
                          let new_bfs = List.map(fun f -> unfold_base_case_formula f cv base_list) ifs in
                          let () = Debug.ninfo_hprint (add_str "new_bfs XXX" (pr_list !CF.print_formula)) new_bfs no_pos in
                          new_bfs
                        else
                          let () = Debug.ninfo_hprint (add_str "old_bfs XXX" (pr_list !CF.print_formula)) bfs no_pos in
                          List.fold_left(fun acc bf -> acc@(gen_base_list (tl@[bf]))) [] bfs
                      in
                      let new_bfs = bfs@(gen_base_list []) in
                      let new_bfs = uniq new_bfs in  (* remove duplicates *)
                      helper_unfold (no-1) new_bfs ifs
                  in
                  let () = Debug.ninfo_hprint (add_str "base case" (pr_list Cprinter.string_of_formula)) bfs no_pos in
                  let () = Debug.ninfo_hprint (add_str "inductive" (pr_list Cprinter.string_of_formula)) ifs no_pos in
                  let bfs = (* bfs@ *)(helper_unfold !Globals.under_infer_limit bfs ifs) in
                  let under_inv = List.fold_left (fun acc f ->
                      let pf = (wrap_under_baga (x_add Cvutil.xpure_symbolic_baga3) cviews0 f) in
                      let () = Debug.ninfo_hprint (add_str "unfold base" Cprinter.string_of_ef_pure_disj) pf no_pos in
                      let acc = uniq acc in
                      acc@(wrap_under_baga (x_add Cvutil.xpure_symbolic_baga3) cviews0 f)
                    ) [] bfs
                  in
                  (* let under_inv = uniq under_inv in *)
                  let () = x_binfo_hp (add_str ("unfolded baga inv("^cv.C.view_name^")") (Cprinter.string_of_ef_pure_disj)) under_inv no_pos in
                  under_inv
              in
              if precise then
                match cv.Cast.view_baga_inv with
                | None -> 
                  let mf = (x_add_1 Excore.EPureI.ef_conv_disj inv) in
                  let () = y_tinfo_hp (add_str "pure inv3" !CP.print_formula) mf in
                  let mf =  Mcpure.mix_of_pure mf  in
                  {cv with
                   C.view_baga = 
                     (let es = Excore.EPureI.get_baga_sv inv in
                      (* CP.SV_INTV.conv_var *) es);
                   C.view_baga_inv = Some inv;
                   C.view_baga_over_inv = Some inv;
                   C.view_baga_under_inv = Some inv;
                   C.view_baga_x_over_inv = Some inv;
                   C.view_user_inv = mf;
                   C.view_x_formula = Mcpure.merge_mems cv.C.view_x_formula mf true;
                  }
                | Some inv0 ->
                  if Excore.EPureI.imply_disj (Excore.EPureI.from_cpure_disj inv) inv0 then 
                    let mf = (x_add_1 Excore.EPureI.ef_conv_disj inv) in
                    let () = y_tinfo_hp (add_str "pure inv2" !CP.print_formula) mf in
                    let mf =  Mcpure.mix_of_pure mf  in
                    {cv with
                     C.view_baga = (let es = Excore.EPureI.get_baga_sv inv in
                                    (* CP.SV_INTV.conv_var *) es);
                     C.view_baga_inv = Some inv;
                     C.view_baga_over_inv = Some inv;
                     C.view_baga_under_inv = Some inv;
                     C.view_baga_x_over_inv = Some inv;
                     C.view_user_inv = mf;
                     C.view_x_formula = Mcpure.merge_mems cv.C.view_x_formula mf true;
                    }
                  else cv
              else
                let inf_inv = x_add_1 Excore.EPureI.ef_conv_disj inv in
                if (omega_imply_raw inf_inv user_inv) || (not is_sound) then
                  let mf = (x_add_1 Excore.EPureI.ef_conv_disj inv) in
                  let () = y_tinfo_hp (add_str "pure inv" !CP.print_formula) mf in
                  let mf =  Mcpure.mix_of_pure mf  in
                  let vu = match under_inv with
                    | [] -> None
                    | _ -> Some under_inv
                  in
                  {cv with
                   C.view_baga = (let es = Excore.EPureI.get_baga_sv inv in
                                  (* CP.SV_INTV.conv_var *) es);
                   C.view_baga_over_inv = Some inv;
                   C.view_baga_under_inv = vu;
                   C.view_x_formula = Mcpure.merge_mems cv.C.view_x_formula mf true;
                  }
                else cv
          ) cviews0
        (* else *)
        (*   cviews0 *)
      in
      (* let () = (\* if !Globals.gen_baga_inv then *\) ( *)
      (*   x_tinfo_pp "end gen baga\n" no_pos; *)
      (*   Globals.dis_inv_baga () *)
      (* ) in *)
      cviews1
    else
      cviews0
  in cviews0

let compute_inv_baga ls_mut_rec_views cviews0 =
  let pr = pr_list (fun vd -> vd.C.view_name) in
  let pr2 = pr_list_ln Cprinter.string_of_view_decl_inv in
  Debug.no_1 "compute_inv_baga" pr pr2 (fun _ -> compute_inv_baga ls_mut_rec_views cviews0) cviews0
