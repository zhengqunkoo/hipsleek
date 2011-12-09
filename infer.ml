open Globals
module DD = Debug
open Gen
open Exc.GTable
open Perm
open Cformula
open Context

module Err = Error
module CP = Cpure
module MCP = Mcpure
module CF = Cformula

let no_infer estate = (estate.es_infer_vars == [])
 
let remove_infer_vars_old estate =
  let iv = estate.es_infer_vars in
  if (iv==[]) then (estate,iv)
  else ({estate with es_infer_vars=[];}, iv) 

let remove_infer_vars estate rt =
  let iv = estate.es_infer_vars in
  if (iv==[]) then (estate,iv)
  else ({estate with es_infer_vars=CP.diff_svl iv rt;}, iv) 

let rec restore_infer_vars_ctx iv ctx = 
  match ctx with
  | Ctx estate -> Ctx {estate with es_infer_vars=iv;}
  | OCtx (ctx1, ctx2) -> OCtx (restore_infer_vars_ctx iv ctx1, restore_infer_vars_ctx iv ctx2)

let restore_infer_vars iv cl =
  if (iv==[]) then cl
  else match cl with
    | FailCtx _ -> cl
    | SuccCtx lst -> SuccCtx (List.map (restore_infer_vars_ctx iv) lst)

let is_inferred_pre estate = 
  let r = (List.length (estate.es_infer_heap))+(List.length (estate.es_infer_pure)) in
  if r>0 then true else false

let rec is_inferred_pre_ctx ctx = 
  match ctx with
  | Ctx estate -> is_inferred_pre estate 
  | OCtx (ctx1, ctx2) -> (is_inferred_pre_ctx ctx1) || (is_inferred_pre_ctx ctx2)

let is_inferred_pre_list_context ctx = 
  match ctx with
  | FailCtx _ -> false
  | SuccCtx lst -> List.exists is_inferred_pre_ctx lst

(* let rec is_inferred_pre_list_context = match ctx with *)
(*   | Ctx estate -> is_inferred_pre estate  *)
(*   | OCtx (ctx1, ctx2) -> (is_inferred_pre_ctx ctx1) || (is_inferred_pre_ctx ctx2) *)

let rec collect_pre_pure ctx = 
  match ctx with
  | Ctx estate -> estate.es_infer_pure 
  | OCtx (ctx1, ctx2) -> (collect_pre_pure ctx1) @ (collect_pre_pure ctx2) 

let rec collect_pre_heap ctx = 
  match ctx with
  | Ctx estate -> estate.es_infer_heap 
  | OCtx (ctx1, ctx2) -> (collect_pre_heap ctx1) @ (collect_pre_heap ctx2) 

let collect_pre_heap_list_context ctx = 
  match ctx with
  | FailCtx _ -> []
  | SuccCtx lst -> List.concat (List.map collect_pre_heap lst)

let collect_pre_pure_list_context ctx = 
  match ctx with
  | FailCtx _ -> []
  | SuccCtx lst -> List.concat (List.map collect_pre_pure lst)

let rec init_vars ctx vars = match ctx with
  | Ctx estate -> Ctx {estate with es_infer_vars = vars}
  | OCtx (ctx1, ctx2) -> OCtx (init_vars ctx1 vars, init_vars ctx2 vars)

let rec infer_heap_aux heap vars = match heap with
  | ViewNode ({ h_formula_view_node = p;
  h_formula_view_arguments = args})
  | DataNode ({h_formula_data_node = p;
  h_formula_data_arguments = args}) -> List.mem p vars
  | Star ({h_formula_star_h1 = h1;
    h_formula_star_h2 = h2;
    h_formula_star_pos = pos})
  | Conj ({h_formula_conj_h1 = h1;
    h_formula_conj_h2 = h2;
    h_formula_conj_pos = pos}) ->
    infer_heap_aux h1 vars || infer_heap_aux h2 vars
  | _ -> false

