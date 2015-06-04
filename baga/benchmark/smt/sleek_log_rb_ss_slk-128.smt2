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





































































































































































































































































































































































(declare-fun v40 () Int)
(declare-fun l28 () node)
(declare-fun r28 () node)
(declare-fun flted255 () Int)
(declare-fun flted256 () Int)
(declare-fun cl () Int)
(declare-fun n () Int)
(declare-fun nl28 () Int)
(declare-fun nr28 () Int)
(declare-fun bhl28 () Int)
(declare-fun bhr28 () Int)
(declare-fun bh () Int)
(declare-fun xprm () node)
(declare-fun x () node)
(declare-fun flted257 () Int)
(declare-fun v94prm () Int)
(declare-fun v95prm () Int)


(assert 
(and 
;lexvar(= flted257 1)
(= flted255 0)
(= flted256 0)
(= cl 1)
(= n (+ (+ nr28 1) nl28))
(= bhl28 bh)
(= bhr28 bh)
(distinct xprm nil)
(= xprm x)
(= v94prm flted257)
(= v95prm 0)
(distinct v94prm v95prm)
(tobool (ssep 
(pto xprm (sref (ref val v40) (ref color flted257) (ref left l28) (ref right r28) ))
(rb l28 nl28 flted255 bhl28)
(rb r28 nr28 flted256 bhr28)
) )
)
)

(assert (not 
;lexvar
))

(check-sat)