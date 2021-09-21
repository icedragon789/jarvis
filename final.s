@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Name: final.s
@ Author: Ben Placzek
@ Description: This module will call the necessary modules
@ to implement Jarvis I Targeting Functions
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ TAR N RNG XXXXX.XX BR YYY.YY SP SS.SS DIR ZZZ.ZZ NULL
@ "TAR1RNG12345.67BR321.12SP11.11DIR001.10\0"
@ Values:
@ s0 : kcharge
@ s1 : lbarrel
@ s2 : mprojectile
@ s3 : tbarrel
@ s4 : tar n
@ s5 : rng xxxxx.xx
@ s6 : br yyy.yy
@ s7 : dir zzz.zzz
@ s8 : 2.0
@ s9 : 3.14159
@ s10 : 180
@ s11 : 9.8
@ s12 : a_projectile
@ s13 : v_projectile
@ s14 : phi
@ s15 : v_proj_xy
@ s16 : v_proj_z
@ s17 : t_flight_uncor
@ s18 : R_projectile_uncor
@ s19 : theta
@ s20 : R_x
@ s21 : R_y
@ s22 : D
@ s23 : D_x
@ s24 : D_y
@ s25 : Bearing_aim
@ s26 : sp ss.ss
@ s27 : R_aim
@ s28 : t_flight_cor
@ s29 : elev_aim
@ s30 : M_charge
@ s31 : printing and storage for operations

.data
constants: .float 200000000, 10, 100.0, 0.1 @ used as constants
inputs: .float 1.0, 12345.67, 321.12, 11.11, 1.10 @ used as inputs
nums: .float 2.0, 3.14, 180, 9.8, 1 @ numerous other constants
.global main @ entry point for code
main:	
	bl init					@ initialize constants
	bl in					@ initialize hardcoded inputs
	bl bearing				@ compute bearing aim for output
	bl elevation			@ compute elevation aim for output
	bl charge				@ compute charge needed for output
	bl printall				@ print some values
	mov r0, #0				@ load r0 with 0 for exit code
	mov r7, #1				@ call r7 with exit service code
	svc 0 					@ service call

