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
















































































































































































































































(declare-fun v12prm () Int)
(declare-fun n () Int)
(declare-fun aprm () Int)
(declare-fun a () Int)
(declare-fun xprm () node)
(declare-fun x () node)


(assert 
(and 
;lexvar(= aprm v12prm)
(= v12prm 1)
(< 0 a)
(< a n)
(= aprm a)
(= xprm x)
(tobool  
(ll x n)
 )
)
)

(assert (not 
;lexvar
))

(check-sat)