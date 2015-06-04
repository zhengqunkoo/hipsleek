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

























































































(declare-fun flted26 () Int)
(declare-fun d7 () Int)
(declare-fun sm21 () Int)
(declare-fun bg13 () Int)
(declare-fun xsprm () node)
(declare-fun xs () node)
(declare-fun p7 () node)
(declare-fun res () node)
(declare-fun bg () Int)
(declare-fun sm () Int)
(declare-fun n () Int)


(assert 
(and 
;lexvar(= res xsprm)
(= (+ flted26 1) n)
(<= sm d7)
(<= d7 bg)
(= sm21 sm)
(= bg13 bg)
(= xsprm xs)
(< 0 n)
(= p7 nil)
(tobool (ssep 
(pto xsprm (sref (ref val d7) (ref next p7) ))
(bnd p7 flted26 sm21 bg13)
) )
)
)

(assert (not 
(exists ((n16 Int)(smres4 Int)(bgres4 Int))(and 
(= n16 n)
(<= bgres4 bg)
(<= sm smres4)
(<= 0 n)
(tobool  
(sll res n16 smres4 bgres4)
 )
))
))

(check-sat)