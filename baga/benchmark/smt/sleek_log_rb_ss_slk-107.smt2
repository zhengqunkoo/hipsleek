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





































































































































































































































































































































































(declare-fun na () Int)
(declare-fun v35 () Int)
(declare-fun nc10 () node)
(declare-fun nc () node)
(declare-fun Anon11 () node)
(declare-fun Anon15 () node)
(declare-fun nb10 () Int)
(declare-fun ha () Int)
(declare-fun na10 () Int)
(declare-fun v80prm () Int)
(declare-fun v79prm () node)
(declare-fun r23 () node)
(declare-fun v78prm () node)
(declare-fun l23 () node)
(declare-fun flted217 () Int)
(declare-fun flted215 () Int)
(declare-fun h () Int)
(declare-fun flted214 () Int)
(declare-fun cprm () node)
(declare-fun c () node)
(declare-fun bprm () node)
(declare-fun b () node)
(declare-fun aprm () node)
(declare-fun a () node)
(declare-fun flted216 () Int)
(declare-fun bhr23 () Int)
(declare-fun nb () Int)
(declare-fun nr23 () Int)
(declare-fun flted213 () Int)
(declare-fun flted212 () Int)
(declare-fun nl23 () Int)
(declare-fun bhl23 () Int)
(declare-fun Anon14 () Int)
(declare-fun n () Int)
(declare-fun bh () Int)
(declare-fun cl () Int)


(assert 
(and 
;lexvar(= nc10 nc)
(= Anon11 Anon15)
(= nb10 nr23)
(= ha bh)
(= na10 n)
(= v80prm 1)
(= v79prm r23)
(= v78prm l23)
(distinct b nil)
(= flted217 0)
(= flted216 (+ 1 h))
(= flted215 (+ 1 h))
(= flted214 0)
(= cprm c)
(= bprm b)
(= aprm a)
(= flted216 (+ bhl23 1))
(= bhl23 bhr23)
(= nb (+ (+ nr23 1) nl23))
(= flted213 0)
(= flted212 0)
(= n nl23)
(= cl Anon14)
(= bh bhl23)
(<= 0 nl23)
(<= 1 bhl23)
(<= 0 Anon14)
(<= Anon14 1)
(= cl 1)
(<= 0 n)
(<= 1 bh)
(<= 0 cl)
(<= cl 1)
(tobool (ssep 
(rb a na flted214 flted215)
(pto bprm (sref (ref val v35) (ref color flted212) (ref left l23) (ref right r23) ))
) )
)
)

(assert (not 
;lexvar
))

(check-sat)