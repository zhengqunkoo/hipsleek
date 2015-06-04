(set-logic QF_S)
(set-info :source |  Sleek solver
  http://loris-7.ddns.comp.nus.edu.sg/~project/s2/beta/
|)

(set-info :smt-lib-version 2.0)
(set-info :category "crafted")
(set-info :status unsat)


(declare-sort node 0)
(declare-fun ele () (Field node Int))
(declare-fun height () (Field node Int))
(declare-fun left () (Field node node))
(declare-fun right () (Field node node))

(define-fun avl ((?in node) (?m Int) (?n Int) (?bal Int))
Space (tospace
(or
(and 
(= ?in nil)
(= ?m 0)
(= ?n 0)
(= ?bal 1)

)(exists ((?n_80 Int))(and 
(= ?m (+ (+ ?m2 1) ?m1))
(<= (+ 0 ?n2) (+ ?n1 1))
(<= ?n1 (+ 1 ?n2))
(= (+ ?bal ?n2) (+ 1 ?n1))
(= ?n_80 ?n)
(tobool (ssep 
(pto ?in (sref (ref ele ?Anon_14) (ref height ?n_80) (ref left ?p) (ref right ?q) ))
(avl ?p ?m1 ?n1 ?Anon_15)
(avl ?q ?m2 ?n2 ?Anon_16)
) )
)))))






































































































































































































































































































































(declare-fun v13 () node)
(declare-fun b8 () node)
(declare-fun Anon96 () node)
(declare-fun n22 () Int)
(declare-fun m18 () Int)
(declare-fun v42prm () node)
(declare-fun q5 () node)
(declare-fun v41prm () Int)
(declare-fun b7 () Int)
(declare-fun n () Int)
(declare-fun m () Int)
(declare-fun left4 () node)
(declare-fun p5 () node)
(declare-fun flted9 () Int)
(declare-fun flted10 () Int)
(declare-fun flted11 () Int)
(declare-fun b6 () Int)
(declare-fun Anon95 () Int)
(declare-fun tn1 () Int)
(declare-fun tm1 () Int)
(declare-fun t6 () node)
(declare-fun x () Int)
(declare-fun tmpprm () node)
(declare-fun tprm () node)
(declare-fun n21 () Int)
(declare-fun b () Int)
(declare-fun tn () Int)
(declare-fun n20 () Int)
(declare-fun n19 () Int)
(declare-fun tm () Int)
(declare-fun m17 () Int)
(declare-fun m16 () Int)
(declare-fun xprm () Int)
(declare-fun Anon97 () Int)


(assert 
(and 
;lexvar(= b8 Anon96)
(= n22 n19)
(= m18 m16)
(= v42prm q5)
(<= b7 2)
(<= 0 b7)
(<= 0 n)
(<= 0 m)
(= v41prm n)
(<= flted9 2)
(<= 0 flted9)
(<= 0 flted10)
(<= 0 flted11)
(= b7 flted9)
(= n flted10)
(= m flted11)
(= left4 p5)
(<= b6 2)
(<= 0 b6)
(<= 0 tn1)
(<= 0 tm1)
(= p5 nil)
(= tm1 0)
(= tn1 0)
(= flted9 1)
(= flted10 1)
(= flted11 1)
(<= Anon95 2)
(<= 0 Anon95)
(<= 0 n20)
(<= 0 m17)
(= b6 Anon95)
(= tn1 n20)
(= tm1 m17)
(= tprm t6)
(= xprm x)
(= tmpprm nil)
(distinct tprm nil)
(= n21 tn)
(= (+ b n19) (+ 1 n20))
(<= n20 (+ 1 n19))
(<= (+ 0 n19) (+ n20 1))
(= tm (+ (+ m16 1) m17))
(< xprm Anon97)
(tobool (ssep 
(avl v13 m n b7)
(pto tprm (sref (ref ele Anon97) (ref height n21) (ref left v13) (ref right q5) ))
) )
)
)

(assert (not 
;lexvar
))

(check-sat)