(**
 * Proof object
 *
 * @author Vu An Hoa
 *)

open Term
	
type proof_step =
	| HYP 
		(* trivial as being hypothesis *)
	| RW of term * term
		(* rewrite *)
	| IND of term * proof * proof
		(* induction on a term; *)
		(* proof for base case and *)
		(* inductive case *)
	| MP of proof * proof
		(* application of Modus Ponen rule *)
		(* {p, p -> q} |- q *)
		
and proof = proof_step list

let mkEmptyProof () = []
	
type infer_rule = 
	| Hyp (* hypothesis *)
	| Rewrite (* rewrite rule, with two parameters [lhs; rhs] such that lhs = rhs or rhs = lhs is in hypotheses *)
	| Induction (* induction on a term, one parameter [N] indicating the term to do induction on *)
	| ModusPonens 
	(* modus ponens, parameter list *)
	(* [F1,F2,...,F_n] to indicate the *)
	(* interpolant formulas, subtree *)
	(* includes proofs for F1, F2, ..., Fn*)
	(* and F1 -> F2 -> ... -> Fn -> goal, *)
	(* usually F1 -> F2 -> ... -> Fn -> goal is in the hypotheses *)

type proof_tree = {
		(* hypotheses (including axioms and established theorems) *)
		context : term list;
		
		(* map symbols to their types *)
		symbol_domain : (int * Domain.domain) list;
		
		(* goal at the root node *)
		goal : term;
		
		(* inference rule to apply *)
		rule : infer_rule;
		
		(* parameters for rule *)
		(* for example, value to do induction on, *)
		(* equation to do rewrite, etc. *)
		params : term list;
		
		(* the children representing sub-goals *)
		(* generated by the rule and their proofs *)
		subtrees : proof_tree list;
	}
	
let mkEmptyProofTree () = []