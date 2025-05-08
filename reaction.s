/* reaction.s — AT&T IA-32 */
    .section .data
lfsr_seed:
    .long 0xABCDE123

    .equ CYCLES_PER_MS, 2600000    /* 2.6 GHz → 2 600 000 cycles/ms */

    .section .text
    .globl get_delay_ms, rdtsc_start, rdtsc_end
    .globl compute_ms, random_key

/*-------------------------------------------------------------*/
/* get_delay_ms:  [ return (rand%3000)+2000 ] in EAX */
get_delay_ms:
    pushl  %ebp
    movl   %esp, %ebp
    call   lfsr_rand            /* EAX = raw LFSR */
    movl   $3000, %ecx
    cdq
    idivl  %ecx                 /* EDX = rem */
    movl   %edx, %eax
    addl   $2000, %eax
    popl   %ebp
    ret

/*-------------------------------------------------------------*/
/* random_key: [ 'A' + (rand%26) ] → AL */
random_key:
    pushl  %ebp
    movl   %esp, %ebp
    call   lfsr_rand
    movl   $26, %ecx
    cdq
    idivl  %ecx
    addb   $'A', %al
    movzx  %al, %eax
    popl   %ebp
    ret

/*-------------------------------------------------------------*/
/* lfsr_rand: 32-bit Fibonacci LFSR taps at 31,29,25,24 → EAX */
lfsr_rand:
    pushl  %ebp
    movl   %esp, %ebp

    movl   lfsr_seed, %eax
    movl   %eax, %ecx
    shrl   $31, %ecx
    movl   %eax, %edx
    shrl   $29, %edx
    xorl   %edx, %ecx
    movl   %eax, %edx
    shrl   $25, %edx
    xorl   %edx, %ecx
    movl   %eax, %edx
    shrl   $24, %edx
    xorl   %edx, %ecx
    andl   $1, %ecx            /* new bit */

    sall   $1, %eax
    orb    %cl, %al
    movl   %eax, lfsr_seed

    popl   %ebp
    ret

/*-------------------------------------------------------------*/
/* rdtsc_start: read TSC → (EBX=low, ECX=high) */
rdtsc_start:
    rdtsc
    movl   %eax, %ebx
    movl   %edx, %ecx
    ret

/*-------------------------------------------------------------*/
/* rdtsc_end: read TSC, subtract start → (EDX:EAX)=delta */
rdtsc_end:
    rdtsc
    subl   %ebx, %eax
    sbbl   %ecx, %edx
    ret

/*-------------------------------------------------------------*/
/* compute_ms: divide 64-bit delta EDX:EAX by CYCLES_PER_MS → EAX */
compute_ms:
    pushl  %ebp
    movl   %esp, %ebp
    movl   $CYCLES_PER_MS, %ecx
    divl   %ecx
    popl   %ebp
    ret