let infer_heap_main iheap ivars old_vars = 
  let rec infer_heap heap vars = 
    match heap with
    | ViewNode ({ h_formula_view_node = p;
    h_formula_view_arguments = args})
    | DataNode ({h_formula_data_node = p;
    h_formula_data_arguments = args}) -> 
      if List.mem p vars then 
        (Gen.Basic.remove_dups (List.filter (fun x -> CP.name_of_spec_var x!= CP.name_of_spec_var p) 
          vars @ args), heap) 
      else (ivars, HTrue)
    | Star ({h_formula_star_h1 = h1;
      h_formula_star_h2 = h2;
      h_formula_star_pos = pos}) ->
      let res1 = infer_heap_aux h1 vars in
      let res2 = infer_heap_aux h2 vars in
      if res1 then 
        let (vars1, heap1) = infer_heap h1 vars in
        let (vars2, heap2) = infer_heap h2 vars1 in
        (vars2, Star ({h_formula_star_h1 = heap1;
                       h_formula_star_h2 = heap2;
                       h_formula_star_pos = pos}))
      else
      if res2 then 
        let (vars2, heap2) = infer_heap h2 vars in
        let (vars1, heap1) = infer_heap h1 vars2 in
        (vars1, Star ({h_formula_star_h1 = heap1;
                       h_formula_star_h2 = heap2;
                       h_formula_star_pos = pos}))
      else (ivars, HTrue)
    | Conj ({h_formula_conj_h1 = h1;
      h_formula_conj_h2 = h2;
      h_formula_conj_pos = pos}) ->
      let res1 = infer_heap_aux h1 vars in
      let res2 = infer_heap_aux h2 vars in
      if res1 then 
        let (vars1, heap1) = infer_heap h1 vars in
        let (vars2, heap2) = infer_heap h2 vars1 in
        (vars2, Conj ({h_formula_conj_h1 = heap1;
                       h_formula_conj_h2 = heap2;
                       h_formula_conj_pos = pos}))
      else
      if res2 then 
        let (vars2, heap2) = infer_heap h2 vars in
        let (vars1, heap1) = infer_heap h1 vars2 in
        (vars1, Conj ({h_formula_conj_h1 = heap1;
                       h_formula_conj_h2 = heap2;
                       h_formula_conj_pos = pos}))
      else (ivars, HTrue)
    | _ -> (ivars, HTrue)
  in infer_heap iheap ivars
(*
type: h_formula ->
  CP.spec_var list -> CP.spec_var list -> CP.spec_var list * h_formula
*)
let infer_heap_main iheap ivars old_vars = 
  let pr1 = !print_h_formula in
  let prv = !print_svl in
  let pr2 = Gen.pr_pair prv pr1 in
  Gen.Debug.no_3 "infer_heap_main" pr1 prv prv pr2 infer_heap_main iheap ivars old_vars

let conv_infer_heap hs =
  let rec helper hs h = match hs with
    | [] -> h
    | x::xs -> 
          let acc = 
	        Star({h_formula_star_h1 = x;
	        h_formula_star_h2 = h;
	        h_formula_star_pos = no_pos})
          in helper xs acc in
  match hs with
    | [] -> HTrue 
    | x::xs -> helper xs x

let extract_pre_list_context x = 
  (* TODO : this has to be implemented by extracting from es_infer_* *)
  (* print_endline (!print_list_context x); *)
  None

(* get exactly one root of h_formula *)
let get_args_h_formula (h:h_formula) =
  match h with
    | DataNode h -> 
          let arg = h.h_formula_data_arguments in
          let new_arg = CP.fresh_spec_vars_prefix "inf" arg in
         Some (h.h_formula_data_node, arg,new_arg, 
         DataNode {h with h_formula_data_arguments=new_arg;})
    | ViewNode h -> 
          let arg = h.h_formula_view_arguments in
          let new_arg = CP.fresh_spec_vars_prefix "inf" arg in
          Some (h.h_formula_view_node, arg,new_arg,
          ViewNode {h with h_formula_view_arguments=new_arg;} )
    | _ -> None

let get_alias_formula (f:formula) =
	let (h, p, fl, b, t) = split_components f in
    let eqns = (MCP.ptr_equations_without_null p) in
    eqns

let build_var_aset lst = CP.EMapSV.build_eset lst

(*
 let iv = es_infer_vars in
 check if h_formula root isin iv
 if not present then 
  begin
    (i) look for le = lhs_pure based on iv e.g n=0
        e.g. infer [n] n=0 |- x::node<..>
   (ii) if le=true then None
        else add not(le) to infer_pure
  end
 else 
  begin
   check if rhs causes a contradiction with estate
      e.g. infer [x] x=null |- x::node<..>
      if so then
           ?
      else
         add h_formula to infer_heap
  end
*)

