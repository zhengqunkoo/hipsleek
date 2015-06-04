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

























































































(declare-fun xsprm () node)
(declare-fun bg16 () Int)
(declare-fun sm24 () Int)
(declare-fun n12 () Int)
(declare-fun n14 () Int)
(declare-fun bg15 () Int)
(declare-fun sm23 () Int)
(declare-fun n11 () Int)
(declare-fun middleprm () Int)
(declare-fun cprm () Int)
(declare-fun xs () node)
(declare-fun sm () NUM)
(declare-fun bg () NUM)
(declare-fun n () Int)
(declare-fun d7 () NUM)
(declare-fun p8 () node)
(declare-fun p7 () node)
(declare-fun bg13 () NUM)
(declare-fun sm21 () NUM)
(declare-fun bg14 () Int)
(declare-fun sm22 () Int)
(declare-fun d8 () Int)
(declare-fun flted26 () Int)
(declare-fun n10 () Int)


(assert 
(and 
;lexvar(= bg16 bg15)
(= sm24 sm23)
(= n12 n14)
(<= 0 n11)
(< 0 n14)
(< 0 middleprm)
(= n11 (+ n14 middleprm))
(<= 0 n10)
(= bg15 bg14)
(= sm23 sm22)
(= n11 n10)
(= (+ middleprm middleprm) cprm)
(= cprm n10)
(distinct xs nil)
(<= 0 flted26)
(= (+ flted26 1) n)
(<= sm d7)
(<= d7 bg)
(= sm21 sm)
(= bg13 bg)
(< 0 n)
(distinct p7 nil)
(= d8 d7)
(= p8 p7)
(<= d8 bg13)
(<= sm21 d8)
(= bg13 bg14)
(= sm21 sm22)
(<= d8 bg14)
(<= sm22 d8)
(= (+ flted26 1) n10)
(tobool  
(bnd xsprm middleprm sm23 bg15)
 )
)
)

(assert (not 
;lexvar
))

(check-sat)