init:	
	ldr r6, =constants
	vldr s0,[r6] 		@ s0 : kcharge	
	vldr s1, [r6,#4]		@ s1 : lbarrel
	vldr s2, [r6, #8]		@ s2 : mprojectile
	vldr s3, [r6, #12]		@ s3 : tbarrel 
	ldr r6, =nums
	vldr s8, [r6]			@ s8 : 2.0 
	vldr s9, [r6, #4]		@ s9 : 3.14159
	vldr s10, [r6, #8]		@ s10 : 180
	vldr s11, [r6, #12]		@ s11 : 9.8
	bx lr

in:
	ldr r6, =inputs
	vldr s4, [r6]			@ tar n 
	vldr s5, [r6,#4]		@ rng xxxxx.xx
	vldr s6, [r6, #8]		@ br yyy.yy
	vldr s7, [r6, #12]		@ sp ss.ss
	vldr s26, [r6, #16]		@ dir zzz.zzz
	bx lr

bearing:
	@ a_projectile = (2.0 * L_barrel) / (t_barrel * t_barrel)
	vmul.f32 s0, s8, s1		@ s0 <- 2.0 * L_barrel
	vmul.f32 s6, s3, s3		@ s6 <- t_barrel * t_barrel
	vdiv.f32 s0, s0, s6		@ s0 <- s31/s30
	vmov.f32 r3, s0			@ r3 <- s0

    @ v_projectile = a_projectile * t_barrel
	vmul.f32 s0, s0, s3		@ s0 <- s0 * s3
	vmov.f32 r4, s0			@ r4 <- s0

    @ Phi = DIR ZZZ.ZZZ * 3.14159 / 180.0
	vmul.f32 s0, s26, s9	@ s0 <- s26*s9
	vdiv.f32 s0, s0, s10 	@ s0 <- s0 / s10
	vmov.f32 r7, s0			@ r7 <- s0

	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@ This is the point that I was heavily stuck.
	@ The rest of my program is written out in pseudo-ARM instructions.
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    @ v_proj_xy = v_projectile * cos(Phi)
	@ s15 = s13*cos(s14)
	@ s8 = cos(s14)
	@ s15 = s13 * s8
	@vmov.f32 s1, r4		@ fetch our v_projectile
	@vmul.f32 s2, s0, s0	@ s2 <- phi * phi
	@vdiv.f32 s2, s2, s8	@ s2 <- phi^2/2!
	@vldr s3, [r5, #16]	@ s3 <- 1
	@vsub.f32 s4,s3, s2	@ s4 <- cos(phi) 

    @ v_proj_z = v_projectile * sin(Phi)
	@ s16 = s13*sin(s14)
	@ s8 = sin(s14)
	@ s16 = s13 * s8

    @ t_flight_uncor = (2.0 * v_proj_z) / 9.8
	@ s17 = (s8*s16) / s11
	@ s8 = s8 * s16
	@ s17 = s8 / s11

    @ R_projectile_uncor = v_proj_xy * t_flight_uncor
	@ s18 = s15*s17


	@ theta = BR YYY.YY * 3.14159 / 180.0
	@ s19 = (s6*s9) / s10

	@ s9 = s6 * s9
	@ s19 = s9 / s10

    @ R_x = R_projectile_uncor * cos(theta)
	@ s20 = s18*cos(s19)

	@ s8 = cos(s19)
	@ s20 = s18*s8

    @ R_y = R_projectile_uncor * sin(theta)
	@ s21 = s18*sin(s19)

	@ s8 = sin(s19)
	@ s21 = s18 * s8 

    @ D = SP SS.SS * t_flight_uncor
	@ s22 = s26 * s17

    @ D_x = D * cos(Phi)
	@ s23 = s22 * cos(s14)

	@ s8 = cos(s14)
	@ s23 = s22 * s8

    @ D_y = D * sin(Phi)
	@ s24 = s22 * sin(s14)

	@ s8 = sin(s14)
	@ s24 = s22 * s8

    @ Bearing_aim = atan((R_x + D_x) / (R_y + D_y))
	@ s25 = arctangent((s20+s23) / (s21+s24))

	@ s8 = s20 + s23
	@ s9 = s21+s24
	@ s10 = s8/s9
	@ s25 = arctangent(s10)

    @ Bearing_aim = (Bearing_aim * 180.0) / 3.14159
	@ s25 = (s25 * s10) / s9
	@ s8 = s25*s10
	@ s25 = s8/s9
	bx lr

elevation:
	@ R_aim = sqrt(((R_x + D_x) * (R_x + D_x)) + ((R_y + D_y) * (R_y + D_y)))
	@ s27 = sqrt(((s20+s23)*(s20+s23) + (s21+s24)*(s21+s24)))
	@ s8 = s20+s23
	@ s8 = s8 * s8
	@ s9 = s21+s24
	@ s9 = s9*s9
	@ s10 = s8+s9
	@ s27 = sqrt(s10)

    @ t_flight_cor = D / v_projectile + t_flight_uncor
	@ s28 = s22 / (s13+s17)

	@ s8 = s13+s17
	@ s28 = s22/s8

    @ elev_aim = acos(R_aim/(v_proj_init_xy * t_flight_cor))
	@ s29 = arccosine(s27/(s15*s28))

	@ s8 = s15*s28
	@ s9 = s27/s8
	@ s29 = arccosine(s9)

	@ elev_aim = (elev_aim *180.0)/3.14159
	@ s29 = (s29*s10)/s9

	@ s8 = s29*s10
	@ s29 = s8/s9

	bx lr
	

charge:
	ldr r6, =constants
	vldr s0, [r6]		@ get our k charge back
	vldr s1, [r6,#4]	@ need l barrel back
	vldr s2, [r6, #8]	@ fetch m projectile

	@ M_charge = 2.0 * L_barrel * m_projectile / (K_Charge * (t_flight_cor * t_flight_cor))
	@ s30 = s8 * s1 * s2 / (s0 * (s28*s28))

	@ s8 = s8 * s1
	@ s8 = s8*s2
	@ s9 = s28*s28
	@ s9 = s0*s9
	@ s30 = s8/s9

	bx lr

.end
