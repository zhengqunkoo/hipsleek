OCAMLC=ocamlc
OCAMLOPT=ocamlopt.opt
OCAMLDEP=ocamldep
OCAMLDOC=ocamldoc

DIRS=.
INCLUDES=-I ./xml -I +ocamlgraph
GUIINCLUDES=-I +lablgtk2
#OCAMLFLAGS=-dtypes $(INCLUDES)    # add other options for ocamlc here
#OCAMLOPTFLAGS=-dtypes $(INCLUDES) # add other options for ocamlopt here
OCAMLFLAGS= -dtypes $(INCLUDES) # add other options for ocamlc here
GUIOCAMLFLAGS= $(OCAMLFLAGS) $(GUIINCLUDES) #
OCAMLOPTFLAGS=$(INCLUDES) # add other options for ocamlopt here
# removed -p from above as it seems related to profiling..
OCAMLYACC=ocamlyacc
OCAMLYACCFLAGS=-v
OCAMLLEX=ocamllex -q
BIN=../bin
DOC=../doc
DOC_SRC=*/*.ml */*.mli
DEP_DOT_FILE=$(DOC)/depend/dependencies.dot
DEP_PS_FILE=$(DOC)/depend/dependencies.ps
DEP_PDF_FILE=$(DOC)/depend/dependencies.pdf
TMP_FILES_PATH = /tmp/$(shell id -un)/prover_tmp_files

all: hip sleek decidez.vo prover
#hip sleek prover prdebug decidez.vo

norm: hip.norm sleek.norm  prover.norm decidez.vo

rest: hip.norm sleek.norm prover.norm prdebug decidez.vo

opt: hip sleek prover

sparser.cmo sparser.ml: sparser.mly
	$(OCAMLYACC) $(OCAMLYACCFLAGS) sparser.mly
	rm sparser.mli
	$(OCAMLC) $(OCAMLFLAGS) -c -g sparser.ml

slexer.cmo slexer.ml: slexer.mll sparser.ml
	$(OCAMLLEX) slexer.mll
	$(OCAMLC) $(OCAMLFLAGS) -c -g slexer.ml

iparser.cmo iparser.ml: iparser.mly
	$(OCAMLYACC) $(OCAMLYACCFLAGS) iparser.mly
	rm iparser.mli
	$(OCAMLC) $(OCAMLFLAGS) -c -g iparser.ml

ilexer.cmo ilexer.ml: ilexer.mll iparser.ml
	$(OCAMLLEX) ilexer.mll
	$(OCAMLC) $(OCAMLFLAGS) -c -g ilexer.ml

ocparser.cmo ocparser.ml: ocparser.mly
	$(OCAMLYACC) $(OCAMLYACCFLAGS) ocparser.mly
	rm ocparser.mli
	$(OCAMLC) $(OCAMLFLAGS) -c -g ocparser.ml

oclexer.cmo oclexer.ml: oclexer.mll ocparser.ml
	$(OCAMLLEX) oclexer.mll
	$(OCAMLC) $(OCAMLFLAGS) -c -g oclexer.ml

rlparser.cmo rlparser.ml: rlparser.mly
	$(OCAMLYACC) $(OCAMLYACCFLAGS) rlparser.mly
	rm rlparser.mli
	$(OCAMLC) $(OCAMLFLAGS) -c -g rlparser.ml

rllexer.cmo rllexer.ml: rllexer.mll rlparser.ml
	$(OCAMLLEX) rllexer.mll
	$(OCAMLC) $(OCAMLFLAGS) -c -g rllexer.ml

MAIN_FILES=typeclass.cmo monads.cmo globals.cmo error.cmo util.cmo debug.cmo \
	cpure.cmo mcpure.cmo ipure.cmo \
	iformula.cmo iast.cmo \
	iparser.cmo ilexer.cmo \
	iprinter.cmo \
	iastUtil.cmo \
	rlparser.cmo rllexer.cmo \
	ocparser.cmo oclexer.cmo unix_add.cmo isabelle.cmo coq.cmo omega.cmo setmona.cmo redlog.cmo \
  net.cmo \
	cvclite.cmo cvc3.cmo smtsolver.cmo \
  cformula.cmo cast.cmo cprinter.cmo mona.cmo\
  tpdispatcher.cmo paralib1.cmo paralib1v2.cmo\
	prooftracer.cmo context.cmo solver.cmo \
	drawing.cmo \
	env.cmo checks.cmo \
	inliner.cmo \
	astsimp.cmo \
	java.cmo cjava.cmo predcomp.cmo rtc.cmo \
	typechecker.cmo \
	globalvars.cmo \
	scriptarguments.cmo\
	main.cmo


