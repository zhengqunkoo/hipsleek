int foo(int** q)
/*@
 requires q::int^^<a>@L
 ensures  res=0;
 //ensures q::int^^<a> & res=0;
 //ensures q::int_star_star<r>*r::int_star<a> & res=0;
*/
{
 return 0;
};

int main()
/*@
 requires true
 ensures true;
*/
{
 int x;
 int* r = &x;
 foo(&r);
 return x;
}

