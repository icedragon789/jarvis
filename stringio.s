        .data        /* data versus code */
        .balign 4    /* alignment on 4-byte boundaries */

/* labels (addresses) for user input, formatters, etc. */
num:    .int    0               /* 4-byte integer */
steps:  .int    0               /* another for the result */
prompt: .asciz  "Integer > 0: " /* zero-terminated ASCII string */
format: .asciz  "%u"            /* %u for "unsigned" */
report: .asciz  "From %u to 1 takes %u steps.\n"
       
        .text          /* code: 'text' in the sense of 'read only' */
        .global main   /* program's entry point must be global */
        .extern printf /* library function */
        .extern scanf  /* ditto */

collatz:                 /** collatz function **/
        mov r0, #0       /* r0 is the step counter */
loop_start:              /** collatz loop **/
        cmp r1, #1       /* are we done? (num == 1?) */
        beq collatz_end  /* if so, return to main */    
       
        and r2, r1, #1            /* odd-even test for r1 (num) */
        cmp r2, #0                /* even? */
        moveq r1, r1, LSR #1      /* even: divide by 2 via a 1-bit right shift */
        addne r1, r1, r1, LSL #1  /* odd: multiply by adding and 1-bit left shift */
        addne r1, #1              /* odd: add the 1 for (3 * num) + 1 */

        add r0, r0, #1            /* increment counter by 1 */
        b loop_start              /* loop again */
collatz_end:
        bx lr                     /* return to caller (main) */

main:  
        push {lr}              /* save link register to stack */

        /* prompt for and read user input */
        ldr r0, =prompt        /* format string's address into r0 */
        bl  printf             /* call printf, with r0 as only argument */

        ldr r0, =format        /* format string for scanf */
        ldr r1, =num           /* address of num into r1 */
        bl  scanf              /* call scanf */

        ldr r1, =num           /* address of num into r1 */
        ldr r1, [r1]           /* value at the address into r1 */
        bl  collatz            /* call collatz with r1 as the argument */

        /* demo a store */
        ldr r3, =steps         /* load memory address into r3 */
        str r0, [r3]           /* store hailstone steps at mem[r3] */

        /* setup report */
        mov r2, r0             /* r0 holds hailstone steps: copy into r2 */
        ldr r1, =num           /* get user's input again */
        ldr r1, [r1]           /* dereference address to get value */
        ldr r0, =report        /* format string for report into r0 */
        bl  printf             /* print report */

        pop {lr}               /* return to caller */