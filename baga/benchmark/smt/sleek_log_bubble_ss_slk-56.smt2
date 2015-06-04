(set-logic QF_S)
(set-info :source |  Sleek solver
  http://loris-7.ddns.comp.nus.edu.sg/~project/s2/beta/
|)

(set-info :smt-lib-version 2.0)
(set-info :category "crafted")
(set-info :status sat)


(declare-sort node 0)
(declare-fun val () (Field node Int))
(declare-fun next () (Field node node))

(define-fun sll ((?in node) (?n Int) (?sm Int) (?lg Int))
Space (tospace
(or
(exists ((?sm_35 Int)(?flted_9_33 node))(and 
(= ?flted_9_33 nil)
(= ?sm ?lg)
(= ?n 1)
(= ?sm_35 ?sm)
(tobool  
(pto ?in (sref (ref val ?sm_35) (ref next ?flted_9_33) ))
 )
))(exists ((?sm_36 Int)(?lg_37 Int)(?flted_10_34 Int))(and 
(= (+ ?flted_10_34 1) ?n)
(distinct ?q nil)
(<= ?sm ?qs)
(= ?sm_36 ?sm)
(= ?lg_37 ?lg)
(tobool (ssep 
(pto ?in (sref (ref val ?sm_36) (ref next ?q) ))
(sll ?q ?flted_10_34 ?qs ?lg_37)
) )
)))))

(define-fun ll ((?in node) (?n Int))
Space (tospace
(or
(and 
(= ?in nil)
(= ?n 0)

)(exists ((?flted_19_26 Int))(and 
(= (+ ?flted_19_26 1) ?n)
(tobool (ssep 
(pto ?in (sref (ref val ?Anon_12) (ref next ?r) ))
(ll ?r ?flted_19_26)
) )
)))))

(define-fun bnd ((?in node) (?n Int) (?sm Int) (?bg Int))
Space (tospace
(or
(and 
(= ?in nil)
(= ?n 0)

)(exists ((?sm_29 Int)(?bg_30 Int)(?flted_15_28 Int))(and 
(= (+ ?flted_15_28 1) ?n)
(<= ?sm ?d)
(< ?d ?bg)
(= ?sm_29 ?sm)
(= ?bg_30 ?bg)
(tobool (ssep 
(pto ?in (sref (ref val ?d) (ref next ?p) ))
(bnd ?p ?flted_15_28 ?sm_29 ?bg_30)
) )
)))))
























































































(declare-fun flted6 () Int)
(declare-fun q1 () node)
(declare-fun qs1 () Int)
(declare-fun s1 () Int)
(declare-fun lg2 () Int)
(declare-fun l1 () Int)
(declare-fun r1 () node)
(declare-fun xsprm () node)
(declare-fun flted1 () Int)
(declare-fun n1 () Int)
(declare-fun val1 () Int)
(declare-fun Anon1 () Int)
(declare-fun val4 () Int)
(declare-fun sm4 () Int)
(declare-fun xs () node)
(declare-fun n () Int)


(assert 
(exists ((flagprm boolean)(tmpprm boolean))(and 
;lexvar(< sm4 Anon1)
(= (+ flted6 1) n1)
(distinct q1 nil)
(<= s1 qs1)
(= sm4 s1)
(= lg2 l1)
(distinct r1 nil)
(< 0 n)
(= xsprm xs)
(= (+ flted1 1) n)
(= n1 flted1)
(<= 0 flted1)
(<= 0 n1)
(= val1 Anon1)
(= val4 sm4)
(= res v7prm)
(tobool (ssep 
(sll q1 flted6 qs1 lg2)
(pto xsprm (sref (ref val sm4) (ref next r1) ))
(pto r1 (sref (ref val Anon1) (ref next q1) ))
) )
))
)

(assert (not 
(exists ((n2 Int)(s2 Int)(l2 Int))(and 
(= n2 n)
(<= 0 n)
(tobool  
(sll xs n2 s2 l2)
 )
))
))

(check-sat)