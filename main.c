/* main.c */
#include <stdio.h>
#include <unistd.h>     // usleep
#include <stdint.h>     // uint32_t

/* Assembly routines (provided in reaction.s) */
extern uint32_t get_delay_ms(void);
extern void      rdtsc_start(void);
extern void      rdtsc_end(void);
extern uint32_t  compute_ms(void);
extern char      random_key(void);

int main(void) {
    int ch, mode;
    uint32_t delay_ms, elapsed;

    /* 1) Select mode */
    printf("Select Game Mode:\n[1] Standard\n[2] Target Key Reaction\n> ");
    mode = getchar() - '0';
    getchar();  // consume newline

    if (mode != 1 && mode != 2) {
        fprintf(stderr, "Invalid mode.\n");
        return 1;
    }

    /* 2) “Get Ready…” + random delay */
    puts("Get Ready...");
    delay_ms = get_delay_ms();
    usleep(delay_ms * 1000);

    /* 3) If target mode, pick and prompt a random letter */
    char target = 0;
    if (mode == 2) {
        target = random_key();
        printf("Press '%c'!\n", target);
    } else {
        puts("GO!");
    }

    /* 4) Start timing, wait for key */
    rdtsc_start();
    ch = getchar();

    /* 5) In target mode, check key */
    if (mode == 2 && ch != target) {
        printf("Wrong key! Expected '%c'.\n", target);
        return 0;
    }

    /* 6) Stop timing and compute ms */
    rdtsc_end();
    elapsed = compute_ms();
    printf("Reaction Time: %u ms\n", elapsed);

    return 0;
}
