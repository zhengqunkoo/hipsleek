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






































































































































































































































































































































(declare-fun cm () Int)
(declare-fun cn () Int)
(declare-fun Anon24 () Int)
(declare-fun Anon18 () Int)
(declare-fun Anon19 () Int)
(declare-fun Anon21 () Int)
(declare-fun Anon22 () Int)
(declare-fun rr () node)
(declare-fun l () node)
(declare-fun v25prm () Int)
(declare-fun b4 () Int)
(declare-fun Anon23 () Int)
(declare-fun n10 () Int)
(declare-fun bn () Int)
(declare-fun m8 () Int)
(declare-fun bm () Int)
(declare-fun b () Int)
(declare-fun Anon20 () Int)
(declare-fun n () Int)
(declare-fun an () Int)
(declare-fun m () Int)
(declare-fun am () Int)
(declare-fun left1 () node)
(declare-fun rl () node)
(declare-fun right1 () node)
(declare-fun k2prm () node)
(declare-fun r () node)
(declare-fun k1prm () node)
(declare-fun k1 () node)


(assert 
(and 
;lexvar(= v25prm (+ 1 n))
(<= n10 n)
(<= b4 2)
(<= 0 b4)
(<= 0 n10)
(<= 0 m8)
(<= Anon23 2)
(<= 0 Anon23)
(<= 0 bn)
(<= 0 bm)
(= b4 Anon23)
(= n10 bn)
(= m8 bm)
(<= b 2)
(<= 0 b)
(<= 0 n)
(<= 0 m)
(<= Anon20 2)
(<= 0 Anon20)
(<= 0 an)
(<= 0 am)
(= b Anon20)
(= n an)
(= m am)
(= left1 rl)
(= right1 r)
(= k2prm r)
(= k1prm k1)
(tobool (ssep 
(avl rr cm cn Anon24)
(pto k1prm (sref (ref ele Anon18) (ref height Anon19) (ref left l) (ref right rl) ))
(pto k2prm (sref (ref ele Anon21) (ref height Anon22) (ref left k1prm) (ref right rr) ))
(avl l m n b)
(avl rl m8 n10 b4)
) )
)
)

(assert (not 
(and 
(tobool  
(pto k1prm (sref (ref ele ele17prm) (ref height height17prm) (ref left left17prm) (ref right right17prm) ))
 )
)
))

(check-sat)