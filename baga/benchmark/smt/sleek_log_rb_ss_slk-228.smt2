(set-logic QF_S)
(set-info :source |  Sleek solver
  http://loris-7.ddns.comp.nus.edu.sg/~project/s2/beta/
|)

(set-info :smt-lib-version 2.0)
(set-info :category "crafted")
(set-info :status unsat)


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





































































































































































































































































































































































(declare-fun l38 () node)
(declare-fun r38 () node)
(declare-fun x () node)
(declare-fun a () Int)
(declare-fun xprm () node)
(declare-fun bhr38 () Int)
(declare-fun bhl38 () Int)
(declare-fun bh () Int)
(declare-fun n () Int)
(declare-fun nl38 () Int)
(declare-fun nr38 () Int)
(declare-fun cl () Int)
(declare-fun flted292 () Int)
(declare-fun flted291 () Int)
(declare-fun flted290 () Int)
(declare-fun v58 () Int)
(declare-fun aprm () Int)


(assert 
(and 
;lexvar(= xprm x)
(= aprm a)
(<= 0 cl)
(<= cl 1)
(distinct xprm nil)
(= bhr38 bh)
(= bhl38 bh)
(= n (+ (+ nr38 1) nl38))
(= cl 1)
(= flted292 0)
(= flted291 0)
(= flted290 1)
(distinct v58 aprm)
(tobool (ssep 
(rb l38 nl38 flted291 bhl38)
(pto xprm (sref (ref val v58) (ref color flted290) (ref left l38) (ref right r38) ))
(rb r38 nr38 flted292 bhr38)
) )
)
)

(assert (not 
(and 
(tobool  
(pto xprm (sref (ref val val42prm) (ref color color43prm) (ref left left42prm) (ref right right42prm) ))
 )
)
))

(check-sat)