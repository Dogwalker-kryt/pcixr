#include <iostream>
#include "pcixr_defs.h"
#include "sysi/sys_interact.h"

typedef bool (*func_ptr)(int argc, char **argv, int *index, void *data);

typedef struct arg_t {
    const char long_name[_64b];
    const char short_name[_16b];

    func_ptr func;
    bool needs_sudo = false;
} arg_t;

void clean_up() {

}






int main(int argc, char **argv) {
    atexit(clean_up);

    for (__uint16_t i = 0; i < argc; ++i) {

    }


    return EXIT_SUCCESS;
}