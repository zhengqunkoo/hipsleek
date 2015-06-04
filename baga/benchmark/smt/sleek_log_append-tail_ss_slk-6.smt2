(set-logic QF_S)
(set-info :source |  Sleek solver
  http://loris-7.ddns.comp.nus.edu.sg/~project/s2/beta/
|)

(set-info :smt-lib-version 2.0)
(set-info :category "crafted")
(set-info :status unsat)


(declare-sort node 0)
(declare-fun val () (Field node Int))
(declare-fun next () (Field node node))

(define-fun ll_tail2 ((?in node) (?tx node) (?n Int))
Space (tospace
(or
(exists ((?flted_18_27 node))(and 
(= ?flted_18_27 nil)
(= ?tx ?in)
(= ?n 1)
(tobool  
(pto ?in (sref (ref val ?Anon_13) (ref next ?flted_18_27) ))
 )
))(exists ((?tx_29 node)(?flted_19_28 Int))(and 
(= (+ ?flted_19_28 1) ?n)
(distinct ?r nil)
(= ?tx_29 ?tx)
(tobool (ssep 
(pto ?in (sref (ref val ?Anon_14) (ref next ?r) ))
(ll_tail2 ?r ?tx_29 ?flted_19_28)
) )
)))))

(define-fun lseg2 ((?in node) (?p node) (?n Int))
Space (tospace
(or
(and 
(= ?in ?p)
(= ?n 0)

)(exists ((?p_32 node)(?flted_15_31 Int))(and 
(= (+ ?flted_15_31 1) ?n)
(= ?p_32 ?p)
(tobool (ssep 
(pto ?in (sref (ref val ?Anon_12) (ref next ?r) ))
(lseg2 ?r ?p_32 ?flted_15_31)
) )
)))))








(declare-fun Anon () Int)
(declare-fun next () node)
(declare-fun flted () node)
(declare-fun ty2 () node)
(declare-fun tx2 () node)
(declare-fun typrm () node)
(declare-fun yprm () node)
(declare-fun txprm () node)
(declare-fun tx () node)
(declare-fun xprm () node)
(declare-fun ty () node)
(declare-fun m () Int)
(declare-fun y () node)
(declare-fun n () Int)
(declare-fun x () node)


(assert 
(and 
;lexvar(= next flted)
(= flted nil)
(= tx2 x)
(= n 1)
(= ty2 ty)
(= tx2 tx)
(= typrm ty)
(= yprm y)
(= txprm tx)
(= xprm x)
(tobool (ssep 
(ll_tail2 y ty2 m)
(pto txprm (sref (ref val Anon) (ref next yprm) ))
) )
)
)

(assert (not 
(exists ((ty3 node)(q Int))(and 
(= ty3 ty)
(= q (+ n m))
(<= 1 m)
(distinct y nil)
(<= 1 n)
(distinct x nil)
(tobool  
(ll_tail2 x ty3 q)
 )
))
))

(check-sat)