PP_FILES=typeclass.cmo monads.cmo globals.cmo error.cmo util.cmo debug.cmo \
	cpure.cmo mcpure.cmo ipure.cmo \
	iformula.cmo iast.cmo \
	iparser.cmo ilexer.cmo \
	iprinter.cmo \
	iastUtil.cmo \
	cformula.cmo cast.cmo cprinter.cmo


MAIN_FILES_OPT := $(MAIN_FILES:.cmo=.cmx)


GUI_FILES=typeclass.cmo monads.cmo monadicinterp.cmo globals.cmo error.cmo util.cmo debug.cmo \
	cpure.cmo mcpure.cmo ipure.cmo \
	iformula.cmo iast.cmo iastUtil.cmo \
	iparser.cmo ilexer.cmo \
	iprinter.cmo \
	ocparser.cmo oclexer.cmo unix_add.cmo isabelle.cmo coq.cmo omega.cmo setmona.cmo redlog.cmo \
  rlparser.cmo rllexer.cmo \
  net.cmo \
	cvclite.cmo cvc3.cmo smtsolver.cmo \
  cformula.cmo cast.cmo cprinter.cmo mona.cmo \
  tpdispatcher.cmo paralib1.cmo paralib1v2.cmo\
	prooftracer.cmo context.cmo solver.cmo \
	drawing.cmo \
	env.cmo checks.cmo \
	inliner.cmo \
	astsimp.cmo \
	java.cmo cjava.cmo predcomp.cmo rtc.cmo \
	typechecker.cmo \
	scriptarguments.cmo \
	globalvars.cmo 	



SLEEK_FILES=typeclass.cmo monads.cmo globals.cmo error.cmo util.cmo debug.cmo \
	cpure.cmo mcpure.cmo ipure.cmo \
	iformula.cmo iast.cmo \
	sparser.cmo slexer.cmo iparser.cmo ilexer.cmo \
	iprinter.cmo \
  iastUtil.cmo \
	rlparser.cmo rllexer.cmo \
	ocparser.cmo oclexer.cmo unix_add.cmo isabelle.cmo coq.cmo omega.cmo setmona.cmo redlog.cmo \
    net.cmo \
	cvclite.cmo cvc3.cmo smtsolver.cmo \
	cformula.cmo cast.cmo cprinter.cmo mona.cmo \
  tpdispatcher.cmo paralib1.cmo paralib1v2.cmo \
  sleekcommons.cmo \
	prooftracer.cmo context.cmo solver.cmo \
	drawing.cmo \
	env.cmo checks.cmo \
	inliner.cmo \
	astsimp.cmo \
	java.cmo cjava.cmo predcomp.cmo rtc.cmo \
	typechecker.cmo \
	xmlfront.cmo nativefront.cmo \
	sleekengine.cmo \
	scriptarguments.cmo \
	sleek.cmo

SLEEK_FILES_OPT := $(SLEEK_FILES:.cmo=.cmx)


MAIN_FILES_2=util.cmo debug.cmo globals.cmo \
	ipure.cmo iformula.cmo iast.cmo \
	iparser.cmo ilexer.cmo \
	iprinter.cmo

MAIN_FILES_2_OPT := $(MAIN_FILES_2:.cmo=.cmx)


PROVE_FILES=typeclass.cmo monads.cmo globals.cmo error.cmo util.cmo debug.cmo \
	cpure.cmo mcpure.cmo ipure.cmo \
	iformula.cmo iast.cmo \
	iparser.cmo ilexer.cmo \
	iprinter.cmo \
  iastUtil.cmo \
	rlparser.cmo rllexer.cmo \
  ocparser.cmo oclexer.cmo unix_add.cmo isabelle.cmo coq.cmo omega.cmo setmona.cmo redlog.cmo \
    net.cmo \
	cvclite.cmo cvc3.cmo smtsolver.cmo\
  cformula.cmo cast.cmo cprinter.cmo mona.cmo \
  tpdispatcher.cmo paralib1.cmo paralib1v2.cmo \
	prooftracer.cmo context.cmo solver.cmo \
	drawing.cmo \
	env.cmo checks.cmo \
	inliner.cmo \
	astsimp.cmo \
	java.cmo cjava.cmo predcomp.cmo rtc.cmo \
	typechecker.cmo \
	prove.cmo

