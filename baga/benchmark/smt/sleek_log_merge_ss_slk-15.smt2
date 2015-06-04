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
(exists ((?sm_28 Int)(?flted_21_26 node))(and 
(= ?flted_21_26 nil)
(= ?sm ?lg)
(= ?n 1)
(= ?sm_28 ?sm)
(tobool  
(pto ?in (sref (ref val ?sm_28) (ref next ?flted_21_26) ))
 )
))(exists ((?sm_29 Int)(?lg_30 Int)(?flted_22_27 Int))(and 
(= (+ ?flted_22_27 1) ?n)
(<= ?sm ?qs)
(= ?sm_29 ?sm)
(= ?lg_30 ?lg)
(tobool (ssep 
(pto ?in (sref (ref val ?sm_29) (ref next ?q) ))
(sll ?q ?flted_22_27 ?qs ?lg_30)
) )
)))))

(define-fun bnd ((?in node) (?n Int) (?sm Int) (?bg Int))
Space (tospace
(or
(and 
(= ?in nil)
(= ?n 0)

)(exists ((?sm_33 Int)(?bg_34 Int)(?flted_9_32 Int))(and 
(= (+ ?flted_9_32 1) ?n)
(<= ?sm ?d)
(<= ?d ?bg)
(= ?sm_33 ?sm)
(= ?bg_34 ?bg)
(tobool (ssep 
(pto ?in (sref (ref val ?d) (ref next ?p) ))
(bnd ?p ?flted_9_32 ?sm_33 ?bg_34)
) )
)))))

























































































(declare-fun p1 () node)
(declare-fun d1 () Int)
(declare-fun xprm () node)
(declare-fun sm3 () Int)
(declare-fun sm2 () Int)
(declare-fun bg3 () Int)
(declare-fun bg2 () Int)
(declare-fun flted1 () Int)
(declare-fun n1 () Int)
(declare-fun v5prm () Int)
(declare-fun x () node)
(declare-fun bg () Int)
(declare-fun sm () Int)
(declare-fun res () Int)
(declare-fun n () Int)


(assert 
(and 
;lexvar(= (+ flted1 1) n)
(<= sm d1)
(<= d1 bg)
(= sm2 sm)
(= bg2 bg)
(distinct xprm nil)
(= xprm x)
(= n1 flted1)
(= sm3 sm2)
(= bg3 bg2)
(<= 0 flted1)
(<= 0 n1)
(= v5prm (+ n1 1))
(= res v5prm)
(tobool (ssep 
(bnd p1 n1 sm3 bg3)
(pto xprm (sref (ref val d1) (ref next p1) ))
) )
)
)

(assert (not 
(exists ((n2 Int)(sm4 Int)(bg4 Int))(and 
(= bg4 bg)
(= sm4 sm)
(= n2 n)
(= res n)
(<= 0 n)
(tobool  
(bnd x n2 sm4 bg4)
 )
))
))

(check-sat)