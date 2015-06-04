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























































































































































































































































































































































































































































(declare-fun p11 () node)
(declare-fun v82prm () node)
(declare-fun Anon22_12954 () Int)
(declare-fun flted20_12953 () Int)
(declare-fun n19 () Int)
(declare-fun m19 () Int)
(declare-fun tmpprm () node)
(declare-fun q11 () node)
(declare-fun x () node)
(declare-fun a () Int)
(declare-fun tmp1prm () node)
(declare-fun xprm () node)
(declare-fun height33 () Int)
(declare-fun n () Int)
(declare-fun height32 () Int)
(declare-fun height31 () Int)
(declare-fun m () Int)
(declare-fun size24 () Int)
(declare-fun size23 () Int)
(declare-fun Anon15 () Int)
(declare-fun aprm () Int)


(assert 
(exists ((flted20 Int)(Anon22 Int))(and 
;lexvar(<= 0 n19)
(<= 0 m19)
(= flted20 (+ 1 m19))
(<= 0 height32)
(<= 0 size23)
(= n19 height32)
(= m19 size23)
(= tmpprm q11)
(= xprm x)
(= aprm a)
(= tmp1prm nil)
(distinct xprm nil)
(= height33 n)
(<= height31 (+ 1 height32))
(<= height32 (+ 1 height31))
(= m (+ (+ size23 1) size24))
(< Anon15 aprm)
(tobool (ssep 
(avl p11 size24 height31)
(pto xprm (sref (ref val Anon15) (ref height height33) (ref left p11) (ref right q11) ))
(avl v82prm flted20 Anon22)
) )
))
)

(assert (not 
(and 
(tobool  
(pto xprm (sref (ref val val34prm) (ref height height34prm) (ref left left34prm) (ref right right34prm) ))
 )
)
))

(check-sat)