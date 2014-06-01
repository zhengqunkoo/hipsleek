(set-logic QF_S)

(declare-sort node 0)
(declare-fun parent () (Field node node))
(declare-fun left () (Field node node))
(declare-fun right () (Field node node))
(declare-fun next () (Field node node))

(define-fun tree ((?in node))
Space (tospace
(or
(exists ((?p_35 node)(?D1_36 node)(?r_37 node)(?n_38 node))(and 
(= ?r_37 nil)
(tobool (ssep 
(pto ?in (sref (ref parent ?p_35) (ref left ?D1_36) (ref right ?r_37) (ref next ?n_38) ))
) )
))(exists ((?p_39 node)(?l_40 node)(?r_41 node)(?D2_42 node))(and 
(distinct ?r_41 nil)
(tobool (ssep 
(pto ?in (sref (ref parent ?p_39) (ref left ?l_40) (ref right ?r_41) (ref next ?D2_42) ))
(tree ?l_40)
(tree ?r_41)
) )
)))))

(define-fun tll ((?in node) (?p node) (?ll node) (?lr node))
Space (tospace
(or
(exists ((?lr_28 node)(?p_21 node)(?D1_22 node)(?l_23 node))(and 
(= ?l_23 nil)
(= ?in ?ll)
(= ?lr_28 ?lr)
(tobool (ssep 
(pto ?in (sref (ref parent ?p_21) (ref left ?D1_22) (ref right ?l_23) (ref next ?lr_28) ))
) )
))(exists ((?p_29 node)(?self_30 node)(?ll_31 node)(?self_32 node)(?z_33 node)(?lr_34 node)(?l_24 node)(?r_25 node)(?D2_26 node)(?z_27 node))(and 
(distinct ?r_25 nil)
(= ?p_29 ?p)
(= ?self_30 ?in)
(= ?ll_31 ?ll)
(= ?self_32 ?in)
(= ?z_33 ?z_27)
(= ?lr_34 ?lr)
(tobool (ssep 
(pto ?in (sref (ref parent ?p_29) (ref left ?l_24) (ref right ?r_25) (ref next ?D2_26) ))
(tll ?l_24 ?self_30 ?ll_31 ?z_27)
(tll ?r_25 ?self_32 ?z_33 ?lr_34)
) )
)))))















(declare-fun D () node)
(declare-fun t () node)
(declare-fun xprm () node)
(declare-fun x () node)
(declare-fun pprm () node)
(declare-fun p () node)
(declare-fun parent () Int)
(declare-fun p1 () Int)
(declare-fun vprm () boolean)
(declare-fun r () node)
(declare-fun l () node)
(declare-fun v1prm () node)
(declare-fun tprm () node)
(declare-fun res () node)


(assert 
(exists ((l node))(and 
(distinct r nil)
(= tprm t)
(= xprm x)
(= pprm p)
(= parent p1)
(distinct r nil)
other(distinct r nil)
other(distinct r nil)
(distinct r nil)
(distinct l nil)
(distinct l nil)
(= res v1prm)
(tobool (ssep 
(tll r xprm lprm tprm)
(pto xprm (sref (ref parent pprm) (ref left l) (ref right r) (ref next D) ))
(tll l xprm v1prm lprm)
emp
) )
))
)

(assert (not 
(exists ((p2 node)(t1 node))(and 
(= p2 p)
(= t1 t)
(distinct r nil)
(= tprm t)
(= xprm x)
(= pprm p)
(= parent p1)
(distinct r nil)
other(distinct r nil)
other(distinct r nil)
(distinct r nil)
(distinct l nil)
(distinct l nil)
(= res v1prm)
(= v1prm res)
other(tobool (ssep 
(tll x p2 res t1)
emp
) )
))
))

(check-sat)