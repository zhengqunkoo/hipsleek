(set-logic QF_S)
(set-info :source |  Sleek solver
  http://loris-7.ddns.comp.nus.edu.sg/~project/s2/beta/
|)

(set-info :smt-lib-version 2.0)
(set-info :category "crafted")
(set-info :status unsat)


(declare-sort node 0)
(declare-fun val () (Field node Int))
(declare-fun height () (Field node Int))
(declare-fun left () (Field node node))
(declare-fun right () (Field node node))

(define-fun avl ((?in node) (?size Int) (?height Int))
Space (tospace
(or
(and 
(= ?in nil)
(= ?size 0)
(= ?height 0)

)(exists ((?height_34 Int))(and 
(= ?size (+ (+ ?size2 1) ?size1))
(<= ?height2 (+ 1 ?height1))
(<= ?height1 (+ 1 ?height2))
(= ?height_34 ?height)
(tobool (ssep 
(pto ?in (sref (ref val ?Anon_14) (ref height ?height_34) (ref left ?p) (ref right ?q) ))
(avl ?p ?size1 ?height1)
(avl ?q ?size2 ?height2)
) )
)))))























































































































































































































































































































































































































































(declare-fun v5 () node)
(declare-fun p11 () node)
(declare-fun Anon15 () Int)
(declare-fun m () Int)
(declare-fun height33 () Int)
(declare-fun n () Int)
(declare-fun tmp1prm () node)
(declare-fun aprm () Int)
(declare-fun a () Int)
(declare-fun xprm () node)
(declare-fun x () node)
(declare-fun tmpprm () node)
(declare-fun size23 () Int)
(declare-fun height32 () Int)
(declare-fun m19 () Int)
(declare-fun n19 () Int)
(declare-fun right1 () node)
(declare-fun q11 () node)
(declare-fun flted21 () Int)
(declare-fun Anon23 () Int)
(declare-fun m20 () Int)
(declare-fun size24 () Int)
(declare-fun height31 () Int)
(declare-fun m21 () Int)
(declare-fun n21 () Int)
(declare-fun n20 () Int)
(declare-fun v87prm () Int)
(declare-fun v88prm () Int)


(assert 
(and 
;lexvar(< Anon15 aprm)
(= m (+ (+ size23 1) size24))
(<= height32 (+ 1 height31))
(<= height31 (+ 1 height32))
(= height33 n)
(distinct xprm nil)
(= tmp1prm nil)
(= aprm a)
(= xprm x)
(= tmpprm q11)
(= m19 size23)
(= n19 height32)
(<= 0 size23)
(<= 0 height32)
(= flted21 (+ 1 m19))
(<= 0 m19)
(<= 0 n19)
(= right1 q11)
(= m20 flted21)
(= n20 Anon23)
(<= 0 flted21)
(<= 0 Anon23)
(<= 0 m20)
(<= 0 n20)
(= m21 size24)
(= n21 height31)
(<= 0 size24)
(<= 0 height31)
(<= 0 m21)
(<= 0 n21)
(= (+ v87prm n21) n20)
(= v88prm 2)
(distinct v87prm v88prm)
(tobool (ssep 
(avl v5 m20 n20)
(pto xprm (sref (ref val Anon15) (ref height height33) (ref left p11) (ref right v5) ))
(avl p11 m21 n21)
) )
)
)

(assert (not 
;lexvar
))

(check-sat)