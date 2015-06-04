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

(define-fun cll ((?in node) (?p node) (?n Int))
Space (tospace
(or
(and 
(= ?in ?p)
(= ?n 0)

)(exists ((?p_28 node)(?flted_11_27 Int))(and 
(= (+ ?flted_11_27 1) ?n)
(distinct ?in ?p)
(= ?p_28 ?p)
(tobool (ssep 
(pto ?in (sref (ref val ?Anon_12) (ref next ?r) ))
(cll ?r ?p_28 ?flted_11_27)
) )
)))))

(define-fun hd ((?in node) (?n Int))
Space (tospace
(or
(and 
(= ?in nil)
(= ?n 0)

)(exists ((?self_25 node)(?flted_15_24 Int))(and 
(= (+ ?flted_15_24 1) ?n)
(= ?self_25 ?in)
(tobool (ssep 
(pto ?in (sref (ref val ?Anon_13) (ref next ?r) ))
(cll ?r ?self_25 ?flted_15_24)
) )
)))))












































(declare-fun Anon1 () Int)
(declare-fun v1prm () node)
(declare-fun r1 () node)
(declare-fun rest () node)
(declare-fun h () node)
(declare-fun p2 () node)
(declare-fun restprm () node)
(declare-fun p () node)
(declare-fun flted1 () Int)
(declare-fun n () Int)
(declare-fun hprm () node)


(assert 
(and 
;lexvar(= v1prm r1)
(= restprm rest)
(= hprm h)
(= h p)
(distinct restprm hprm)
(= p2 p)
(distinct restprm p)
(= (+ flted1 1) n)
(tobool (ssep 
(pto restprm (sref (ref val Anon1) (ref next r1) ))
(cll r1 p2 flted1)
) )
)
)

(assert (not 
(and 
(= hprm p3)
(tobool  
(cll v1prm p3 n1)
 )
)
))

(check-sat)