PROVE_FILES_OPT := $(PROVE_FILES:.cmo=.cmx)

WEB_FILES=globals.cmo error.cmo util.cmo debug.cmo \
	cpure.cmo mcpure.cmo ipure.cmo \
	iformula.cmo iast.cmo \
	iparser.cmo ilexer.cmo \
	iprinter.cmo \
  iastUtil.cmo \
	rlparser.cmo rllexer.cmo \
	ocparser.cmo oclexer.cmo unix_add.cmo isabelle.cmo coq.cmo omega.cmo setmona.cmo \
  net.cmo \
	cvclite.cmo cvc3.cmo smtsolver.cmo \
  cformula.cmo cast.cmo cprinter.cmo mona.cmo \
  tpdispatcher.cmo paralib1.cmo paralib1v2.cmo \
	prooftracer.cmo context.cmo solver.cmo \
	drawing.cmo \
	env.cmo checks.cmo \
	inliner.cmo \
	astsimp.cmo \
	java.cmo cjava.cmo predcomp.cmo rtc.cmo \
	typechecker.cmo \
	web.cmo
hip1: $(MAIN_FILES_2) 
	$(OCAMLC) -g -o $@ $(OCAMLFLAGS) unix.cma str.cma graph.cma $(MAIN_FILES_2)

hipc:
	make clean; make hip

hip.norm: decidez.vo $(MAIN_FILES)
	$(OCAMLC) -g -o $@ $(OCAMLFLAGS) unix.cma str.cma graph.cma $(MAIN_FILES)
#[ -d $(TMP_FILES_PATH) ] && true || mkdir -p $(TMP_FILES_PATH)  
hip: $(MAIN_FILES_OPT) decidez.vo
	$(OCAMLOPT) -o $@ $(OCAMLOPTFLAGS) unix.cmxa str.cmxa graph.cmxa $(MAIN_FILES_OPT)
#	[ -d $(TMP_FILES_PATH) ] && true || mkdir -p $(TMP_FILES_PATH)  

mytop: $(MAIN_FILES) decidez.vo
	ocamlmktop -o $@ $(OCAMLFLAGS) unix.cma str.cma graph.cma $(MAIN_FILES)

prdebug: $(PP_FILES) 
	 $(OCAMLC) -a -o $@ $(OCAMLFLAGS) unix.cma str.cma graph.cma $(PP_FILES)
#	 [ -d $(TMP_FILES_PATH) ] && true || mkdir -p $(TMP_FILES_PATH)  

hipgui: $(GUI_FILES) decidez.vo scriptarguments.ml gui.ml maingui.ml
	$(OCAMLC) -g -o $@ $(GUIOCAMLFLAGS) unix.cma str.cma graph.cma lablgtk.cma lablgtksourceview2.cma $(GUI_FILES) scriptarguments.ml gui.ml maingui.ml
#	[ -d $(TMP_FILES_PATH) ] && true || mkdir -p $(TMP_FILES_PATH)  

#hip.opt: $(MAIN_FILES:*.cmo=*.cmx) 
#	make -f Makefile.opt hip.opt

prover.norm: $(PROVE_FILES)
	$(OCAMLC) -g -o $@ $(OCAMLFLAGS) unix.cma str.cma graph.cma $(PROVE_FILES)
#	[ -d $(TMP_FILES_PATH) ] && true || mkdir -p $(TMP_FILES_PATH)  

prover: $(PROVE_FILES_OPT)
	$(OCAMLOPT) -o $@ $(OCAMLOPTFLAGS) unix.cmxa str.cmxa graph.cmxa $(PROVE_FILES_OPT)


web: $(WEB_FILES)
	$(OCAMLC) -g -o $@ $(OCAMLFLAGS) unix.cma str.cma graph.cma $(WEB_FILES)

