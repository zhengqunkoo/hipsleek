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

(define-fun sll ((?in node) (?n Int) (?sm Int) (?lg Int))
Space (tospace
(or
(exists ((?flted_13_23 node))(and 
(= ?flted_13_23 nil)
(= ?qmin ?sm)
(= ?qmin ?lg)
(= ?n 1)
(tobool  
(pto ?in (sref (ref val ?qmin) (ref next ?flted_13_23) ))
 )
))(exists ((?sm_25 Int)(?lg_26 Int)(?flted_14_24 Int))(and 
(= (+ ?flted_14_24 1) ?n)
(<= ?sm ?qs)
(= ?sm_25 ?sm)
(= ?lg_26 ?lg)
(tobool (ssep 
(pto ?in (sref (ref val ?sm_25) (ref next ?q) ))
(sll ?q ?flted_14_24 ?qs ?lg_26)
) )
)))))

(define-fun bnd ((?in node) (?n Int) (?sm Int) (?bg Int))
Space (tospace
(or
(and 
(= ?in nil)
(= ?n 0)

)(exists ((?sm_29 Int)(?bg_30 Int)(?flted_9_28 Int))(and 
(= (+ ?flted_9_28 1) ?n)
(<= ?sm ?d)
(< ?d ?bg)
(= ?sm_29 ?sm)
(= ?bg_30 ?bg)
(tobool (ssep 
(pto ?in (sref (ref val ?d) (ref next ?p) ))
(bnd ?p ?flted_9_28 ?sm_29 ?bg_30)
) )
)))))
























































































(declare-fun bg3 () NUM)
(declare-fun sm5 () NUM)
(declare-fun n1 () Int)
(declare-fun xsnextprm () __Exc)
(declare-fun p1 () __Exc)
(declare-fun xsvalprm () NUM)
(declare-fun v5prm () NUM)
(declare-fun xs () __Exc)
(declare-fun c () NUM)
(declare-fun xsprm () __Exc)
(declare-fun bg2 () NUM)
(declare-fun sm4 () NUM)
(declare-fun bg () NUM)
(declare-fun sm () NUM)
(declare-fun flted8 () Int)
(declare-fun n () Int)
(declare-fun cprm () NUM)
(declare-fun d1 () NUM)


(assert 
(and 
;lexvar(= bg3 bg2)
(= sm5 sm4)
(= n1 flted8)
(= xsnextprm p1)
(= xsvalprm d1)
(= v5prm d1)
(= xsprm xs)
(= cprm c)
(<= sm c)
(<= c bg)
(distinct xsprm nil)
(= bg2 bg)
(= sm4 sm)
(< d1 bg)
(<= sm d1)
(= (+ flted8 1) n)
(<= cprm d1)

)
)

(assert (not 
;lexvar
))

(check-sat)