#!/usr/bin/perl

use File::Find;
use File::Basename;
use Getopt::Long;
use Sys::Hostname;
use File::NCopy;
use File::Path 'rmtree';
use Cwd;
use lib '/usr/local/share/perl/5.10.0';
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::SaveParser;

GetOptions( "stop"  => \$stop,
			"help" => \$help,
			"root=s" => \$root,
			"tp=s" => \$prover,
			"flags=s" => \$flags,
			"copy-to-home21" => \$home21,
            "log-timings" => \$timings,
            "log-string=s" => \$str_log,
            "bags" => \$bags,
            "term" => \$term,
            "lists" => \$lists
			);
@param_list = @ARGV;
if(($help) || (@param_list == ""))
{
	print "./run-fast-tests.pl [-help] [-root path_to_sleek] [-tp name_of_prover] [-log-timings] [-log-string string_to_be_added_to_the_log] [-copy-to-home21] hip_tr|hip|imm|imm-filed|sleek|parahip|hip_vperm|sleek_vperm|sleek_fracperm|infinity|mem [-flags \"arguments to be transmited to hip/sleek \"]\n";
	exit(0);
}

if($root){
	$exempl_path = "$root/examples/working";
	$exec_path = "$root";
}
else
	{
		$exempl_path = ".";
		$exec_path = '../..';
	}

if($prover){
	%provers = ('cvcl' => 'cvcl', 'cvc3' => 'cvc3', 'oc' => 'oc','oc-2.1.6' => 'oc-2.1.6', 
		'co' => 'co', 'isabelle' => 'isabelle', 'coq' => 'coq', 'mona' => 'mona', 'om' => 'om', 
		'oi' => 'oi', 'set' => 'set', 'cm' => 'cm', 'redlog' => 'redlog', 'rm' => 'rm', 'prm' => 'prm', 'z3' => 'z3', 'z3-2.19' => 'z3-2.19', 'zm' => 'zm', 'log' => 'log');
	if (!exists($provers{$prover})){
        print "./run-fast-tests.pl [-help] [-root path_to_sleek] [-tp name_of_prover] [-log-timings]  [-log-string string_to_be_added_to_the_log] [-copy-to-home21] hip_tr|hip|sleek|parahip|hip_vperm|sleek_vperm|sleek_fracperm [-flags \"arguments to be transmited to hip/sleek \"]\n";
		print "\twhere name_of_prover should be one of the followings: 'cvcl', 'cvc3', 'omega', 'co', 'isabelle', 'coq', 'mona', 'om', 'oi', 'set', 'cm', 'redlog', 'rm', 'prm', 'z3' or 'zm'\n";
		exit(0);
	}
}
else{
    if("$flags" =~ m/-tp (\w+)\b/ ){
        $prover = "$1";
    }
    else{
	$prover = "oc";
    }
}

if("$flags"){
	$script_arguments = "$flags";
	if (!($script_arguments =~ "-tp ")){
		$script_arguments = $script_arguments." -tp ".$prover;
	}
}
else{
	$script_arguments = " -tp ".$prover;
}

if($home21){
	$current_dir = getcwd();
	$current_hostname = hostname;
	#if ($current_hostname eq "loris-21"){
	#	print "The current host is already loris-21";
	#	exit(0);
	#}
	$target_dir = "/home21/".getlogin()."/sleek_tmp_".getppid();
	mkdir $target_dir or die "\nerror: Could not create directory $target_dir\n";
	my $cp = File::NCopy->new(recursive => 1);
    $cp->copy("$exec_path/*", $target_dir) or die "Could not perform rcopy of $source_dir to $target_dir: $!";
	$exec_path = "$target_dir";
	$exempl_path = "$target_dir/examples/working";
	if($root){
		chdir("$root") or die "Can't chdir to $root $!";
	}else{
		chdir("$target_dir") or die "Can't chdir to $target_dir $!"; 
	}	
}

if($timings){
    my $parser = new Spreadsheet::ParseExcel::SaveParser;
    $timings_logfile = "timings_log.xls";
    if(-e "$timings_logfile") {#check for file existance
        $book = $parser->Parse("$timings_logfile") #open file for appending
            or die "File $timings_logfile was not found";
        my $count = $book->{SheetCount};#total number of worksheets of the workbook
        my $provers_sheet_no = 0;
        for(my $i=0; $i < $count ; $i++){#iterate through all the worksheets 
            if ($book->{Worksheet}[$i]->{Name} =~ "$prover") {#check if a profiling worksheet of the selected prover already exists
                if($book->{Worksheet}[$i]->{Name} =~ m/_(\d+)/) {#find the no. of the newest worksheet of this prover
                    if($provers_sheet_no < int($1)){
                        $provers_sheet_no = int($1);
                    }
                }
            }
        }
        $provers_sheet_no = $provers_sheet_no + 1;
        my $new_worksheet_name = "$prover"."_".$provers_sheet_no;#compute the name of the new worksheet: prover_maxno
        $book->AddWorksheet($new_worksheet_name);
        local $^W = 0;
        $workbook = $book->SaveAs("temp_"."$timings_logfile");
        $worksheet = $workbook->sheets($count);
    }else{
        #create a new file
        $workbook = Spreadsheet::WriteExcel->new("temp_"."$timings_logfile")
            or die "Could not create file $timings_logfile"; 
        my $new_worksheet_name = "$prover"."_1";
        $workbook->add_worksheet($new_worksheet_name);
        $worksheet = $workbook->sheets(0);
    }

    $row = 3;
    (my $Second, my $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time);
    $Year += 1900;
    $Month++;
    $date = "$Day/$Month/$Year  $Hour:$Minute";
    $worksheet->set_column(0, 0, 10);
    $worksheet->write($row, 3, "Time:");
    $worksheet->write($row, 4, $date);
    $row++;
    $worksheet->write($row, 3, "Prover:");
    $worksheet->write($row, 4, "$prover");
    $row++;
    if("$flags"){
        $worksheet->write($row, 3, "Call args:");
        $worksheet->write($row, 4, "$flags");
    }
    $row++;
    if("$str_log"){
        $worksheet->write($row, 3, "Comments:");
        $worksheet->write($row, 4, "$str_log");
    }
    $row = $row + 2;
    $programCol = 1;
    $mainCol = 2;
    $childCol = 3;
    $cl = $childCol;
    if("$flags" =~ m/--enable-logging-txt\b/ ){
     $cl=$childCol+1;
     $prooflogCol = $cl;	
    }
    $totalCol = $cl+1;
    $falseContextCol = $cl+2;
    my $format = $workbook->add_format();
    $format->set_bold();
    $format->set_align('center');
    $worksheet->write($row, $programCol, "Program", $format);
    $worksheet->set_column($programCol, 0, 15);
    $worksheet->set_column($mainCol,$falseContextCol, 10);
    $worksheet->write($row, $mainCol, "Main", $format);
    $worksheet->write($row, $childCol, "Child", $format);
    if("$flags" =~ m/--enable-logging-txt\b/ ){
       $worksheet->write($row, $prooflogCol, "Proof log", $format);
    }
    $worksheet->write($row, $totalCol, "Total time", $format);
    $worksheet->write($row, $falseContextCol, "No. false ctx", $format);

}

