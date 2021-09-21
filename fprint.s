@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Name: fprint.s
@ Author: Ben Placzek
@ Description: This module will print necessary registers
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.global fprint
fprint:
        push {r0-r4, lr}
        vstr s0, [r1]
        vldr s16, [r1]        @ load pi as float in s15
        vcvt.f64.f32 d7, s16  @ convert s15 to double in d7

        ldr r0, =msg
        vmov r2, r3, d7       @ 2nd argument for printf() as 64-bit value passe
        bl printf

        pop {r0-r4, pc}


.global printall
printall:
        @ print const array

        bl fprint @  K_charge
        vmov s0, s1 
        bl fprint @  L_barrel
        vmov s0, s2
        bl fprint @  m_projectile
        vmov s0, s3
        bl fprint @  t_barrel

        @ print inputs array

        vmov s0, s4
        bl fprint @  tar N
        vmov s0, s5
        bl fprint @ RNG XXXXX.XX
        vmov s0, s6
        bl fprint @  BR YYY.YY
        vmov s0, s7
        bl fprint @  SP SS.SS
	vmov s0, s26
	bl fprint @  DIR ZZZ.ZZZ

        @ print other number array

        vmov s0, s8
        bl fprint @  2.0
        vmov s0, s9
        bl fprint @ 3.14159
        vmov s0, s10
        bl fprint @  180.0
        vmov s0, s11
        bl fprint @  9.8

	vmov s0, r3 @ print a_projectile
	bl fprint  @ 1999.99

	vmov s0, r4 @ print v_projectile
	bl fprint @ 199.99

	vmov s0, r7 @ print phi
	bl fprint @ 0.019
      	bx lr

.data
        msg: .string "%f\n"
