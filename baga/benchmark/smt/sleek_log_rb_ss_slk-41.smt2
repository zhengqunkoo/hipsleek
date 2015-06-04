(set-logic QF_S)
(set-info :source |  Sleek solver
  http://loris-7.ddns.comp.nus.edu.sg/~project/s2/beta/
|)

(set-info :smt-lib-version 2.0)
(set-info :category "crafted")
(set-info :status sat)


(declare-sort node 0)
(declare-fun val () (Field node Int))
(declare-fun color () (Field node Int))
(declare-fun left () (Field node node))
(declare-fun right () (Field node node))

(define-fun rb ((?in node) (?n Int) (?cl Int) (?bh Int))
Space (tospace
(or
(or
(and 
(= ?in nil)
(= ?n 0)
(= ?bh 1)
(= ?cl 0)

)(exists ((?flted_12_38 Int)(?flted_12_39 Int)(?flted_12_40 Int))(and 
(= ?flted_12_40 1)
(= ?flted_12_39 0)
(= ?flted_12_38 0)
(= ?cl 1)
(= ?n (+ (+ ?nr 1) ?nl))
(= ?bhl ?bh)
(= ?bhr ?bh)
(tobool (ssep 
(pto ?in (sref (ref val ?v) (ref color ?flted_12_40) (ref left ?l) (ref right ?r) ))
(rb ?l ?nl ?flted_12_39 ?bhl)
(rb ?r ?nr ?flted_12_38 ?bhr)
) )
)))(exists ((?flted_13_41 Int))(and 
(= ?flted_13_41 0)
(= ?cl 0)
(= ?n (+ (+ ?nr 1) ?nl))
(= ?bhl ?bhr)
(= ?bh (+ ?bhl 1))
(tobool (ssep 
(pto ?in (sref (ref val ?v) (ref color ?flted_13_41) (ref left ?l) (ref right ?r) ))
(rb ?l ?nl ?Anon_14 ?bhl)
(rb ?r ?nr ?Anon_15 ?bhr)
) )
)))))





































































































































































































































































































































































(declare-fun v18 () Int)
(declare-fun l10 () node)
(declare-fun r10 () node)
(declare-fun xprm () node)
(declare-fun bhr10 () Int)
(declare-fun bhl10 () Int)
(declare-fun nl10 () Int)
(declare-fun nr10 () Int)
(declare-fun flted109 () Int)
(declare-fun flted108 () Int)
(declare-fun flted110 () Int)
(declare-fun x () node)
(declare-fun cl () Int)
(declare-fun bh () Int)
(declare-fun n () Int)


(assert 
(and 
;lexvar(= res v34prm)
(= xprm x)
(distinct xprm nil)
(= bhr10 bh)
(= bhl10 bh)
(= n (+ (+ nr10 1) nl10))
(= cl 1)
(= flted109 0)
(= flted108 0)
(= flted110 1)
(distinct flted110 0)
(tobool (ssep 
(pto xprm (sref (ref val v18) (ref color flted110) (ref left l10) (ref right r10) ))
(rb l10 nl10 flted108 bhl10)
(rb r10 nr10 flted109 bhr10)
) )
)
)

(assert (not 
(exists ((n2 Int)(cl2 Int)(bh2 Int))(and 
(= bh2 bh)
(= cl2 cl)
(= n2 n)
(= cl 0)
(<= cl 1)
(<= 0 cl)
(<= 1 bh)
(<= 0 n)
(tobool  
(rb x n2 cl2 bh2)
 )
))
))

(check-sat)