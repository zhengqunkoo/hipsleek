
Processing file "bsort-1.ss"
Parsing bsort-1.ss ...
Parsing ../../prelude.ss ...
Starting Reduce... 
Starting Omega...oc
Translating global variables to procedure parameters...

Checking procedure bubble$node... 
!!! REL :  A(res)
!!! POST:  !(res)
!!! PRE :  true
!!! REL :  B(res)
!!! POST:  true
!!! PRE :  true
!!! OLD SPECS: ((None,[]),EInfer [xs,A,B]
              EBase exists (Expl)(Impl)[n](ex)xs::ll<n>@M[Orig][LHSCase]&
                    xs!=null&{FLOW,(20,21)=__norm}
                      EBase true&MayLoop&{FLOW,(1,23)=__flow}
                              EAssume 1::
                                
                                EXISTS(n_38,s,
                                l: xs::sll<n_38,s,l>@M[Orig][LHSCase]&
                                A(res) & n_38=n&{FLOW,(20,21)=__norm})
                                or EXISTS(n_39: xs::ll<n_39>@M[Orig][LHSCase]&
                                   B(res) & n_39=n&{FLOW,(20,21)=__norm})
                                )
!!! NEW SPECS: ((None,[]),EBase exists (Expl)(Impl)[n](ex)xs::ll<n>@M[Orig][LHSCase]&
                  xs!=null&{FLOW,(20,21)=__norm}
                    EBase true&MayLoop&{FLOW,(1,23)=__flow}
                            EAssume 1::
                              
                              xs::sll<n_38,s,l>@M[Orig][LHSCase]&n_38=n & 
                              !(res) & 0<=n&{FLOW,(20,21)=__norm}
                              or xs::ll<n_39>@M[Orig][LHSCase]&n_39=n & 0<=n&
                                 {FLOW,(20,21)=__norm}
                              )
!!! NEW RELS:[ (res<=0) --> A(res),
 (tmp_42' & 1<=res & A(tmp_42')) --> A(res),
 (!(tmp_42') & res<=0 & A(tmp_42')) --> A(res),
 (A(tmp_42') & 1<=res & tmp_42') --> A(res),
 (A(tmp_42') & res<=0 & !(tmp_42')) --> A(res),
 (res<=0) --> B(res),
 (1<=res) --> B(res),
 (res<=0) --> B(res),
 (1<=res) --> B(res),
 (res<=0) --> B(res),
 (B(tmp_42') & 1<=res & tmp_42') --> B(res),
 (B(tmp_42') & res<=0 & !(tmp_42')) --> B(res)]
!!! NEW ASSUME:[]
!!! NEW RANK:[]
Procedure bubble$node SUCCESS

Termination checking result:

Stop Omega... 459 invocations 
0 false contexts at: ()

Total verification time: 1.34 second(s)
	Time spent in main process: 1.02 second(s)
	Time spent in child processes: 0.32 second(s)
