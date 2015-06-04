(set-logic QF_S)
(set-info :source |  Sleek solver
  http://loris-7.ddns.comp.nus.edu.sg/~project/s2/beta/
|)

(set-info :smt-lib-version 2.0)
(set-info :category "crafted")
(set-info :status unsat)


(declare-sort node 0)
(declare-fun val () (Field node Int))
(declare-fun next () (Field node node))

(define-fun ll ((?in node) (?n Int))
Space (tospace
(or
(and 
(= ?in nil)
(= ?n 0)

)(exists ((?flted_14_23 Int))(and 
(= (+ ?flted_14_23 1) ?n)
(tobool (ssep 
(pto ?in (sref (ref val ?Anon_12) (ref next ?q) ))
(ll ?q ?flted_14_23)
) )
)))))
















































































































































































































































(declare-fun Anon46 () Int)
(declare-fun m () Int)
(declare-fun tmpprm () node)
(declare-fun q46 () node)
(declare-fun xs () node)
(declare-fun ysprm () node)
(declare-fun ys () node)
(declare-fun xsprm () node)
(declare-fun flted66 () Int)
(declare-fun n () Int)


(assert 
(and 
;lexvar(= tmpprm q46)
(= xsprm xs)
(= ysprm ys)
(distinct xsprm nil)
(= (+ flted66 1) n)
(tobool (ssep 
(pto xsprm (sref (ref val Anon46) (ref next q46) ))
(ll q46 flted66)
(ll ys m)
) )
)
)

(assert (not 
(and 
(tobool  
(pto xsprm (sref (ref val val36prm) (ref next next36prm) ))
 )
)
))

(check-sat)