extern int __VERIFIER_nondet_int(void);

int test_fun(int x, int y)
{
    int c = 0;
    while ((x > 0) || (y > 0)) {
        if (x > 0) {
            x = x - 1;
        } else {
            if (y > 0) {
                y = y - 1;
            } else {
                
            }
        }
        c = c + 1;
    }
    return c;
}

int main() {
    return test_fun(__VERIFIER_nondet_int(), __VERIFIER_nondet_int());
}