#$(OCAMLC) -g -o $@ $(OCAMLFLAGS) unix.cma str.cma graph.cma $(PROVE_FILES)

sleekc:
	make clean; make sleek 

xml/xml-light.cma:
	make -C xml

xml/xml-light.cmxa:
	make -C xml xml-light.cmxa

sleek.norm: xml/xml-light.cma decidez.vo $(SLEEK_FILES) 
	$(OCAMLC) -g -o $@ $(OCAMLFLAGS) unix.cma str.cma graph.cma xml-light.cma $(SLEEK_FILES)
#	[ ! -d $(TMP_FILES_PATH) ] && mkdir -p $(TMP_FILES_PATH) 

sleek: xml/xml-light.cmxa decidez.vo $(SLEEK_FILES_OPT) 
	$(OCAMLOPT) -o $@ $(OCAMLOPTFLAGS) unix.cmxa str.cmxa graph.cmxa xml-light.cmxa $(SLEEK_FILES_OPT)

#sleek.opt: xml/xml-light.cmxa $(SLEEK_FILES:*.cmo=*.cmx) 
#	$(OCAMLOPT) -o $@ $(OCAMLOPTFLAGS) unix.cmxa str.cmxa graph.cmxa $(SLEEK_FILES:*.cmo=*.cmx)

CRISTINA_FILES=util.cmo debug.cmo globals.cmo error.cmo \
	cpure.cmo mcpure.cmo cformula.cmo cast.cmo

cristina: $(CRISTINA_FILES)

TEST_OO_FILES=util.cmo debug.cmo globals.cmo error.cmo \
	cpure.cmo mcpure.cmo ipure.cmo \
	iformula.cmo iast.cmo \
	checks.cmo \
	iparser.cmo ilexer.cmo \
	iprinter.cmo \
	iastUtil.cmo \
	cformula.cmo cast.cmo cprinter.cmo \
	rlparser.cmo rllexer.cmo \
	ocparser.cmo oclexer.cmo unix_add.cmo isabelle.cmo coq.cmo omega.cmo mona.cmo\
	cvclite.cmo cvc3.cmo smtsolver.cmo tpdispatcher.cmo \
	context.cmo \
	solver.cmo \
	env.cmo astsimp.cmo \
	test-oo.cmo \
#	typechecker.cmo \
#	main.cmo

oo: $(TEST_OO_FILES)
	$(OCAMLC) -g -o $@ $(OCAMLFLAGS) unix.cma str.cma graph.cma $(TEST_OO_FILES)


JAVA_FILES=util.cmo debug.cmo globals.cmo error.cmo \
	cpure.cmo mcpure.cmo ipure.cmo \
	iformula.cmo iast.cmo iprinter.cmo \
	iparser.cmo ilexer.cmo \
	iastUtil.cmo \
	java.cmo

j: $(JAVA_FILES)
	$(OCAMLC) -g -o $@ $(OCAMLFLAGS) unix.cma str.cma graph.cma $(JAVA_FILES)

decidez.vo:
	coqtop -compile decidez

# ------------------------------------------------------------
# Common rules
# ------------------------------------------------------------
.SUFFIXES: .ml .mli .cmo .cmi .cmx .mly .mll

.ml.annot:
	$(OCAMLC) $(OCAMLFLAGS) -c -g $<

.ml.cmo:
	$(OCAMLC) $(OCAMLFLAGS) -c -g $<

.mli.cmi:
	$(OCAMLC) $(OCAMLFLAGS) -c -g $<

.ml.cmx:
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<

# Clean up
clean: 
	rm -f decidez.glob decidez.vo slexer.ml ilexer.ml iparser.ml oclexer.ml ocparser.ml rlparser.ml rllexer.ml *.cmo *.cmi *.cmx *.o *.mli *.output *.annot hip.exe hip hip.norm sleek.norm sleek sleek.exe prover prover.norm web *~ oo oo.exe hipgui prdebug ss ss.exe ss.norm

# Dependencies
beforedepend: iparser.ml ocparser.ml

depend: beforedepend
	(for d in $(DIRS); \
	do $(OCAMLDEP) $(INCLUDES) $$d/*.mli $$d/*.ml; \
	done) > .depend

-include .depend
# DO NOT DELETE
