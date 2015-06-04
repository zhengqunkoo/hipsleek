(set-logic QF_S)
(set-info :source |  Sleek solver
  http://loris-7.ddns.comp.nus.edu.sg/~project/s2/beta/
|)

(set-info :smt-lib-version 2.0)
(set-info :category "crafted")
(set-info :status unsat)


(declare-sort node2 0)
(declare-fun val () (Field node2 Int))
(declare-fun left () (Field node2 node2))
(declare-fun right () (Field node2 node2))

(define-fun complete ((?in node2) (?n Int) (?nmin Int))
Space (tospace
(or
(or
(and 
(= ?in nil)
(= ?n 0)
(= ?nmin 0)

)(exists ((?flted_25_33 Int)(?flted_25_34 Int))(and 
(= (+ ?flted_25_34 1) ?n)
(= (+ ?flted_25_33 2) ?n)
(tobool (ssep 
(pto ?in (sref (ref val ?Anon_13) (ref left ?l) (ref right ?r) ))
(complete ?l ?flted_25_34 ?nmin1)
(complete ?r ?flted_25_33 ?nmin2)
) )
)))(exists ((?flted_26_35 Int)(?flted_26_36 Int))(and 
(= (+ ?flted_26_36 1) ?n)
(= (+ ?flted_26_35 1) ?n)
(tobool (ssep 
(pto ?in (sref (ref val ?Anon_14) (ref left ?l) (ref right ?r) ))
(complete ?l ?flted_26_36 ?nmin1)
(complete ?r ?flted_26_35 ?nmin2)
) )
)))))









































































































































































(declare-fun Anon_188 () Int)
(declare-fun l_189 () node2)
(declare-fun r_191 () node2)
(declare-fun t () node2)
(declare-fun tprm () node2)
(declare-fun nmin () Int)
(declare-fun nmin1_190 () Int)
(declare-fun nmin2_192 () Int)
(declare-fun flted_186 () Int)
(declare-fun flted1_187 () Int)
(declare-fun n () Int)


(assert 
(exists ((flted Int)(flted1 Int)(Anon Int)(l node2)(nmin1 Int)(r node2)(nmin2 Int))(and 
;lexvar(= tprm t)
(distinct tprm nil)
(= (+ flted 2) n)
(= (+ flted1 1) n)
(tobool (ssep 
(pto tprm (sref (ref val Anon) (ref left l) (ref right r) ))
(complete l flted1 nmin1)
(complete r flted nmin2)
) )
))
)

(assert (not 
(and 
(tobool  
(pto tprm (sref (ref val valprm) (ref left leftprm) (ref right rightprm) ))
 )
)
))

(check-sat)