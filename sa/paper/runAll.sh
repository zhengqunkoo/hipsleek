echo "sll-reverse"
../../hip sll-reverse.ss  | grep  "verification time"
# echo "sll-last"
# ../../hip sll-last-2.ss  | grep  "verification time"
echo "qsort-2.ss"
../../hip qsort-2.ss  | grep  "verification time"
echo "zip_paper_eq"
../../hip zip_paper_eq.ss | grep  "verification time"
echo "sll+head"
../../hip single_paper.ss --pred-en-oblg | grep  "verification time"
echo "skip-list.ss"
../../hip sll-dll.ss | grep  "verification time"
echo "check-sorted"
../../hip check-sorted.ss  --sa-en-pure-field | grep  "verification time"
echo "CSll"
../../hip cll.ss  | grep  "verification time"
echo "check-CSll"
../../hip check-cll.ss  | grep  "verification time"
echo " 0/1 SLLs"
../../hip sll-01-slls.ss  | grep  "verification time"
echo "sll2dll"
../../hip sll-dll.ss | grep  "verification time"
echo "check-dll"
../../hip check-dll.ss  | grep  "verification time"
echo "dll-app"
../../hip dll-append_paper.ss  | grep  "verification time"
# echo "dll-del"
# ../../hip dll-del.ss  | grep  "verification time"
echo "bt-search-2.ss"
../../hip bt-search-2.ss | grep  "verification time"
echo "tll"
../../hip tll.ss   | grep  "verification time"
echo "rose-tree"
../../hip rose-sll-1.ss   | grep  "verification time"
echo "check tree+multi"
../../hip check-multi-tree.ss   | grep  "verification time"
echo "check mcf"
../../hip check-mcf.ss   | grep  "verification time"
echo "check tll"
../../hip check-tll.ss   | grep  "verification time"
