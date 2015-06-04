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






































































































































































































































































































































(declare-fun Anon101 () Int)
(declare-fun q7 () node)
(declare-fun Anon103 () Int)
(declare-fun q5 () node)
(declare-fun p7 () node)
(declare-fun v50prm () node)
(declare-fun v12 () node)
(declare-fun v49prm () Int)
(declare-fun b9 () Int)
(declare-fun Anon102 () Int)
(declare-fun n29 () Int)
(declare-fun m23 () Int)
(declare-fun b8 () Int)
(declare-fun Anon96 () Int)
(declare-fun n22 () Int)
(declare-fun m18 () Int)
(declare-fun left3 () node)
(declare-fun resn9 () Int)
(declare-fun resb1 () Int)
(declare-fun p5 () node)
(declare-fun flted8 () Int)
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
(declare-fun n26 () Int)
(declare-fun b7 () Int)
(declare-fun n () Int)
(declare-fun n27 () Int)
(declare-fun n28 () Int)
(declare-fun m () Int)
(declare-fun m22 () Int)
(declare-fun m21 () Int)


(assert 
(and 
;lexvar(= v50prm v12)
(<= b9 2)
(<= 0 b9)
(<= 0 n29)
(<= 0 m23)
(= v49prm n29)
(<= Anon102 2)
(<= 0 Anon102)
(<= 0 n27)
(<= 0 m22)
(= b9 Anon102)
(= n29 n27)
(= m23 m22)
(= (+ 2 n22) n)
(<= b8 2)
(<= 0 b8)
(<= 0 n22)
(<= 0 m18)
(<= Anon96 2)
(<= 0 Anon96)
(<= 0 n19)
(<= 0 m16)
(= b8 Anon96)
(= n22 n19)
(= m18 m16)
(<= b7 2)
(<= 0 b7)
(<= 0 n)
(<= 0 m)
(<= resb1 2)
(<= 0 resb1)
(<= 0 resn9)
(<= 0 flted8)
(= b7 resb1)
(= n resn9)
(= m flted8)
(= left3 p5)
(<= b6 2)
(<= 0 b6)
(<= 0 tn1)
(<= 0 tm1)
(< 0 tn1)
(< 0 tm1)
(distinct p5 nil)
(= flted8 (+ 1 tm1))
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
(= n26 n)
(= (+ b7 n28) (+ 1 n27))
(<= n27 (+ 1 n28))
(<= (+ 0 n28) (+ n27 1))
(= m (+ (+ m21 1) m22))
(tobool (ssep 
(pto tprm (sref (ref ele Anon97) (ref height n21) (ref left v12) (ref right q5) ))
(pto v12 (sref (ref ele Anon101) (ref height n26) (ref left p7) (ref right q7) ))
(avl q7 m21 n28 Anon103)
(avl q5 m18 n22 b8)
(avl p7 m23 n29 b9)
) )
)
)

(assert (not 
(and 
(tobool  
(pto v50prm (sref (ref ele ele33prm) (ref height height33prm) (ref left left33prm) (ref right right33prm) ))
 )
)
))

(check-sat)