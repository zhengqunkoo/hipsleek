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
(exists ((?sm_25 Int)(?flted_14_23 node))(and 
(= ?flted_14_23 nil)
(= ?sm ?lg)
(= ?n 1)
(= ?sm_25 ?sm)
(tobool  
(pto ?in (sref (ref val ?sm_25) (ref next ?flted_14_23) ))
 )
))(exists ((?sm_26 Int)(?lg_27 Int)(?flted_15_24 Int))(and 
(= (+ ?flted_15_24 1) ?n)
(distinct ?q nil)
(<= ?sm ?qs)
(= ?sm_26 ?sm)
(= ?lg_27 ?lg)
(tobool (ssep 
(pto ?in (sref (ref val ?sm_26) (ref next ?q) ))
(sll ?q ?flted_15_24 ?qs ?lg_27)
) )
)))))

(define-fun bnd ((?in node) (?n Int) (?sm Int) (?bg Int))
Space (tospace
(or
(and 
(= ?in nil)
(= ?n 0)

)(exists ((?sm_30 Int)(?bg_31 Int)(?flted_10_29 Int))(and 
(= (+ ?flted_10_29 1) ?n)
(<= ?sm ?d)
(< ?d ?bg)
(= ?sm_30 ?sm)
(= ?bg_31 ?bg)
(tobool (ssep 
(pto ?in (sref (ref val ?d) (ref next ?p) ))
(bnd ?p ?flted_10_29 ?sm_30 ?bg_31)
) )
)))))






































(declare-fun flted1_177 () Int)
(declare-fun q_178 () node)
(declare-fun qs_179 () Int)
(declare-fun sm2_175 () Int)
(declare-fun xs () Int)
(declare-fun lg1_176 () Int)
(declare-fun xl () Int)
(declare-fun xprm () node)
(declare-fun x () node)
(declare-fun vprm () node)
(declare-fun v () node)
(declare-fun n () Int)
(declare-fun tmpprm () node)


(assert 
(exists ((sm2 Int)(lg1 Int)(flted1 Int)(q node)(qs Int))(and 
;lexvar(= (+ flted1 1) n)
(distinct q nil)
(<= xs qs)
(= sm2 xs)
(= lg1 xl)
(= xprm x)
(= vprm v)
(< 0 n)
(= tmpprm nil)
(tobool (ssep 
(pto xprm (sref (ref val sm2) (ref next q) ))
(sll q flted1 qs lg1)
) )
))
)

(assert (not 
(and 
(tobool  
(pto xprm (sref (ref val valprm) (ref next nextprm) ))
 )
)
))

(check-sat)