let infer_heap_nodes (es:entail_state) (rhs:h_formula) rhs_rest conseq = 
  let iv = es.es_infer_vars in
  let rt = get_args_h_formula rhs in
  let lhs_als = get_alias_formula es.es_formula in
  let lhs_aset = build_var_aset lhs_als in
  let rhs_als = get_alias_formula conseq in
  let rhs_aset = build_var_aset rhs_als in
  let (b,args,inf_vars,new_h,new_iv,alias) = match rt with (* is rt captured by iv *)
    | None -> false,[],[],HTrue,iv,[]
    | Some (r,args,arg2,h) -> 
          let alias = CP.EMapSV.find_equiv_all r lhs_aset in
          let rt_al = [r]@alias in (* set of alias with root of rhs *)
          let b = not((CP.intersect iv rt_al) == []) in (* does it intersect with iv *)
          (* let new_iv = (CP.diff_svl (arg2@iv) rt_al) in *)
          let new_iv = arg2@iv in
          let alias = if List.mem r iv then [] else alias in
          (List.exists (CP.eq_spec_var_aset lhs_aset r) iv,args,arg2,h,new_iv,alias) in
  let args_al = List.map (fun v -> CP.EMapSV.find_equiv_all v rhs_aset) args in
  (* let _ = print_endline ("infer_heap_nodes") in *)
  (* let _ = print_endline ("infer var: "^(!print_svl iv)) in *)
  (* let _ = print_endline ("new infer var: "^(!print_svl new_iv)) in *)
  (* (\* let _ = print_endline ("LHS aliases: "^(pr_list (pr_pair !print_sv !print_sv) lhs_als)) in *\) *)
  (* (\* let _ = print_endline ("RHS aliases: "^(pr_list (pr_pair !print_sv !print_sv) rhs_als)) in *\) *)
  (* let _ = print_endline ("root: "^(pr_option (fun (r,_,_,_) -> !print_sv r) rt)) in *)
  (* let _ = print_endline ("rhs node: "^(!print_h_formula rhs)) in *)
  (* let _ = print_endline ("renamed rhs node: "^(!print_h_formula new_h)) in *)
  (* (\* let _ = print_endline ("heap args: "^(!print_svl args)) in *\) *)
  (* (\* let _ = print_endline ("heap inf args: "^(!print_svl inf_vars)) in *\) *)
  (* (\* let _ = print_endline ("heap arg aliases: "^(pr_list !print_svl args_al)) in *\) *)
  (* let _ = print_endline ("root in iv: "^(string_of_bool b)) in *)
  (* (\* let _ = print_endline ("RHS exist vars: "^(!print_svl es.es_evars)) in *\) *)
  (* (\* let _ = print_endline ("RHS impl vars: "^(!print_svl es.es_gen_impl_vars)) in *\) *)
  (* (\* let _ = print_endline ("RHS expl vars: "^(!print_svl es.es_gen_expl_vars)) in *\) *)
  (* (\* let _ = print_endline ("imm pure stack: "^(pr_list !print_mix_formula es.es_imm_pure_stk)) in *\) *)
  if b then 
    begin
      (* Take the alias as the inferred pure *)
      let rec filter_var f vars = match f with
        | CP.Or (f1,f2,l,p) -> CP.Or (filter_var f1 vars, filter_var f2 vars, l, p)
        | _ -> if Omega.is_sat f "0" then CP.filter_var f vars else CP.mkFalse no_pos
      in
      let simplify = fun f vars -> match vars with
        | [] -> CP.mkTrue no_pos
        | _ -> Omega.simplify (filter_var (Omega.simplify f) vars) 
      in
      let _,new_p,_,_,_ = CF.split_components es.es_formula in
      let new_p = simplify (MCP.pure_of_mix new_p) alias in
      (* TODO WN : push a match action on must_action_stk *)
      let r = {
          match_res_lhs_node = new_h;
          match_res_lhs_rest = HTrue;
          match_res_holes = [];
          match_res_type = Root;
          match_res_rhs_node = rhs;
          match_res_rhs_rest = rhs_rest;} in
      let act = M_match r in
      (must_action_stk # push act;
      Some (new_iv,new_h,new_p))
    end
  else None

