HeapPred HP_2(node a, node b).
HeapPred HP_1(node a).

get_next[
ass [H1,G4]:{
  HP_2(v_node_29_526',x) * x::node<val_28_543,v_node_29_526'> --> G4(v_node_29_526',x,v_544)& x=v_544;
  H1(x) --> x::node<val_28_524',next_28_525'> * HP_2(next_28_525',x)

 }

hpdefs [H1,G4]:{
  G4(next_28_525',x,v_544) --> x::node<val_28_524',next_28_525'>&x=v_544;
  H1(x) --> x::node<_,next_28_525'>&true

 }
]
