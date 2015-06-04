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

























































































(declare-fun x1prm () node)
(declare-fun lres6 () Int)
(declare-fun sres6 () Int)
(declare-fun flted16 () Int)
(declare-fun xl () Int)
(declare-fun b1 () NUM)
(declare-fun xs () Int)
(declare-fun s1 () NUM)
(declare-fun n () Int)
(declare-fun n1 () Int)
(declare-fun x1 () node)
(declare-fun x2 () node)
(declare-fun x2prm () node)
(declare-fun lg4 () Int)
(declare-fun b2 () Int)
(declare-fun sm12 () Int)
(declare-fun s2 () Int)
(declare-fun qs3 () Int)
(declare-fun flted12 () Int)
(declare-fun n2 () Int)
(declare-fun q3 () node)


(assert 
(and 
;lexvar(distinct x2 nil)
(<= xs xl)
(<= 1 n)
;eqmax;eqmin(= flted16 (+ 1 n))
(distinct x1 nil)
(<= s1 b1)
(<= 1 n1)
(= xl b1)
(= xs s1)
(= n n1)
(= x2 x1)
(= x2prm x2)
(distinct x2prm nil)
(= lg4 b2)
(= sm12 s2)
(<= s2 qs3)
(= (+ flted12 1) n2)
(distinct q3 nil)
(tobool (ssep 
(sll x1prm flted16 sres6 lres6)
(pto x2prm (sref (ref val sm12) (ref next q3) ))
(sll q3 flted12 qs3 lg4)
) )
)
)

(assert (not 
(and 
(tobool  
(pto x2prm (sref (ref val val8prm) (ref next next8prm) ))
 )
)
))

(check-sat)