let infer_pure estate lhs_xpure rhs_xpure pos =
  if no_infer estate then None
  else
    let fml = CP.mkAnd (MCP.pure_of_mix lhs_xpure) (MCP.pure_of_mix rhs_xpure) pos in
    let check_sat = Omega.is_sat fml "0" in
    let rec filter_var f vars = match f with
      | CP.Or (f1,f2,l,p) -> CP.Or (filter_var f1 vars, filter_var f2 vars, l, p)
      | _ -> if Omega.is_sat f "0" then CP.filter_var f vars else CP.mkFalse pos
    in
    let simplify = fun f vars -> Omega.simplify (filter_var (Omega.simplify f) vars) in
    let iv = estate.es_infer_vars in
    let invariants = List.fold_left (fun p1 p2 -> CP.mkAnd p1 p2 pos) (CP.mkTrue pos) estate.es_infer_invs in
    if check_sat then
      (* Temporarily *)
(*      if List.length estate.es_trace > 0 & List.hd estate.es_trace = "Base case fold" then None*)
(*      else                                                                                     *)
        let new_p = simplify fml iv in
        let new_p = simplify (CP.mkAnd new_p invariants pos) iv in
        if CP.isConstTrue new_p then None
        else
          let args = CP.fv new_p in 
          let new_iv = (CP.diff_svl iv args) in
          let new_estate =
            {estate with 
              es_formula = normalize 0 estate.es_formula (CF.formula_of_pure_formula new_p pos) pos;
              es_infer_pure = estate.es_infer_pure@[new_p];
              es_infer_vars = new_iv
            }
          in
          Some (new_p, new_estate)
    else
      let mkNot purefml =
        let conjs = CP.split_conjunctions purefml in
        let conjs = List.map (fun c -> CP.mkNot_s c) conjs in
        List.fold_left (fun p1 p2 -> CP.mkAnd p1 p2 pos) (CP.mkTrue pos) conjs
      in      
      let lhs_simplified = simplify (MCP.pure_of_mix lhs_xpure) iv in
      let new_p = simplify (CP.mkAnd (mkNot lhs_simplified) invariants pos) iv in
      if CP.isConstFalse new_p then None
      else
        let args = CP.fv new_p in 
        let new_iv = (CP.diff_svl iv args) in
        let new_estate =
          {estate with 
            es_formula = CF.mkFalse (CF.mkTrueFlow ()) pos;
            es_infer_pure = estate.es_infer_pure@[new_p];
            es_infer_vars = new_iv
          }
        in
        Some (new_p, new_estate)

let infer_empty_rhs estate lhs_p rhs_p pos =
  estate

let infer_empty_rhs_old estate lhs_p rhs_p pos =
  if no_infer estate then estate
  else
    let _ = DD.devel_pprint ("\n inferring_empty_rhs:"^(!print_formula estate.es_formula)^ "\n\n")  pos in
    let rec filter_var f vars = match f with
      | CP.Or (f1,f2,l,p) -> CP.Or (filter_var f1 vars, filter_var f2 vars, l, p)
      | _ -> CP.filter_var f vars
    in
    let infer_pure = MCP.pure_of_mix rhs_p in
    let infer_pure = if CP.isConstTrue infer_pure then infer_pure
    else CP.mkAnd (MCP.pure_of_mix rhs_p) (MCP.pure_of_mix lhs_p) pos
    in
    (*        print_endline ("PURE: " ^ Cprinter.string_of_pure_formula infer_pure);*)
    let infer_pure = Omega.simplify (filter_var infer_pure estate.es_infer_vars) in
    let pure_part2 = Omega.simplify (List.fold_left (fun p1 p2 -> CP.mkAnd p1 p2 pos) (CP.mkTrue pos)
        (estate.es_infer_pures @ [MCP.pure_of_mix rhs_p])) in
    (*        print_endline ("PURE2: " ^ Cprinter.string_of_pure_formula infer_pure);*)
    let infer_pure = if Omega.is_sat pure_part2 "0" = false then [CP.mkFalse pos] else [infer_pure] in
      {estate with es_infer_heap = []; es_infer_pure = infer_pure;
          es_infer_pures = estate.es_infer_pures @ [(MCP.pure_of_mix rhs_p)]}

