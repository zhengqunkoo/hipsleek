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





































































































































































































































































































































































(declare-fun v19 () Int)
(declare-fun l11 () node)
(declare-fun Anon4 () Int)
(declare-fun r11 () node)
(declare-fun Anon5 () Int)
(declare-fun cl () Int)
(declare-fun n () Int)
(declare-fun nl11 () Int)
(declare-fun nr11 () Int)
(declare-fun bhr11 () Int)
(declare-fun bh () Int)
(declare-fun bhl11 () Int)
(declare-fun xprm () node)
(declare-fun x () node)
(declare-fun flted111 () Int)
(declare-fun v29prm () Int)
(declare-fun v30prm () Int)


(assert 
(and 
;lexvar(= flted111 0)
(= cl 0)
(= n (+ (+ nr11 1) nl11))
(= bhl11 bhr11)
(= bh (+ bhl11 1))
(distinct xprm nil)
(= xprm x)
(= v29prm flted111)
(= v30prm 0)
(= v29prm v30prm)
(tobool (ssep 
(pto xprm (sref (ref val v19) (ref color flted111) (ref left l11) (ref right r11) ))
(rb l11 nl11 Anon4 bhl11)
(rb r11 nr11 Anon5 bhr11)
) )
)
)

(assert (not 
;lexvar
))

(check-sat)