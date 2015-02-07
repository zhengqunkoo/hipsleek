//extern void __VERIFIER_error() __attribute__ ((__noreturn__));
/*
  requires true
  ensures true & flow __Error;
*/

/*
 * Recursive computation of fibonacci numbers.
 * 
 * Author: Matthias Heizmann
 * Date: 2013-07-13
 * 
 */



int fibonacci(int n)
/*@
  //infer [@post_n]
  requires true
  ensures n<1 & res=0 | n>=1 & res>=0;
 */
{
    if (n < 1) {
        return 0;
    } else if (n == 1) {
        return 1;
    } else {
        return fibonacci(n-1) + fibonacci(n-2);
    }
}

// ex21-fib02.c

extern int __VERIFIER_nondet_int(void)
;

// Expect SUCCESS
// Return FAIL
int main()
/*@
  requires true
  //ensures res=0 & flow __norm or res=1 & flow __norm; // __Error;
  ensures res=0 & flow __norm or true & flow __Error;
*/
{
    int x = 9;
    int result = fibonacci(x);
    // dprint;
    if (result == 34) {
      // dprint;
      return 0;
    } else {
      //return 1;
      throw_err();
      //ERROR: __VERIFIER_error();
    }
}

/*
# svcomp14/recursive/fail/ex21a-Fib02-error.c

I added the following into prelude.ss

void throw_err()
  requires true
  ensures true & flow __Error;

Why did I have a pre-cond failure?

Checking procedure main$... 
Proving precondition in method throw_err$ Failed.
  (must) cause: must_err (__Error#E) LOCS: [50;47;48;-1;55]

*/