let infer_empty_rhs2 estate lhs_xpure rhs_p pos =
  estate

let infer_empty_rhs2_old estate lhs_xpure rhs_p pos =
  if no_infer estate then estate
  else
    let _ = DD.devel_pprint ("\n inferring_empty_rhs2:"^(!print_formula estate.es_formula)^ "\n\n")  pos in
    (* let lhs_xpure,_,_,_ = xpure prog estate.es_formula in *)
    let pure_part_aux = Omega.is_sat (CP.mkAnd (MCP.pure_of_mix lhs_xpure) (MCP.pure_of_mix rhs_p) pos) "0" in
    let rec filter_var_aux f vars = match f with
      | CP.Or (f1,f2,l,p) -> CP.Or (filter_var_aux f1 vars, filter_var_aux f2 vars, l, p)
      | _ -> CP.filter_var f vars
    in
    let filter_var f vars = 
      if CP.isConstTrue (Omega.simplify f) then CP.mkTrue pos 
      else
        let res = filter_var_aux f vars in
        if CP.isConstTrue (Omega.simplify res) then CP.mkFalse pos
        else res
    in
    let invs = List.fold_left (fun p1 p2 -> CP.mkAnd p1 p2 pos) (CP.mkTrue pos) estate.es_infer_invs in
    let pure_part = 
      if pure_part_aux = false then
        let mkNot purefml = 
          let conjs = CP.split_conjunctions purefml in
          let conjs = List.map (fun c -> CP.mkNot_s c) conjs in
          List.fold_left (fun p1 p2 -> CP.mkAnd p1 p2 pos) (CP.mkTrue pos) conjs
        in
        let lhs_pure = CP.mkAnd (mkNot(Omega.simplify 
            (filter_var (MCP.pure_of_mix lhs_xpure) estate.es_infer_vars))) invs pos in
        (*print_endline ("PURE2: " ^ Cprinter.string_of_pure_formula lhs_pure);*)
        CP.mkAnd lhs_pure (MCP.pure_of_mix rhs_p) pos
      else Omega.simplify (CP.mkAnd (CP.mkAnd (MCP.pure_of_mix lhs_xpure) (MCP.pure_of_mix rhs_p) pos) invs pos)
    in
    let pure_part = filter_var (Omega.simplify pure_part) estate.es_infer_vars in
    (*        print_endline ("PURE: " ^ Cprinter.string_of_mix_formula rhs_p);*)
    let pure_part = Omega.simplify pure_part in
    let pure_part2 = Omega.simplify (CP.mkAnd pure_part 
        (List.fold_left (fun p1 p2 -> CP.mkAnd p1 p2 pos) (CP.mkTrue pos) 
            (estate.es_infer_pures @ [MCP.pure_of_mix rhs_p])) pos) in
    (*        print_endline ("PURE1: " ^ Cprinter.string_of_pure_formula pure_part);*)
    (*        print_endline ("PURE2: " ^ Cprinter.string_of_pure_formula pure_part2);*)
    let pure_part = if (CP.isConstTrue pure_part & pure_part_aux = false) 
      || Omega.is_sat pure_part2 "0" = false then [CP.mkFalse pos] else [pure_part] in
    {estate with es_infer_heap = []; es_infer_pure = pure_part;
        es_infer_pures = estate.es_infer_pures @ [(MCP.pure_of_mix rhs_p)]}

(* what does this method do? *)
let infer_for_unfold prog estate lhs_node pos =
              estate

let infer_for_unfold_old prog estate lhs_node pos =
  if no_infer estate then estate
  else
    let _ = DD.devel_pprint ("\n inferring_for_unfold:"^(!print_formula estate.es_formula)^ "\n\n")  pos in
    let inv = match lhs_node with
      | ViewNode ({h_formula_view_name = c}) ->
            let vdef = Cast.look_up_view_def pos prog.Cast.prog_view_decls c in
            let i = MCP.pure_of_mix (fst vdef.Cast.view_user_inv) in
            if List.mem i estate.es_infer_invs then estate.es_infer_invs
            else estate.es_infer_invs @ [i]
      | _ -> estate.es_infer_invs
    in {estate with es_infer_invs = inv} 