@excl_files = ();
$error_count = 0;
$error_files = "";
$hip = "$exec_path/hip ";
# TODO : check if hip is n-hip, as b-hip is too slow
# please use make native
$sleek = "$exec_path/sleek ";
$output_file = "log";
# list of file, nr of functions, function name, output, function name, output......
# files are searched in the subdirectory with the same name as the list name, in examples/working/hip directory (ex. hip/array for "array" list)
%hip_files=(
	# AN HOA : ADDED ARRAY TESTING EXAMPLES
	"array"=>[
		["arr_at.java",1,"","main","SUCCESS"],
		["arr_binarysearch.java",1,"","binary_search","SUCCESS"],
		["arr_search_decrease_less_than_two.java",1,"","searchzero","FAIL"], # induction required
		["arr_bubblesort.java",2,"","bubblesort","SUCCESS","bubble","SUCCESS"],
		["arr_bubblesort_perm.java",2,"","bubblesort","SUCCESS","bubble","SUCCESS"],
		["arr_double.java",1,"","doublearr","SUCCESS"],
		["arr_extract_nonzeros.java",3,"","copy_nonzeros","SUCCESS","count_nonzeros","SUCCESS","extract_nonzeros","SUCCESS"],
		["arr_init.java",1,"","zinit","SUCCESS"],
		["arr_insertsort.java",2,"","insertelm","SUCCESS","insertion_sort","SUCCESS"],
		["arr_insertsort_perm.java",2,"","insertelm","SUCCESS","insertion_sort","SUCCESS"],
		["arr_invert.java",2,"","Invert","SUCCESS","InvertHelper","SUCCESS"],
		["arr_max.java",1,"","max_value_of_array","SUCCESS"],
		["arr_mergesort.java",3,"","merge_sorted_arrays","SUCCESS","copy_array","SUCCESS","merge_sort","SUCCESS"],
		["arr_new_exp.java",1,"","main","SUCCESS"],
		["arr_nqueens.java",3,"","nQueens","SUCCESS","nQueensHelper","SUCCESS","nQueensHelperHelper","SUCCESS"],
		["arr_qsort.java",2,"","arraypart","SUCCESS","qsort","SUCCESS"],
		["arr_rev.java",1,"","arrayrev","SUCCESS"],
		["arr_selectionsort.java",2,"","array_index_of_max","SUCCESS","selection_sort","SUCCESS"],
		["arr_selectionsort_perm.java",2,"","array_index_of_max","SUCCESS","selection_sort","SUCCESS"],
		["arr_sparse.java",3,"--imm","create","SUCCESS","get","SUCCESS","setsa","SUCCESS"],
		["arr_sum.java",2,"","sigmaright","SUCCESS","sigmaleft","SUCCESS"] # there is an axiom that requires induction
	],
	# END OF ARRAY TESTING EXAMPLES
	"hip_tr"=>[["trees.ss",1,"insert"]],
	"infinity" =>[["bst-inf.ss",2,"--dsd --en-inf","delete","SUCCESS","remove_min","SUCCESS"],
	["inf-selsort.ss",3,"--dsd --en-disj-compute --en-inf","find_min","SUCCESS","delete_min","SUCCESS","selection_sort","SUCCESS"],
	["inf-ins.ss",1,"--dsd --en-inf","insert","SUCCESS"],
	["inf-sel.ss",3,"--dsd --en-inf","find_min","SUCCESS","delete_min","SUCCESS","selection_sort","SUCCESS"],
	],
    "imm" =>[ 
        ["bigint.ss",17,  " --imm -tp redlog",
		 "clone", "SUCCESS",
		 "int_value", "SUCCESS",
		 "bigint_of", "SUCCESS",
         "add_one_digit", "SUCCESS",
#		 "test", "SUCCESS", 
         "add_c", "SUCCESS",
         "add", "SUCCESS",
         "sub_one_digit", "SUCCESS",
         "sub_c", "SUCCESS",
         "sub", "SUCCESS",
         "mult_c", "SUCCESS",
         "shift_left", "SUCCESS",
         "mult", "SUCCESS",
#		 "karatsuba_mult", "SUCCESS",
         "is_zero", "SUCCESS",
         "is_equal", "SUCCESS",
         "compare2", "SUCCESS", #loop?
         "compare_int", "SUCCESS",
         "div_with_remainder", "SUCCESS"],
        ["bigint_imm.ss",18,  " --imm -tp redlog",
         "clone", "SUCCESS",
         "int_value", "SUCCESS",
         "bigint_of", "SUCCESS",
         "add_one_digit", "SUCCESS",
         "test", "SUCCESS", 
         "add_c", "SUCCESS",
         "add", "SUCCESS",
         "sub_one_digit", "SUCCESS",
         "sub_c", "SUCCESS",
         "sub", "SUCCESS",
         "mult_c", "SUCCESS",
         "shift_left", "SUCCESS",
         "mult2", "SUCCESS",
#		 "karatsuba_mult", "SUCCESS",
         "is_zero", "SUCCESS",
         "is_equal", "SUCCESS",
         "compare2", "SUCCESS",
         "compare_int", "SUCCESS",
         "div_with_remainder", "SUCCESS"],
        ["bigint_imm-star.ss",17,  " --imm -tp redlog",
         "clone", "SUCCESS",
         "int_value", "SUCCESS",
         "bigint_of", "SUCCESS",
         "add_one_digit", "SUCCESS",
#		 "test", "SUCCESS", 
         "add_c", "SUCCESS",
         "add", "SUCCESS",
         "sub_one_digit", "SUCCESS",
         "sub_c", "SUCCESS",
         "sub", "SUCCESS",
         "mult_c", "SUCCESS",
         "shift_left", "SUCCESS",
         "mult", "SUCCESS",
#		 "karatsuba_mult", "SUCCESS",
         "is_zero", "SUCCESS",
         "is_equal", "SUCCESS",
         "compare2", "SUCCESS",
         "compare_int", "SUCCESS",
         "div_with_remainder", "SUCCESS"],
        ["bigint-tight.ss",17,  " --imm -tp redlog",
         "clone", "SUCCESS",
         "int_value", "SUCCESS",
         "bigint_of", "SUCCESS",
         "add_one_digit", "SUCCESS",
#		 "test", "SUCCESS", 
         "add_c", "SUCCESS",
         "add", "SUCCESS",
         "sub_one_digit", "SUCCESS",
         "sub_c", "SUCCESS",
         "sub", "SUCCESS",
         "mult_c", "SUCCESS",
         "shift_left", "SUCCESS",
         "mult", "SUCCESS",
#		 "karatsuba_mult", "SUCCESS",
         "is_zero", "SUCCESS",
         "is_equal", "SUCCESS",
         "compare2", "SUCCESS",
         "compare_int", "SUCCESS",
         "div_with_remainder", "SUCCESS"],
        ["bigint-tight-imm.ss",18,  " --imm -tp redlog",
         "clone", "SUCCESS",
         "int_value", "SUCCESS",
         "bigint_of", "SUCCESS",
         "add_one_digit", "SUCCESS",
         "test", "SUCCESS", 
         "add_c", "SUCCESS",
         "add", "SUCCESS",
         "sub_one_digit", "SUCCESS",
         "sub_c", "SUCCESS",
         "sub", "SUCCESS",
         "mult_c", "SUCCESS",
         "shift_left", "SUCCESS",
         "mult", "SUCCESS",
#		 "karatsuba_mult", "SUCCESS",
         "is_zero", "SUCCESS",
         "is_equal", "SUCCESS",
         "compare2", "SUCCESS",
         "compare_int", "SUCCESS",
         "div_with_remainder", "SUCCESS"],
        ["bigint-tight-imm-star.ss",17,  " --imm -tp redlog",
         "clone", "SUCCESS",
         "int_value", "SUCCESS",
         "bigint_of", "SUCCESS",
         "add_one_digit", "SUCCESS",
#		 "test", "SUCCESS", 
         "add_c", "SUCCESS",
         "add", "SUCCESS",
         "sub_one_digit", "SUCCESS",
         "sub_c", "SUCCESS",
         "sub", "SUCCESS",
         "mult_c", "SUCCESS",
         "shift_left", "SUCCESS",
         "mult", "SUCCESS",
#		 "karatsuba_mult", "SUCCESS",
         "is_zero", "SUCCESS",
         "is_equal", "SUCCESS",
         "compare2", "SUCCESS",
         "compare_int", "SUCCESS",
         "div_with_remainder", "SUCCESS"],
        ["append_imm.ss", 1,  " --imm ", "append", "SUCCESS"],
        ["kara.ss",1,  " --imm -tp redlog", "karatsuba_mult","SUCCESS"],
        ["kara-imm-star.ss",1,  " --imm -tp redlog" , "karatsuba_mult","SUCCESS"],
        ["kara-imm-conj.ss",1,  "--imm -tp redlog", "karatsuba_mult","SUCCESS"],
        ["ll_imm.ss", 6,  " --imm ", "length", "SUCCESS",
         "append", "SUCCESS",
         "sumN", "SUCCESS",
         "set_next", "SUCCESS",
         "get_next_next", "SUCCESS",
         "get_next", "SUCCESS"
        ]],
        "mem" => [
        ["dag.ss",2,"-tp om --mem --ramify","mark","SUCCESS","mark2","SUCCESS"],
        ["dag_values.ss",2,"-tp om --mem --ramify","mark","SUCCESS","mark2","SUCCESS"],
        ["dag_values_infer.ss",2,"-tp om --mem --ramify --infer-mem","mark","SUCCESS","mark2","SUCCESS"],   
        ["graph.ss",2,"-tp om --mem --ramify","mark","SUCCESS","mark2","SUCCESS"],
        ["graph_values.ss",2,"-tp om --mem --ramify","mark","SUCCESS","mark2","SUCCESS"],
        ["graph_values_infer.ss",2,"-tp om --mem --ramify --infer-mem","mark","SUCCESS","mark2","SUCCESS"],
        ["dag_1.ss",1,"-tp om --mem --ramify","mark","SUCCESS"],
        ["dag_1_ramify.ss",1,"-tp om --mem --ramify","mark","SUCCESS"],
        ["graph_1.ss",1,"-tp om --mem --ramify","mark","SUCCESS"],
        ["graph_1_ramify.ss",1,"-tp om --mem --ramify","mark","SUCCESS"],
        ["dag_copy.ss",1,"-tp om --mem --ramify","copy_dag","SUCCESS"],
        ["garbage_collector.ss",3,"-tp om --mem --ramify","mark","SUCCESS","sweep","SUCCESS","collect","SUCCESS"],
        ["garbage_collector_values.ss",3,"-tp om --mem --ramify","mark","SUCCESS","sweep","SUCCESS","collect","SUCCESS"],
        ["garbage_collector_values_infer.ss",3,"-tp om --mem --ramify --infer-mem","mark","SUCCESS","sweep","SUCCESS","collect","SUCCESS"],
        ["llsortll.ss",6,"-tp om --mem --eps","overlaid_insert","SUCCESS","delete2","SUCCESS","insert2","SUCCESS",
        "get_tail","SUCCESS","insertion_sort","SUCCESS","id","SUCCESS"],
        ["infer_llsortll.ss",6,"-tp om --mem --eps --infer-mem","overlaid_insert","SUCCESS","delete2","SUCCESS","insert2","SUCCESS",
        "get_tail","SUCCESS","insertion_sort","SUCCESS","id","SUCCESS"],
        ["lltree.ss",1,"-tp om --mem","move_request","SUCCESS"],
        ["infer_lltree.ss",1,"-tp om --mem --infer-mem","move_request","SUCCESS"],
        ["lltree2.ss",1,"-tp om --mem --eps","move_request","SUCCESS"],
        ["infer_lltree2.ss",1,"-tp om --mem --eps --infer-mem","move_request","SUCCESS"],
        ["nodell.ss",6,"-tp om --mem --ramify","delete_cache","SUCCESS","delete","SUCCESS","add_L","SUCCESS",
        "caching","SUCCESS","add_in","SUCCESS","find","SUCCESS"],
        ["nodell_infer.ss",6,"-tp om --mem --ramify --infer-mem","delete_cache","SUCCESS","delete","SUCCESS","add_L","SUCCESS",
        "caching","SUCCESS","add_in","SUCCESS","find","SUCCESS"],
        ["pll.ss",2,"-tp om --mem","length","SUCCESS","sum","SUCCESS"],
        ["pll_ramify.ss",2,"-tp om --mem --ramify","length","SUCCESS","sum","SUCCESS"],
        ["pll_infer.ss",2,"-tp om --mem --infer-mem","length","SUCCESS","sum","SUCCESS"],
        ["pll_ramify_infer.ss",2,"-tp om --mem --ramify --infer-mem","length","SUCCESS","sum","SUCCESS"],
        ["doubly_circular_list.ss",4,"-tp om --mem","insert_node_dcll","SUCCESS","insert_lln","SUCCESS",
        "insert_llt","SUCCESS","insert_dcll","SUCCESS"],
        ["infer_doubly_circular_list.ss",4,"-tp om --mem --infer-mem","insert_node_dcll","SUCCESS","insert_lln","SUCCESS",
        "insert_llt","SUCCESS","insert_dcll","SUCCESS"],
        ["process_schedular.ss",4,"-tp om --mem","insert_process","SUCCESS","insert_rll","SUCCESS",
        "insert_pll","SUCCESS","insert_sll","SUCCESS"],
        ["process_schedular_ramify.ss",4,"-tp om --mem --ramify","insert_process","SUCCESS","insert_rll","SUCCESS",
        "insert_pll","SUCCESS","insert_sll","SUCCESS"],
        ["ramified-cells.ss",3,"--mem --ramify","ex0","SUCCESS","ex1","SUCCESS","mark","SUCCESS"],
        ["ramified-pairs.ss",1,"--mem --ramify","mark","SUCCESS"],
        ["jsvarstore.ss",1,"--mem --ramify","ex1","SUCCESS"],
        ["graph_spanning.ss",1,"-tp om --mem --ramify --eps","spanning","SUCCESS"],
        ["graph_spanning_infer.ss",1,"-tp om --mem --ramify --eps --infer-mem","spanning","SUCCESS"],
        ],
	"hip" =>[
#	["2-3trees.ss",4,"make_node","SUCCESS","insert_left","SUCCESS","insert_middle","SUCCESS","insert_right","SUCCESS","insert","SUCCESS"],
				["eps.ss",2,  "", "get_next","SUCCESS","get_next_next","SUCCESS"],
				["append.ss",1,  "", "append","SUCCESS"],
				["append-tail.ss",1,  "","append","SUCCESS"],
				["avl-bind.ss",9,  "", "height","SUCCESS", "rotate_left","SUCCESS", "rotate_right","SUCCESS", "get_max","SUCCESS", "rotate_double_left","SUCCESS",
					"rotate_double_right","SUCCESS","build_avl1","SUCCESS","build_avl2","SUCCESS","insert","SUCCESS",
					#"insert_inline","SUCCESS","remove_min","SUCCESS","delete","SUCCESS"
					],
				["avl.ss",10,	 "",  "height","SUCCESS","rotate_left","SUCCESS","rotate_right","SUCCESS",
								 "get_max","SUCCESS","rotate_double_left","SUCCESS","rotate_double_right","SUCCESS",
								 "build_avl1","SUCCESS","build_avl2","SUCCESS",
								 "insert","SUCCESS","insert_inline","SUCCESS",
								 #"remove_min","SUCCESS","delete","SUCCESS"
								 ],
				["avl-orig-2.ss",7,  "","height","SUCCESS","get_max","SUCCESS","insert","SUCCESS",
								 "double_left_child","SUCCESS","double_right_child","SUCCESS",
								 "rotate_left_child","SUCCESS", "rotate_right_child","SUCCESS",
								 #"f","SUCCESS","g","SUCCESS","h","SUCCESS","k","SUCCESS","test","SUCCESS",  "rotate_left_child_2","SUCCESS"
								 ],
				["avl-orig3.ss",7, "", "height","SUCCESS","get_max","SUCCESS",
				"insert","SUCCESS",	"double_left_child","SUCCESS",
				"double_right_child","SUCCESS",	"rotate_left_child","SUCCESS",
				"rotate_right_child","SUCCESS"],
			    ["bll.ss",2,  "", "insert","SUCCESS",
							"delete","SUCCESS"],
				["bubble.ss",4,  "", "id2","SUCCESS",
								"id3","SUCCESS",
								"bubble","SUCCESS",
								"bsort","SUCCESS",
								#"skip","SUCCESS"
								],
				["cll.ss",5,  "", "test","SUCCESS",
						 "insert","SUCCESS",
						 "count_rest","SUCCESS",
						 "count","SUCCESS",
						 "delete","SUCCESS"],
				["complete.ss",5, "", "maxim","SUCCESS",
								 "minim","SUCCESS",
								 "height","SUCCESS",
								 "min_height","SUCCESS",
								 "insert","SUCCESS"],
				["dll.ss",10, "", "insert","SUCCESS",
							 "delete","SUCCESS",
							 "delete1","SUCCESS",
							 "test_del","SUCCESS",
							 "test_del2","SUCCESS",
							 "test_fold","SUCCESS",
							 "append","SUCCESS",
							 "append1","SUCCESS",
							 "f1","SUCCESS",
							 "f2","SUCCESS",
							 #"append3","SUCCESS",
							 #"find_last","SUCCESS",
							 #"id1","SUCCESS"	
							 ],
				["heaps.ss",5, "", "insert","SUCCESS",
								#"insert1","SUCCESS",
								"deleteoneel","SUCCESS",
								#"deleteoneel1","SUCCESS",
								"deleteone","SUCCESS",
								#"deleteone1","SUCCESS",
								"ripple","SUCCESS",
								#"ripple1","SUCCESS",
								"deletemax","SUCCESS",
								#"deletemax1","SUCCESS"
								],
				["insertion.ss",2, "", "insert","SUCCESS",
								  "insertion_sort","SUCCESS"],
				["ll.ss",10, "", "append","SUCCESS",
						  "ret_first","SUCCESS",
						  "get_next","SUCCESS",
						  "set_next","SUCCESS",
						  "set_null","SUCCESS",
						  "get_next_next","SUCCESS",
						  "insert","SUCCESS",
						  "delete","SUCCESS",
						  #"delete1","SUCCESS",
						  "create_list","SUCCESS",
						  "reverse","SUCCESS",
						  #"reverse1","SUCCESS",
						  #"test","SUCCESS"
						  ],
				["merge.ss",5, "", "count","SUCCESS",
							  "split_func","SUCCESS",
							  #"div2","SUCCESS",
							  "merge_sort","SUCCESS",
							  "merge","SUCCESS",
							  "insert","SUCCESS",
							  #"merge_sort_1","SUCCESS"
							  ],
				["perfect.ss",5, "", "simple_insert","SUCCESS",
								"create","SUCCESS",
								"maxim","SUCCESS",
								"height","SUCCESS",
								"insert","SUCCESS"],
				["qsort.ss",3, "", "partition","SUCCESS",
								"append_bll","SUCCESS",
								"qsort","SUCCESS"],
        # goes into a loop with combined-lemma-heuristics still
				#["qsort-tail.ss",2, "", "qsort","SUCCESS","partition1","SUCCESS"],
				["selection.ss",3, "", "find_min","SUCCESS",
								"delete_min","SUCCESS",
								"selection_sort","SUCCESS"],
				["sll.ss",6, "", "insert","SUCCESS",
							"insert2","SUCCESS",
							"delete","SUCCESS",
							"get_tail","SUCCESS",
							"insertion_sort","SUCCESS",
							"id","SUCCESS"],
				["trees.ss",6, "", "append","SUCCESS",
								#"append1","SUCCESS",
								"count","SUCCESS",
								"flatten","SUCCESS",
								#"flatten1","SUCCESS",
								"insert","SUCCESS",
								#"insert1","SUCCESS",
								"remove_min","SUCCESS",
								#"remove_min1","SUCCESS",
								"delete","SUCCESS",
								#"delete1","SUCCESS"
								],
				["rb.ss",18, "", "rotate_case_3","SUCCESS",
							"case_2","SUCCESS",
							"rotate_case_3r","SUCCESS",
							"case_2r","SUCCESS",
							"is_red","SUCCESS",
							"is_black","SUCCESS",
							"del_6","SUCCESS",
							"del_6r","SUCCESS",
							"del_5","SUCCESS",
							"del_5r","SUCCESS",
							"del_4","SUCCESS",
							"del_4r","SUCCESS",
							"del_3","SUCCESS",
							"del_3r","SUCCESS",
							"del_2","SUCCESS",
							#"del_2r","SUCCESS",
							#"bh","SUCCESS",
							"remove_min","SUCCESS", #fixed duplicated false
							"del","SUCCESS",
							#"test_insert","SUCCESS",
							#"node_error","SUCCESS",
							"insert","SUCCESS"],
		        ["global1.ss",1, "", "increase","SUCCESS"],
                ["global2.ss",1, "", "increase","SUCCESS"],
                ["global3.ss",2, "", "increase","SUCCESS",
                                "increase_n","SUCCESS"],
                ["global4.ss",2, "", "increase_n","SUCCESS",
                                "main", "SUCCESS"],
                ["global5.ss",2, "", "increase","SUCCESS",
                                "decrease","SUCCESS"],
		        ["global-ll.ss",5, "", "insert_rec","SUCCESS",
                                  "delete_last_rec","SUCCESS",
                                  "insert","SUCCESS",
                                  "delete_last","SUCCESS",
                                  "main","SUCCESS"],
		        ["global-mutual-rec.ss",3, "", "decrease1","SUCCESS",
                                          "decrease2","SUCCESS",
										  "main","SUCCESS"],
				["classic/classic1.ss",2, "", "foo1", "SUCCESS", "foo2", "SUCCESS"],
				["classic/classic1.ss",2, "--classic", "foo1", "FAIL", "foo2", "SUCCESS"],
				["classic/classic1a.ss",2, "", "foo1", "SUCCESS", "foo2", "SUCCESS"],
				["classic/classic1a.ss",2, "--classic", "foo1", "SUCCESS", "foo2", "FAIL"],
				["classic/classic2.ss",2, "", "foo1", "FAIL", "foo2", "SUCCESS"],
				["classic/classic2a.ss",2, "", "foo1", "SUCCESS", "foo2", "FAIL"],
				["classic/classic3.ss",2, "", "foo1", "SUCCESS", "foo2", "SUCCESS"],
				["classic/classic3a.ss",2, "", "foo1", "SUCCESS", "foo2", "SUCCESS"],
				["../../modular_examples/dll-modular.ss",11, "--overeps", 
					"append", "SUCCESS", "append1", "SUCCESS", "append2", "SUCCESS",
					"delete", "SUCCESS", "delete1", "SUCCESS", "f1", "SUCCESS",
					"f2", "SUCCESS", "insert", "SUCCESS", "test_del", "SUCCESS",
					"test_del2", "SUCCESS", "test_fold", "SUCCESS"],
				# ["../../modular_examples/dll-modular.ss",11, "--overeps", 
				# 	"append", "SUCCESS", "append1", "SUCCESS", "append2", "SUCCESS",
				# 	"delete", "SUCCESS", "delete1", "SUCCESS", "f1", "SUCCESS",
				# 	"f2", "SUCCESS", "insert", "SUCCESS", "test_del", "SUCCESS",
				# 	"test_del2", "SUCCESS", "test_fold", "SUCCESS"],
				["../../modular_examples/selection-modular.ss",3, "--overeps --lda", 
					"delete_min", "SUCCESS", "find_min", "SUCCESS", "selection_sort", "SUCCESS"],
				["../../modular_examples/qsort-modular.ss",3, "--overeps --lda", 
					"append_bll", "SUCCESS", "partition", "SUCCESS", "qsort", "SUCCESS"],				
				#["../../modular_examples/2-3trees-modular.ss",5, "--overeps", 
				#	"insert_left", "SUCCESS", "height", "SUCCESS", "minim", "SUCCESS",
				#	"min_height", "SUCCESS", "insert", "SUCCESS"],
				],	
	"hip_long_mod" => [["../../modular_examples/sorted_list_modular.ss",8, "--overeps -tp om", 
					"insert_first", "SUCCESS", "copy", "SUCCESS", "delete", "SUCCESS",
					"double_reverse", "SUCCESS", "insert", "SUCCESS", "insert_last", "SUCCESS",
					"merge", "SUCCESS", "reverse","SUCCESS"],
					["../../modular_examples/complete-modular.ss",5, "--overeps", 
					"maxim", "SUCCESS", "height", "SUCCESS", "minim", "SUCCESS",
					"min_height", "SUCCESS", "insert", "SUCCESS"],
					#["../../modular_examples/avl_modular.ss",8, "--overeps -tp om", 
					#"height", "SUCCESS", "diff_h_by_1", "SUCCESS", "diff_h_by_2", "SUCCESS",
					#"eq_h", "SUCCESS", "get_max", "SUCCESS", "get_max_height_add1", "SUCCESS",
					#"less_h", "SUCCESS", "remove_min_add","SUCCESS"],
					],	
	"hip_barr" => [
		["../tree_shares/thesis/video_ex1_th3.ss",6, "--eps --dis-field-ann --dis-precise-xpure -perm dperm", 
                                "th1_loop","SUCCESS","th1","SUCCESS",
								"th2_loop","SUCCESS","th2","SUCCESS",
								"th3_loop","SUCCESS","th3","SUCCESS"],
		["../tree_shares/thesis/SIMD_ex1_v2_th3.ss",10, "--eps --dis-field-ann --dis-precise-xpure -perm dperm", 
                                "controll","SUCCESS","control","SUCCESS",
								"thl1","SUCCESS","th1","SUCCESS",
								"thl2","SUCCESS","th2","SUCCESS",
								"thl3","SUCCESS","th3","SUCCESS",
								"thl4","SUCCESS","th4","SUCCESS"],						
		["../tree_shares/thesis/SIMD_ex1_th1.ss",6, "--eps --dis-field-ann --dis-precise-xpure -perm dperm", 
                                "controll","SUCCESS","control","SUCCESS",
								"thl1","SUCCESS","th1","SUCCESS",
								"thl2","SUCCESS","th2","SUCCESS"],
		["../tree_shares/thesis/PIPE_ex1_th5.ss",6, "--eps --dis-field-ann --dis-precise-xpure -perm dperm", 
                                "controll","SUCCESS","thl5","SUCCESS",
								"thl1","SUCCESS","thl2","SUCCESS",
								"thl3","SUCCESS","thl4","SUCCESS"],
		["../tree_shares/thesis/MIXED_ex1_th4.ss",15, "--eps --dis-field-ann --dis-precise-xpure -perm dperm", 
                                "ctl12","SUCCESS","ctl11","SUCCESS",
								"starterc","SUCCESS","thl12","SUCCESS",
								"thl22","SUCCESS","thl21","SUCCESS",
								"thl11","SUCCESS","startert1","SUCCESS",
								"startert2","SUCCESS","thl32","SUCCESS",
								"thl31","SUCCESS","startert3","SUCCESS",
								"thl42","SUCCESS","thl41","SUCCESS",
								"startert4","SUCCESS",
								],
		["../tree_shares/thesis/MISD_ex2_th5.ss",12, "--eps --dis-field-ann --dis-precise-xpure -perm dperm", 
                                "controll","SUCCESS","control","SUCCESS",
								"thl","SUCCESS","th","SUCCESS",
								"thl2","SUCCESS","th2","SUCCESS",
								"thl3","SUCCESS","th3","SUCCESS",
								"thl4","SUCCESS","th4","SUCCESS",
								"thl5","SUCCESS","th5","SUCCESS",
								],		
		["../tree_shares/thesis/MISD_ex1_th5.ss",4, "--eps --dis-field-ann --dis-precise-xpure -perm dperm", 
                                "controll","SUCCESS","control","SUCCESS",
								"thl","SUCCESS","th","SUCCESS"
								],	
		["../tree_shares/thesis/barrier-weak.ss",4, "--eps --dis-field-ann --dis-precise-xpure -perm dperm", 
                                "th1_loop","SUCCESS","th1","SUCCESS",
								"th2_loop","SUCCESS","th2","SUCCESS"
								],	
		["../tree_shares/thesis/barrier-strong.ss",4, "--eps --dis-field-ann --dis-precise-xpure -perm dperm", 
                                "th1_loop","SUCCESS","th1","SUCCESS",
								"th2_loop","SUCCESS","th2","SUCCESS"
								],	
		["../tree_shares/thesis/barrier-paper.ss",4, "--eps --dis-field-ann --dis-precise-xpure -perm dperm", 
                                "th1_loop","SUCCESS","th1","SUCCESS",
								"th2_loop","SUCCESS","th2","SUCCESS"
								],	
	],
	"hip_vperm" =>[
				["vperm/alt_threading.ss",2,  "--ann-vp", 
                                "increment","SUCCESS",
                                "main","SUCCESS"
								],
				["vperm/fibonacci.ss",2,  "--ann-vp -tp z3 -perm none --dis-ls dis--locklevel", 
                                "seq_fib","SUCCESS",
                                "para_fib2","SUCCESS"
								],
				["vperm/global-var-norace.ss",2,  "--ann-vp --dis-pgbv", 
                                "inc","SUCCESS",
                                "func","SUCCESS"
								],
				["vperm/global-var-race.ss",2,  "--ann-vp --dis-pgbv", 
                                "inc","SUCCESS",
                                "func","FAIL"
								],
				["vperm/mergesort.ss",5,  "--ann-vp", 
                                "count","SUCCESS",
                                "split_func","SUCCESS",
                                "merge","SUCCESS",
                                "insert","SUCCESS",
                                "parallel_merge_sort2","SUCCESS"
								],
				["vperm/passive_stack_race.ss",2,  "--ann-vp", 
                                "assign","SUCCESS",
                                "stack_race","FAIL"
								],
				["vperm/stack_race.ss",2,  "--ann-vp", 
                                "assign","SUCCESS",
                                "stack_race","FAIL"
								],
				["vperm/quicksort.ss",3,  "--ann-vp", 
                                "partition","SUCCESS",
                                "append_bll","SUCCESS",
                                "para_qsort2","SUCCESS",
								],
				["vperm/task_decompose.ss",4,  "--ann-vp", 
                                "inc","SUCCESS",
                                "creator","SUCCESS",
                                "joiner","SUCCESS",
                                "main","SUCCESS"
								],
				["vperm/threads.ss",6,  "--ann-vp", 
                                "make_tree","SUCCESS",
                                "tree_compute_sum_facs","SUCCESS",
                                "summator","SUCCESS",
                                "start_sum_thread","SUCCESS",
                                "join_sum_thread","SUCCESS",
                                "main","SUCCESS"
								],
				["vperm/tree_count.ss",1,  "--ann-vp", 
                                "parallelCount2","SUCCESS"
								],
				["vperm/tree_search.ss",1,  "--ann-vp -tp mona -perm none", 
                                "para_search2","SUCCESS"
								],
				["vperm/vperm_check.ss",6,  "--ann-vp", 
                                "inc","SUCCESS",
                                "incCell","SUCCESS",
                                "test1","FAIL",
                                "test2","FAIL",
                                "test3","FAIL",
                                "test4","FAIL"
								],
				["vperm/vperm_simple.ss",4,  "--ann-vp", 
                                "foo","SUCCESS",
                                "f","SUCCESS",
                                "foo2","SUCCESS",
                                "f2","SUCCESS"
								]
             ],
	"parahip" =>[
        ### GENERAL TESTS
				["parahip/simple.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/forkjoin.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/cell.ss",2,  "--en-para -tp parahip", 
                                "test","SUCCESS",
                                "test1","FAIL-1"
								],
				["parahip/cell4.ss",2,  "--en-para -tp parahip", 
                                "inc","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/cell-lock-vperm.ss",2,  "--en-para -tp parahip", 
                                "testCell","SUCCESS",
                                "testVar","FAIL-1"
								],
				["parahip/cell-extreme-cases.ss",4,  "--en-para -tp parahip", 
                                "test","FAIL-2",
                                "test2","FAIL-2",
                                "test3","FAIL-1",
                                "test4","FAIL-1"
								],
				["parahip/ls-bind.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/ls-waitlevel2.ss",3,  "--en-para -tp parahip", 
                                "func2","SUCCESS",
                                "func3","SUCCESS",
                                "func4","SUCCESS"
								],
        ### DEADLOCKED and DEADLOCK-FREE scenarios
				["parahip/double-acquire.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","FAIL-2"
								],
				["parahip/no-deadlock1.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/no-deadlock2.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/no-deadlock3.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/deadlock1.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","FAIL-1"
								],
				["parahip/deadlock2.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","FAIL-1"
								],
				["parahip/deadlock3.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","FAIL-1"
								],
				["parahip/disj-no-deadlock1.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/disj-no-deadlock2.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/disj-no-deadlock3.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/disj-deadlock.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","FAIL-1"
								],
				["parahip/ordered-locking.ss",2,  "--en-para -tp parahip", 
                                "func","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/unordered-locking.ss",2,  "--en-para -tp parahip", 
                                "func","FAIL-1",
                                "main","SUCCESS"
								],
        ### FUNTIONAL CORRECTNESS
				["parahip/multicast.ss",2,  "--en-para -tp parahip", 
                                "initialize","SUCCESS",
                                "thread","SUCCESS"
								],
				["parahip/oracle.ss",2,  "--en-para -tp parahip", 
                                "thread","SUCCESS",
                 #NOTE: loop calls' naming could be varied
#                                "f_r_767_hip_parahip_oracle_ss_54_2","SUCCESS",
#                                "f_r_689_hip_parahip_oracle_ss_80_4","SUCCESS",
                                "main","SUCCESS"
								],
# slow in parahip/owicki-gries.ss due to search. Could modify search heuristics.
				["parahip/owicki-gries.ss",3,  "--en-para -tp parahip", 
                                "incrementor2","SUCCESS",
                                "incrementor1","SUCCESS",
                                "main","SUCCESS"
								],
				["parahip/fibonacci.ss",2,  "--en-para -tp parahip", 
                                "seq_fib","SUCCESS",
                                "para_fib","SUCCESS"
								],
				["parahip/create_and_acquire.ss",1,  "--en-para -tp parahip --dis-locklevel", 
                                "create_and_acquire","SUCCESS"
								]
        ### END parahip
             ],
	"bags" =>[
        ["avl-all-1.ss", 8, "", "remove_min", "SUCCESS", "rotate_double_right", "SUCCESS", "rotate_double_left", "SUCCESS", 
         "get_max", "SUCCESS", "rotate_right", "SUCCESS", "rotate_left", "SUCCESS", "height", "SUCCESS"],
        ["avl-all.ss", 11, "", "delete", "SUCCESS", "delete_top", "SUCCESS", "remove_min", "SUCCESS","remove_max_add", "SUCCESS", ,"remove_min_add","SUCCESS",
         "insert", "SUCCESS", "rotate_double_left",  "SUCCESS", "get_max", "SUCCESS", "rotate_right", "SUCCESS", "rotate_left", "SUCCESS", "height", "SUCCESS"],
        ["avl-modular-2.ss", 16, "", "delete", "SUCCESS", "delete_top", "SUCCESS", "remove_min", "SUCCESS", "remove_max_add", "SUCCESS", "remove_min_add", "SUCCESS", 
         "insert", "SUCCESS", "rotate_double_right", "SUCCESS", "rotate_double_left", "SUCCESS", "get_max", "SUCCESS", "rotate_right", "SUCCESS", 
         "rotate_left", "SUCCESS", "diff_h_by_2", "SUCCESS", "diff_h_by_1", "SUCCESS", "eq_h", "SUCCESS", "less_h", "SUCCESS", "get_max_height_add1", "SUCCESS",
         "height","SUCCESS"],
        ["avl-modular-3.ss", 11, "", "delete", "SUCCESS", "delete_top", "SUCCESS", "remove_min", "SUCCESS","remove_max_add", "SUCCESS", ,"remove_min_add","SUCCESS",
         "insert", "SUCCESS", "rotate_double_left",  "SUCCESS", "get_max", "SUCCESS", "rotate_right", "SUCCESS", "rotate_left", "SUCCESS", "height", "SUCCESS"],
        ["avl-modular-2.ss", 17, "", "delete", "SUCCESS", "delete_top", "SUCCESS", "remove_min", "SUCCESS", "remove_max_add", "SUCCESS", "remove_min_add", "SUCCESS", 
         "insert", "SUCCESS", "rotate_double_right", "SUCCESS", "rotate_double_left", "SUCCESS", "get_max", "SUCCESS", "rotate_right", "SUCCESS", 
         "rotate_left", "SUCCESS", "diff_h_by_2", "SUCCESS", "diff_h_by_1", "SUCCESS", "eq_h", "SUCCESS", "less_h", "SUCCESS", "get_max_height_add1", "SUCCESS",
         "height","SUCCESS"],
        ["avl-modular-hei.ss", 14, "", "delete", "SUCCESS", "delete_top", "SUCCESS", "remove_min", "SUCCESS", "remove_max_add", "SUCCESS", "remove_min_add", "SUCCESS", 
         "insert", "SUCCESS", "rotate_double_right", "SUCCESS", "rotate_double_left", "SUCCESS", "get_max", "SUCCESS", "rotate_right", "SUCCESS", 
         "rotate_left", "SUCCESS", "rotate_right2", "SUCCESS", "rotate_left2", "SUCCESS", "height","SUCCESS"],
        ["avl-modular-new3.ss", 18, "", "delete", "SUCCESS", "delete_top", "SUCCESS", "remove_min", "SUCCESS", "remove_max_add", "SUCCESS", "remove_min_add", "SUCCESS", 
         "insert", "SUCCESS", "is_mem", "SUCCESS","rotate_double_right", "SUCCESS", "rotate_double_left", "SUCCESS", "get_max", "SUCCESS", "rotate_right", "SUCCESS", 
         "rotate_left", "SUCCESS", "diff_h_by_2", "SUCCESS", "diff_h_by_1", "SUCCESS", "eq_h", "SUCCESS", "less_h", "SUCCESS", "get_max_height_add1", "SUCCESS",
         "height","SUCCESS"],
        ["avl-modular-set.ss", 3 ,"", "delete", "SUCCESS", "delete_top", "SUCCESS", "remove_min", "SUCCESS"],
        ["avl-modular-siz.ss", 3 , "", "delete", "SUCCESS", "delete_top", "SUCCESS", "remove_min", "SUCCESS"],
        ["avl-modular.ss", 12, "", "delete", "SUCCESS", "delete_top", "SUCCESS", "remove_min", "SUCCESS", "remove_max_add", "SUCCESS", "remove_min_add", "SUCCESS", 
         "insert", "SUCCESS", "rotate_double_right", "SUCCESS", "rotate_double_left", "SUCCESS", "get_max", "SUCCESS", "rotate_right", "SUCCESS", 
         "rotate_left", "SUCCESS", "height","SUCCESS"],
        ["avl.scp.ss", 19 ,"", "delete", "SUCCESS", "remove_min", "SUCCESS", "insert_inline1", "SUCCESS", "insert_inline", "SUCCESS", "insert1", "SUCCESS", "insert", "SUCCESS",
         "build_avl2", "SUCCESS", "build_avl1", "SUCCESS", "rotate_double_right1", "SUCCESS", "rotate_double_right", "SUCCESS", "rotate_double_left1", "SUCCESS",
         "rotate_double_left", "SUCCESS", "get_max", "SUCCESS", "rotate_right1", "SUCCESS", "rotate_right", "SUCCESS", "rotate_left1", "SUCCESS", "rotate_left", "SUCCESS",
         "height1", "SUCCESS", "height", "SUCCESS"],
        ["avl.ss",  8, "", "insert_inline", "SUCCESS",  "insert", "SUCCESS", "rotate_double_right", "SUCCESS", "rotate_double_left", "SUCCESS", "get_max", "SUCCESS", 
         "rotate_right", "SUCCESS", "rotate_left", "SUCCESS","height", "SUCCESS"],
        ["bubble.ss", 3, "", "bsort1", "SUCCESS", "bubble1", "SUCCESS", "id1", "SUCCESS"],
        ["cll.ss", 4, "", "delete2", "SUCCESS", "delete", "SUCCESS", "count", "SUCCESS", "count_rest", "SUCCESS"],
        ["dll.ss", 2, "", "append", "SUCCESS", "insert", "SUCCESS"],
        ["insertion.ss", 3, "", "insertion_sort", "SUCCESS", "delete", "SUCCESS", "insert", "SUCCESS"],
        ["ll.ss", 4, "", "reverse1", "SUCCESS", "delete1", "SUCCESS", "insert", "SUCCESS", "append", "SUCCESS"],
        ["merge-modular.ss", 5, "", "insert1", "SUCCESS", "merge1", "SUCCESS", "merge_sort1", "SUCCESS", "split1", "SUCCESS", "count1", "SUCCESS"],
        ["merge.ss", 5, "", "insert1", "SUCCESS", "merge1", "SUCCESS", "merge_sort1", "SUCCESS", "split1", "SUCCESS", "count1", "SUCCESS"],
        ["qsort.ss", 3, "", "qsort1", "SUCCESS", "append_bll1", "SUCCESS", "partition1", "SUCCESS"],
        ["rb_bags.ss", 19, "", "insert_1", "SUCCESS", "del_1", "SUCCESS", "remove_min_1", "SUCCESS", "del_2r_1", "SUCCESS", "del_2_1", "SUCCESS", "del_3r_1", "SUCCESS",
         "del_3_1", "SUCCESS", "del_4r_1", "SUCCESS", "del_4_1", "SUCCESS", "del_5r_1", "SUCCESS", "del_5_1", "SUCCESS", "del_6r_1", "SUCCESS", "del_6_1", "SUCCESS",
         "is_black_1", "SUCCESS", "is_red_1", "SUCCESS", "case_2r_1", "SUCCESS", "rotate_case_3r_1", "SUCCESS", "case_2_1", "SUCCESS", "rotate_case_3_1", "SUCCESS"],
        ["rb.scp.ss", 38, "", "insert_1", "SUCCESS", "insert", "SUCCESS", "del_1", "SUCCESS", "del", "SUCCESS", "remove_min_1", "SUCCESS", "remove_min", "SUCCESS", 
         "del_2r_1", "SUCCESS", "del_2r", "SUCCESS", "del_2_1", "SUCCESS", "del_2", "SUCCESS", "del_3r_1", "SUCCESS", "del_3r", "SUCCESS", "del_3_1", "SUCCESS", 
         "del_3", "SUCCESS", "del_4r_1", "SUCCESS", "del_4r", "SUCCESS", "del_4_1", "SUCCESS", "del_4", "SUCCESS", "del_5r_1", "SUCCESS", "del_5r", "SUCCESS", 
         "del_5_1", "SUCCESS", "del_5", "SUCCESS", "del_6r_1", "SUCCESS", "del_6r", "SUCCESS", "del_6_1", "SUCCESS", "del_6", "SUCCESS", "is_black_1", "SUCCESS", 
         "is_black", "SUCCESS", "is_red_1", "SUCCESS", "is_red", "SUCCESS", "case_2r_1", "SUCCESS", "case_2r", "SUCCESS", "rotate_case_3r_1", "SUCCESS", 
         "rotate_case_3r", "SUCCESS", "case_2_1", "SUCCESS", "case_2", "SUCCESS", "rotate_case_3_1", "SUCCESS", "rotate_case_3", "SUCCESS"],
        ["selection.ss", 3, "", "selection_sort", "SUCCESS", "delete_min", "SUCCESS", "find_min", "SUCCESS"],
        ["trees.ss", 5, "", "delete1", "SUCCESS", "remove_min1", "SUCCESS", "insert1", "SUCCESS", "flatten1", "SUCCESS", "append1", "SUCCESS"]],
    "term" => [
        ["e1.ss", 1, "", "loop", "SUCCESS"],
        ["ex1.ss", 2, "", "length", "SUCCESS", "app2", "SUCCESS"],
        ["ex10.ss", 1, "", "loop", "SUCCESS"],
        ["ex11.ss", 1, "", "bsearch", "SUCCESS"],
				#["ex12.ss", 1, "-tp redlog", "loop", "SUCCESS"],
				#["ex13.ss", 1, "", "loop", "SUCCESS"],
				#["ex14.ss", 1, "", "loop", "SUCCESS"],
        ["ex15.ss", 2, "", "loop", "SUCCESS", "f", "SUCCESS"],
        ["ex16.ss", 1, "", "loop", "SUCCESS"],
        ["ex2.ss", 1, "", "loop", "SUCCESS"],
        ["ex3.ss", 1, "", "loop", "SUCCESS"],
        ["ex4.ss", 1, "", "inc_loop", "SUCCESS"],
        ["ex5.ss", 1, "", "foo", "SUCCESS"],
        ["ex6.ss", 1, "", "Ack", "SUCCESS"],
        ["ex7.ss", 3, "", "loop_aux1", "SUCCESS", "loop_aux", "SUCCESS", "loop", "SUCCESS"],
        ["ex8.ss", 2, "", "loop2", "SUCCESS", "loop", "SUCCESS"],
        ["ex9.ss", 1, "", "loop", "SUCCESS"],
        ["mutual.ss", 2, "", "g", "SUCCESS", "f", "SUCCESS"],
				["benchs/lit/cav08-1.ss", 1, "", "loop", "SUCCESS"],
				["benchs/lit/cav08-2.ss", 1, "", "loop", "SUCCESS"],
				["benchs/lit/cav08-3.ss", 1, "", "loop", "SUCCESS"],
				["benchs/lit/cav08-4.ss", 1, "", "loop", "SUCCESS"],
				["benchs/lit/cav08-5.ss", 2, "", "loop", "SUCCESS", "f", "SUCCESS"],
				["benchs/lit/cav08-6.ss", 1, "", "gcd", "SUCCESS"],
				["benchs/lit/dijkstra76-1.ss", 1, "", "loop", "SUCCESS"],
				["benchs/lit/dijkstra76-2.ss", 1, "", "loop", "SUCCESS"],
				["benchs/lit/dijkstra76-3.ss", 1, "", "loop", "SUCCESS"],
        # -tp z3 caused timeouts below
				#["benchs/lit/leap-year-bug-zune.ss", 2, "-tp z3", "ConvertDays", "SUCCESS", "loop", "SUCCESS"],
				["benchs/lit/pldi06-1.ss", 1, "", "loop", "SUCCESS"],
				["benchs/lit/pldi06-2.ss", 3, "", "main", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/lit/pldi06-3.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/lit/pldi06-4.ss", 3, "", "main", "SUCCESS", "loop", "SUCCESS", "loop_aux", "SUCCESS"],
				["benchs/lit/pldi06-5.ss", 1, "", "Ack", "SUCCESS"],
				["benchs/lit/popl07-1.ss", 3, "", "loop_1", "SUCCESS", "loop_2", "SUCCESS", "loop_3", "SUCCESS"],
				["benchs/lit/popl07-2.ss", 1, "", "loop", "SUCCESS"],
				["benchs/lit/sas05.ss", 2, "", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/lit/sas10-1.ss", 3, "", "f", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/lit/sas10-2.ss", 2, "", "foo", "SUCCESS", "loop", "SUCCESS"],
				["benchs/lit/sas10-2a.ss", 2, "", "foo", "SUCCESS", "loop", "SUCCESS"],
				["benchs/lit/sas10-3.ss", 3, "", "main", "SUCCESS", "foo", "SUCCESS", "loop", "SUCCESS"],
				["benchs/lit/vcc-1.ss", 2, "", "f", "SUCCESS", "g", "SUCCESS"],
				["benchs/lit/vmcai05-1a.ss", 1, "", "loop", "SUCCESS"],
				["benchs/lit/vmcai05-1b.ss", 1, "-tp redlog", "loop", "SUCCESS"],
				["benchs/key/AlternatingIncr.ss", 1, "", "increase", "SUCCESS"],
				["benchs/key/AlternDiv-invalid-1.ss", 1, "-tp redlog", "loop", "SUCCESS"],
				["benchs/key/AlternDiv.ss", 1, "-tp redlog", "loop", "SUCCESS"],
				["benchs/key/AlternDivWidening.ss", 2, "-tp redlog", "loop", "SUCCESS", "loop_aux", "SUCCESS"],
				["benchs/key/AlternDivWide.ss", 2, "", "loop", "SUCCESS", "loop_aux", "SUCCESS"],
				["benchs/key/AlternKonv.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Collatz.ss", 1, "", "collatz", "SUCCESS"],
				["benchs/key/ComplInterv2.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/ComplInterv3.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/ComplInterv.ss", 1, "-tp z3", "loop", "SUCCESS"],
				["benchs/key/ComplxStruc-may.ss", 1, "", "complxStruc", "SUCCESS"], #MayLoop
				["benchs/key/ComplxStruc2.ss", 2, "", "loop", "SUCCESS", "complxStruc", "SUCCESS"],
				["benchs/key/ConvLower.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Cousot.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/DoubleNeg.ss", 1, "-tp redlog", "loop", "SUCCESS"],
				["benchs/key/Even.ss", 2, "", "even", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/Ex01.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Ex02.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Ex03.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Ex04.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Ex05.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Ex06.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Ex07.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Ex08.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/Ex09.ss", 2, "", "half", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/Fibonacci.ss", 2, "", "fib", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/Flip2.ss", 1, "", "flip", "SUCCESS"],
				["benchs/key/Flip3.ss", 1, "", "flip", "SUCCESS"],
				["benchs/key/Flip.ss", 1, "", "flip", "SUCCESS"],
				["benchs/key/Gauss.ss", 2, "", "sum", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/Gcd-may.ss", 1, "", "gcd", "SUCCESS"], #MayLoop
				["benchs/key/Lcm.ss", 2, "", "lcm", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/Marbie1.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Marbie2.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/Middle.ss", 1, "", "middle", "SUCCESS"],
				["benchs/key/MirrorIntervSim.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/MirrorInterv.ss", 2, "", "mirrorInterv", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/ModuloLower.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/ModuloUp.ss", 2, "-tp redlog", "up", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/Narrowing.ss", 2, "", "narrowing", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/NarrowKonv.ss", 2, "", "narrowKonv", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/NegPos.ss", 1, "-tp redlog", "loop", "SUCCESS"],
				["benchs/key/Plait-may.ss", 1, "", "plait", "SUCCESS"], #MayLoop
				["benchs/key/Sunset.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/TrueDiv.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/TwoFloatInterv.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/UpAndDownIneq.ss", 2, "", "upAndDown", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/UpAndDown.ss", 2, "", "upAndDown", "SUCCESS", "loop", "SUCCESS"],
				["benchs/key/WhileBreak.ss", 1, "", "loop", "SUCCESS"],
				["benchs/key/WhileDecr.ss", 1, "", "decrease", "SUCCESS"],
				["benchs/key/WhileIncrPart.ss", 1, "", "increase", "SUCCESS"],
				["benchs/key/WhileIncr.ss", 1, "", "increase", "SUCCESS"],
				["benchs/key/WhileNestedOffset.ss", 3, "", "increase", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/key/WhileNested.ss", 3, "", "increase", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/key/WhilePart.ss", 1, "", "increase", "SUCCESS"],
				["benchs/key/WhileSingle.ss", 1, "", "increase", "SUCCESS"],
				["benchs/key/WhileSum.ss", 1, "", "increase", "SUCCESS"],
				["benchs/key/WhileTrue.ss", 1, "", "endless", "SUCCESS"],
				["benchs/aprove/Aprove_09/DivMinus2.ss", 3, "", "main", "SUCCESS", "div", "SUCCESS", "minus", "SUCCESS"],
				["benchs/aprove/Aprove_09/DivMinus.ss", 2, "", "main", "SUCCESS", "div", "SUCCESS"],
				["benchs/aprove/Aprove_09/DivWithoutMinus.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Aprove_09/Duplicate.ss", 2, "", "main", "SUCCESS", "round", "SUCCESS"],
				["benchs/aprove/Aprove_09/GCD2.ss", 2, "-tp redlog", "main", "SUCCESS", "gcd", "SUCCESS"],
				["benchs/aprove/Aprove_09/GCD3.ss", 3, "", "main", "SUCCESS", "gcd", "SUCCESS", "mod", "SUCCESS"],
				["benchs/aprove/Aprove_09/GCD4.ss", 3, "", "main", "SUCCESS", "gcd", "SUCCESS", "mod", "SUCCESS"],
				["benchs/aprove/Aprove_09/GCD5.ss", 2, "-tp redlog", "main", "SUCCESS", "gcd", "SUCCESS"],
				["benchs/aprove/Aprove_09/GCD.ss", 2, "-tp redlog", "main", "SUCCESS", "gcd", "SUCCESS"],
				["benchs/aprove/Aprove_09/LogAG.ss", 3, "", "main", "SUCCESS", "half", "SUCCESS", "log", "SUCCESS"],
				["benchs/aprove/Aprove_09/LogBuiltIn.ss", 2, "", "main", "SUCCESS", "log", "SUCCESS"],
				["benchs/aprove/Aprove_09/LogIterative.ss", 2, "-tp redlog", "main", "SUCCESS", "log", "SUCCESS"],
				["benchs/aprove/Aprove_09/LogMult.ss", 2, "-tp redlog", "main", "SUCCESS", "log", "SUCCESS"],
				["benchs/aprove/Aprove_09/Log.ss", 3, "", "main", "SUCCESS", "half", "SUCCESS", "log", "SUCCESS"],
				["benchs/aprove/Aprove_09/McCarthyIterative-may.ss", 1, "", "mcCarthy", "SUCCESS"], #MayLoop
				["benchs/aprove/Aprove_09/McCarthyRec.ss", 1, "", "mcCarthy", "SUCCESS"],
				["benchs/aprove/Aprove_09/MinusBuiltIn.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Aprove_09/MinusMin.ss", 2, "", "main", "SUCCESS", "mn", "SUCCESS"],
				["benchs/aprove/Aprove_09/MinusUserDefined.ss", 2, "", "main", "SUCCESS", "gt", "SUCCESS"],
				["benchs/aprove/Aprove_09/Mod.ss", 3, "", "main", "SUCCESS", "mod", "SUCCESS", "minus", "SUCCESS"],
				["benchs/aprove/Aprove_09/PlusSwap.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/Aprove_09/Round3.ss", 1, "", "main", "SUCCESS"],
		###############################################(1)
				["benchs/aprove/AProVE_10/AG313.ss", 2, "", "main", "SUCCESS", "quot", "SUCCESS"],
		###############################################(2)
				["benchs/aprove/AProVE_11_iterative/RetValRec.ss", 3, "", "main", "SUCCESS", "ret", "SUCCESS", "test", "SUCCESS"],
				["benchs/aprove/AProVE_11_iterative/RetVal.ss", 3, "", "main", "SUCCESS", "ret", "SUCCESS", "test", "SUCCESS"],
		###############################################(2)
				["benchs/aprove/AProVE11NO/LoopingNonTerm.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/AProVE11NO/NonPeriodicNonTerm2.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
		###############################################(13)
				["benchs/aprove/BOG_RTA_11/Avg.ss", 1, "", "avg", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/EqUserDefRec.ss", 2, "", "main", "SUCCESS", "eq", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/Fibonacci.ss", 2, "", "main", "SUCCESS", "fib", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/LeUserDefRec.ss", 2, "", "main", "SUCCESS", "le", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/LogRecursive.ss", 2, "-tp redlog", "main", "SUCCESS", "log", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/Nest.ss", 2, "", "main", "SUCCESS", "nest", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/TerminatiorRec01.ss", 3, "", "main", "SUCCESS", "f", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/TerminatiorRec02.ss", 1, "-tp redlog", "fact", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/TerminatiorRec03.ss", 1, "", "f", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/TerminatiorRec04-modified.ss", 3, "", "main", "SUCCESS", "f", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/TerminatiorRec04.ss", 3, "", "main", "SUCCESS", "f", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/TimesPlusUserDef.ss", 3, "", "main", "SUCCESS", "times", "SUCCESS", "plus", "SUCCESS"],
				["benchs/aprove/BOG_RTA_11/TwoWay.ss", 1, "-tp redlog", "twoWay", "SUCCESS"],
		###############################################(28)
				["benchs/aprove/Costa_Julia_09/Break.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Continue1.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Continue.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/costa09-example_1.ss", 6, "", "incr", "SUCCESS", "add", "SUCCESS", 
			"incr2", "SUCCESS", "add2", "SUCCESS", "incr3", "SUCCESS", "add3", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/costa09-example_2.ss", 2, "-tp redlog", "main", "SUCCESS", "divBy", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/costa09-example_3.ss", 2, "", "main", "SUCCESS", "m", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc1-exc.ss", 2, "", "main", "SUCCESS", "rec_f", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc2-exc.ss", 2, "", "main", "SUCCESS", "rec_f", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc3-exc.ss", 2, "", "main", "SUCCESS", "rec_f", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc4-exc.ss", 2, "", "main", "SUCCESS", "rec_f", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc5-exc.ss", 2, "", "main", "SUCCESS", "rec_f", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc-exc.ss", 2, "", "main", "SUCCESS", "rec_f", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc1-no.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc2-no.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc3-no.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc4-no.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc5-no.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Exc-no.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Loop1.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Nested.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/Sequence.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09/TestJulia4.ss", 1, "-tp redlog", "main", "SUCCESS"],
		###############################################(11)
				["benchs/aprove/Costa_Julia_09-recursive/Ackermann.ss", 2, "", "main", "SUCCESS", "ack", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09-recursive/Double-1.ss", 2, "-tp redlog", "test", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09-recursive/Double2-1.ss", 3, "", "main", "SUCCESS", "test", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09-recursive/Double2.ss", 2, "", "main", "SUCCESS", "test", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09-recursive/Double3-1.ss", 3, "", "main", "SUCCESS", "test", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09-recursive/Double3.ss", 2, "", "main", "SUCCESS", "test", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09-recursive/Double.ss", 2, "-tp redlog", "main", "SUCCESS", "test", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09-recursive/Factorial.ss", 2, "-tp redlog", "main", "SUCCESS", "fact", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09-recursive/FactSumList.ss", 2, "-tp redlog", "doSum", "SUCCESS", "fact", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09-recursive/FactSum.ss", 2, "-tp redlog", "doSum", "SUCCESS", "fact", "SUCCESS", "main", "SUCCESS"],
				["benchs/aprove/Costa_Julia_09-recursive/Hanoi.ss", 2, "", "main", "SUCCESS", "sol", "SUCCESS"],
		###############################################(3)
				["benchs/aprove/Julia_10_Iterative/NonPeriodic.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_10_Iterative/Test11.ss", 1, "-tp redlog", "main", "SUCCESS"],
				["benchs/aprove/Julia_10_Iterative/Test2.ss", 3, "", "main", "SUCCESS", "iter", "SUCCESS", "add", "SUCCESS"],
		###############################################(8)
				["benchs/aprove/Julia_10_Recursive/AckR.ss", 2, "", "main", "SUCCESS", "ack", "SUCCESS"],
                # --eps caused problem below
				["benchs/aprove/Julia_10_Recursive/FibSLR.ss", 4, "-tp redlog", 
				"main", "SUCCESS", "fib", "SUCCESS", "doSum", "SUCCESS", "create", "SUCCESS"],
				["benchs/aprove/Julia_10_Recursive/HanR.ss", 2, "", "main", "SUCCESS", "sol", "SUCCESS"],
				["benchs/aprove/Julia_10_Recursive/Power.ss", 3, "-tp redlog", "power", "SUCCESS", "even", "SUCCESS", "odd", "SUCCESS"],
				["benchs/aprove/Julia_10_Recursive/Recursions.ss", 6, "", "main", "SUCCESS", "rec0", "SUCCESS", "rec1", "SUCCESS",
			"rec2", "SUCCESS", "rec3", "SUCCESS", "rec4", "SUCCESS"],
				["benchs/aprove/Julia_10_Recursive/Test10.ss", 4, "", "main", "SUCCESS", "rec", "SUCCESS", 
			"test", "SUCCESS", "descend", "SUCCESS"],
				["benchs/aprove/Julia_10_Recursive/Test12.ss", 2, "-tp redlog", "main", "SUCCESS", "rec", "SUCCESS"],
				["benchs/aprove/Julia_10_Recursive/Test1.ss", 2, "", "main", "SUCCESS", "rec", "SUCCESS"],
		###############################################(21)
				["benchs/aprove/Julia_11_iterative/ChooseLife.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/Choose.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/Continue.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/Loop.ss", 2, "-tp redlog", "main", "SUCCESS", "test", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_00.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_01.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_02.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_03.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_04.ss", 6, "", "main", "SUCCESS", "for_1", "SUCCESS", "for_2", "SUCCESS", 
				"for_3", "SUCCESS", "for_4", "SUCCESS", "for_5", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_05.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_06.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_10.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_11.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_12.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_20.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_21.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_22.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_23.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/NO_24.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/Parts.ss", 6, "", "parts", "SUCCESS", "main", "SUCCESS", "for_1", "SUCCESS",
				"loop_1", "SUCCESS", "for_2", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/aprove/Julia_11_iterative/Swingers.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
		###############################################(44)
				["benchs/aprove/pasta/PastaA10.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaA1.ss", 3, "", "main", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/aprove/pasta/PastaA4.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaA5.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaA6.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaA7.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaA8.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaA9.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaB10.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaB11.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaB12.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaB13.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaB14.ss", 3, "", "main", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/aprove/pasta/PastaB15.ss", 3, "", "main", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/aprove/pasta/PastaB16-loop.ss", 3, "", "main", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/aprove/pasta/PastaB16.ss", 3, "", "main", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/aprove/pasta/PastaB17.ss", 3, "", "main", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/aprove/pasta/PastaB18.ss", 3, "", "main", "SUCCESS", "loop", "SUCCESS", "decrease", "SUCCESS"],
				["benchs/aprove/pasta/PastaB1.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaB2.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaB3.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaB4.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaB4-loop.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaB5.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaB6.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaB7.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaB8.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaC10-while.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaC11.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaC11-while.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaC1.ss", 3, "", "main", "SUCCESS", "loop_1", "SUCCESS", "loop_2", "SUCCESS"],
				["benchs/aprove/pasta/PastaC1-while.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaC2-while.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaC3.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaC3-while.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaC4-while.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaC5-while.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaC7-simpl-1.ss", 1, "", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaC7-simpl-2.ss", 1, "", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaC7-simpl.ss", 1, "", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaC7.ss", 2, "", "main", "SUCCESS", "loop", "SUCCESS"],
				["benchs/aprove/pasta/PastaC7-while.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaC8-while.ss", 1, "", "main", "SUCCESS"],
				["benchs/aprove/pasta/PastaC9-while.ss", 1, "", "main", "SUCCESS"]
    ],
    "lists" => [
        # ["allz1.ss", 0, ""],
        # ["allz2.ss", 0, ""],
        # ["allz3.ss", 0, ""],
        # ["allz4.ss", 0, ""],
        ["demo.ss", 11, "",, "reverse", "SUCCESS", "create_list", "SUCCESS", "delete_val", "SUCCESS", "delete", "SUCCESS", "insert", "SUCCESS", "get_next_next", "SUCCESS", "set_null", "SUCCESS", "set_next", "SUCCESS", "get_next", "SUCCESS", "ret_first", "SUCCESS", "append", "SUCCESS"],
        ["demo2.ss", 3, "", "app_rev", "SUCCESS", "reverse", "SUCCESS", "append", "SUCCESS"],
        ["err-coq.ss", 2, "", "ret_first2", "SUCCESS", "ret_first", "SUCCESS"],
        ["ll.ss", 11, "", "reverse", "SUCCESS", "create_list", "SUCCESS", "delete_val", "SUCCESS", "delete", "SUCCESS", "insert", "SUCCESS", "get_next_next", "SUCCESS", "set_null", "SUCCESS", "set_next", "SUCCESS", "get_next", "SUCCESS", "ret_first", "SUCCESS", "append", "SUCCESS"],
        ["ll_bak.ss", 11, "", "reverse", "SUCCESS", "create_list", "SUCCESS", "delete_val", "SUCCESS", "delete", "SUCCESS", "insert", "SUCCESS", "get_next_next", "SUCCESS", "set_null", "SUCCESS", "set_next", "SUCCESS", "get_next", "SUCCESS", "ret_first", "SUCCESS", "append", "SUCCESS"],
        ["ll_bak2.ss", 11, "", "reverse", "SUCCESS", "create_list", "SUCCESS", "delete_val", "SUCCESS", "delete", "SUCCESS", "insert", "SUCCESS", "get_next_next", "SUCCESS", "set_null", "SUCCESS", "set_next", "SUCCESS", "get_next", "SUCCESS", "ret_first", "SUCCESS", "append", "SUCCESS"],
        ["ll_bak3.ss", 11, "", "reverse", "SUCCESS", "create_list", "SUCCESS", "delete_val", "SUCCESS", "delete", "SUCCESS", "insert", "SUCCESS", "get_next_next", "SUCCESS", "set_null", "SUCCESS", "set_next", "SUCCESS", "get_next", "SUCCESS", "ret_first", "SUCCESS", "append", "SUCCESS"],
        ["ll_nolists.ss", 11, "", "reverse", "SUCCESS", "create_list", "SUCCESS", "delete_val", "SUCCESS", "delete", "SUCCESS", "insert", "SUCCESS", "get_next_next", "SUCCESS", "set_null", "SUCCESS", "set_next", "SUCCESS", "get_next", "SUCCESS", "ret_first", "SUCCESS", "append", "SUCCESS"],
        ["ll_test1.ss", 1, "", "reverse", "SUCCESS"],
        ["ll_test2.ss", 1, "", "delete", "SUCCESS"],
        # above fails on postcondition!
        # ["ll_test3.ss", , "", ],
        # above takes too long
        ["ll_test4.ss", 1, "", "test", "SUCCESS"],
        ["ll_test5.ss", 1, "", "delete_val", "SUCCESS"],
        # ["lr.ss", 2, "", "my_rev", "SUCCESS", "reverse", "SUCCESS"],
        # above takes too long
        ["lrev-bug.ss", 1, "", "lrev", "SUCCESS"],
        ["lrev.ss", 1, "", "lrev", "SUCCESS"],
        # ["lz_bak.ss", 0, ""],
        # ["lz_bak2.ss", 0, ""],
        ["merge.ss", 1, "", "merge", "SUCCESS"],
        ["merge1.ss", 1, "", "merge", "SUCCESS"],
        ["merge2.ss", 1, "", "merge", "SUCCESS"],
        ["merge3.ss", 1, "", "merge", "SUCCESS"],
        ["mk_zero.ss", 1, "", "mk_zero", "SUCCESS"],
        ["perm.ss", 1, "", "append", "SUCCESS"]
    ],
    "lemmas"=>[["lemma_check01.ss", 3, " --elp ", "V1", "Valid", "V2", "Valid", "F3", "Fail"],
               ["lemma_check02.ss", 2, " --elp ", "F5", "Fail", "V6", "Valid."],
               ["lemma_check03.ss", 3, " --elp ", "L1", "Valid", "L2", "Valid", "L4", "Fail"],
               ["lemma_check04.ss", 3, " --elp ", "L41", "Valid", "L42", "Fail", "L43","Fail"],
               ["lemma_check06.ss", 6, " --elp ",  "L61", "Valid", "L67", "Valid", "L62", "Valid", "L64", "Fail", "L65", "Fail", "L66", "Fail"]
    ]
    );

# list of file, string with result of each entailment&lemma....
# the pattern to add a new program below: ["program_name", "default options", "lemma validity check results", "checkentail results"]
%sleek_files=(
    "sleek"=>[["sleek.slk", "","", "Valid.Valid.Valid.Fail."],
                      ["sleek1.slk", "", "", "Fail."],
                      ["sleek10.slk", "", "", "Valid.Fail."],
                      ["sleek2.slk", "", "", "Fail.Valid.Fail.Fail.Valid.Valid.Valid.Fail."],
                      ["sleek3.slk", "", "Valid.", "Valid.Fail.Valid."],
                      ["sleek4.slk", "", "", "Valid.Valid."],
                      ["sleek6.slk", "", "", "Valid.Valid."],
                      ["sleek7.slk", "", "Valid.", "Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Fail.Valid."],
                      # slow in sleek8.slk due to search
                      ["sleek8.slk", "", "Valid.", "Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Fail.Valid.Fail."],
                      ["sleek9.slk", "", "Valid.Valid.","Valid.Fail.Valid.Valid."],
											["symb-diff.slk", "", "", "Valid.Valid.Valid."],
                      ["infer/infer1.slk", "", "", "Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid."],
                      ["infer/infer2.slk", "", "", "Valid.Valid.Valid.Fail.Valid.Fail.Valid.Valid.Fail."],
                      ["infer/infer4.slk", "", "", "Fail."],
                      ["infer/infer5.slk", "", "", "Valid.Valid.Fail.Valid."],
                      ["infer/infer6.slk", "", "", "Valid."],
                      ["infer/infer7.slk", "", "", "Valid.Valid.Valid.Valid.Fail.Valid.Valid.Valid.Fail.Valid."],
                      ["infer/infer8.slk", "", "", "Valid.Valid.Valid.Fail.Fail.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Fail.Fail.Valid.Valid.Valid."],
                      ["infer/infer9.slk", "", "", "Valid.Valid.Valid.Valid.Valid.Fail.Valid.Fail.Valid.Valid."],
#                      ["infer/infer10.slk", "", "", "Valid.Valid.Valid.Valid.Valid.Valid.Fail.Fail.Valid.Valid.Fail.Valid.Fail.Fail.Fail.Fail."],
                      ["infer/infer10.slk", "", "", "Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Fail.Fail.Fail.Valid."],
                      ["infer/infer11.slk", "", "", "Fail."],
#                      ["infer/infer12.slk", "", "", "Valid.Fail.Fail.Fail.Fail.Valid.Fail.Fail.Fail.Fail.Fail.Valid.Fail.Fail.Fail.Valid.Valid.Valid."],
                      ["infer/infer12.slk", "", "", "Valid.Fail.Valid.Fail.Fail.Valid.Valid.Valid.Valid.Fail.Fail.Valid.Fail.Fail.Fail.Valid.Valid.Valid."],
                      ["infer/infer13.slk", "--sa-en-cont", "", "Valid.Valid.Valid.Valid.Valid."],
                      ["infer/infer14.slk", "--sa-en-pure-field", "", "Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid."],
                      ["infer/infer15.slk", "", "", "Valid.Valid.Valid.Valid.Valid.Valid.Valid."],
                      ["infer/infer16.slk", "", "", "Valid.Valid.Valid.Valid.Valid.Valid."],
# TODO : why are spaces so important in " --imm "?
                      ["ann1.slk", " --imm --en-imm-inv", "", "Valid.Valid.Valid.Valid.Fail.Valid.Valid.Fail.Fail.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Fail.Valid.Fail.Valid.Fail.Fail.Valid.Valid.Valid.Fail.Valid.Valid.Fail."],
                      ["imm/imm1.slk", " --imm ", "", "Fail.Valid.Valid.Valid.Valid.Valid."],
                      #["imm/imm2.slk", "--imm", "Valid.Fail.Valid.Valid.Valid.Fail.Valid.Fail."],
                      ["imm/imm2.slk", " --imm ", "", "Fail.Valid.Fail.Valid.Fail."],
                      ["imm/imm3.slk", " --imm ", "", "Fail.Fail.Valid.Valid.Valid.Valid."],
                      ["imm/imm4.slk", " --imm ", "", "Valid.Fail."],
                      ["imm/imm-hard.slk", " --imm --eps", "", "Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid."],
                      ["imm-field/sleek01.slk", " --field-ann ", "", "Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail."],
                      ["imm-field/sleek02.slk", " --field-ann ", "", "Fail.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Fail."],
                      ["imm-field/sleek03.slk", " --field-ann ", "", "Valid.Fail.Valid.Valid.Fail.Valid.Valid.Fail.Valid.Valid.Fail."],
                      ["classic/classic1.slk", "", "", "Valid.Valid.Valid.Valid.Valid.Valid.Fail.Fail."],
                      ["classic/classic1.slk", " --classic", "", "Fail.Valid.Valid.Valid.Fail.Valid.Fail.Fail."],
                      ["classic/classic2.slk", "", "", "Fail.Valid.Valid.Valid.Fail.Valid.Fail.Fail."],
                      ["classic/classic3.slk", "", "", "Valid.Valid.Valid.Valid.Valid.Valid.Fail.Fail."],
                      ["classic/classic4.slk", "", "", "Valid.Fail.Valid.Fail.Valid.Fail.Valid.Fail."],
                      ["infinity.slk","--dsd --en-inf","",                      "Fail.Valid.Valid.Fail.Valid.Valid.Fail.Valid.Valid.Valid.Fail.Valid.Valid.Fail.Fail.Valid.Fail.Valid.Fail.Fail.Valid.Valid.Fail.Valid.Fail.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Valid.Fail.Fail.Fail.Valid.Valid.Valid.Fail.Fail.Valid.Fail.Fail.Valid.Valid.Valid.Valid.Valid.Fail.Fail.Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Fail.Valid.Valid.Valid.Valid.Valid."]
                      ],
		"sleek_barr"=>[["../tree_shares/barrier.slk", "--eps --dis-field-ann --dis-precise-xpure -perm dperm", "Barrrier b1n Success.Barrrier b3n Fail:  frames do not match (1->2).Barrrier b2n Fail:  contradiction in post for transition (1->2).Barrrier b4n Fail:  no contradiction found in preconditions of transitions from 1  for preconditions: .", ""],
				  ["../tree_shares/barrier3.slk", "--eps --dis-field-ann --dis-precise-xpure -perm dperm", "Barrrier b1n Success.Barrrier b3n Fail:  frames do not match (1->2).Barrrier b2n Fail:  contradiction in post for transition (1->2).", ""]
				 ],
		"sleek_dfrac"=>[["../tree_shares/fractionals.slk", "--eps --dis-field-ann -perm dperm","", "Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Fail."],
				  ["../tree_shares/barrier2.slk", "--eps --dis-field-ann -perm dperm","", "Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Fail."],
				  ["../tree_shares/fractions.slk", "--eps --dis-field-ann -perm dperm","", "Valid.Fail.Valid.Fail.Fail.Fail.Valid.Valid.Fail.Fail.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Fail.Valid.Fail.Valid.Valid.Valid.Fail.Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Valid.Fail.Fail.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Fail."]
                 ],
    "sleek_vperm" => [
                      ["vperm/vperm.slk"," --ann-vp ", "", "Valid.Valid.Fail.Valid.Valid.Fail.Fail.Fail.Valid.Valid.Valid."],
                      ["vperm/vperm2.slk"," --ann-vp ", "", "Valid.Valid.Fail."]],
		"sleek_fracperm"=>[["fracperm/sleek.slk","--en-para -perm fperm -tp redlog", "","Valid.Valid.Valid.Fail."],
					["fracperm/sleek1.slk","--en-para -perm fperm -tp redlog", "", "Fail."],
					["fracperm/sleek10.slk","--en-para -perm fperm -tp redlog", "", "Valid.Fail."],
					["fracperm/sleek2.slk","--en-para -perm fperm -tp redlog", "", "Fail.Valid.Fail.Fail.Valid.Valid.Valid.Fail."],
					["fracperm/sleek3.slk","--en-para -perm fperm -tp redlog", "", "Valid.Fail.Valid."],
					["fracperm/sleek4.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid."],
					["fracperm/sleek6.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid."],
					["fracperm/sleek7.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Fail.Valid."],
                  # slow in sleek8.slk due to search
				  ["fracperm/sleek8.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Fail.Valid.Fail."],
					["fracperm/sleek9.slk","--en-para -perm fperm -tp redlog", "", "Valid.Fail.Valid.Valid."],

                    ["fracperm/norm1.slk","--en-para -perm fperm -tp redlog", "", "Fail.Valid.Fail.Valid."],
					["fracperm/norm3.slk","--en-para -perm fperm -tp redlog", "", "Fail.Valid.Valid.Valid.Valid.Valid.Valid.Fail."],
					["fracperm/norm4.slk","--en-para -perm fperm -tp redlog", "","Valid.Valid.Valid."],
					["fracperm/uni_vars.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid.Fail."],
					["fracperm/frac1.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid.Valid.Fail.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid.Valid."],
					["fracperm/frac2.slk","--en-para -perm fperm -tp redlog", "", "Valid.Fail.Valid.Valid.Valid.Fail.Fail.Valid.Valid.Fail.Valid.Fail.Fail."],
					["fracperm/frac3.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Fail.Fail.Fail.Fail."],
					["fracperm/split_simple.slk","--en-para -perm fperm -tp redlog", "", "Valid.Fail.Valid.Fail.Fail.Valid.Valid.Valid."],
					["fracperm/combine_data.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Fail.Valid."],
					["fracperm/combine_simple.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid.Fail.Valid.Valid.Valid.Valid."],
					["fracperm/split-combine.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid.Valid."],
                  ["fracperm/combine2.slk","--en-para -perm fperm -tp redlog", "", "Valid.Valid.Valid.Valid."]
           ],
    "lemmas"=>[["lemma_check01.slk", " --elp ", "Valid.Valid.Fail.", ""],
              ["lemma_check02.slk", " --elp ", "Fail.Valid.", ""],
              ["lemma_check03.slk", " --elp ", "Valid.Valid.Fail.", ""],
              ["lemma_check04.slk", " --elp ", "Valid.Fail.Fail.", ""],
              ["lemma_check06.slk", " --elp ", "Valid.Valid.Valid.Fail.Fail.Fail.", ""]],
    "musterr"=>[["err1.slk","","must.may.must.must.may.must.may.must.must.Valid.may.must."],
               ["err2.slk","","must.may.must.must.must.may.must.must.may.may.may.must.may.must.may.must.may.must.must.must.must.Valid.must.Valid.must.must.must.must.Valid.may.may."],
			   ["err3.slk","","must.must.must.must.must.must.may.must.must."],
			   ["err4.slk","","must.Valid.must.may.Valid.Valid.Valid.may.may.must.may.must.Valid.may.may.must.must.Valid."],
			   ["err5.slk","","may.must.Valid.may.may.may.must.may.Valid.must.must.must.must.may.Valid.may.must.Valid.must.must."], #operators
			   ["err6.slk","","must.Valid.may.may.must.Valid."],
			   ["err7.slk","","Valid.must.must.must.must.Valid.may.Valid.must.must.Valid."],
               ["err9.slk","","bot.Valid.must.may.bot.Valid.must.may."]]

    );

# if($timings){
    $mainSum = 0.0;
    $childSum = 0.0;
    $totalSum = 0.0;
    $prooflogSum = 0.0;
    $falseContextSum = 0;
# }

open(LOGFILE, "> $output_file") || die ("Could not open $output_file.\n");
sleek_process_file();
hip_process_file();
close(LOGFILE);

if ($error_count > 0) {
  print "Total number of errors: $error_count in files:\n $error_files.\n";
}
else
	{print "All test results were as expected.\n";}
if($home21){
	chdir("/home") or die "Can't chdir to $target_dir $!";
	rmtree(["$target_dir"]) or die ("Could not delete folder: $target_dir $!");
}

printf "Total verification time: %.2f second\n", $totalSum;
printf "\tTime spent in main process: %.2f second\n", $mainSum;
printf "\tTime spent in child processes: %.2f second\n", $childSum;
printf "\tNumber of false contexts: %d\n", $falseContextSum; 
 

if($timings){
    #do the last computations and close the timings log worksheet
    #compute the total times*
    $row = $row + 2;
    my $format = $workbook->add_format();
    $format->set_bold();
    $format->set_num_format('0.00');
    $format->set_align('right');
    $worksheet->write($row, $programCol, "Totals:", $format);
    $worksheet->write($row, $mainCol, "$mainSum", $format);
    $worksheet->write($row, $childCol, "$childSum", $format);
    if("$flags" =~ m/--enable-logging-txt\b/ ){
      $worksheet->write($row, $prooflogCol, "$prooflogSum", $format);	
    }
    $worksheet->write($row, $totalCol, $totalSum, $format);
    $worksheet->write($row, $falseContextCol, $falseContextSum, $format);
    $workbook->close();
    my $parser = new Spreadsheet::ParseExcel::SaveParser;
    $book = $parser->Parse("temp_"."$timings_logfile") #open file for appending
            or die "File $timings_logfile was not found";
    local $^W = 0;
    $workbook = $book->SaveAs("$timings_logfile");
    $workbook->close();
    unlink("temp_"."$timings_logfile");
}
exit(0);

sub log_one_line_of_timings{
 my ($prog_name, $outp) = @_;
 $row++;
 $worksheet->write($row, $programCol, "$prog_name");
 my $format = $workbook->add_format();
 # $format->set_num_format('0.00');
 $format->set_align('right');
 if($outp =~ m/Total verification time: (.*?) second/){
     my $formatted_no = sprintf "%.2f", "$1";
     $worksheet->write_number($row, $totalCol, $formatted_no, $format);
     $totalSum = $totalSum + $1;
 }
 if($outp =~ m/Time spent in main process: (.*?) second/){
     my $formatted_no = sprintf "%.2f", "$1";
     $worksheet->write($row, $mainCol, $formatted_no, $format);
     $mainSum = $mainSum + $1;
 }
 if($outp =~ m/Time spent in child processes: (.*?) second/){
     my $formatted_no = sprintf "%.2f", "$1";
     $worksheet->write($row, $childCol, $formatted_no, $format);
     $childSum = $childSum + $1;
 }
 if($outp =~ m/	Time for logging: (.*?) second/){
     my $formatted_no = sprintf "%.2f", "$1";
     $worksheet->write($row, $prooflogCol, $formatted_no, $format);
     $prooflogSum = $prooflogSum + $1;
 }
 if($outp =~ m/\b(\w+) false contexts/){
     $format->set_num_format('0');
     $worksheet->write($row, $falseContextCol, "$1", $format);
     $falseContextSum = $falseContextSum + $1;
 }
}

sub sum_of_timings {
 my $outp = $_[0];
 if($outp =~ m/Total verification time: (.*?) second/){
     $totalSum = $totalSum + $1;
 }
 if($outp =~ m/Time spent in main process: (.*?) second/){
     $mainSum = $mainSum + $1;
 }
 if($outp =~ m/Time spent in child processes: (.*?) second/){
     $childSum = $childSum + $1;
 }
 if($outp =~ m/	Time for logging: (.*?) second/){
     $prooflogSum = $prooflogSum + $1;
 }
 if($outp =~ m/\b(\w+) false contexts/){
     $falseContextSum = $falseContextSum + $1;
 }
}

# string-pattern for collecting hip answer after the verification of a procedure:
#   "Procedure proc_name$ignored_string RESULT", where proc_name is the name of the procedure to be 
#                                                  verified, and RESULT can be either SUCCESS or FAIL
sub hip_process_file {
    foreach $param (@param_list)
    {
        my $procedure = "Procedure"; # assume the lemma checking is disabled by default; 
        if ("$param" =~ "lemmas") { $procedure = "Entailing lemma"; }
        if ("$param" =~ "hip") {
            $exempl_path_full = "$exempl_path/hip";
            print "Starting hip tests:\n";
        } else {
            $exempl_path_full = "$exempl_path/hip/$param";
            print "Starting hip-$param tests:\n";
        }
		$t_list = $hip_files{$param};
		foreach $test (@{$t_list})
		{
            $extra_options = $test->[2];
            if ("$extra_options" eq "") {
                print "Checking $test->[0]\n";
            } else {
                print "Checking $test->[0] (runs with extra options: $extra_options)\n";
            }
			#print "$hip $script_arguments $extra_options $exempl_path/hip/$test->[0] 2>&1 \n";
			$output = `$hip $script_arguments $extra_options $exempl_path_full/$test->[0] 2>&1`;
			print LOGFILE "\n======================================\n";
			print LOGFILE "$output";
			$limit = $test->[1]*2+2;
			#print "\nbegin"."$output"."end\n";
#            my @lines = split /\n/, $output;
#            @results = [];
#            foreach my $line (@lines) {
#                for($i = 3; $i<$limit;$i+=2)
#                {
#                    #print $line . "\n";
#                    if($line =~ /$procedure $test->[$i]/ && $line =~ m/SUCCESS/){
#                        @results[$i] = "SUCCESS";
#                    }
#                    elsif($line =~ /$procedure $test->[$i]/  && $line =~ m/FAIL/ ){
#                        @results[$i] = "FAIL";
#                    }
#                }
#            }
#            for ($i = 3; $i<$limit;$i+=2) {
#                #print $test->[$i] ."\n";
#                #print @results[$i] ."\n";
#                #print $test->[$i+1] ."\n";
#                if(@results[$i] ne $test->[$i+1])

			for($i = 3; $i<$limit;$i+=2)
			{
				if($output !~ /$procedure $test->[$i]\$.* $test->[$i+1]\./)
				{
			 		$error_count++;
					$error_files=$error_files."error at: $test->[0] $test->[$i]\n";
					print "error at: $test->[0] $test->[$i]\n";
				}
			}
			#Termination checking result
      if ($output !~ "ERR:") {}
			else {
				$error_count++;
				$error_files=$error_files."term error at: $test->[0] $test->[$i]\n";
				print "term error at: $test->[0] $test->[$i]\n";
			}
      if($timings) {
        log_one_line_of_timings ($test->[0],$output);
      }
      sum_of_timings ($output);
    }
  }
}



sub sleek_process_file  {
  foreach $param (@param_list)
  {
      my $lem = 0; # assume the lemma checking is disabled by default; make $lem=1 if lemma checking will be enabled by default and uncomment elsif
      my $err = 0;
	  my $barr = 0;
      if ("$param" =~ "musterr") {
          print "Starting sleek must/may errors tests:\n";
          $exempl_path_full = "$exec_path/errors";
          $err = 1;
      }
      if (("$param" =~ "lemmas") ||  ($script_arguments=~"--elp")) {  $lem = 1; }
	  if ("$param" =~ "sleek_barr"){ $barr=1;}
#      elsif ($script_arguments=~"--dlp"){ $lem = 0; }
      
      if ("$param" =~ "sleek") {
          print "Starting sleek tests:\n";
          $exempl_path_full = "$exempl_path/sleek";
      }else {
          $exempl_path_full = "$exempl_path_full/$param";
          print "Starting sleek-$param tests:\n";
      }
      $t_list = $sleek_files{$param};
      foreach $test (@{$t_list})
			{
            my $extra_options = $test->[1];
            if ("$extra_options" eq "") {
                print "Checking $test->[0]\n";
            } else {
                print "Checking $test->[0] (runs with extra options: $extra_options)\n";
            }
            $script_args = $script_arguments." ".$extra_options;
			$output = `$sleek $script_args $exempl_path_full/$test->[0] 2>&1`;
			print LOGFILE "\n======================================\n";
	        print LOGFILE "$output";
            my $lemmas_results = "";
            my $entail_results = "";
			my $barrier_results = "";
            my @lines = split /\n/, $output; 
            foreach my $line (@lines) { 
                if($line =~ m/Entailing lemma/){
                    if($line =~ m/Valid\./) { $lemmas_results = $lemmas_results ."Valid."; }
                    elsif($line =~ m/EXC\./) { $lemmas_results = $lemmas_results ."EXC."; }
                    elsif($line =~ m/Fail\./)  { $lemmas_results = $lemmas_results ."Fail.";}
                }elsif($line =~ m/Barrrier/){
					 $barrier_results = $barrier_results .$line .".";
				}elsif($line =~ m/Entail/){
                    if( $err == 1) {
                        $i = index($line, "Valid. (bot)",0);
                        $h = index($line, "Valid.",0);
                        $j = index($line, "Fail.(must)",0);
                        $k = index($line, "Fail.(may)",0);
                        #  print "i=".$i ." h=". $h . " j=" .$j . " k=".$k ."\n";
                        if($i >= 0) { $r = $r ."bot."; }
                        elsif($h >= 0) { $r = $r ."Valid."; }
                        elsif($j >= 0)  { $r = $r ."must.";} #$line =~ m/Fail.(must)/
                        elsif($k >= 0)  { $r = $r ."may.";}
                    }
                    else {
                        if($line =~ m/Valid\./) { $entail_results = $entail_results ."Valid."; }
                        elsif($line =~ m/EXC\./) {  $entail_results = $entail_results ."EXC."; }
                        elsif($line =~ m/Fail\./)  { $entail_results = $entail_results ."Fail.";}
                    }
                }
            }
			if ((($lem==0) && ($barr==0) && ($entail_results !~ /^$test->[3]$/)) || 
				(($lem == 1)  && ($lemmas_results !~ /^$test->[2]$/)) || 
				($barr==1 && ($barrier_results ne $test->[2])))
			{
                            @results = split (/\./, $entail_results);
                            # print "\n@results";
                            @expected = split (/\./, $test->[3]);
                            my %mark_failures = map {if ($results[$_] !~ $expected[$_]) {$_+1 =>"$expected[$_]"} else {(0 => "same")}} 0 .. $#results;
                            my @failures = grep {  $_ > 0 } keys  %mark_failures;
                            my @failures_e = map {  "\{".$_ ."#". $mark_failures{$_}."\}" } @failures;
                            # my @failures =  grep { $mark_failures{$_} != "same"} keys %mark_failures;
                            # print "@failures";
                            local $" = ',';
                            print "Unexpected result with : $test->[0] (failed check(s): @failures_e) \n";
                            $error_count++;
                            $error_files = $error_files . " " . $test->[0]."(@failures_e)";
			}	
			if($timings) {
				# log_one_line_of_timings ($test->[0],$output);
			}
			sum_of_timings ($output);
		}
	}
}
