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
















































































































































































































































(declare-fun m () Int)
(declare-fun Anon22 () Int)
(declare-fun xsprm () node)
(declare-fun ysprm () node)
(declare-fun next6 () node)
(declare-fun tmpprm () node)
(declare-fun q22 () node)
(declare-fun xs () node)
(declare-fun ys2 () node)
(declare-fun ys () node)
(declare-fun xs2 () node)
(declare-fun flted34 () Int)
(declare-fun n () Int)


(assert 
(and 
;lexvar(= xsprm tmpprm)
(= ysprm xs2)
(= next6 q22)
(= tmpprm q22)
(= xs2 xs)
(= ys2 ys)
(distinct xs2 nil)
(= (+ flted34 1) n)
(tobool (ssep 
(ll q22 flted34)
(ll ys m)
(pto xs2 (sref (ref val Anon22) (ref next ys2) ))
) )
)
)

(assert (not 
(and 
(tobool (ssep 
(ll xsprm n9)
(ll ysprm m2)
) )
)
))

(check-sat)