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






































































































































































































































































































































(declare-fun Anon132 () Int)
(declare-fun resl10 () node)
(declare-fun tprm () node)
(declare-fun height12 () Int)
(declare-fun v76_37920 () Int)
(declare-fun resr10 () node)
(declare-fun b18 () Int)
(declare-fun Anon133 () Int)
(declare-fun n46 () Int)
(declare-fun m36 () Int)
(declare-fun resn14 () Int)
(declare-fun tmp20 () Int)
(declare-fun tmp21 () Int)
(declare-fun Anon12 () Int)
(declare-fun Anon11 () Int)
(declare-fun an () Int)
(declare-fun am () Int)
(declare-fun lr () node)
(declare-fun q7 () node)
(declare-fun ll () node)
(declare-fun p7 () node)
(declare-fun Anon10 () Int)
(declare-fun Anon9 () node)
(declare-fun Anon101 () node)
(declare-fun Anon8 () Int)
(declare-fun r () node)
(declare-fun q5 () node)
(declare-fun l () node)
(declare-fun v12 () node)
(declare-fun Anon7 () Int)
(declare-fun Anon6 () NUM)
(declare-fun b10 () Int)
(declare-fun Anon103 () Int)
(declare-fun m24 () Int)
(declare-fun b9 () Int)
(declare-fun Anon102 () Int)
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
(declare-fun t7 () node)
(declare-fun x () NUM)
(declare-fun n21 () Int)
(declare-fun n20 () Int)
(declare-fun n19 () Int)
(declare-fun m17 () Int)
(declare-fun m16 () Int)
(declare-fun xprm () NUM)
(declare-fun Anon97 () NUM)
(declare-fun n26 () Int)
(declare-fun b7 () Int)
(declare-fun n () Int)
(declare-fun n27 () Int)
(declare-fun n28 () Int)
(declare-fun m () Int)
(declare-fun m22 () Int)
(declare-fun m21 () Int)
(declare-fun n30 () Int)
(declare-fun n29 () Int)
(declare-fun Anon151 () node)
(declare-fun Anon134 () node)
(declare-fun p13 () node)
(declare-fun resrl5 () node)
(declare-fun q13 () node)
(declare-fun resrr5 () node)
(declare-fun bm () Int)
(declare-fun bn () Int)
(declare-fun Anon152 () Int)
(declare-fun Anon135 () Int)
(declare-fun cm () Int)
(declare-fun cn () Int)
(declare-fun Anon153 () Int)
(declare-fun Anon136 () Int)
(declare-fun resrn5 () Int)
(declare-fun b19 () Int)
(declare-fun n49 () Int)
(declare-fun n50 () Int)
(declare-fun n51 () Int)
(declare-fun m39 () Int)
(declare-fun m41 () Int)
(declare-fun m40 () Int)
(declare-fun res () node)
(declare-fun t6 () node)
(declare-fun b () Int)
(declare-fun tn () Int)
(declare-fun tm () Int)


(assert 
(exists ((v76prm Int))(and 
;lexvar(= res tprm)
(= height12 resn14)
(= v76prm (+ 1 n46))
(<= n49 n46)
(<= b19 2)
(<= 0 b19)
(<= 0 n49)
(<= 0 m39)
(distinct resr10 nil)
(<= Anon135 2)
(<= 0 Anon135)
(<= 0 bn)
(<= 0 bm)
(<= Anon136 2)
(<= 0 Anon136)
(<= 0 cn)
(<= 0 cm)
(<= b18 2)
(<= 0 b18)
(<= 0 n46)
(<= 0 m36)
(<= Anon133 2)
(<= 0 Anon133)
(<= 0 an)
(<= 0 am)
(= b18 Anon133)
(= n46 an)
(= m36 am)
(<= Anon12 2)
(<= 0 Anon12)
(<= Anon11 2)
(<= 0 Anon11)
(<= Anon8 2)
(<= 0 Anon8)
;eqmax(= resn14 (+ 1 tmp20))
;eqmax(= resrn5 (+ 1 tmp21))
(distinct t7 nil)
(<= b8 2)
(<= 0 b8)
(<= 0 n22)
(<= 0 m18)
(distinct v12 nil)
(<= b9 2)
(<= 0 b9)
(<= 0 n29)
(<= 0 m23)
(<= b10 2)
(<= 0 b10)
(<= 0 n30)
(<= 0 m24)
(= Anon12 b10)
(= bn n30)
(= bm m24)
(= Anon11 b9)
(= an n29)
(= am m23)
(= lr q7)
(= ll p7)
(= Anon10 n26)
(= Anon9 Anon101)
(= Anon8 b8)
(= cn n22)
(= cm m18)
(= r q5)
(= l v12)
(= Anon7 n21)
(= Anon6 Anon97)
(<= Anon103 2)
(<= 0 Anon103)
(<= 0 n28)
(<= 0 m21)
(= b10 Anon103)
(= n30 n28)
(= m24 m21)
(<= Anon102 2)
(<= 0 Anon102)
(<= 0 n27)
(<= 0 m22)
(= b9 Anon102)
(= n29 n27)
(= m23 m22)
(= (+ 2 n22) n)
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
(= t7 t6)
(= xprm x)
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
(< n30 n29)
(= Anon151 Anon134)
(= p13 resrl5)
(= q13 resrr5)
(= m41 bm)
(= n50 bn)
(= Anon152 Anon135)
(= m40 cm)
(= n51 cn)
(= Anon153 Anon136)
(<= n50 (+ 1 n51))
(<= (+ 0 n51) (+ n50 1))
(= resrn5 n49)
(= (+ b19 n51) (+ 1 n50))
(= m39 (+ (+ m40 1) m41))
(tobool (ssep 
(avl resl10 m36 n46 b18)
(avl resr10 m39 n49 b19)
(pto tprm (sref (ref ele Anon132) (ref height v76prm) (ref left resl10) (ref right resr10) ))
) )
))
)

(assert (not 
(exists ((flted28 Int)(resn16 Int)(resb4 Int))(and 
(< 0 tn)
(< 0 tm)
(distinct t6 nil)
(= flted28 (+ 1 tm))
(<= b 2)
(<= 0 b)
(<= 0 tn)
(<= 0 tm)
(tobool  
(avl res flted28 resn16 resb4)
 )
))
))

(check-sat)