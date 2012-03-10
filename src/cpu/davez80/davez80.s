;@ --------------------------- Defines ----------------------------

     cpucontext .req r6

    .equ z80sppc_pointer,            0                  ;@  0
    .equ z80hlfa_pointer,            z80sppc_pointer+4     ;@  4
    .equ z80debc_pointer,            z80hlfa_pointer+4     ;@  8
    .equ z80iyix_pointer,            z80debc_pointer+4     ;@  12
    .equ z80hlfa2_pointer,           z80iyix_pointer+4     ;@  16
    .equ z80debc2_pointer,           z80hlfa2_pointer+4    ;@  20
    .equ z80cyclesleft_pointer,      z80debc2_pointer+4    ;@  24
    .equ z80flagsir_pointer,         z80cyclesleft_pointer+4   ;@  28

    .equ z80irqcallback,          z80flagsir_pointer+4
    .equ z80_write8,              z80irqcallback+4
    .equ z80_write16,             z80_write8+4
    .equ z80_in,                  z80_write16+4
    .equ z80_out,                 z80_in+4
    .equ z80_read8,               z80_out+4
    .equ z80_read16,              z80_read8+4
    .equ z80_rebaseSP,            z80_read16+4
    .equ z80_rebasePC,            z80_rebaseSP+4

    .equ ppMemFetch,			  z80_rebasePC+4
    .equ ppMemFetchData,		  ppMemFetch+4
    .equ ppMemRead,				  ppMemFetchData+4
    .equ ppMemWrite,			  ppMemRead+4
    .equ debugCallback,			  ppMemWrite+4



.ALIGN
            .ltorg

            .data
            mpointer:	.word 0
            rpointer:	.word 0
            rompointer:	.word 0
            IFF1:	.word 0
            IFF2:	.word 0


            .ALIGN

.text


@ ***** EnterCPU *****
.ALIGN
.GLOBAL DaveZ80EnterCPU
.TYPE DaveZ80EnterCPU,function
.CODE 32


	@FlagC=1,
	@FlagN=2,
	@FlagP=4,
	@Flag3=8,
	@FlagH=16,
	@Flag5=32,
	@FlagZ=64,
	@FlagS=128


	@** Following ARM registers are reserved To match Z80 registers
	@** R5 - Bit 31=IFF2, 30=IFF1,29&28=Int Mode, 27-Page Enable, 26-Model, 25-Current Rom, 24-128K Screen, 23-Tape Load, 22,21=Beeper, 20-18=Border, 17=Halt status, 16=Debug flag, 15-8=I, 7-0=R
	@** R6 - cpu context
	@** R7 - SP  PC
	@** R8 - H L F A
	@** R9 - D E B C
	@** R10 - IX IY
	@** R11 - Cycles
	@** R12 - 16 bit mask 0000FFFF


DaveZ80EnterCPU:

	stmfd r13!,{r3-r12,lr}
			ldr r4,=mpointer
			str r0,[r4]

			ldr r4,=rpointer
			str r1,[r4]
			mov r6,r1
			mov r0,r1		@Load address For external register storage

			ldr r7,[r0],#4 @Start reloading registers -  SP PC
			ldr r8,[r0],#4 @H L F A
			ldr r9,[r0],#4 @D E B C
			ldr r10,[r0],#4 @IY IX
			ldr r2,[r0],#4 @H' L' F' A'
			ldr r3,[r0],#4 @D' E' B' C'
			ldr r11,[r0],#4 @Cycles
			ldr r5,[r0] @user flags			@ IFF2 IFF1 (14 spare bits) I R
			mov r12,#0xFF00 @16 bit mask
			add r12,r12,#0x00FF @16 bit mask
			ldr r4,=ExReg
			str r2,[r4,#4]
			str r3,[r4,#8]





CPU_LOOP:
			add r0,r5,#1
			and r0,r0,#127
			bic r5,r5,#127
			orr r5,r5,r0				@ 4 Lines to increase r register!
			tst r5,#0x20000				@ Test for HALT flag
			movne r2,#4					@ Move 4 cycles into R2
			bne	ENDOPCODES				@ Jump past opcodes
OPCODES:
			and r1,r7,r12				@Mask the 16 bits that relate to the PC
			bl MEMFETCH

			add r1,r1,#1				@Increment PC
			and r1,r1,r12				@Mask the 16 bits that relate to the PC
			bic r7,r7,r12				@Clear the old PC value
			orr r7,r7,r1				@Store the new PC value
@			ldr r3,=rpointer
@			ldr r2,[r3]   				@These three lines store the opcode For debugging
@			str r0,[r2,#36]
			add r15,r15,r0, lsl #2 		@Multipy opcode by 4 To get value To add To PC


			nop

			B OPCODE_00
			B OPCODE_01
			B OPCODE_02
			B OPCODE_03
			B OPCODE_04
			B OPCODE_05
			B OPCODE_06
			B OPCODE_07
			B OPCODE_08
			B OPCODE_09
			B OPCODE_0A
			B OPCODE_0B
			B OPCODE_0C
			B OPCODE_0D
			B OPCODE_0E
			B OPCODE_0F
			B OPCODE_10
			B OPCODE_11
			B OPCODE_12
			B OPCODE_13
			B OPCODE_14
			B OPCODE_15
			B OPCODE_16
			B OPCODE_17
			B OPCODE_18
			B OPCODE_19
			B OPCODE_1A
			B OPCODE_1B
			B OPCODE_1C
			B OPCODE_1D
			B OPCODE_1E
			B OPCODE_1F
			B OPCODE_20
			B OPCODE_21
			B OPCODE_22
			B OPCODE_23
			B OPCODE_24
			B OPCODE_25
			B OPCODE_26
			B OPCODE_27
			B OPCODE_28
			B OPCODE_29
			B OPCODE_2A
			B OPCODE_2B
			B OPCODE_2C
			B OPCODE_2D
			B OPCODE_2E
			B OPCODE_2F
			B OPCODE_30
			B OPCODE_31
			B OPCODE_32
			B OPCODE_33
			B OPCODE_34
			B OPCODE_35
			B OPCODE_36
			B OPCODE_37
			B OPCODE_38
			B OPCODE_39
			B OPCODE_3A
			B OPCODE_3B
			B OPCODE_3C
			B OPCODE_3D
			B OPCODE_3E
			B OPCODE_3F
			B OPCODE_40
			B OPCODE_41
			B OPCODE_42
			B OPCODE_43
			B OPCODE_44
			B OPCODE_45
			B OPCODE_46
			B OPCODE_47
			B OPCODE_48
			B OPCODE_49
			B OPCODE_4A
			B OPCODE_4B
			B OPCODE_4C
			B OPCODE_4D
			B OPCODE_4E
			B OPCODE_4F
			B OPCODE_50
			B OPCODE_51
			B OPCODE_52
			B OPCODE_53
			B OPCODE_54
			B OPCODE_55
			B OPCODE_56
			B OPCODE_57
			B OPCODE_58
			B OPCODE_59
			B OPCODE_5A
			B OPCODE_5B
			B OPCODE_5C
			B OPCODE_5D
			B OPCODE_5E
			B OPCODE_5F
			B OPCODE_60
			B OPCODE_61
			B OPCODE_62
			B OPCODE_63
			B OPCODE_64
			B OPCODE_65
			B OPCODE_66
			B OPCODE_67
			B OPCODE_68
			B OPCODE_69
			B OPCODE_6A
			B OPCODE_6B
			B OPCODE_6C
			B OPCODE_6D
			B OPCODE_6E
			B OPCODE_6F
			B OPCODE_70
			B OPCODE_71
			B OPCODE_72
			B OPCODE_73
			B OPCODE_74
			B OPCODE_75
			B OPCODE_76
			B OPCODE_77
			B OPCODE_78
			B OPCODE_79
			B OPCODE_7A
			B OPCODE_7B
			B OPCODE_7C
			B OPCODE_7D
			B OPCODE_7E
			B OPCODE_7F
			B OPCODE_80
			B OPCODE_81
			B OPCODE_82
			B OPCODE_83
			B OPCODE_84
			B OPCODE_85
			B OPCODE_86
			B OPCODE_87
			B OPCODE_88
			B OPCODE_89
			B OPCODE_8A
			B OPCODE_8B
			B OPCODE_8C
			B OPCODE_8D
			B OPCODE_8E
			B OPCODE_8F
			B OPCODE_90
			B OPCODE_91
			B OPCODE_92
			B OPCODE_93
			B OPCODE_94
			B OPCODE_95
			B OPCODE_96
			B OPCODE_97
			B OPCODE_98
			B OPCODE_99
			B OPCODE_9A
			B OPCODE_9B
			B OPCODE_9C
			B OPCODE_9D
			B OPCODE_9E
			B OPCODE_9F
			B OPCODE_A0
			B OPCODE_A1
			B OPCODE_A2
			B OPCODE_A3
			B OPCODE_A4
			B OPCODE_A5
			B OPCODE_A6
			B OPCODE_A7
			B OPCODE_A8
			B OPCODE_A9
			B OPCODE_AA
			B OPCODE_AB
			B OPCODE_AC
			B OPCODE_AD
			B OPCODE_AE
			B OPCODE_AF
			B OPCODE_B0
			B OPCODE_B1
			B OPCODE_B2
			B OPCODE_B3
			B OPCODE_B4
			B OPCODE_B5
			B OPCODE_B6
			B OPCODE_B7
			B OPCODE_B8
			B OPCODE_B9
			B OPCODE_BA
			B OPCODE_BB
			B OPCODE_BC
			B OPCODE_BD
			B OPCODE_BE
			B OPCODE_BF
			B OPCODE_C0
			B OPCODE_C1
			B OPCODE_C2
			B OPCODE_C3
			B OPCODE_C4
			B OPCODE_C5
			B OPCODE_C6
			B OPCODE_C7
			B OPCODE_C8
			B OPCODE_C9
			B OPCODE_CA
			B OPCODE_CB
			B OPCODE_CC
			B OPCODE_CD
			B OPCODE_CE
			B OPCODE_CF
			B OPCODE_D0
			B OPCODE_D1
			B OPCODE_D2
			B OPCODE_D3
			B OPCODE_D4
			B OPCODE_D5
			B OPCODE_D6
			B OPCODE_D7
			B OPCODE_D8
			B OPCODE_D9
			B OPCODE_DA
			B OPCODE_DB
			B OPCODE_DC
			B OPCODE_DD
			B OPCODE_DE
			B OPCODE_DF
			B OPCODE_E0
			B OPCODE_E1
			B OPCODE_E2
			B OPCODE_E3
			B OPCODE_E4
			B OPCODE_E5
			B OPCODE_E6
			B OPCODE_E7
			B OPCODE_E8
			B OPCODE_E9
			B OPCODE_EA
			B OPCODE_EB
			B OPCODE_EC
			B OPCODE_ED
			B OPCODE_EE
			B OPCODE_EF
			B OPCODE_F0
			B OPCODE_F1
			B OPCODE_F2
			B OPCODE_F3
			B OPCODE_F4
			B OPCODE_F5
			B OPCODE_F6
			B OPCODE_F7
			B OPCODE_F8
			B OPCODE_F9
			B OPCODE_FA
			B OPCODE_FB
			B OPCODE_FC
			B OPCODE_FD
			B OPCODE_FE
			B OPCODE_FF

OPCODE_00:	@ NOP
	@ We do nothing!
	mov r2,#4
B ENDOPCODES

OPCODE_01:	@ LD BC,nn
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT
	add r1,r1,#2			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r9,r9,r12			@ Clear target byte To 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#10
B ENDOPCODES

OPCODE_02:	@ LD (BC),A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	and r1,r9,r12			@ Mask register value to a short (16 bit) value
	bl MEMSTORE 			@ Store value memory
	mov r2,#7
B ENDOPCODES

OPCODE_03:	@ INC BC
	mov r0,r9			@ Get source value
	add r0,r0,#1			@ Increase by 1
	and r0,r0,r12			@ Mask to 16 bits
	bic r9,r9,r12			@ Clear target byte To 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#6
B ENDOPCODES

OPCODE_04:	@ INC B
	mov r0,r9,lsr #8		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibble
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_05:	@ DEC B
	mov r0,r9,lsr #8		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_06:	@ LD B,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_07:	@ RLCA
	and r0,r8,#0xFF			@ Move accumulator into R0
	bic r8,r8,#0xFF			@ Clear old accumulator value
	bic r8,r8,#0x3B00		@ Clear 3,5,H,N,C flags
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	orrne r0,r0,#0x1		@ Set bit 0 of accumulator if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r8,r8,r0			@ Store new value
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#4
B ENDOPCODES

OPCODE_08:	@ EX AF,AF
	ldr r2,=ExReg			@ Get base of EXX register storage
	ldr r0,[r2,#4]			@ Load HLFA at offset 4
	mov r1,r8			@ Move FA to low short
	strb r1,[r2,#4]			@ Store low byte
	mov r1,r1,lsr #8		@ Move FA to low short
	strb r1,[r2,#5]			@ Store low byte
	bic r8,r8,r12			@ Mask of old HL value
	and r0,r0,r12			@ Clear HL segment
	orr r8,r8,r0			@ Clear flags
	mov r2,#4
B ENDOPCODES


OPCODE_D9:	@ EXX
	ldr r2,=ExReg			@ Get base of EXX register storage
	ldr r0,[r2,#4]			@ Load HLFA at offset 4

	ldr r1,[r2,#8]			@ Load DEBC at offset 8
	str r9,[r2,#8]			@ Store current DEBC back to offset 8 and decrease r2 to offset 4
	mov r9,r1			@ Move loaded DEBC to R9
	mov r1,r8,lsr #16		@ Move HL to low short
	strb r1,[r2,#6]			@ Store low byte
	mov r1,r1,lsr #8		@ Shift HL 8 bits to right
	strb r1,[r2,#7]			@ Store high byte
	and r8,r8,r12			@ Mask off old HL value
	bic r0,r0,r12			@ Clear flags and accumulator from loaded value
	orr r8,r8,r0			@ Set new HL value
	mov r2,#4
B ENDOPCODES

.ltorg
.data
ExReg:
.word 0,0,0

.text

OPCODE_09:	@ ADD HL,BC
	and r0,r9,r12			@ Mask to 16 bits
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r8,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r2
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r8,lsr #16		@ Get destination register
	and r2,r2,r12			@ Mask off to 16 bits
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
@	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r2,#11
B ENDOPCODES

OPCODE_0A:	@ LD A,(BC)
	and r1,r9,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD	 		@load value from memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_0B:	@ DEC BC
	mov r0,r9			@ Get source value
	sub r0,r0,#1			@ Decrease by 1
	and r0,r0,r12			@ Mask to 16 bits
	bic r9,r9,r12			@ Clear target byte To 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#6
B ENDOPCODES

OPCODE_0C:	@ INC C
	mov r0,r9			@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibble
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_0D:	@ DEC C
	mov r0,r9			@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_0E:	@ LD C,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_0F:	@ RRCA
	and r0,r8,#0xFF			@ Move accumulator into R0
	bic r8,r8,#0x3B00		@ Clear 3,5,H,N,C flag
	movs r0,r0,lsr #1		@ Shift Right 1
	and r0,r0,#0xFF			@ Mask back to byte
	bic r8,r8,#0xFF			@ Clear old accumulator value
	orr r8,r8,r0			@ Store new value
	orrcs r8,r8,#0x180		@ Set bit 7 and Z80 carry flag if shift cause ARM carry
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#4
B ENDOPCODES

@OPCODE_10:	@ DJNZ (PC+e)
@	and r1,r7,r12			@ Move PC into R2 and mask to 16 bits
@	bl MEMFETCH
@	add r1,r1,#1			@ Increase PC to compensate for byte just loaded
@	mov r3,#0			@ This is for cycle count
@	mov r2,r9,lsr #8		@ Move B register into R0
@	sub r2,r2,#1			@ Decrease by 1
@	ands r2,r2,#0xFF		@ Mask back to byte
@	bic r9,r9,#0xFF00		@ Clear old B reg value
@	orr r9,r9,r2,lsl #8		@ Store new b value
@	addne r3,r3,#5			@ Add 5 tstates
@	addne r1,r1,r0			@ Add to PC
@	tstne r0,#128			@ Check sign for 2's displacemen
@	subne r1,r1,#256 		@ Make amount negative if above 127
@	and r1,r1,r12			@ Mask to 16 bits
@	bic r7,r7,r12			@ Clear old PC
@	orr r7,r7,r1			@ Add new PC
@	add r2,r3,#8			@ Add standard tstates
@B ENDOPCODES


OPCODE_10:	@ DJNZ (PC+e)
	mov r2,r9,lsr #8		@ Move B register into R2
	sub r2,r2,#1			@ Decrease by 1
	ands r2,r2,#0xFF		@ Mask back to byte
	bic r9,r9,#0xFF00		@ Clear old B reg value
	orr r9,r9,r2,lsl #8		@ Store new b value
	addeq r0,r1,#1			@ Adjust PC
	andeq r0,r0,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC
	orreq r7,r7,r0			@ Add new PC
	moveq r2,#8			@ Put tstates in R2
	beq ENDOPCODES
	bl MEMFETCH			@ Get displacement if jump needed (R1 still contains PC correct PC).
	add r1,r1,r0			@ Add to PC
	add r1,r1,#1			@ Adjust for extra byte read
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask to 16 bits
	orr r7,r7,r1			@ Add new PC
	mov r2,#13			@ Put tstates in R2
B ENDOPCODES


OPCODE_11:	@ LD DE,nn
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT
	add r1,r1,#2			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r9,r9,r12			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#10
B ENDOPCODES

OPCODE_12:	@ LD (DE),A

	and r0,r8,#0x000000FF		@ Mask value to a single byte
	mov r1,r9,lsr #16		@ Get value of register
	bl MEMSTORE 			@ Store value in memory
	mov r2,#7
B ENDOPCODES

OPCODE_13:	@ INC DE
	mov r0,r9,lsr #16		@ Get source value
	add r0,r0,#1			@ Increase by 1
@	and r0,r0,r12			@ Mask to 16 bits
	and r9,r9,r12			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#6
B ENDOPCODES

OPCODE_14:	@ INC D
	mov r0,r9,lsr #24		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibbl
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_15:	@ DEC D
	mov r0,r9,lsr #24		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_16:	@ LD D,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_17:	@ RLA
	and r0,r8,#0xFF			@ Move accumulator into R0
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0x3B00		@ Clear 3,5,H,N,C flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	bic r8,r8,#0xFF			@ Clear old accumulator value
	orr r8,r8,r0			@ Store new value
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#4
B ENDOPCODES

OPCODE_18:	@ JR (PC+e)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	bl MEMFETCH2			@ Load byte from address
	add r2,r2,#1			@ Increase PC to compensate for byte just loaded
	add r0,r2,r1			@ Add to PC
	tst r1,#128			@ Check sign for 2's displacemen
	subne r0,r0,#256 		@ Make amount negative if above 127
	and r0,r0,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r0			@ Add new PC
	mov r2,#12
B ENDOPCODES

OPCODE_19:	@ ADD HL,DE
	mov r0,r9,lsr #16		@ Get source valu
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r8,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r2
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r8,lsr #16		@ Get destination register
	and r2,r2,r12			@ Mask off to 16 bits
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
@	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r2,#11
B ENDOPCODES

OPCODE_1A:	@ LD A,(DE)
	mov r1,r9,lsr #16		@ Get value of register
	bl MEMREAD	 		@load value from memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_1B:	@ DEC DE
	mov r0,r9,lsr #16		@ Get source value
	sub r0,r0,#1			@ Decrease by 1
@	and r0,r0,r12			@ Mask to 16 bits
	and r9,r9,r12			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#6
B ENDOPCODES

OPCODE_1C:	@ INC E
	mov r0,r9,lsr #16		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibbl
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_1D:	@ DEC E
	mov r0,r9,lsr #16		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_1E:	@ LD E,n
	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_1F:	@ RRA
	and r0,r8,#0xFF			@ Move accumulator into R0
	mov r1,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0x3B00		@ Clear 3,5,H,N,C flag
	movs r0,r0,lsr #1		@ Shift Right 1
	and r0,r0,#0xFF			@ Mask back to byte
	bic r8,r8,#0xFF			@ Clear old accumulator value
	orr r8,r8,r0			@ Store new value
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r1,#1 			@ Test if old carry was set
	orrne r8,r8,#0x80		@ Set bit 7 of accumulator if so
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#4
B ENDOPCODES

OPCODE_20:	@ JR NZ,(PC+e)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	tst r8,#0x4000			@ Test Z flag
	bne	jrnz
	bl MEMFETCH2			@ Load byte from address
	add r2,r2,#1			@ Increase PC to compensate for byte just loaded
	add r0,r2,r1			@ Add to PC
	tst r1,#128			@ Check sign for 2's displacemen
	subne r0,r0,#256 		@ Make amount negative if above 127
	and r0,r0,r12			@ Mask to 16 bits
	mov r2,#12			@ Tstates
	b jrnzf
jrnz:
	add r2,r2,#1			@ Increase the PC by 1
	and r0,r2,r12			@ Mask to 16 bits
	mov r2,#7			@ Tstates
jrnzf:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r0			@ Add new PC
B ENDOPCODES

OPCODE_21:	@ LD HL,nn
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT
	add r1,r1,#2			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r8,r8,r12			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#10
B ENDOPCODES

OPCODE_22:	@ LD (nn),HL
	mov r0,r8,lsr #16		@ Get source value
	and r2,r7,r12			@ Mask PC register
	add r1,r2,#2			@ Store PC + 2 in R1
	and r1,r1,r12			@ Mask new PC to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store incremented value
	bl MEMFETCHSHORT2		@ Get memory location into R1
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#16
B ENDOPCODES

OPCODE_23:	@ INC HL
	mov r0,r8,lsr #16		@ Get source value
	add r0,r0,#1			@ Increase by 1
@	and r0,r0,r12			@ Mask to 16 bits
	and r8,r8,r12			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#6
B ENDOPCODES

OPCODE_24:	@ INC H
	mov r0,r8,lsr #24		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibbl
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_25:	@ DEC H
	mov r0,r8,lsr #24		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_26:	@ LD H,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_27:	@ DAA
	mov r1,r8,lsl #23		@ Get accumulator and carry flag
	mov r1,r1,lsr #23
	tst r8,#0x1000			@ Test H flag
	orrne r1,r1,#0x200		@ Set bit 9 if H flag was set
	adrl r2,DAA			@ Get start of DAA table
	ldrb r0,[r2,r1]			@ Get DAA offset value
	and r1,r1,#0xFF			@ Mask off bits 8 and 9
	cmp r1,#0x99			@ Do we need to set carry flag
	orrhi r8,r8,#0x100		@ If so, set it
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x200			@ Are we adding or subtracting?
	subne r2,r1,r2
	addeq r2,r1,r2
	bic r8,r8,#0xFC00		@ Clear all flags except C and N
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator  to a single byte
	tst r8,#0x200			@ Are we adding or subtracting?
	subne r2,r2,r0			@ Perform subtraction
	addeq r2,r2,r0			@ Perform addition
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r0,Parity			@ Get start of parity table
	ldrb r1,[r0,r2]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF			@ Clear old accumulator
	orr r8,r8,r2			@ Store new accumulator
	mov r2,#4
B ENDOPCODES

OPCODE_28:	@ JR Z,(PC+e)
	and r2,r7,r12			@Move PC into R2 and mask to 16 bits
	tst r8,#0x4000			@ Test Z flag
	beq	jrz
	bl MEMFETCH2			@ Load byte from address
	add r2,r2,#1			@ Increase PC to compensate for byte just loaded
	add r0,r2,r1			@ Add to PC
	tst r1,#128			@ Check sign for 2's displacement
	subne r0,r0,#256 		@ Make amount negative if above 127
	and r0,r0,r12			@ Mask to 16 bits
	mov r2,#12			@ Tstates
	b jrzf
jrz:
	add r2,r2,#1			@ Increase the PC by 1
	and r0,r2,r12			@ Mask to 16 bits
	mov r2,#7			@ Tstates
jrzf:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r0			@ Add new PC
B ENDOPCODES

OPCODE_29:	@ ADD HL,HL
	mov r0,r8,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r2,r2
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r2,r0,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
@	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r2,#11
B ENDOPCODES

OPCODE_2A:	@ LD HL,(nn)
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT2		@ Get address in R1
	add r2,r2,#2			@ Increment PC
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	bl MEMREADSHORT			@ Load 16 bit value from memory
	and r8,r8,r12			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#16
B ENDOPCODES

OPCODE_2B:	@ DEC HL
	mov r0,r8,lsr #16		@ Get source value
	sub r0,r0,#1			@ Decrease by 1
@	and r0,r0,r12			@ Mask to 16 bits
	and r8,r8,r12			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#6
B ENDOPCODES

OPCODE_2C:	@ INC L
	mov r0,r8,lsr #16		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibbl
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_2D:	@ DEC L
	mov r0,r8,lsr #16		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_2E:	@ LD L,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_2F:	@ CPL
	eor r0,r8,#0xFF			@ Perform XOR on accumulator
	and r0,r0,#0xFF			@ Mask to a byte
	bic r8,r8,#0x3A00		@ Clear 5,H,3 and N flags
	bic r8,r8,#0x00FF		@ Clear accumulator
	orr r8,r8,r0			@ Store accumulator
	tst r8,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r8,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	orr r8,r8,#0x1000		@ Set H flag
	mov r2,#4
B ENDOPCODES

OPCODE_30:	@ JR NC,(PC+e)
	and r2,r7,r12			@Move PC into R2 and mask to 16 bits
	tst r8,#0x100			@ Test C flag
	bne	jrnc
	bl MEMFETCH2			@ Load byte from address
	add r2,r2,#1			@ Increase PC to compensate for byte just loaded
	add r0,r2,r1			@ Add to PC
	tst r1,#128			@ Check sign for 2's displacemen
	subne r0,r0,#256 		@ Make amount negative if above 127
	and r0,r0,r12			@ Mask to 16 bits
	mov r2,#12			@ Tstates
	b jrncf
jrnc:
	add r2,r2,#1			@ Increase the PC by 1
	and r0,r2,r12			@ Mask to 16 bits
	mov r2,#7			@ Tstates
jrncf:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r0			@ Add new PC
B ENDOPCODES

OPCODE_31:	@ LD SP,nn
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT
	add r1,r1,#2			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r7,r7,r12			@ Clear target byte to 0
	orr r7,r7,r0,lsl #16		@ Place value on target register
	mov r2,#10
B ENDOPCODES

OPCODE_32:	@ LD (n),A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	and r2,r7,r12			@ Mask PC register
	add r1,r2,#2			@ Store PC + 2 in R1
	and r1,r1,r12			@ Mask new PC to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store incremented value
	bl MEMFETCHSHORT2		@ Get memory location into R1
	bl MEMSTORE 			@ Store value in memory
	mov r2,#13
B ENDOPCODES

OPCODE_33:	@ INC SP
	mov r0,r7,lsr #16		@ Get source value
	add r0,r0,#1			@ Increase by 1
@	and r0,r0,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear target byte to 0
	orr r7,r7,r0,lsl #16		@ Place value on target register
	mov r2,#6
B ENDOPCODES

OPCODE_34:	@ INC (HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibble
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2 			@ Store value in memory
@	strb r0,[r3]			@ R3 still contains correct address
	mov r2,#11
B ENDOPCODES

OPCODE_35:	@ DEC (HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bl STOREMEM2 			@ Store value in memory
	@strb r0,[r3]			@ R£ still contains correct address
	mov r2,#11
B ENDOPCODES

OPCODE_36:	@ LD (HL),n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMSTORE 			@ Store value in memory
	mov r2,#10
B ENDOPCODES

OPCODE_37:	@ SCF
	bic r8,r8,#0x3A00		@ Clear 5,H,3 and N flags
	tst r8,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r8,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x100		@ Set C flag
	mov r2,#4
B ENDOPCODES

OPCODE_38:	@ JR C,(PC+e)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	tst r8,#0x100			@ Test C flag
	beq	jrc
	bl MEMFETCH2			@ Load byte from address
	add r2,r2,#1			@ Increase PC to compensate for byte just loaded
	add r0,r2,r1			@ Add to PC
	tst r1,#128			@ Check sign for 2's displacement
	subne r0,r0,#256 		@ Make amount negative if above 127
	and r0,r0,r12			@ Mask to 16 bits
	mov r2,#12			@ Tstates
	b jrcf
jrc:
	add r2,r2,#1			@ Increase the PC by 1
	and r0,r2,r12			@ Mask to 16 bits
	mov r2,#7			@ Tstates
jrcf:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r0			@ Add new PC
B ENDOPCODES

OPCODE_39:	@ ADD HL,SP
	mov r0,r7,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r8,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r2
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r8,lsr #16		@ Get destination register
	and r2,r2,r12			@ Mask off to 16 bits
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
@	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r2,#11
B ENDOPCODES

OPCODE_3A:	@ LD A,(n)
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT2		@ Get address
	add r2,r2,#2			@ Increment PC
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	bl MEMREAD	 		@ Load value from memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#13
B ENDOPCODES

OPCODE_3B:	@ DEC SP
	mov r0,r7,lsr #16		@ Get source value
	sub r0,r0,#1			@ Decrease by 1
@	and r0,r0,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear target byte to 0
	orr r7,r7,r0,lsl #16		@ Place value on target register
	mov r2,#6
B ENDOPCODES

OPCODE_3C:	@ INC A
	mov r0,r8			@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibbl
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_3D:	@ DEC A
	mov r0,r8			@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_3E:	@ LD A,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_3F:	@ CCF
	bic r8,r8,#0x3A00		@ Clear 5,H,3 and N flags
	tst r8,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r8,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	tst r8,#0x100			@ Test C flag
	orrne r8,r8,#0x1000		@ Set H flag if C was Set
	eor r8,r8,#0x100		@ Invert C flag
	mov r2,#4
B ENDOPCODES

OPCODE_40:	@ LD B,B
	mov r2,#4
B ENDOPCODES

OPCODE_41:	@ LD B,C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_42:	@ LD B,D
	mov r0,r9,lsr #24		@ Get source value
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_43:	@ LD B,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_44:	@ LD B,H
	mov r0,r8,lsr #24		@ Get source value
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_45:	@ LD B,L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_46:	@ LD B,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD	 		@load value from memory
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_47:	@ LD B,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_48:	@ LD C,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_49:	@ LD C,C
	mov r2,#4
B ENDOPCODES

OPCODE_4A:	@ LD C,D
	mov r0,r9,lsr #24		@ Get source value
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_4B:	@ LD C,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_4C:	@ LD C,H
	mov r0,r8,lsr #24		@ Get source value
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_4D:	@ LD C,L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_4E:	@ LD C,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD	 		@load value from memory
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_4F:	@ LD C,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_50:	@ LD D,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_51:	@ LD D,C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_52:	@ LD D,D
	mov r2,#4
B ENDOPCODES

OPCODE_53:	@ LD D,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_54:	@ LD D,H
	mov r0,r8,lsr #24		@ Get source value
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_55:	@ LD D,L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_56:	@ LD D,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD	 		@load value from memory
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_57:	@ LD D,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_58:	@ LD E,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_59:	@ LD E,C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_5A:	@ LD E,D
	mov r0,r9,lsr #24		@ Get source value
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_5B:	@ LD E,E
	mov r2,#4
B ENDOPCODES

OPCODE_5C:	@ LD E,H
	mov r0,r8,lsr #24		@ Get source value
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_5D:	@ LD E,L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_5E:	@ LD E,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD	 		@load value from memory
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_5F:	@ LD E,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_60:	@ LD H,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_61:	@ LD H,C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_62:	@ LD H,D
	mov r0,r9,lsr #24		@ Get source value
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_63:	@ LD H,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_64:	@ LD H,H
	mov r2,#4
B ENDOPCODES

OPCODE_65:	@ LD H,L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_66:	@ LD H,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD	 		@load value from memory
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_67:	@ LD H,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_68:	@ LD L,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_69:	@ LD L,C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_6A:	@ LD L,D
	mov r0,r9,lsr #24		@ Get source value
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_6B:	@ LD L,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_6C:	@ LD L,H
	mov r0,r8,lsr #24		@ Get source value
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_6D:	@ LD L,L
	mov r2,#4
B ENDOPCODES

OPCODE_6E:	@ LD L,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD	 		@load value from memory
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_6F:	@ LD L,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_70:	@ LD (HL),B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMSTORE 			@ Store value in memory
	mov r2,#7
B ENDOPCODES

OPCODE_71:	@ LD (HL),C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMSTORE 			@ Store value in memory
	mov r2,#7
B ENDOPCODES

OPCODE_72:	@ LD (HL),D
	mov r0,r9,lsr #24		@ Get source value
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMSTORE 			@ Store value in memory
	mov r2,#7
B ENDOPCODES

OPCODE_73:	@ LD (HL),E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMSTORE 			@ Store value in memory
	mov r2,#7
B ENDOPCODES

OPCODE_74:	@ LD (HL),H
	mov r0,r8,lsr #24		@ Get source value
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMSTORE 			@ Store value in memory
	mov r2,#7
B ENDOPCODES

OPCODE_75:	@ LD (HL),L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMSTORE 			@ Store value in memory
	mov r2,#7
B ENDOPCODES

OPCODE_76:	@ HALT
	orr r5,r5,#0x20000		@ Set Halt flag
	mov r2,#4
B ENDOPCODES

OPCODE_77:	@ LD (HL),A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMSTORE 			@ Store value in memory
	mov r2,#7
B ENDOPCODES

OPCODE_78:	@ LD A,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_79:	@ LD A,C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_7A:	@ LD A,D
	mov r0,r9,lsr #24		@ Get source value
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_7B:	@ LD A,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_7C:	@ LD A,H
	mov r0,r8,lsr #24		@ Get source value
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_7D:	@ LD A,L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_7E:	@ LD A,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD	 		@load value from memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_7F:	@ LD A,A
	mov r2,#4
B ENDOPCODES

OPCODE_80:	@ ADD A,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_81:	@ ADD A,C
	and r0,r9,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_82:	@ ADD A,D
	mov r0,r9,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_83:	@ ADD A,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_84:	@ ADD A,H
	mov r0,r8,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_85:	@ ADD A,L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_86:	@ ADD A,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#7
B ENDOPCODES

OPCODE_87:	@ ADD A,A
	and r0,r8,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	add r2,r1,r1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r2,r0,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register

	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_88:	@ ADC A,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_89:	@ ADC A,C
	and r0,r9,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_8A:	@ ADC A,D
	mov r0,r9,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_8B:	@ ADC A,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_8C:	@ ADC A,H
	mov r0,r8,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_8D:	@ ADC A,L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_8E:	@ ADC A,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#7
B ENDOPCODES

OPCODE_8F:	@ ADC A,A
	and r0,r8,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	add r2,r1,r1
	tst r8,#0x100			@ Test carry flag
	addne r2,r2,#1			@ If set add 1
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r2,r0,r0			@ Perform addition
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_90:	@ SUB A,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_91:	@ SUB A,C
	and r0,r9,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_92:	@ SUB A,D
	mov r0,r9,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_93:	@ SUB A,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_94:	@ SUB A,H
	mov r0,r8,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_95:	@ SUB A,L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_96:	@ SUB A,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#7
B ENDOPCODES

OPCODE_97:	@ SUB A,A
	and r0,r8,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	sub r2,r1,r1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	subs r2,r0,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_98:	@ SBC A,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_99:	@ SBC A,C
	and r0,r9,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_9A:	@ SBC A,D
	mov r0,r9,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_9B:	@ SBC A,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_9C:	@ SBC A,H
	mov r0,r8,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_9D:	@ SBC A,L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_9E:	@ SBC A,(HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#7
B ENDOPCODES

OPCODE_9F:	@ SBC A,A
	and r0,r8,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	sub r2,r1,r1
	tst r8,#0x100			@ Test carry flag
	subne r2,r2,#1			@ If set subtract 1
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r2,r0,r0			@ Perform substraction
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_A0:	@ AND B
	mov r0,r9,lsr #8		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_A1:	@ AND C
	mov r0,r9			@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_A2:	@ AND D
	mov r0,r9,lsr #24		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_A3:	@ AND E
	mov r0,r9,lsr #16		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_A4:	@ AND H
	mov r0,r8,lsr #24		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_A5:	@ AND L
	mov r0,r8,lsr #16		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_A6:	@ AND (HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_A7:	@ AND A
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r8,#255			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	mov r2,#4
B ENDOPCODES

OPCODE_A8:	@ XOR B
	mov r0,r9,lsr #8		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_A9:	@ XOR C
	mov r0,r9			@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_AA:	@ XOR D
	mov r0,r9,lsr #24		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_AB:	@ XOR E
	mov r0,r9,lsr #16		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_AC:	@ XOR H
	mov r0,r8,lsr #24		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_AD:	@ XOR L
	mov r0,r8,lsr #16		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_AE:	@ XOR (HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_AF:	@ XOR A
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r8,r8,#0x4000		@ Set Zero flag
	orr r8,r8,#0x400		@ Set parity flag if
	mov r2,#4
B ENDOPCODES

OPCODE_B0:	@ OR B
	mov r0,r9,lsr #8		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_B1:	@ OR C
	mov r0,r9			@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_B2:	@ OR D
	mov r0,r9,lsr #24		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_B3:	@ OR E
	mov r0,r9,lsr #16		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_B4:	@ OR H
	mov r0,r8,lsr #24		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_B5:	@ OR L
	mov r0,r8,lsr #16		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_B6:	@ OR (HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_B7:	@ OR A
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r8,r8			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_B8:	@ CP B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	eor r0,r0,r8			@ Perform XOR between original value and accumulator
	eor r2,r2,r8			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_B9:	@ CP C
	and r0,r9,#0xFF			@ Mask to single byte
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	eor r0,r0,r8			@ Perform XOR between original value and accumulator
	eor r2,r2,r8			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_BA:	@ CP D
	mov r0,r9,lsr #24		@ Get source value
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	eor r0,r0,r8			@ Perform XOR between original value and accumulator
	eor r2,r2,r8			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_BB:	@ CP E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	eor r0,r0,r8			@ Perform XOR between original value and accumulator
	eor r2,r2,r8			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128				@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_BC:	@ CP H
	mov r0,r8,lsr #24		@ Get source value
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	eor r0,r0,r8			@ Perform XOR between original value and accumulator
	eor r2,r2,r8			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_BD:	@ CP L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	eor r0,r0,r8			@ Perform XOR between original value and accumulator
	eor r2,r2,r8			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#4
B ENDOPCODES

OPCODE_BE:	@ CP (HL)
	mov r1,r8,lsr #16		@ Get value of register
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8				@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	eor r0,r0,r8			@ Perform XOR between original value and accumulator
	eor r2,r2,r8			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#7
B ENDOPCODES

OPCODE_BF:	@ CP A

	bic r8,r8,#0xFF00		@ Clear all flags

	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r1			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	@ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orr r8,r8,#0x4200		@ Set Z and N flags
	and r1,r7,r12			@ Get PC
	mov r0,#0x500
	add r0,r0,#0x6B
	cmp r1,r0
	ldreq r0,=tapetype
	ldreq r3,[r0]
	@ldreq r3,[r0,#104]		@1=tap 2 =tzx
	cmpeq r3,#1
	orreq r5,r5,#0x800000		@ Set Tape loader flag
	moveq r11,#4			@ Interrupt so tape loading can start
	mov r2,#4
B ENDOPCODES

.ltorg
.data

tapetype:
.word 0
.text

OPCODE_C0:	@ RET NZ
	mov r2,#5			@ Tstates
	tst r8,#0x4000			@ Test NZ flag
	bne ENDOPCODES
	mov r1,r7,lsr #16		@ Put SP in R2
	bl MEMREADSHORT			@ Retrieve PC into R1
	mov r7,r0			@ Put it into R7 (PC)
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#11			@ Increase Tstates
B ENDOPCODES

OPCODE_C1:	@ POP BC
	mov r1,r7,lsr #16		@ Put SP in R2
	bl MEMREADSHORT
	add r1,r1,#2			@ Increase SP
	and r7,r7,r12			@ lLear old SP value
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	bic r9,r9,r12			@ Clear target byte To 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#10
B ENDOPCODES

OPCODE_C2:	@ JP NZ,(nn)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	tst r8,#0x4000			@ Test Z flag
	movne r1,r7			@ Get old PC if cond not met
	addne r1,r1,#2			@ Increase the PC by 2
	andne r1,r1,r12			@ Mask to 16 bits
	bleq MEMFETCHSHORT2		@ Read address into R1
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r1			@ Add new PC
	mov r2,#10
B ENDOPCODES

OPCODE_C3:	@ JP (nn)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	bl MEMFETCHSHORT2		@ Read address into R1
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r1			@ Add new PC
	mov r2,#10
B ENDOPCODES

OPCODE_C4:	@ CALL NZ,(nn)
	tst r8,#0x4000			@ Test Z flag
	bne callnz
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	bl MEMFETCHSHORT2		@ Get address from current PC into r1
	mov r4,r1			@ Save address in R4
	add r0,r2,#2			@ Increase Pc by 2
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#17			@ set tstates
	b callnzf
callnz:
	mov r1,r7			@ Get old PC if cond not met
	add r1,r1,#2			@ Increase the PC by 2
	and r4,r1,r12			@ Mask to 16 bits
	mov r2,#10			@ set tstates
callnzf:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r4			@ Add new PC
B ENDOPCODES

OPCODE_C5:	@ PUSH BC

	and r0,r9,r12			@ Mask to 16 bits
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#11
B ENDOPCODES

OPCODE_C6:	@ ADD A,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#7
B ENDOPCODES

OPCODE_C7:	@ RST 0H
	and r0,r7,r12			@ Move PC into R0 and mask to 16 bits
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memor
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,#0x0			@ Add New PC
	mov r2,#11
B ENDOPCODES

OPCODE_C8:	@ RET Z
	mov r2,#5			@ Tstates
	tst r8,#0x4000			@ Test NZ flag
	beq ENDOPCODES
	mov r1,r7,lsr #16		@ Put SP in R2
	bl MEMREADSHORT			@ Retrieve PC into R1
	and r7,r0,r12			@ Put it into R7 (PC)
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#11			@ Increase Tstates
b ENDOPCODES

OPCODE_C9:	@ RET
	mov r2,r7,lsr #16		@Put SP in R2
	bl MEMREADSHORT2
	mov r7,r1			@Create 16 bit address in PC Register
	add r2,r2,#2			@Increase SP
	add r7,r7,r2,lsl #16		@Put SP in Reg 7
	mov r2,#10
B ENDOPCODES

OPCODE_CA:	@ JP Z,(nn)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	tst r8,#0x4000			@ Test Z flag
	moveq r1,r7			@ Get old PC if cond not met
	addeq r1,r1,#2			@ Increase the PC by 2
	andeq r1,r1,r12			@ Mask to 16 bits
	blne MEMFETCHSHORT2		@ Read address into R1
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r1			@ Add new PC
	mov r2,#10
B ENDOPCODES

OPCODE_CB:	@ CB
	b CBCODES
B ENDOPCODES

OPCODE_CC:	@ CALL Z,(nn)
	tst r8,#0x4000			@Test Z flag
	beq callz
	and r2,r7,r12			@Move PC into R2 and mask to 16 bits
	bl MEMFETCHSHORT2		@Get address from current PC into r1
	mov r4,r1			@Save address in R4
	add r0,r2,#2			@Increase Pc by 2
	mov r1,r7,lsr #16		@Put SP into R1
	sub r1,r1,#2			@Decrease stack by 2
	and r1,r1,r12			@Mask to 16 bits
	and r7,r7,r12			@Clear old SP
	orr r7,r7,r1,lsl #16		@Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#17			@ set tstates
	b callzf
callz:
	mov r1,r7			@ Get old PC if cond not met
	add r1,r1,#2			@ Increase the PC by 2
	and r4,r1,r12			@ Mask to 16 bits
	mov r2,#10			@ set tstates
callzf:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r4			@ Add new PC
B ENDOPCODES

OPCODE_CD:	@ CALL (nn)
	and r2,r7,r12			@Move PC into R2 and mask to 16 bits
	bl MEMFETCHSHORT2		@Get address from current PC into r1
	mov r4,r1			@Save address in R4
	add r0,r2,#2			@Increase Pc by 2
	mov r1,r7,lsr #16		@Put SP into R1
	sub r1,r1,#2			@Decrease stack by 2
	and r1,r1,r12			@Mask to 16 bits
	and r7,r7,r12			@Clear old SP
	orr r7,r7,r1,lsl #16		@Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r4			@ Add new PC
	mov r2,#17
B ENDOPCODES

OPCODE_CE:	@ ADC A,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#7
B ENDOPCODES

OPCODE_CF:	@ RST 8H
	and r0,r7,r12			@ Move PC into R0 and mask to 16 bits
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memor
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,#0x8			@ Add New PC
	mov r2,#11
B ENDOPCODES

OPCODE_D0:	@ RET NC
	mov r2,#5			@ Tstates
	tst r8,#0x100			@ Test NC flag
	bne ENDOPCODES
	mov r1,r7,lsr #16		@ Put SP in R2
	bl MEMREADSHORT			@ Retrieve PC into R1
	mov r7,r0			@ Put it into R7 (PC)
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#11			@ Increase Tstates
B ENDOPCODES

OPCODE_D1:	@ POP DE
	mov r1,r7,lsr #16		@Put SP in R2
	bl MEMREADSHORT
	add r1,r1,#2			@ Increase SP
	and r7,r7,r12			@ CLear old SP value
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	and r9,r9,r12			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#10
B ENDOPCODES

OPCODE_D2:	@ JP NC,(nn)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	tst r8,#0x100			@ Test C flag
	movne r1,r7			@ Get old PC if cond not met
	addne r1,r1,#2			@ Increase the PC by 2
	andne r1,r1,r12			@ Mask to 16 bits
	bleq MEMFETCHSHORT2		@ Read address into R1
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r1			@ Add new PC
	mov r2,#10
B ENDOPCODES

OPCODE_D3:	@ OUT (n),A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2			@ Load byte from address
	add r2,r2,#1			@ Increment PC
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	and r0,r8,#0xFF			@ Get port number

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_out] @ r0=port r1=data
    ldmia sp!,{r3,r12,lr}

	mov r2,#11
B ENDOPCODES

OPCODE_D4:	@ CALL NC,(nn)
	tst r8,#0x100			@Test C flag
	bne callnc
	and r2,r7,r12			@Move PC into R2 and mask to 16 bits
	bl MEMFETCHSHORT2		@Get address from current PC into r1
	mov r4,r1			@Save address in R4
	add r0,r2,#2			@Increase Pc by 2
	mov r1,r7,lsr #16		@Put SP into R1
	sub r1,r1,#2			@Decrease stack by 2
	and r1,r1,r12			@Mask to 16 bits
	and r7,r7,r12			@Clear old SP
	orr r7,r7,r1,lsl #16		@Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#17			@ set tstates
	b callncf
callnc:
	mov r1,r7			@ Get old PC if cond not met
	add r1,r1,#2			@ Increase the PC by 2
	and r4,r1,r12			@ Mask to 16 bits
	mov r2,#10			@ set tstates
callncf:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r4			@ Add new PC
B ENDOPCODES

OPCODE_D5:	@ PUSH DE
	mov r0,r9,lsr #16		@ Get source value
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#11
B ENDOPCODES

OPCODE_D6:	@ SUB A,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#7
B ENDOPCODES

OPCODE_D7:	@ RST 10H
	and r0,r7,r12			@ Move PC into R0 and mask to 16 bits
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memor
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,#0x10			@ Add New PC
	mov r2,#11
B ENDOPCODES

OPCODE_D8:	@ RET C
	mov r2,#5			@ Tstates
	tst r8,#0x100			@ Test NC flag
	beq ENDOPCODES
	mov r1,r7,lsr #16		@ Put SP in R2
	bl MEMREADSHORT			@ Retrieve PC into R1
	mov r7,r0			@ Put it into R7 (PC)
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#11			@ Increase Tstates
B ENDOPCODES

OPCODE_DA:	@ JP C,(nn)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	tst r8,#0x100			@ Test C flag
	moveq r1,r7			@ Get old PC if cond not met
	addeq r1,r1,#2			@ Increase the PC by 2
	andeq r1,r1,r12			@ Mask to 16 bits
	blne MEMFETCHSHORT2		@ Read address into R1
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r1			@ Add new PC
	mov r2,#10
B ENDOPCODES

OPCODE_DB:	@ IN A,(n)
	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r8,#0xFF			@ Get port number
	orr r0,r0,r1,lsl #8

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}

	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#11
B ENDOPCODES

OPCODE_DC:	@ CALL C,(nn)
	tst r8,#0x100			@Test C flag
	beq callc
	and r2,r7,r12			@Move PC into R2 and mask to 16 bits
	bl MEMFETCHSHORT2		@Get address from current PC into r1
	mov r4,r1			@Save address in R4
	add r0,r2,#2			@Increase Pc by 2
	mov r1,r7,lsr #16		@Put SP into R1
	sub r1,r1,#2			@Decrease stack by 2
	and r1,r1,r12			@Mask to 16 bits
	and r7,r7,r12			@Clear old SP
	orr r7,r7,r1,lsl #16		@Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#17			@ set tstates
	b callcf
callc:
	mov r1,r7			@ Get old PC if cond not met
	add r1,r1,#2			@ Increase the PC by 2
	and r4,r1,r12			@ Mask to 16 bits
	mov r2,#10			@ set tstates
callcf:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r4			@ Add new PC
B ENDOPCODES

OPCODE_DD:	@ DD
	b DDCODES
B ENDOPCODES

OPCODE_DE:	@ SBC A,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#7
B ENDOPCODES

OPCODE_DF:	@ RST 18H
	and r0,r7,r12			@ Move PC into R0 and mask to 16 bits
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memor
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,#0x18			@ Add New PC
	mov r2,#11
B ENDOPCODES

OPCODE_E0:	@ RET PO
	mov r2,#5			@ Tstates
	tst r8,#0x400			@ Test PO flag
	bne ENDOPCODES
	mov r1,r7,lsr #16		@ Put SP in R2
	bl MEMREADSHORT			@ Retrieve PC into R1
	mov r7,r0			@ Put it into R7 (PC)
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#11			@ Increase Tstates
B ENDOPCODES

OPCODE_E1:	@ POP HL
	mov r1,r7,lsr #16		@ Put SP in R2
	bl MEMREADSHORT
	add r1,r1,#2			@ Increase SP
	and r7,r7,r12			@ Clear old SP value
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	and r8,r8,r12			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#10
B ENDOPCODES

OPCODE_E2:	@ JP PO,(nn)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	tst r8,#0x400			@ Test P flag
	movne r1,r7			@ Get old PC if cond not met
	addne r1,r1,#2			@ Increase the PC by 2
	andne r1,r1,r12			@ Mask to 16 bits
	bleq MEMFETCHSHORT2		@ Read address into R1
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r1			@ Add new PC
	mov r2,#10
B ENDOPCODES

OPCODE_E3:	@ EX (SP),HL
	mov r2,r7,lsr #16		@ Get location of SP
	bl MEMREADSHORT2		@ Get value in SP location into R1
	mov r0,r8,lsr #16		@ Get source value
	and r8,r8,r12			@ Clear source byte to 0
	orr r8,r8,r1,lsl #16		@ Place value on target register
	mov r1,r7,lsr #16		@ Get value of SP
	bl MEMSTORESHORT		@ Store to memory
	mov r2,#23
B ENDOPCODES

OPCODE_E4:	@ CALL PO,(nn)
	tst r8,#0x400			@Test P flag
	bne callpo
	and r2,r7,r12			@Move PC into R2 and mask to 16 bits
	bl MEMFETCHSHORT2		@Get address from current PC into r1
	mov r4,r1			@Save address in R4
	add r0,r2,#2			@Increase Pc by 2
	mov r1,r7,lsr #16		@Put SP into R1
	sub r1,r1,#2			@Decrease stack by 2
	and r1,r1,r12			@Mask to 16 bits
	and r7,r7,r12			@Clear old SP
	orr r7,r7,r1,lsl #16		@Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#17			@ set tstates
	b callpof
callpo:
	mov r1,r7			@ Get old PC if cond not met
	add r1,r1,#2			@ Increase the PC by 2
	and r4,r1,r12			@ Mask to 16 bits
	mov r2,#10			@ set tstates
callpof:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r4			@ Add new PC
B ENDOPCODES

OPCODE_E5:	@ PUSH HL
	mov r0,r8,lsr #16		@ Get source value
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#11
B ENDOPCODES

OPCODE_E6:	@ AND n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_E7:	@ RST 20H
	and r0,r7,r12			@ Move PC into R0 and mask to 16 bits
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memor
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,#0x20			@ Add New PC
	mov r2,#11
B ENDOPCODES

OPCODE_E8:	@ RET PE
	mov r2,#5			@ Tstates
	tst r8,#0x400			@ Test PE flag
	beq ENDOPCODES
	mov r1,r7,lsr #16		@ Put SP in R2
	bl MEMREADSHORT			@ Retrieve PC into R1
	mov r7,r0			@ Put it into R7 (PC)
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#11			@ Increase Tstates
B ENDOPCODES

OPCODE_E9:	@ JP (HL)
	mov r0,r8,lsr #16		@ Move HL into R0
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r0			@ Add new PC
	mov r2,#4
B ENDOPCODES

OPCODE_EA:	@ JP PE,(nn)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	tst r8,#0x400			@ Test P flag
	moveq r1,r7			@ Get old PC if cond not met
	addeq r1,r1,#2			@ Increase the PC by 2
	andeq r1,r1,r12			@ Mask to 16 bits
	blne MEMFETCHSHORT2		@ Read address into R1
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r1			@ Add new PC
	mov r2,#10
B ENDOPCODES

OPCODE_EB:	@ EX DE,HL
	mov r0,r8,lsr #16		@ Get source value
	mov r1,r9,lsr #16		@ Get destination register
	and r9,r9,r12			@ Clear target byte to 0
	and r8,r8,r12			@ Clear source byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	orr r8,r8,r1,lsl #16		@ Place value on target register
	mov r2,#4
B ENDOPCODES

OPCODE_EC:	@ CALL PE,(nn)
	tst r8,#0x400			@ Test P flag
	beq callpe
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	bl MEMFETCHSHORT2		@ Get address from current PC into r1
	mov r4,r1			@ Save address in R4
	add r0,r2,#2			@ Increase Pc by 2
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#17			@ set tstates
	b callpef
callpe:
	mov r1,r7			@ Get old PC if cond not met
	add r1,r1,#2			@ Increase the PC by 2
	and r4,r1,r12			@ Mask to 16 bits
	mov r2,#10			@ set tstates
callpef:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r4			@ Add new PC
B ENDOPCODES

OPCODE_ED:	@ ED
	b EXCODES
B ENDOPCODES

OPCODE_EE:	@ XOR n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_EF:	@ RST 28H
	and r0,r7,r12			@ Move PC into R0 and mask to 16 bits
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memor
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,#0x28			@ Add New PC
	mov r2,#11
B ENDOPCODES

OPCODE_F0:	@ RET P
	mov r2,#5			@ Tstates
	tst r8,#0x8000			@ Test P flag
	bne ENDOPCODES
	mov r1,r7,lsr #16		@ Put SP in R2
	bl MEMREADSHORT			@ Retrieve PC into R1
	mov r7,r0			@ Put it into R7 (PC)
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#11			@ Increase Tstates
B ENDOPCODES

OPCODE_F1:	@ POP AF
	mov r1,r7,lsr #16		@ Put SP in R1
	bl MEMREADSHORT3
	add r1,r1,#2			@ Increase SP
	and r7,r7,r12			@ Clear old SP value
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	bic r8,r8,r12			@ Clear target byte To 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#10
B ENDOPCODES

OPCODE_F2:	@ JP P,(nn)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	tst r8,#0x8000			@ Test S flag
	movne r1,r7			@ Get old PC if cond not met
	addne r1,r1,#2			@ Increase the PC by 2
	andne r1,r1,r12			@ Mask to 16 bits
	bleq MEMFETCHSHORT2		@ Read address into R1
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r1			@ Add new PC
	mov r2,#10
B ENDOPCODES

OPCODE_F3:	@ DI
	bic r5,r5,#0xC0000000		@ Set IFF1 and IFF2 flags (bits 31 and 30)
	mov r2,#4
B ENDOPCODES

OPCODE_F4:	@ CALL P,(nn)
	tst r8,#0x8000			@Test S flag
	bne callp
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	bl MEMFETCHSHORT2		@ Get address from current PC into r1
	mov r4,r1			@ Save address in R4
	add r0,r2,#2			@ Increase Pc by 2
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#17			@ set tstates
	b callpf
callp:
	mov r1,r7			@ Get old PC if cond not met
	add r1,r1,#2			@ Increase the PC by 2
	and r4,r1,r12			@ Mask to 16 bits
	mov r2,#10			@ set tstates
callpf:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r4			@ Add new PC
B ENDOPCODES

OPCODE_F5:	@ PUSH AF
	and r0,r8,r12			@ Mask to 16 bits
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r2,r1,#2			@ Decrease stack by 2
	and r2,r2,r12			@ Mask to 16 bits
	add r1,r2,#1
	bl MEMSTORE			@ Store value in memory
	mov r0,r0,lsr #8
	mov r1,r2
	bl MEMSTORE			@ Store value in memory
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r2,lsl #16		@ Replace with new SP
	mov r2,#11
B ENDOPCODES

OPCODE_F6:	@ OR n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#7
B ENDOPCODES

OPCODE_F7:	@ RST 30H
	and r0,r7,r12			@ Move PC into R0 and mask to 16 bits
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memor
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,#0x30			@ Add New PC
	mov r2,#11
B ENDOPCODES

OPCODE_F8:	@ RET M
	mov r2,#5			@ Tstates
	tst r8,#0x8000			@ Test M flag
	beq ENDOPCODES
	mov r1,r7,lsr #16		@ Put SP in R2
	bl MEMREADSHORT			@ Retrieve PC into R1
	mov r7,r0			@ Put it into R7 (PC)
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#11			@ Increase Tstates
B ENDOPCODES

OPCODE_F9:	@ LD SP,HL
	mov r0,r8,lsr #16		@ Get source value
	and r7,r7,r12			@ Clear target byte to 0
	orr r7,r7,r0,lsl #16		@ Place value on target register
	mov r2,#6
B ENDOPCODES

OPCODE_FA:	@ JP M,(nn)
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	tst r8,#0x8000			@ Test S flag
	moveq r1,r7			@ Get old PC if cond not met
	addeq r1,r1,#2			@ Increase the PC by 2
	andeq r1,r1,r12			@ Mask to 16 bits
	blne MEMFETCHSHORT2		@ Read address into R1
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r1			@ Add new PC
	mov r2,#10
B ENDOPCODES

OPCODE_FB:	@ EI
	orr r5,r5,#0xC0000000		@ Set IFF1 and IFF2 flags (bits 31 and 30)
	mov r2,#4
B ENDOPCODES

OPCODE_FC:	@ CALL M,(nn)
	tst r8,#0x8000			@ Test S flag
	beq callm
	and r2,r7,r12			@ Move PC into R2 and mask to 16 bits
	bl MEMFETCHSHORT2		@ Get address from current PC into r1
	mov r4,r1			@ Save address in R4
	add r0,r2,#2			@ Increase Pc by 2
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#17			@ set tstates
	b callmf
callm:
	mov r1,r7			@ Get old PC if cond not met
	add r1,r1,#2			@ Increase the PC by 2
	and r4,r1,r12			@ Mask to 16 bits
	mov r2,#10			@ set tstates
callmf:
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r4			@ Add new PC
B ENDOPCODES

OPCODE_FD:	@ FD
	b FDCODES
B ENDOPCODES

OPCODE_FE:	@ CP n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#7
B ENDOPCODES

OPCODE_FF:	@ RST 38H
	and r0,r7,r12			@ Move PC into R0 and mask to 16 bits
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memor
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,#0x38			@ Add New PC
	mov r2,#11
B ENDOPCODES

EXCODES:
	bl MEMFETCH
	add r1,r1,#1		@R1 should still contain the PC so increment
	and r1,r1,r12		@Mask the 16 bits that relate to the PC
	bic r7,r7,r12		@Clear the old PC value
	orr r7,r7,r1		@Store the new PC value
	add r3,r5,#1
	and r3,r3,#127
	bic r5,r5,#127
	orr r5,r5,r3				@ 4 Lines to increase r register!
@	adrl r3,rpointer
@	ldr r2,[r3]    		@These three lines store the opcode For debugging
@	Str r0,[r2,#40]
	add r15,r15,r0, lsl #2  @Multipy opcode by 4 To get value To add To PC

	nop

			B EXOPCODE_00
			B EXOPCODE_01
			B EXOPCODE_02
			B EXOPCODE_03
			B EXOPCODE_04
			B EXOPCODE_05
			B EXOPCODE_06
			B EXOPCODE_07
			B EXOPCODE_08
			B EXOPCODE_09
			B EXOPCODE_0A
			B EXOPCODE_0B
			B EXOPCODE_0C
			B EXOPCODE_0D
			B EXOPCODE_0E
			B EXOPCODE_0F
			B EXOPCODE_10
			B EXOPCODE_11
			B EXOPCODE_12
			B EXOPCODE_13
			B EXOPCODE_14
			B EXOPCODE_15
			B EXOPCODE_16
			B EXOPCODE_17
			B EXOPCODE_18
			B EXOPCODE_19
			B EXOPCODE_1A
			B EXOPCODE_1B
			B EXOPCODE_1C
			B EXOPCODE_1D
			B EXOPCODE_1E
			B EXOPCODE_1F
			B EXOPCODE_20
			B EXOPCODE_21
			B EXOPCODE_22
			B EXOPCODE_23
			B EXOPCODE_24
			B EXOPCODE_25
			B EXOPCODE_26
			B EXOPCODE_27
			B EXOPCODE_28
			B EXOPCODE_29
			B EXOPCODE_2A
			B EXOPCODE_2B
			B EXOPCODE_2C
			B EXOPCODE_2D
			B EXOPCODE_2E
			B EXOPCODE_2F
			B EXOPCODE_30
			B EXOPCODE_31
			B EXOPCODE_32
			B EXOPCODE_33
			B EXOPCODE_34
			B EXOPCODE_35
			B EXOPCODE_36
			B EXOPCODE_37
			B EXOPCODE_38
			B EXOPCODE_39
			B EXOPCODE_3A
			B EXOPCODE_3B
			B EXOPCODE_3C
			B EXOPCODE_3D
			B EXOPCODE_3E
			B EXOPCODE_3F
			B EXOPCODE_40
			B EXOPCODE_41
			B EXOPCODE_42
			B EXOPCODE_43
			B EXOPCODE_44
			B EXOPCODE_45
			B EXOPCODE_46
			B EXOPCODE_47
			B EXOPCODE_48
			B EXOPCODE_49
			B EXOPCODE_4A
			B EXOPCODE_4B
			B EXOPCODE_4C
			B EXOPCODE_4D
			B EXOPCODE_4E
			B EXOPCODE_4F
			B EXOPCODE_50
			B EXOPCODE_51
			B EXOPCODE_52
			B EXOPCODE_53
			B EXOPCODE_54
			B EXOPCODE_55
			B EXOPCODE_56
			B EXOPCODE_57
			B EXOPCODE_58
			B EXOPCODE_59
			B EXOPCODE_5A
			B EXOPCODE_5B
			B EXOPCODE_5C
			B EXOPCODE_5D
			B EXOPCODE_5E
			B EXOPCODE_5F
			B EXOPCODE_60
			B EXOPCODE_61
			B EXOPCODE_62
			B EXOPCODE_63
			B EXOPCODE_64
			B EXOPCODE_65
			B EXOPCODE_66
			B EXOPCODE_67
			B EXOPCODE_68
			B EXOPCODE_69
			B EXOPCODE_6A
			B EXOPCODE_6B
			B EXOPCODE_6C
			B EXOPCODE_6D
			B EXOPCODE_6E
			B EXOPCODE_6F
			B EXOPCODE_70
			B EXOPCODE_71
			B EXOPCODE_72
			B EXOPCODE_73
			B EXOPCODE_74
			B EXOPCODE_75
			B EXOPCODE_76
			B EXOPCODE_77
			B EXOPCODE_78
			B EXOPCODE_79
			B EXOPCODE_7A
			B EXOPCODE_7B
			B EXOPCODE_7C
			B EXOPCODE_7D
			B EXOPCODE_7E
			B EXOPCODE_7F
			B EXOPCODE_80
			B EXOPCODE_81
			B EXOPCODE_82
			B EXOPCODE_83
			B EXOPCODE_84
			B EXOPCODE_85
			B EXOPCODE_86
			B EXOPCODE_87
			B EXOPCODE_88
			B EXOPCODE_89
			B EXOPCODE_8A
			B EXOPCODE_8B
			B EXOPCODE_8C
			B EXOPCODE_8D
			B EXOPCODE_8E
			B EXOPCODE_8F
			B EXOPCODE_90
			B EXOPCODE_91
			B EXOPCODE_92
			B EXOPCODE_93
			B EXOPCODE_94
			B EXOPCODE_95
			B EXOPCODE_96
			B EXOPCODE_97
			B EXOPCODE_98
			B EXOPCODE_99
			B EXOPCODE_9A
			B EXOPCODE_9B
			B EXOPCODE_9C
			B EXOPCODE_9D
			B EXOPCODE_9E
			B EXOPCODE_9F
			B EXOPCODE_A0
			B EXOPCODE_A1
			B EXOPCODE_A2
			B EXOPCODE_A3
			B EXOPCODE_A4
			B EXOPCODE_A5
			B EXOPCODE_A6
			B EXOPCODE_A7
			B EXOPCODE_A8
			B EXOPCODE_A9
			B EXOPCODE_AA
			B EXOPCODE_AB
			B EXOPCODE_AC
			B EXOPCODE_AD
			B EXOPCODE_AE
			B EXOPCODE_AF
			B EXOPCODE_B0
			B EXOPCODE_B1
			B EXOPCODE_B2
			B EXOPCODE_B3
			B EXOPCODE_B4
			B EXOPCODE_B5
			B EXOPCODE_B6
			B EXOPCODE_B7
			B EXOPCODE_B8
			B EXOPCODE_B9
			B EXOPCODE_BA
			B EXOPCODE_BB
			B EXOPCODE_BC
			B EXOPCODE_BD
			B EXOPCODE_BE
			B EXOPCODE_BF
			B EXOPCODE_C0
			B EXOPCODE_C1
			B EXOPCODE_C2
			B EXOPCODE_C3
			B EXOPCODE_C4
			B EXOPCODE_C5
			B EXOPCODE_C6
			B EXOPCODE_C7
			B EXOPCODE_C8
			B EXOPCODE_C9
			B EXOPCODE_CA
			B EXOPCODE_CB
			B EXOPCODE_CC
			B EXOPCODE_CD
			B EXOPCODE_CE
			B EXOPCODE_CF
			B EXOPCODE_D0
			B EXOPCODE_D1
			B EXOPCODE_D2
			B EXOPCODE_D3
			B EXOPCODE_D4
			B EXOPCODE_D5
			B EXOPCODE_D6
			B EXOPCODE_D7
			B EXOPCODE_D8
			B EXOPCODE_D9
			B EXOPCODE_DA
			B EXOPCODE_DB
			B EXOPCODE_DC
			B EXOPCODE_DD
			B EXOPCODE_DE
			B EXOPCODE_DF
			B EXOPCODE_E0
			B EXOPCODE_E1
			B EXOPCODE_E2
			B EXOPCODE_E3
			B EXOPCODE_E4
			B EXOPCODE_E5
			B EXOPCODE_E6
			B EXOPCODE_E7
			B EXOPCODE_E8
			B EXOPCODE_E9
			B EXOPCODE_EA
			B EXOPCODE_EB
			B EXOPCODE_EC
			B EXOPCODE_ED
			B EXOPCODE_EE
			B EXOPCODE_EF
			B EXOPCODE_F0
			B EXOPCODE_F1
			B EXOPCODE_F2
			B EXOPCODE_F3
			B EXOPCODE_F4
			B EXOPCODE_F5
			B EXOPCODE_F6
			B EXOPCODE_F7
			B EXOPCODE_F8
			B EXOPCODE_F9
			B EXOPCODE_FA
			B EXOPCODE_FB
			B EXOPCODE_FC
			B EXOPCODE_FD
			B EXOPCODE_FE
			B EXOPCODE_FF

EXOPCODE_00:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_01:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_02:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_03:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_04:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_05:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_06:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_07:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_08:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_09:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_0A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_0B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_0C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_0D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_0E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_0F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_10:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_11:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_12:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_13:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_14:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_15:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_16:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_17:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_18:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_19:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_1A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_1B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_1C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_1D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_1E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_1F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_20:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_21:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_22:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_23:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_24:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_25:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_26:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_27:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_28:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_29:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_2A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_2B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_2C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_2D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_2E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_2F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_30:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_31:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_32:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_33:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_34:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_35:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_36:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_37:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_38:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_39:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_3A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_3B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_3C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_3D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_3E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_3F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_40:		@IN B,(C)

	and r0,r9,r12			@ Mask B Reg (Port number)

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}


	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#12
B ENDOPCODES

EXOPCODE_41:		@OUT (C),B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	and r1,r1,#0xFF			@ Mask B Reg (Port number)

	mov r2,#12
B ENDOPCODES

EXOPCODE_42:		@SBC HL,BC
	and r0,r9,r12			@ Maskto 16 bits
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r8,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r8,lsr #16		@ Get destination register
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform subtraction
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,r12			@ Mask back to 16 bits and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#32768			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r1,r8,lsr #16		@ Get destination register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#32768			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

EXOPCODE_43:		@LD (nn),BC
	and r0,r9,r12			@ Mask value to a 16 bit number
	and r2,r7,r12			@ Mask PC register
	add r1,r2,#2			@ Store PC + 2 in R1
	and r1,r1,r12			@ Mask new PC to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store incremented value
	bl MEMFETCHSHORT2		@ Get memory location into R1
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#20
B ENDOPCODES

EXOPCODE_44:		@NEG
	mov r0,#0			@ Put 0 in R0
	and r2,r8,#15			@ Mask off to a low nibble of accumulator
	sub r2,r0,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask accumulator off to a single byte
	subs r2,r0,r2			@ Perform subtraction
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r8,r8,#0xFF			@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	and r0,r8,r2			@ And the accumulator and result
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

EXOPCODE_45:		@RETN
	bic r5,r5,#0x40000000		@ Clear old IFF 1 value
	tst r5,#0x80000000		@ Test IFF 2 value
	orrne r5,r5,#0x40000000		@ Set IFF1 to same as IFF2
	mov r1,r7,lsr #16		@ Put SP in R1
	bl MEMREADSHORT
	mov r7,r0			@ Put new PC in R7
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#14
B ENDOPCODES

EXOPCODE_46:		@IM 0
	bic r5,r5,#0x30000000		@ Set IM to 0, flags (bits 29 And 28 cleared)
	mov r2,#8
B ENDOPCODES

EXOPCODE_47:		@LD I,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r5,r5,#0x0000FF00		@ Clear target byte to 0
	orr r5,r5,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

EXOPCODE_48:		@IN C,(C)
	and r0,r9,r12			@ Mask B Reg (Port number)

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}


	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#12
B ENDOPCODES

EXOPCODE_49:		@OUT (C),C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	and r1,r1,#0xFF			@ Mask B Reg (Port number)

	mov r2,#12
B ENDOPCODES

EXOPCODE_4A:		@ADC HL,BC
	and r0,r9,r12			@ Maskto 16 bits
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r8,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r8,lsr #16		@ Get destination register
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,r12			@ Mask back to 16 bits and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#32768			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r1,r8,lsr #16		@ Get destination register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#32768			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

EXOPCODE_4B:		@LD BC,(nn)
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT2		@ Get address
	add r2,r2,#2			@ Increment PC
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	bl MEMREADSHORT			@ Load 16 bit value from memory
	bic r9,r9,r12			@ Clear target byte To 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#20
B ENDOPCODES

EXOPCODE_4C:		@NEG
	mov r0,#0			@ Put 0 in R0
	and r2,r8,#15			@ Mask off to a low nibble of accumulator
	sub r2,r0,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask accumulator off to a single byte
	subs r2,r0,r2			@ Perform subtraction
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r8,r8,#0xFF			@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	and r0,r8,r2			@ And the accumulator and result
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

EXOPCODE_4D:		@RETI
	bic r5,r5,#0x40000000		@ Clear old IFF 1 value
	tst r5,#0x80000000		@ Test IFF 2 value
	orrne r5,r5,#0x40000000		@ Set IFF1 to same as IFF2
	mov r1,r7,lsr #16		@ Put SP in R1
	bl MEMREADSHORT
	mov r7,r0			@ Put new PC in R7
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#14
B ENDOPCODES

EXOPCODE_4E:		@IM 0
	bic r5,r5,#0x30000000		@ Set IM to 0, flags (bits 29 And 28 cleared)
	mov r2,#8
B ENDOPCODES

EXOPCODE_4F:		@LD R,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r5,r5,#0x000000FF		@ Clear target byte to 0
	orr r5,r5,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

EXOPCODE_50:		@IN D,(C)
	and r0,r9,r12			@ Mask B Reg (Port number)

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#12
B ENDOPCODES

EXOPCODE_51:		@OUT (C),D
	mov r0,r9,lsr #24		@ Get source value
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	and r1,r1,#0xFF			@ Mask B Reg (Port number)
	mov r2,#12
B ENDOPCODES

EXOPCODE_52:		@SBC HL,DE
	mov r0,r9,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r8,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r8,lsr #16		@ Get destination register
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform subtraction
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,r12			@ Mask back to 16 bits and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#32768			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r1,r8,lsr #16		@ Get destination register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#32768			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

EXOPCODE_53:		@LD (nn),DE
	mov r0,r9,lsr #16		@ Get source value
	and r2,r7,r12			@ Mask PC register
	add r1,r2,#2			@ Store PC + 2 in R1
	and r1,r1,r12			@ Mask new PC to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store incremented value
	bl MEMFETCHSHORT2		@ Get memory location into R1
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#20
B ENDOPCODES

EXOPCODE_54:		@NEG
	mov r0,#0			@ Put 0 in R0
	and r2,r8,#15			@ Mask off to a low nibble of accumulator
	sub r2,r0,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask accumulator off to a single byte
	subs r2,r0,r2			@ Perform subtraction
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r8,r8,#0xFF			@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	and r0,r8,r2			@ And the accumulator and result
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

EXOPCODE_55:		@RETN
	bic r5,r5,#0x40000000		@ Clear old IFF 1 value
	tst r5,#0x80000000		@ Test IFF 2 value
	orrne r5,r5,#0x40000000		@ Set IFF1 to same as IFF2
	mov r1,r7,lsr #16		@ Put SP in R1
	bl MEMREADSHORT
	mov r7,r0			@ Put new PC in R7
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#14
B ENDOPCODES

EXOPCODE_56:		@IM 1
	bic r5,r5,#0x20000000		@ Set IM to 1, flags (bits 29 cleared And 28 set)
	orr r5,r5,#0x10000000		@ Set IM to 1, flags (bits 29 cleared And 28 set)
	mov r2,#8
B ENDOPCODES

EXOPCODE_57:		@LD A,I
	mov r0,r5,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0			@ Test if zero
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	tst r5,#0x80000000		@ Test IFF2 flag
	orrne r8,r8,#0x400		@ Set parity to IFF2
	mov r2,#8
B ENDOPCODES

EXOPCODE_58:		@IN E,(C)
	and r0,r9,r12			@ Mask B Reg (Port number)

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}

	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#12
B ENDOPCODES

EXOPCODE_59:		@OUT (C),E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	and r1,r1,#0xFF			@ Mask B Reg (Port number)
	mov r2,#12
B ENDOPCODES

EXOPCODE_5A:		@ADC HL,DE
	mov r0,r9,lsr #16		@ Get source valu
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r8,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r8,lsr #16		@ Get destination register
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,r12			@ Mask back to 16 bits and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#32768			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r1,r8,lsr #16		@ Get destination register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#32768			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

EXOPCODE_5B:		@LD DE,(nn)
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT2		@ Get address
	add r2,r2,#2			@ Increment PC
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	bl MEMREADSHORT			@ Load 16 bit value from memory
	and r9,r9,r12			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#20
B ENDOPCODES

EXOPCODE_5C:		@NEG
	mov r0,#0			@ Put 0 in R0
	and r2,r8,#15			@ Mask off to a low nibble of accumulator
	sub r2,r0,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask accumulator off to a single byte
	subs r2,r0,r2			@ Perform subtraction
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r8,r8,#0xFF			@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	and r0,r8,r2			@ And the accumulator and result
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

EXOPCODE_5D:		@RETN
	bic r5,r5,#0x40000000		@ Clear old IFF 1 value
	tst r5,#0x80000000		@ Test IFF 2 value
	orrne r5,r5,#0x40000000		@ Set IFF1 to same as IFF2
	mov r1,r7,lsr #16		@ Put SP in R1
	bl MEMREADSHORT
	mov r7,r0			@ Put new PC in R7
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#14
B ENDOPCODES

EXOPCODE_5E:		@IM 2
	orr r5,r5,#0x20000000		@ Set IM to 2, flags (bits 29 set And 29 cleared)
	bic r5,r5,#0x10000000		@ Set IM to 2, flags (bits 29 set And 29 cleared)
	mov r2,#8
B ENDOPCODES

EXOPCODE_5F:		@LD A,R
	and r0,r5,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0			@ Test if zero
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	tst r5,#0x80000000		@ Test IFF2 flag
	orrne r8,r8,#0x400		@ Set parity to IFF2
	mov r2,#8
B ENDOPCODES

EXOPCODE_60:		@IN H,(C)
	and r0,r9,r12			@ Mask B Reg (Port number)

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#12
B ENDOPCODES

EXOPCODE_61:		@OUT (C),H
	mov r0,r8,lsr #24		@ Get source value
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	and r1,r1,#0xFF			@ Mask B Reg (Port number)
	mov r2,#12
B ENDOPCODES

EXOPCODE_62:		@SBC HL,HL
	mov r0,r8,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	and r1,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	tst r8,#0x100			@ Test carry flag
	sub r2,r1,r1
	subne r2,r2,#1			@ If set subtract 1
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r8,lsr #16		@ Get destination register
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform subtraction
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,r12			@ Mask back to 16 bits and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#32768			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r1,r8,lsr #16		@ Get destination register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#32768			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

EXOPCODE_63:		@LD (nn),HL
	mov r0,r8,lsr #16		@ Get source value
	and r2,r7,r12			@ Mask PC register
	add r1,r2,#2			@ Store PC + 2 in R1
	and r1,r1,r12			@ Mask new PC to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store incremented value
	bl MEMFETCHSHORT2		@ Get memory location into R1
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#20
B ENDOPCODES

EXOPCODE_64:		@NEG
	mov r0,#0			@ Put 0 in R0
	and r2,r8,#15			@ Mask off to a low nibble of accumulator
	sub r2,r0,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask acumulator off to a single byte
	subs r2,r0,r2			@ Perform subtraction
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0xFF			@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	and r0,r8,r2			@ And the accumulator and result
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

EXOPCODE_65:		@RETN
	bic r5,r5,#0x40000000		@ Clear old IFF 1 value
	tst r5,#0x80000000		@ Test IFF 2 value
	orrne r5,r5,#0x40000000		@ Set IFF1 to same as IFF2
	mov r1,r7,lsr #16		@ Put SP in R1
	bl MEMREADSHORT
	mov r7,r0			@ Put new PC in R7
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#14
B ENDOPCODES

EXOPCODE_66:		@IM 0
	bic r5,r5,#0x30000000		@ Set IM to 0, flags (bits 29 And 28 cleared)
	mov r2,#8
B ENDOPCODES

EXOPCODE_67:		@RRD
	mov r1,r8,lsr #16		@ Get value of HL register
	bl MEMREAD
	mov r2,r0			@ Move value to R2
	and r1,r8,#0xF			@ Get low nibble of accumulator
	mov r1,r1,lsl #4		@ Move low nibble to high nibble
	orr r0,r1,r0,lsr #4		@ Create new (HL) value
	bl STOREMEM2			@ Store back to memory
@	strb r0,[r3]			@ R3 still contains correct address
	and r0,r2,#0xF			@ Get low nibble
	bic r8,r8,#0xF			@ Clear low nible of accumulator
	orrs r8,r8,r0			@ Create new accumulator value
 	bic r8,r8,#0xFE00		@ Clear old flags (except carry)
	tst r8,#0xFF			@ Test if zero
	orreq r8,r8,#0x4000		@ Set zero flag if acc is 0
	tst r8,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r8,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r8,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	tst r5,#0x80000000		@ Test IFF2 flag
	orrne r8,r8,#0x400		@ Set P flag if IFF2 set
	mov r2,#18
B ENDOPCODES


EXOPCODE_68:		@IN L,(C)
	and r0,r9,r12			@ Mask B Reg (Port number)

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#12
B ENDOPCODES

EXOPCODE_69:		@OUT (C),L
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	and r1,r1,#0xFF			@ Mask B Reg (Port number)
	mov r2,#12
B ENDOPCODES

EXOPCODE_6A:		@ADC HL,HL
	mov r0,r8,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	add r2,r2,r2
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r2,r0,r0			@ Perform addition
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,r12			@ Mask back to 16 bits and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#32768			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r1,r8,lsr #16		@ Get destination register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#32768			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

EXOPCODE_6B:		@LD HL,(nn)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT			@ Get address
	add r1,r1,#2			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r0			@ Put address to load into R1
	bl MEMREADSHORT			@ Load 16 bit value from memory
	and r8,r8,r12			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#20
B ENDOPCODES

EXOPCODE_6C:		@NEG
	mov r0,#0			@ Put 0 in R0
	and r2,r8,#15			@ Mask off to a low nibble of accumulator
	sub r2,r0,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask acumulator off to a single byte
	subs r2,r0,r2			@ Perform subtraction
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0xFF			@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	and r0,r8,r2			@ And the accumulator and result
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

EXOPCODE_6D:		@RETN
	bic r5,r5,#0x40000000		@ Clear old IFF 1 value
	tst r5,#0x80000000		@ Test IFF 2 value
	orrne r5,r5,#0x40000000		@ Set IFF1 to same as IFF2
	mov r1,r7,lsr #16		@ Put SP in R1
	bl MEMREADSHORT
	mov r7,r0			@ Put new PC in R7
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#14
B ENDOPCODES

EXOPCODE_6E:		@IM 0
	bic r5,r5,#0x30000000		@ Set IM to 0, flags (bits 29 And 28 cleared)
	mov r2,#8
B ENDOPCODES

EXOPCODE_6F:		@RLD
	mov r1,r8,lsr #16		@ Get value of HL register
	bl MEMREAD			@ load value from memory
	mov r2,r0,lsl #4		@ Move low nibble to high nibble
	and r1,r8,#0xF			@ Get low nibble of accumulator
	orr r0,r2,r1			@ Create new (HL) value
	bl STOREMEM2			@ Store back to memory
@	strb r0,[r3]			@ R3 still contains correct HL address
	and r1,r8,#0xF0			@ Get high nible of accumulator
	orrs r0,r1,r2,lsr #8		@ Create new accumulator value
	bic r8,r8,#0xFF			@ Clear old accumulator
	orr r8,r8,r0			@ Store new accumulator
 	bic r8,r8,#0xFE00		@ Clear old flags (except carry)
	orreq r8,r8,#0x4000		@ Set zero flag if acc is 0
	tst r8,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r8,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r8,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	tst r5,#0x80000000		@ Test IFF2 flag
	orrne r8,r8,#0x400		@ Set P flag if IFF2 set
	mov r2,#18
B ENDOPCODES

EXOPCODE_70:		@IN F,(C)
	and r0,r9,r12			@ Mask B Reg (Port number)

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x0000FF00		@ Clear target byte to 0
	orr r8,r8,r0,lsl #8		@ Place value on target register
	mov r2,#12
B ENDOPCODES

EXOPCODE_71:		@OUT (C),0
	mov r0,#0			@ Put zero in R0
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	and r1,r1,#0xFF			@ Mask B Reg (Port number)

	mov r2,#12
B ENDOPCODES

EXOPCODE_72:		@SBC HL,SP
	mov r0,r7,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r8,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r8,lsr #16		@ Get destination register
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform subtraction
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,r12			@ Mask back to 16 bits and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#32768			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r1,r8,lsr #16		@ Get destination register
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#32768			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

EXOPCODE_73:		@LD (nn),SP
	mov r0,r7,lsr #16		@ Get source value
	and r2,r7,r12			@ Mask PC register
	add r1,r2,#2			@ Store PC + 2 in R1
	and r1,r1,r12			@ Mask new PC to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store incremented value
	bl MEMFETCHSHORT2		@ Get memory location into R1
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#20
B ENDOPCODES

EXOPCODE_74:		@NEG
	mov r0,#0			@ Put 0 in R0
	and r2,r8,#15			@ Mask off to a low nibble of accumulator
	sub r2,r0,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask acumulator off to a single byte
	subs r2,r0,r2			@ Perform subtraction
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0xFF			@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	and r0,r8,r2			@ And the accumulator and result
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

EXOPCODE_75:		@RETN
	bic r5,r5,#0x40000000		@ Clear old IFF 1 value
	tst r5,#0x80000000		@ Test IFF 2 value
	orrne r5,r5,#0x40000000		@Set IFF1 to same as IFF2
	mov r1,r7,lsr #16		@ Put SP in R1
	bl MEMREADSHORT
	mov r7,r0			@ Put new PC in R7
	add r1,r1,#2			@ Increase SP
	add r7,r7,r1,lsl #16		@ Put SP in Reg 7
	mov r2,#14
B ENDOPCODES

EXOPCODE_76:		@IM 1
	bic r5,r5,#0x20000000		@ Set IM to 1, flags (bits 29 cleared And 28 set)
	orr r5,r5,#0x10000000		@ Set IM to 1, flags (bits 29 cleared And 28 set)
	mov r2,#8
B ENDOPCODES

EXOPCODE_77:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_78:		@IN A,(C)
	and r0,r9,r12			@ Mask B Reg (Port number)

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#12
B ENDOPCODES

EXOPCODE_79:		@OUT (C),A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	and r1,r1,#0xFF			@ Mask B Reg (Port number)
	mov r2,#12
B ENDOPCODES

EXOPCODE_7A:		@ADC HL,SP
	mov r0,r7,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r8,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r8,lsr #16		@ Get destination register
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,r12			@ Mask back to 16 bits and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#32768			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r8,r8,r12			@ Clear target short to 0
	orr r8,r8,r2,lsl #16		@ Place value on target register
	mov r1,r8,lsr #16		@ Get destination register
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#32768			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

EXOPCODE_7B:		@LD SP,(nn)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT			@ Get address
	add r1,r1,#2			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r0			@ Put address to load into R1
	bl MEMREADSHORT			@ Load 16 bit value from memory
	and r7,r7,r12			@ Clear target byte to 0
	orr r7,r7,r0,lsl #16		@ Place value on target register
	mov r2,#20
B ENDOPCODES

EXOPCODE_7C:		@NEG
	mov r0,#0			@ Put 0 in R0
	and r2,r8,#15			@ Mask off to a low nibble of accumulator
	sub r2,r0,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask acumulator off to a single byte
	subs r2,r0,r2			@ Perform subtraction
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0xFF			@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	and r0,r8,r2			@ And the accumulator and result
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

EXOPCODE_7D:		@RETN
	bic r5,r5,#0x40000000		@Clear old IFF 1 value
	tst r5,#0x80000000		@Test IFF 2 value
	orrne r5,r5,#0x40000000		@Set IFF1 to same as IFF2
	mov r1,r7,lsr #16		@Put SP in R1
	bl MEMREADSHORT
	mov r7,r0			@Put new PC in R7
	add r1,r1,#2			@Increase SP
	add r7,r7,r1,lsl #16		@Put SP in Reg 7
	mov r2,#14
B ENDOPCODES

EXOPCODE_7E:		@IM 2
	orr r5,r5,#0x20000000		@ Set IM to 2, flags (bits 29 set And 29 cleared)
	bic r5,r5,#0x10000000		@ Set IM to 2, flags (bits 29 set And 29 cleared)
	mov r2,#8
B ENDOPCODES

EXOPCODE_7F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_80:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_81:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_82:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_83:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_84:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_85:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_86:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_87:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_88:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_89:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_8A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_8B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_8C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_8D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_8E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_8F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_90:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_91:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_92:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_93:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_94:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_95:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_96:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_97:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_98:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_99:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_9A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_9B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_9C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_9D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_9E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_9F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_A0:		@LDI
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0				@ 4 Lines to increase r register!
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	add r1,r1,#1 				@ Increase HL
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value

	mov r1,r9,lsr #16			@ Get value of DE register

	sub r9,r9,#1 				@ Decrease BC
	ands r9,r9,r12 				@ Mask to 16 bits
	bic r8,r8,#0x1600			@ Clear H,P & N flags
	orrne r8,r8,#0x400			@ Set P flag if not zero

	add r2,r1,#1 				@ Increase DE
	orr r9,r9,r2,lsl #16			@ Store new DE value


	bl MEMSTORE 				@ Store value to memory - before inc in R1
	mov r2,#16
B ENDOPCODES

EXOPCODE_A1:		@CPI
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0				@ 4 Lines to increase r register!
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	add r1,r1,#1 				@ Increase HL
	and r1,r1,r12 				@ Mask to 16 bits
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value
	bic r8,r8,#0xFE00			@ Clear all flags except carry
	and r1,r8,#15				@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16				@ Test bit 4 flag
	orrne r8,r8,#0x1000			@ Set H flag if set
	and r1,r8,#255				@ Mask off accumulator to a single byte
	sub r2,r1,r0				@ Compare values
	ands r2,r2,#0xFF			@ Mask back to byte and set flags
	orreq r8,r8,#0x4000			@ Set Zero flag if need be
	tst r2,#128				@ Test sign
	orrne r8,r8,#0x8000			@ Set Sign flag if need be
	tst r2,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r2,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	orr r8,r8,#0x200			@ Set N fla
	and r2,r9,r12				@ Get masked value of BC register
	sub r2,r2,#1 				@ Decrease BC
	ands r2,r2,r12 				@ Mask to 16 bits
	bic r9,r9,r12 				@ Clear old BC value
	orr r9,r9,r2				@ Store new BC value
	orrne r8,r8,#0x400			@ Set P flag if not zero
	mov r2,#16
B ENDOPCODES

EXOPCODE_A2:		@INI
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	sub r0,r1,#1			@ Decrease B reg
	bic r9,r9,#0xFF00		@ Clear old B reg
	ands r0,r0,#0xFF		@ Mask new B reg
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	orr r9,r9,r0,lsl #8		@ Store new B reg
	and r0,r1,#0xFF			@ Mask B Reg (Port number)

	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}

	orr r8,r8,#0x200		@ Set N Flag
@	tst r0,#32			@ Test 5 flag
@	orrne r8,r8,#0x2000		@ Set 5 flag
@	tst r0,#8			@ Test 3 flag
@	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8,lsr #16		@ Move HL into R1
	add r2,r1,#1			@ Increment HL Register
	and r8,r8,#12			@ Clear old HL value
	orr r8,r8,r2,lsl #16		@ Replace with new HL value
	bl MEMSTORE			@ Store byte to memory
	mov r2,#16
B ENDOPCODES

EXOPCODE_A3:		@OUTI
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	add r1,r1,#1 				@ Increase HL
	@and r1,r1,r12 				@ Mask to 16 bits
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value
	mov r2,r9,lsr #8			@ Get B register
	and r2,r2,#0xFF				@ Get masked value of B register
	sub r2,r2,#1 				@ Decrease B
	ands r2,r2,#0xFF 			@ Mask to 8 bits
	and r1,r9,#0xFF				@ Get masked value of C register

	bic r9,r9,#0xFF00 			@ Clear old B value
	orr r9,r9,r2,lsl #8			@ Store new B value
	mov r2,#16
B ENDOPCODES

EXOPCODE_A4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_A5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_A6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_A7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_A8:		@LDD
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0				@ 4 Lines to increase r register!
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	sub r1,r1,#1 				@ Decrease HL
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value

	mov r1,r9,lsr #16			@ Get value of DE register

	sub r9,r9,#1 				@ Decrease BC
	ands r9,r9,r12 				@ Mask to 16 bits
	bic r8,r8,#0x1600			@ Clear H,P & N flags
	orrne r8,r8,#0x400			@ Set P flag if not zero

	sub r2,r1,#1 				@ Decrease DE
	orr r9,r9,r2,lsl #16			@ Store new DE value


	bl MEMSTORE 				@ Store value to memory - before inc in R1
	mov r2,#16
B ENDOPCODES

EXOPCODE_A9:		@CPD
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0				@ 4 Lines to increase r register!
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	sub r1,r1,#1 				@ Decrease HL
	and r1,r1,r12 				@ Mask to 16 bits
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value
	bic r8,r8,#0xFE00			@ Clear all flags except carry
	and r1,r8,#15				@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16				@ Test bit 4 flag
	orrne r8,r8,#0x1000			@ Set H flag if set
	and r1,r8,#255				@ Mask off accumulator to a single byte
	sub r2,r1,r0				@ Compare values
	ands r2,r2,#0xFF			@ Mask back to byte and set flags
	orreq r8,r8,#0x4000			@ Set Zero flag if need be
	tst r2,#128				@ Test sign
	orrne r8,r8,#0x8000			@ Set Sign flag if need be
	tst r2,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r2,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	orr r8,r8,#0x200			@ Set N fla
	and r2,r9,r12				@ Get masked value of BC register
	sub r2,r2,#1 				@ Decrease BC
	ands r2,r2,r12 				@ Mask to 16 bits
	bic r9,r9,r12 				@ Clear old BC value
	orr r9,r9,r2				@ Store new BC value
	orrne r8,r8,#0x400			@ Set P flag if not zero
	mov r2,#16
B ENDOPCODES

EXOPCODE_AA:		@IND
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	sub r0,r1,#1			@ Decrease B reg
	bic r9,r9,#0xFF00		@ Clear old B reg
	ands r0,r0,#0xFF		@ Mask new B reg
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	orr r9,r9,r0,lsl #8		@ Store new B reg
	and r0,r1,#0xFF			@ Mask B Reg (Port number)
	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}

	orr r8,r8,#0x200		@ Set N Flag
@	tst r0,#32			@ Test 5 flag
@	orrne r8,r8,#0x2000		@ Set 5 flag
@	tst r0,#8			@ Test 3 flag
@	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8,lsr #16		@ Move HL into R1
	sub r2,r1,#1			@ Decrement HL Register
	and r8,r8,#12			@ Clear old HL value
	orr r8,r8,r2,lsl #16		@ Replace with new HL value
	bl MEMSTORE			@ Store byte to memory
	mov r2,#16
B ENDOPCODES

EXOPCODE_AB:		@OUTD
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	sub r1,r1,#1 				@ Decrease HL
	@and r1,r1,r12 				@ Mask to 16 bits
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value
	mov r2,r9,lsr #8			@ Get B register
	and r2,r2,#0xFF				@ Get masked value of B register
	sub r2,r2,#1 				@ Decrease B
	ands r2,r2,#0xFF 			@ Mask to 8 bits
	and r1,r9,#0xFF				@ Get masked value of C register

	bic r9,r9,#0xFF00 			@ Clear old B value
	orr r9,r9,r2,lsl #8			@ Store new B value
	mov r2,#16
B ENDOPCODES

EXOPCODE_AC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_AD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_AE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_AF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_B0:		@LDIR
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0				@ 4 Lines to increase r register!
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	add r1,r1,#1 				@ Increase HL
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value
	mov r1,r9,lsr #16			@ Get value of DE register
	add r2,r1,#1 				@ Increase DE
	bl MEMSTORE 				@ Store value to memory

	sub r9,r9,#1 				@ Decrease BC
	ands r9,r9,r12 				@ Mask to 16 bits

	orr r9,r9,r2,lsl #16			@ Store new DE value

	bic r8,r8,#0x1600			@ Clear H,P & N flags
	moveq r2,#16				@ Put in initial tstates
	beq ENDOPCODES				@ Finish instruction if zero
	@and r1,r7,r12				@ Get masked PC
	sub r1,r7,#2				@ Take PC back 2
	and r1,r1,r12				@ Mask back to 16 bits
	bic r7,r7,r12				@ Clear old PC value
	orr r7,r7,r1				@ Store new PC value
	mov r2,#21				@ Increase tstates
B ENDOPCODES

EXOPCODE_B1:		@CPIR
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0				@ 4 Lines to increase r register!
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	add r1,r1,#1 				@ Increase HL
	and r1,r1,r12 				@ Mask to 16 bits
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value
	bic r8,r8,#0xFE00			@ Clear all flags except carry
	and r1,r8,#15				@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16				@ Test bit 4 flag
	orrne r8,r8,#0x1000			@ Set H flag if set
	and r1,r8,#255				@ Mask off accumulator to a single byte
	sub r2,r1,r0				@ Compare values
	ands r2,r2,#0xFF			@ Mask back to byte and set flags
	orreq r8,r8,#0x4000			@ Set Zero flag if need be
	tst r2,#128				@ Test sign
	orrne r8,r8,#0x8000			@ Set Sign flag if need be
	tst r2,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r2,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	orr r8,r8,#0x200			@ Set N fla
	and r2,r9,r12				@ Get masked value of BC register
	sub r2,r2,#1 				@ Decrease BC
	ands r2,r2,r12 				@ Mask to 16 bits
	bic r9,r9,r12 				@ Clear old BC value
	orr r9,r9,r2				@ Store new BC value
	orrne r8,r8,#0x400			@ Set P flag if not zero
	mov r2,#16				@ Increase tstates
	beq ENDOPCODES				@ Finish instruction if zero
	tst r8,#0x4000				@ Test Z flag
	bne ENDOPCODES				@ Finish instruction if set
	@and r1,r7,r12				@ Get masked PC
	sub r1,r7,#2				@ Take PC back 2
	and r1,r1,r12				@ Mask back to 16 bits
	bic r7,r7,r12				@ Clear old PC value
	orr r7,r7,r1				@ Store new PC value
	add r2,r2,#5				@ Increase tstates
B ENDOPCODES

EXOPCODE_B2:		@INIR
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0			@ 4 Lines to increase r register!
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	sub r0,r1,#1			@ Decrease B reg
	bic r9,r9,#0xFF00		@ Clear old B reg
	ands r0,r0,#0xFF		@ Mask new B reg
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	orr r9,r9,r0,lsl #8		@ Store new B reg
	and r0,r1,#0xFF			@ Mask B Reg (Port number)
	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}

	orr r8,r8,#0x200		@ Set N Flag
@	tst r0,#32			@ Test 5 flag
@	orrne r8,r8,#0x2000		@ Set 5 flag
@	tst r0,#8			@ Test 3 flag
@	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8,lsr #16		@ Move HL into R1
	add r2,r1,#1			@ Increment HL Register
	and r8,r8,#12			@ Clear old HL value
	orr r8,r8,r2,lsl #16		@ Replace with new HL value
	bl MEMSTORE			@ Store byte to memory
	tst r8,#0x4000			@ Test Zero Flag
	movne r2,#16
	bne ENDOPCODES
	mov r2,#21			@ Increase tstates
	sub r1,r7,#2
	and r1,r1,r12
	bic r7,r7,r12
	orr r7,r7,r1
B ENDOPCODES

EXOPCODE_B3:		@OTIR
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0				@ 4 Lines to increase r register!
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	add r1,r1,#1 				@ Increase HL
	@and r1,r1,r12 				@ Mask to 16 bits
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value
	mov r2,r9,lsr #8			@ Get B register
	and r2,r2,#0xFF				@ Get masked value of B register
	sub r2,r2,#1 				@ Decrease B
	ands r2,r2,#0xFF 			@ Mask to 8 bits
	and r1,r9,#0xFF				@ Get masked value of C register

	bic r9,r9,#0xFF00 			@ Clear old B value
	orr r9,r9,r2,lsl #8			@ Store new B value
	cmp r2,#0
	mov r2,#16
	beq ENDOPCODES
	add r2,r2,#5			@ Increase tstates
	sub r1,r7,#2
	and r1,r1,r12
	bic r7,r7,r12
	orr r7,r7,r1
B ENDOPCODES

EXOPCODE_B4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_B5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_B6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_B7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_B8:		@LDDR
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0				@ 4 Lines to increase r register!
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	sub r1,r1,#1 				@ Decrease HL
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value
	mov r1,r9,lsr #16			@ Get value of DE register
	sub r2,r1,#1 				@ Decrease DE
	bl MEMSTORE 				@ Store value to memory

	sub r9,r9,#1 				@ Decrease BC
	ands r9,r9,r12 				@ Mask to 16 bits

	orr r9,r9,r2,lsl #16			@ Store new DE value

	bic r8,r8,#0x1600			@ Clear H,P & N flags
	moveq r2,#16				@ Put in initial tstates
	beq ENDOPCODES				@ Finish instruction if zero
	@and r1,r7,r12				@ Get masked PC
	sub r1,r7,#2				@ Take PC back 2
	and r1,r1,r12				@ Mask back to 16 bits
	bic r7,r7,r12				@ Clear old PC value
	orr r7,r7,r1				@ Store new PC value
	mov r2,#21
B ENDOPCODES

EXOPCODE_B9:		@CPDR
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0				@ 4 Lines to increase r register!
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	sub r1,r1,#1 				@ Decrease HL
	and r1,r1,r12 				@ Mask to 16 bits
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value
	bic r8,r8,#0xFE00			@ Clear all flags except carry
	and r1,r8,#15				@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16				@ Test bit 4 flag
	orrne r8,r8,#0x1000			@ Set H flag if set
	and r1,r8,#255				@ Mask off accumulator to a single byte
	sub r2,r1,r0				@ Compare values
	ands r2,r2,#0xFF			@ Mask back to byte and set flags
	orreq r8,r8,#0x4000			@ Set Zero flag if need be
	tst r2,#128				@ Test sign
	orrne r8,r8,#0x8000			@ Set Sign flag if need be
	tst r2,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r2,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	orr r8,r8,#0x200			@ Set N fla
	and r2,r9,r12				@ Get masked value of BC register
	sub r2,r2,#1 				@ Decrease BC
	ands r2,r2,r12 				@ Mask to 16 bits
	bic r9,r9,r12 				@ Clear old BC value
	orr r9,r9,r2				@ Store new BC value
	orrne r8,r8,#0x400			@ Set P flag if not zero
	mov r2,#16				@ Set initial tstates
	beq ENDOPCODES				@ Finish instruction if zero
	tst r8,#0x4000				@ Test Z flag
	bne ENDOPCODES				@ Finish instruction if set
	@and r1,r7,r12				@ Get masked PC
	sub r1,r7,#2				@ Take PC back 2
	and r1,r1,r12				@ Mask back to 16 bits
	bic r7,r7,r12				@ Clear old PC value
	orr r7,r7,r1				@ Store new PC value
	add r2,r2,#5				@ Increase tstates
B ENDOPCODES

EXOPCODE_BA:		@INDR
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0			@ 4 Lines to increase r register!
	bic r8,r8,#0xFE00		@ Clear all flags except carry
	and r2,r9,#0xFF			@ Get value of C reg
	mov r1,r9,lsr #8		@ Get value of B reg
	sub r0,r1,#1			@ Decrease B reg
	bic r9,r9,#0xFF00		@ Clear old B reg
	ands r0,r0,#0xFF		@ Mask new B reg
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	orr r9,r9,r0,lsl #8		@ Store new B reg
	and r0,r1,#0xFF			@ Mask B Reg (Port number)
	stmdb sp!,{r3,r12,lr}
     mov lr,pc
     ldr pc,[cpucontext,#z80_in] ;@ r0=port - data returned in r0
    ldmia sp!,{r3,r12,lr}

	orr r8,r8,#0x200		@ Set N Flag
@	tst r0,#32			@ Test 5 flag
@	orrne r8,r8,#0x2000		@ Set 5 flag
@	tst r0,#8			@ Test 3 flag
@	orrne r8,r8,#0x800		@ Set 3 flag
	mov r1,r8,lsr #16		@ Move HL into R1
	sub r2,r1,#1			@ Decrement HL Register
	and r8,r8,#12			@ Clear old HL value
	orr r8,r8,r2,lsl #16		@ Replace with new HL value
	bl MEMSTORE			@ Store byte to memory
	tst r8,#0x4000			@ Test Zero Flag
	movne r2,#16
	bne ENDOPCODES
	mov r2,#21			@ Increase tstates
	sub r1,r7,#2
	and r1,r1,r12
	bic r7,r7,r12
	orr r7,r7,r1
B ENDOPCODES

EXOPCODE_BB:		@OTDR
	@add r0,r5,#1
	@and r0,r0,#127
	@bic r5,r5,#127
	@orr r5,r5,r0				@ 4 Lines to increase r register!
	mov r1,r8,lsr #16			@ Get value of HL register
	bl MEMREAD
	sub r1,r1,#1 				@ Decrease HL
	@and r1,r1,r12 				@ Mask to 16 bits
	and r8,r8,r12 				@ Clear old HL value
	orr r8,r8,r1,lsl #16			@ Store new HL value
	mov r2,r9,lsr #8			@ Get B register
	and r2,r2,#0xFF				@ Get masked value of B register
	sub r2,r2,#1 				@ Decrease B
	ands r2,r2,#0xFF 			@ Mask to 8 bits
	and r1,r9,#0xFF				@ Get masked value of C register
	bic r9,r9,#0xFF00 			@ Clear old B value
	orr r9,r9,r2,lsl #8			@ Store new B value
	cmp r2,#0
	mov r2,#16
	beq ENDOPCODES
	add r2,r2,#5			@ Increase tstates
	sub r1,r7,#2
	and r1,r1,r12
	bic r7,r7,r12
	orr r7,r7,r1

B ENDOPCODES

EXOPCODE_BC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_BD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_BE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_BF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_C0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_C1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_C2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_C3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_C4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_C5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_C6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_C7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_C8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_C9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_CA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_CB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_CC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_CD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_CE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_CF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_D0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_D1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_D2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_D3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_D4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_D5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_D6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_D7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_D8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_D9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_DA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_DB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_DC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_DD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_DE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_DF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_E0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_E1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_E2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_E3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_E4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_E5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_E6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_E7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_E8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_E9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_EA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_EB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_EC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_ED:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_EE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_EF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_F0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_F1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_F2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_F3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_F4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_F5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_F6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_F7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_F8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_F9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_FA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_FB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_FC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_FD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_FE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

EXOPCODE_FF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

CBCODES:
	bl MEMREAD
	add r1,r1,#1		@R1 should still contain the PC so increment
	and r1,r1,r12		@Mask the 16 bits that relate to the PC
	bic r7,r7,r12		@Clear the old PC value
	orr r7,r7,r1		@Store the new PC value
	add r3,r5,#1
	and r3,r3,#127
	bic r5,r5,#127
	orr r5,r5,r3				@ 4 Lines to increase r register!
@	ldr r3,=rpointer
@	ldr r2,[r3]    		@These three lines store the opcode For debugging
@	Str r0,[r2,#40]
	add r15,r15,r0, lsl #2  @Multipy opcode by 4 To get value To add To PC

	nop

			B CBOPCODE_00
			B CBOPCODE_01
			B CBOPCODE_02
			B CBOPCODE_03
			B CBOPCODE_04
			B CBOPCODE_05
			B CBOPCODE_06
			B CBOPCODE_07
			B CBOPCODE_08
			B CBOPCODE_09
			B CBOPCODE_0A
			B CBOPCODE_0B
			B CBOPCODE_0C
			B CBOPCODE_0D
			B CBOPCODE_0E
			B CBOPCODE_0F
			B CBOPCODE_10
			B CBOPCODE_11
			B CBOPCODE_12
			B CBOPCODE_13
			B CBOPCODE_14
			B CBOPCODE_15
			B CBOPCODE_16
			B CBOPCODE_17
			B CBOPCODE_18
			B CBOPCODE_19
			B CBOPCODE_1A
			B CBOPCODE_1B
			B CBOPCODE_1C
			B CBOPCODE_1D
			B CBOPCODE_1E
			B CBOPCODE_1F
			B CBOPCODE_20
			B CBOPCODE_21
			B CBOPCODE_22
			B CBOPCODE_23
			B CBOPCODE_24
			B CBOPCODE_25
			B CBOPCODE_26
			B CBOPCODE_27
			B CBOPCODE_28
			B CBOPCODE_29
			B CBOPCODE_2A
			B CBOPCODE_2B
			B CBOPCODE_2C
			B CBOPCODE_2D
			B CBOPCODE_2E
			B CBOPCODE_2F
			B CBOPCODE_30
			B CBOPCODE_31
			B CBOPCODE_32
			B CBOPCODE_33
			B CBOPCODE_34
			B CBOPCODE_35
			B CBOPCODE_36
			B CBOPCODE_37
			B CBOPCODE_38
			B CBOPCODE_39
			B CBOPCODE_3A
			B CBOPCODE_3B
			B CBOPCODE_3C
			B CBOPCODE_3D
			B CBOPCODE_3E
			B CBOPCODE_3F
			B CBOPCODE_40
			B CBOPCODE_41
			B CBOPCODE_42
			B CBOPCODE_43
			B CBOPCODE_44
			B CBOPCODE_45
			B CBOPCODE_46
			B CBOPCODE_47
			B CBOPCODE_48
			B CBOPCODE_49
			B CBOPCODE_4A
			B CBOPCODE_4B
			B CBOPCODE_4C
			B CBOPCODE_4D
			B CBOPCODE_4E
			B CBOPCODE_4F
			B CBOPCODE_50
			B CBOPCODE_51
			B CBOPCODE_52
			B CBOPCODE_53
			B CBOPCODE_54
			B CBOPCODE_55
			B CBOPCODE_56
			B CBOPCODE_57
			B CBOPCODE_58
			B CBOPCODE_59
			B CBOPCODE_5A
			B CBOPCODE_5B
			B CBOPCODE_5C
			B CBOPCODE_5D
			B CBOPCODE_5E
			B CBOPCODE_5F
			B CBOPCODE_60
			B CBOPCODE_61
			B CBOPCODE_62
			B CBOPCODE_63
			B CBOPCODE_64
			B CBOPCODE_65
			B CBOPCODE_66
			B CBOPCODE_67
			B CBOPCODE_68
			B CBOPCODE_69
			B CBOPCODE_6A
			B CBOPCODE_6B
			B CBOPCODE_6C
			B CBOPCODE_6D
			B CBOPCODE_6E
			B CBOPCODE_6F
			B CBOPCODE_70
			B CBOPCODE_71
			B CBOPCODE_72
			B CBOPCODE_73
			B CBOPCODE_74
			B CBOPCODE_75
			B CBOPCODE_76
			B CBOPCODE_77
			B CBOPCODE_78
			B CBOPCODE_79
			B CBOPCODE_7A
			B CBOPCODE_7B
			B CBOPCODE_7C
			B CBOPCODE_7D
			B CBOPCODE_7E
			B CBOPCODE_7F
			B CBOPCODE_80
			B CBOPCODE_81
			B CBOPCODE_82
			B CBOPCODE_83
			B CBOPCODE_84
			B CBOPCODE_85
			B CBOPCODE_86
			B CBOPCODE_87
			B CBOPCODE_88
			B CBOPCODE_89
			B CBOPCODE_8A
			B CBOPCODE_8B
			B CBOPCODE_8C
			B CBOPCODE_8D
			B CBOPCODE_8E
			B CBOPCODE_8F
			B CBOPCODE_90
			B CBOPCODE_91
			B CBOPCODE_92
			B CBOPCODE_93
			B CBOPCODE_94
			B CBOPCODE_95
			B CBOPCODE_96
			B CBOPCODE_97
			B CBOPCODE_98
			B CBOPCODE_99
			B CBOPCODE_9A
			B CBOPCODE_9B
			B CBOPCODE_9C
			B CBOPCODE_9D
			B CBOPCODE_9E
			B CBOPCODE_9F
			B CBOPCODE_A0
			B CBOPCODE_A1
			B CBOPCODE_A2
			B CBOPCODE_A3
			B CBOPCODE_A4
			B CBOPCODE_A5
			B CBOPCODE_A6
			B CBOPCODE_A7
			B CBOPCODE_A8
			B CBOPCODE_A9
			B CBOPCODE_AA
			B CBOPCODE_AB
			B CBOPCODE_AC
			B CBOPCODE_AD
			B CBOPCODE_AE
			B CBOPCODE_AF
			B CBOPCODE_B0
			B CBOPCODE_B1
			B CBOPCODE_B2
			B CBOPCODE_B3
			B CBOPCODE_B4
			B CBOPCODE_B5
			B CBOPCODE_B6
			B CBOPCODE_B7
			B CBOPCODE_B8
			B CBOPCODE_B9
			B CBOPCODE_BA
			B CBOPCODE_BB
			B CBOPCODE_BC
			B CBOPCODE_BD
			B CBOPCODE_BE
			B CBOPCODE_BF
			B CBOPCODE_C0
			B CBOPCODE_C1
			B CBOPCODE_C2
			B CBOPCODE_C3
			B CBOPCODE_C4
			B CBOPCODE_C5
			B CBOPCODE_C6
			B CBOPCODE_C7
			B CBOPCODE_C8
			B CBOPCODE_C9
			B CBOPCODE_CA
			B CBOPCODE_CB
			B CBOPCODE_CC
			B CBOPCODE_CD
			B CBOPCODE_CE
			B CBOPCODE_CF
			B CBOPCODE_D0
			B CBOPCODE_D1
			B CBOPCODE_D2
			B CBOPCODE_D3
			B CBOPCODE_D4
			B CBOPCODE_D5
			B CBOPCODE_D6
			B CBOPCODE_D7
			B CBOPCODE_D8
			B CBOPCODE_D9
			B CBOPCODE_DA
			B CBOPCODE_DB
			B CBOPCODE_DC
			B CBOPCODE_DD
			B CBOPCODE_DE
			B CBOPCODE_DF
			B CBOPCODE_E0
			B CBOPCODE_E1
			B CBOPCODE_E2
			B CBOPCODE_E3
			B CBOPCODE_E4
			B CBOPCODE_E5
			B CBOPCODE_E6
			B CBOPCODE_E7
			B CBOPCODE_E8
			B CBOPCODE_E9
			B CBOPCODE_EA
			B CBOPCODE_EB
			B CBOPCODE_EC
			B CBOPCODE_ED
			B CBOPCODE_EE
			B CBOPCODE_EF
			B CBOPCODE_F0
			B CBOPCODE_F1
			B CBOPCODE_F2
			B CBOPCODE_F3
			B CBOPCODE_F4
			B CBOPCODE_F5
			B CBOPCODE_F6
			B CBOPCODE_F7
			B CBOPCODE_F8
			B CBOPCODE_F9
			B CBOPCODE_FA
			B CBOPCODE_FB
			B CBOPCODE_FC
			B CBOPCODE_FD
			B CBOPCODE_FE
			B CBOPCODE_FF

CBOPCODE_00:		@RLC B
	mov r0,r9,lsr #8			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flags
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry old bit 7 was set
	orrne r0,r0,#0x1			@ Set bit 0 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_01:		@RLC C
	mov r0,r9				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1			@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_02:		@RLC D
	mov r0,r9,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1			@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_03:		@RLC E
	mov r0,r9,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1			@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_04:		@RLC H
	mov r0,r8,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1			@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_05:		@RLC L
	mov r0,r8,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1			@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_06:		@RLC (HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1			@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	@strb r0,[r3]				@ Store back in mem as R3 still contains address of HL
	bl STOREMEM2
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

CBOPCODE_07:		@RLC A
	mov r0,r8				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1			@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_08:		@RRC B
	mov r0,r9,lsr #8			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	and r0,r0,#0x7F				@ Mask back to byte and clear bit 7
	orrcs r8,r8,#0x100			@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80			@ Set bit 7 if old bit 0 was set
	cmp r0,#0
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_09:		@RRC C
	and r0,r9,#0xFF				@ Get source value and mask
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80			@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_0A:		@RRC D
	mov r0,r9,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80			@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_0B:		@RRC E
	mov r0,r9,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	and r0,r0,#0x7F				@ Mask back to byte and clear bit 7
	orrcs r8,r8,#0x100			@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80			@ Set bit 7 if old bit 0 was set
	cmp r0,#0
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_0C:		@RRC H
	mov r0,r8,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift left 1
	orrcs r8,r8,#0x100			@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80			@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_0D:		@RRC L
	mov r0,r8,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	and r0,r0,#0x7F				@ Clear to byte and clear bit 7
	orrcs r8,r8,#0x100			@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80			@ Set bit 7 if old bit 0 was set
	cmp r0,#0				@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_0E:		@RRC (HL)
	mov r1,r8,lsr #16			@ Get value of register
	and r1,r1,r12				@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80			@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	bl STOREMEM2
	@strb r0,[r3]				@ Store back to mem as R3 still contains address of HL
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

CBOPCODE_0F:		@RRC A
	and r0,r8,#0xFF				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift left 1
	orrcs r8,r8,#0x100			@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80			@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_10:		@RL B
	mov r0,r9,lsr #8			@ Get source value
	tst r8,#0x100				@ Test current carry flag
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	orrne r0,r0,#1				@ Set bit 0 if carry was set
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_11:		@RL C
	mov r0,r9				@ Get source value
	tst r8,#0x100				@ Test current carry flag
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	orrne r0,r0,#1				@ Set bit 0 if carry was set
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_12:		@RL D
	mov r0,r9,lsr #24			@ Get source value
	tst r8,#0x100				@ Test current carry flag
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	orrne r0,r0,#1				@ Set bit 0 if carry was set
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_13:		@RL E
	mov r0,r9,lsr #16			@ Get source value
	tst r8,#0x100				@ Test current carry flag
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	orrne r0,r0,#1				@ Set bit 0 if carry was set
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_14:		@RL H
	mov r0,r8,lsr #24			@ Get source value
	tst r8,#0x100				@ Test current carry flag
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	orrne r0,r0,#1				@ Set bit 0 if carry was set
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_15:		@RL L
	mov r0,r8,lsr #16			@ Get source value
	tst r8,#0x100				@ Test current carry flag
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	orrne r0,r0,#1				@ Set bit 0 if carry was set
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_16:		@RL (HL)
	mov r1,r8,lsr #16			@ Get value of register
	and r1,r1,r12				@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100				@ Test current carry flag
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	orrne r0,r0,#1				@ Set bit 0 if carry was set
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	bl STOREMEM2
	@strb r0,[r3]				@ Store to mem, R3 still contain HL address
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

CBOPCODE_17:		@RL A
	mov r0,r8				@ Get source value
	tst r8,#0x100				@ Test current carry flag
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	orrne r0,r0,#1				@ Set bit 0 if carry was set
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_18:		@RR B
	mov r0,r9,lsr #8			@ Get source value
	mov r3,r8,lsr #8			@ Move old flags into R3
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift Right 1
	and r0,r0,#0x7F				@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100			@ Set Z80 carry flag is shift cause ARM carry
	tst r3,#1 				@ Test if old carry was set
	orrne r0,r0,#0x80			@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_19:		@RR C
	and r0,r9,#0xFF				@ Get source value and mask
	mov r3,r8,lsr #8			@ Move old flags into R3
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift Right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry flag is shift cause ARM carry
	tst r3,#1 				@ Test if old carry was set
	orrne r0,r0,#0x80			@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_1A:		@RR D
	mov r0,r9,lsr #24			@ Get source value
	mov r3,r8,lsr #8			@ Move old flags into R1
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift Right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry flag is shift cause ARM carry
	tst r3,#1 				@ Test if old carry was set
	orrne r0,r0,#0x80			@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_1B:		@RR E
	mov r0,r9,lsr #16			@ Get source value
	mov r3,r8,lsr #8			@ Move old flags into R1
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift Right 1
	and r0,r0,#0x7F				@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100			@ Set Z80 carry flag is shift cause ARM carry
	tst r3,#1 				@ Test if old carry was set
	orrne r0,r0,#0x80			@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_1C:		@RR H
	mov r0,r8,lsr #24			@ Get source value
	mov r3,r8,lsr #8			@ Move old flags into R1
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift Right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry flag is shift cause ARM carry
	tst r3,#1 				@ Test if old carry was set
	orrne r0,r0,#0x80			@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_1D:		@RR L
	mov r0,r8,lsr #16			@ Get source value
	mov r3,r8,lsr #8			@ Move old flags into R1
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift Right 1
	and r0,r0,#0x7F				@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100			@ Set Z80 carry flag is shift cause ARM carry
	tst r3,#1 				@ Test if old carry was set
	orrne r0,r0,#0x80			@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_1E:		@RR (HL)
	mov r1,r8,lsr #16			@ Get value of register
	and r1,r1,r12				@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r2,r8,lsr #8			@ Move old flags into R1
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift Right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry flag is shift cause ARM carry
	tst r2,#1 				@ Test if old carry was set
	orrne r0,r0,#0x80			@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	bl STOREMEM2
	@strb r0,[r3]				@ Store to mem
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

CBOPCODE_1F:		@RR A
	and r0,r8,#0xFF				@ Get source value
	mov r3,r8,lsr #8			@ Move old flags into R1
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift Right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry flag is shift cause ARM carry
	tst r3,#1 				@ Test if old carry was set
	orrne r0,r0,#0x80			@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_20:		@SLA B
	mov r0,r9,lsr #8			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_21:		@SLA C
	mov r0,r9				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_22:		@SLA D
	mov r0,r9,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_23:		@SLA E
	mov r0,r9,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_24:		@SLA H
	mov r0,r8,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_25:		@SLA L
	mov r0,r8,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_26:		@SLA (HL)
	mov r1,r8,lsr #16			@ Get value of register
	and r1,r1,r12				@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	bl STOREMEM2
	@strb r0,[r3]				@ Store to mem
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

CBOPCODE_27:		@SLA A
	mov r0,r8				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_28:		@SRA B
	mov r0,r9,lsr #8			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	bic r0,r0,#128				@ Clear bit 7
	tst r0,#64				@ Test bit 6
	orrne r0,r0,#0x80			@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_29:		@SRA C
	mov r0,r9				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	bic r0,r0,#128				@ Clear bit 7
	tst r0,#64				@ Test bit 6
	orrne r0,r0,#0x80			@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_2A:		@SRA D
	mov r0,r9,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	bic r0,r0,#128				@ Clear bit 7
	tst r0,#64				@ Test bit 6
	orrne r0,r0,#0x80			@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_2B:		@SRA E
	mov r0,r9,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	bic r0,r0,#128				@ Clear bit 7
	tst r0,#64				@ Test bit 6
	orrne r0,r0,#0x80			@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_2C:		@SRA H
	mov r0,r8,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	bic r0,r0,#128				@ Clear bit 7
	tst r0,#64				@ Test bit 6
	orrne r0,r0,#0x80			@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_2D:		@SRA L
	mov r0,r8,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	bic r0,r0,#128				@ Clear bit 7
	tst r0,#64				@ Test bit 6
	orrne r0,r0,#0x80			@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_2E:		@SRA (HL)
	mov r1,r8,lsr #16			@ Get value of register
	and r1,r1,r12				@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	bic r0,r0,#128				@ Clear bit 7
	tst r0,#64				@ Test bit 6
	orrne r0,r0,#0x80			@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	bl STOREMEM2
	@strb r0,[r3]				@ Store to mem
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

CBOPCODE_2F:		@SRA A
	mov r0,r8				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	bic r0,r0,#128				@ Clear bit 7
	tst r0,#64				@ Test bit 6
	orrne r0,r0,#0x80			@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF			@ Mask back to byte
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_30:		@SLL B
	mov r0,r9,lsr #8			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF				@ Mask back to byte
	orr r0,r0,#1				@ Insert 1 at end
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_31:		@SLL C
	mov r0,r9				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF				@ Mask back to byte
	orr r0,r0,#1				@ Insert 1 at end
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_32:		@SLL D
	mov r0,r9,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF				@ Mask back to byte
	orr r0,r0,#1				@ Insert 1 at end
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_33:		@SLL E
	mov r0,r9,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF				@ Mask back to byte
	orr r0,r0,#1				@ Insert 1 at end
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_34:		@SLL H
	mov r0,r8,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF				@ Mask back to byte
	orr r0,r0,#1				@ Insert 1 at end
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_35:		@SLL L
	mov r0,r8,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF				@ Mask back to byte
	orr r0,r0,#1				@ Insert 1 at end
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_36:		@SLL (HL)
	mov r1,r8,lsr #16			@ Get value of register
	and r1,r1,r12				@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF				@ Mask back to byte
	orr r0,r0,#1				@ Insert 1 at end
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	bl STOREMEM2
	@strb r0,[r3]				@ Store to mem
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

CBOPCODE_37:		@SLL A
	mov r0,r8				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	mov r0,r0,lsl #1			@ Shift left 1
	tst r0,#256				@ Test bit 8
	orrne r8,r8,#0x100			@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF				@ Mask back to byte
	orr r0,r0,#1				@ Insert 1 at end
	tst r0,#128				@ Test S flag
	orrne r8,r8,#0x8000			@ Set S flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_38:		@SRL B
	mov r0,r9,lsr #8			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F			@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_39:		@SRL C
	mov r0,r9				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F			@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_3A:		@SRL D
	mov r0,r9,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F			@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_3B:		@SRL E
	mov r0,r9,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F			@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_3C:		@SRL H
	mov r0,r8,lsr #24			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F			@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_3D:		@SRL L
	mov r0,r8,lsr #16			@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F			@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_3E:		@SRL (HL)
	mov r1,r8,lsr #16			@ Get value of register
	and r1,r1,r12				@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F			@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	bl STOREMEM2
	@strb r0,[r3]				@ Store to mem
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	mov r2,#15
B ENDOPCODES

CBOPCODE_3F:		@SRL A
	mov r0,r8				@ Get source value
	bic r8,r8,#0xFF00			@ Clear all flag
	movs r0,r0,lsr #1			@ Shift right 1
	orrcs r8,r8,#0x100			@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F			@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000			@ Set Zero flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	adrl r2,Parity				@ Get start of parity table
	ldrb r3,[r2,r0]				@ Get parity value
	cmp r3,#0				@ Test parity value
	orrne r8,r8,#0x400			@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0				@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_40:		@BIT 0,B
	mov r0,r9,lsr #8			@ Get source value
	ands r1,r0,#0x01			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_41:		@BIT 0,C
	mov r0,r9				@ Get source value
	ands r1,r0,#0x01			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_42:		@BIT 0,D
	mov r0,r9,lsr #24			@ Get source value
	ands r1,r0,#0x01			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_43:		@BIT 0,E
	mov r0,r9,lsr #16			@ Get source value
	ands r1,r0,#0x01			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_44:		@BIT 0,H
	mov r0,r8,lsr #24			@ Get source value
	ands r1,r0,#0x01			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_45:		@BIT 0,L
	mov r0,r8,lsr #16			@ Get source value
	ands r1,r0,#0x01			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_46:		@BIT 0,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	ands r1,r0,#0x01			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#12
B ENDOPCODES

CBOPCODE_47:		@BIT 0,A
	mov r0,r8			@ Get source value
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_48:		@BIT 1,B
	mov r0,r9,lsr #8			@ Get source value
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_49:		@BIT 1,C
	mov r0,r9			@ Get source value
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_4A:		@BIT 1,D
	mov r0,r9,lsr #24			@ Get source value
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_4B:		@BIT 1,E
	mov r0,r9,lsr #16			@ Get source value
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_4C:		@BIT 1,H
	mov r0,r8,lsr #24			@ Get source value
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_4D:		@BIT 1,L
	mov r0,r8,lsr #16			@ Get source value
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_4E:		@BIT 1,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	ands r1,r0,#0x02			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#12
B ENDOPCODES

CBOPCODE_4F:		@BIT 1,A
	mov r0,r8			@ Get source value
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_50:		@BIT 2,B
	mov r0,r9,lsr #8			@ Get source value
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_51:		@BIT 2,C
	mov r0,r9			@ Get source value
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_52:		@BIT 2,D
	mov r0,r9,lsr #24			@ Get source value
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_53:		@BIT 2,E
	mov r0,r9,lsr #16			@ Get source value
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_54:		@BIT 2,H
	mov r0,r8,lsr #24			@ Get source value
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_55:		@BIT 2,L
	mov r0,r8,lsr #16			@ Get source value
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_56:		@BIT 2,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	ands r1,r0,#0x04			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#12
B ENDOPCODES

CBOPCODE_57:		@BIT 2,A
	mov r0,r8			@ Get source value
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_58:		@BIT 3,B
	mov r0,r9,lsr #8			@ Get source value
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_59:		@BIT 3,C
	mov r0,r9			@ Get source value
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_5A:		@BIT 3,D
	mov r0,r9,lsr #24			@ Get source value
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_5B:		@BIT 3,E
	mov r0,r9,lsr #16			@ Get source value
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_5C:		@BIT 3,H
	mov r0,r8,lsr #24			@ Get source value
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_5D:		@BIT 3,L
	mov r0,r8,lsr #16			@ Get source value
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_5E:		@BIT 3,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	ands r1,r0,#0x08			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#12
B ENDOPCODES

CBOPCODE_5F:		@BIT 3,A
	mov r0,r8			@ Get source value
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_60:		@BIT 4,B
	mov r0,r9,lsr #8			@ Get source value
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_61:		@BIT 4,C
	mov r0,r9			@ Get source value
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_62:		@BIT 4,D
	mov r0,r9,lsr #24			@ Get source value
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_63:		@BIT 4,E
	mov r0,r9,lsr #16			@ Get source value
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_64:		@BIT 4,H
	mov r0,r8,lsr #24			@ Get source value
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_65:		@BIT 4,L
	mov r0,r8,lsr #16			@ Get source value
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_66:		@BIT 4,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	ands r1,r0,#0x10			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#12
B ENDOPCODES

CBOPCODE_67:		@BIT 4,A
	mov r0,r8			@ Get source value
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_68:		@BIT 5,B
	mov r0,r9,lsr #8			@ Get source value
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_69:		@BIT 5,C
	mov r0,r9			@ Get source value
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_6A:		@BIT 5,D
	mov r0,r9,lsr #24			@ Get source value
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_6B:		@BIT 5,E
	mov r0,r9,lsr #16			@ Get source value
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_6C:		@BIT 5,H
	mov r0,r8,lsr #24			@ Get source value
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_6D:		@BIT 5,L
	mov r0,r8,lsr #16			@ Get source value
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_6E:		@BIT 5,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	ands r1,r0,#0x20			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#12
B ENDOPCODES

CBOPCODE_6F:		@BIT 5,A
	mov r0,r8			@ Get source value
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_70:		@BIT 6,B
	mov r0,r9,lsr #8			@ Get source value
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_71:		@BIT 6,C
	mov r0,r9			@ Get source value
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_72:		@BIT 6,D
	mov r0,r9,lsr #24			@ Get source value
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_73:		@BIT 6,E
	mov r0,r9,lsr #16			@ Get source value
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_74:		@BIT 6,H
	mov r0,r8,lsr #24			@ Get source value
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_75:		@BIT 6,L
	mov r0,r8,lsr #16			@ Get source value
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_76:		@BIT 6,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	ands r1,r0,#0x40			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#12
B ENDOPCODES

CBOPCODE_77:		@BIT 6,A
	mov r0,r8			@ Get source value
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_78:		@BIT 7,B
	mov r0,r9,lsr #8			@ Get source value
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_79:		@BIT 7,C
	mov r0,r9			@ Get source value
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_7A:		@BIT 7,D
	mov r0,r9,lsr #24			@ Get source value
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_7B:		@BIT 7,E
	mov r0,r9,lsr #16			@ Get source value
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_7C:		@BIT 7,H
	mov r0,r8,lsr #24			@ Get source value
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_7D:		@BIT 7,L
	mov r0,r8,lsr #16			@ Get source value
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_7E:		@BIT 7,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	ands r1,r0,#0x80			@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000			@Set S flag if bit was set
	orreq r8,r8,#0x4400			@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#12
B ENDOPCODES

CBOPCODE_7F:		@BIT 7,A
	mov r0,r8			@ Get source value
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#8
B ENDOPCODES

CBOPCODE_80:		@RES 0,B
	mov r0,r9,lsr #8			@ Get source value
	bic r0,r0,#0x01			@ Reset Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_81:		@RES 0,C
	mov r0,r9			@ Get source value
	bic r0,r0,#0x01			@ Reset Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_82:		@RES 0,D
	mov r0,r9,lsr #24			@ Get source value
	bic r0,r0,#0x01			@ Reset Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_83:		@RES 0,E
	mov r0,r9,lsr #16			@ Get source value
	bic r0,r0,#0x01			@ Reset Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_84:		@RES 0,H
	mov r0,r8,lsr #24			@ Get source value
	bic r0,r0,#0x01			@ Reset Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_85:		@RES 0,L
	mov r0,r8,lsr #16			@ Get source value
	bic r0,r0,#0x01			@ Reset Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_86:		@RES 0,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_87:		@RES 0,A
	mov r0,r8			@ Get source value
	bic r0,r0,#0x01			@ Reset Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_88:		@RES 1,B
	mov r0,r9,lsr #8			@ Get source value
	bic r0,r0,#0x02			@ Reset Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_89:		@RES 1,C
	mov r0,r9			@ Get source value
	bic r0,r0,#0x02			@ Reset Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_8A:		@RES 1,D
	mov r0,r9,lsr #24			@ Get source value
	bic r0,r0,#0x02			@ Reset Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_8B:		@RES 1,E
	mov r0,r9,lsr #16			@ Get source value
	bic r0,r0,#0x02			@ Reset Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_8C:		@RES 1,H
	mov r0,r8,lsr #24			@ Get source value
	bic r0,r0,#0x02			@ Reset Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_8D:		@RES 1,L
	mov r0,r8,lsr #16			@ Get source value
	bic r0,r0,#0x02			@ Reset Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_8E:		@RES 1,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_8F:		@RES 1,A
	mov r0,r8			@ Get source value
	bic r0,r0,#0x02			@ Reset Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_90:		@RES 2,B
	mov r0,r9,lsr #8			@ Get source value
	bic r0,r0,#0x04			@ Reset Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_91:		@RES 2,C
	mov r0,r9			@ Get source value
	bic r0,r0,#0x04			@ Reset Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_92:		@RES 2,D
	mov r0,r9,lsr #24			@ Get source value
	bic r0,r0,#0x04			@ Reset Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_93:		@RES 2,E
	mov r0,r9,lsr #16			@ Get source value
	bic r0,r0,#0x04			@ Reset Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_94:		@RES 2,H
	mov r0,r8,lsr #24			@ Get source value
	bic r0,r0,#0x04			@ Reset Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_95:		@RES 2,L
	mov r0,r8,lsr #16			@ Get source value
	bic r0,r0,#0x04			@ Reset Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_96:		@RES 2,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_97:		@RES 2,A
	mov r0,r8			@ Get source value
	bic r0,r0,#0x04			@ Reset Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_98:		@RES 3,B
	mov r0,r9,lsr #8			@ Get source value
	bic r0,r0,#0x08			@ Reset Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_99:		@RES 3,C
	mov r0,r9			@ Get source value
	bic r0,r0,#0x08			@ Reset Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_9A:		@RES 3,D
	mov r0,r9,lsr #24			@ Get source value
	bic r0,r0,#0x08			@ Reset Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_9B:		@RES 3,E
	mov r0,r9,lsr #16			@ Get source value
	bic r0,r0,#0x08			@ Reset Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_9C:		@RES 3,H
	mov r0,r8,lsr #24			@ Get source value
	bic r0,r0,#0x08			@ Reset Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_9D:		@RES 3,L
	mov r0,r8,lsr #16			@ Get source value
	bic r0,r0,#0x08			@ Reset Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_9E:		@RES 3,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_9F:		@RES 3,A
	mov r0,r8			@ Get source value
	bic r0,r0,#0x08			@ Reset Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_A0:		@RES 4,B
	mov r0,r9,lsr #8			@ Get source value
	bic r0,r0,#0x10			@ Reset Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_A1:		@RES 4,C
	mov r0,r9			@ Get source value
	bic r0,r0,#0x10			@ Reset Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_A2:		@RES 4,D
	mov r0,r9,lsr #24			@ Get source value
	bic r0,r0,#0x10			@ Reset Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_A3:		@RES 4,E
	mov r0,r9,lsr #16			@ Get source value
	bic r0,r0,#0x10			@ Reset Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_A4:		@RES 4,H
	mov r0,r8,lsr #24			@ Get source value
	bic r0,r0,#0x10			@ Reset Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_A5:		@RES 4,L
	mov r0,r8,lsr #16			@ Get source value
	bic r0,r0,#0x10			@ Reset Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_A6:		@RES 4,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_A7:		@RES 4,A
	mov r0,r8			@ Get source value
	bic r0,r0,#0x10			@ Reset Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_A8:		@RES 5,B
	mov r0,r9,lsr #8			@ Get source value
	bic r0,r0,#0x20			@ Reset Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_A9:		@RES 5,C
	mov r0,r9			@ Get source value
	bic r0,r0,#0x20			@ Reset Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_AA:		@RES 5,D
	mov r0,r9,lsr #24			@ Get source value
	bic r0,r0,#0x20			@ Reset Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_AB:		@RES 5,E
	mov r0,r9,lsr #16			@ Get source value
	bic r0,r0,#0x20			@ Reset Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_AC:		@RES 5,H
	mov r0,r8,lsr #24			@ Get source value
	bic r0,r0,#0x20			@ Reset Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_AD:		@RES 5,L
	mov r0,r8,lsr #16			@ Get source value
	bic r0,r0,#0x20			@ Reset Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_AE:		@RES 5,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_AF:		@RES 5,A
	mov r0,r8			@ Get source value
	bic r0,r0,#0x20			@ Reset Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_B0:		@RES 6,B
	mov r0,r9,lsr #8			@ Get source value
	bic r0,r0,#0x40			@ Reset Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_B1:		@RES 6,C
	mov r0,r9			@ Get source value
	bic r0,r0,#0x40			@ Reset Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_B2:		@RES 6,D
	mov r0,r9,lsr #24			@ Get source value
	bic r0,r0,#0x40			@ Reset Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_B3:		@RES 6,E
	mov r0,r9,lsr #16			@ Get source value
	bic r0,r0,#0x40			@ Reset Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_B4:		@RES 6,H
	mov r0,r8,lsr #24			@ Get source value
	bic r0,r0,#0x40			@ Reset Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_B5:		@RES 6,L
	mov r0,r8,lsr #16			@ Get source value
	bic r0,r0,#0x40			@ Reset Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_B6:		@RES 6,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_B7:		@RES 6,A
	mov r0,r8			@ Get source value
	bic r0,r0,#0x40			@ Reset Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_B8:		@RES 7,B
	mov r0,r9,lsr #8			@ Get source value
	bic r0,r0,#0x80			@ Reset Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_B9:		@RES 7,C
	mov r0,r9			@ Get source value
	bic r0,r0,#0x80			@ Reset Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_BA:		@RES 7,D
	mov r0,r9,lsr #24			@ Get source value
	bic r0,r0,#0x80			@ Reset Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_BB:		@RES 7,E
	mov r0,r9,lsr #16			@ Get source value
	bic r0,r0,#0x80			@ Reset Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_BC:		@RES 7,H
	mov r0,r8,lsr #24			@ Get source value
	bic r0,r0,#0x80			@ Reset Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_BD:		@RES 7,L
	mov r0,r8,lsr #16			@ Get source value
	bic r0,r0,#0x80			@ Reset Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_BE:		@RES 7,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_BF:		@RES 7,A
	mov r0,r8			@ Get source value
	bic r0,r0,#0x80			@ Reset Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_C0:		@SET 0,B
	mov r0,r9,lsr #8			@ Get source value
	orr r0,r0,#0x01			@ Set Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_C1:		@SET 0,C
	mov r0,r9			@ Get source value
	orr r0,r0,#0x01			@ Set Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_C2:		@SET 0,D
	mov r0,r9,lsr #24			@ Get source value
	orr r0,r0,#0x01			@ Set Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_C3:		@SET 0,E
	mov r0,r9,lsr #16			@ Get source value
	orr r0,r0,#0x01			@ Set Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_C4:		@SET 0,H
	mov r0,r8,lsr #24			@ Get source value
	orr r0,r0,#0x01			@ Set Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_C5:		@SET 0,L
	mov r0,r8,lsr #16			@ Get source value
	orr r0,r0,#0x01			@ Set Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_C6:		@SET 0,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_C7:		@SET 0,A
	mov r0,r8			@ Get source value
	orr r0,r0,#0x01			@ Set Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_C8:		@SET 1,B
	mov r0,r9,lsr #8			@ Get source value
	orr r0,r0,#0x02			@ Set Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_C9:		@SET 1,C
	mov r0,r9			@ Get source value
	orr r0,r0,#0x02			@ Set Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_CA:		@SET 1,D
	mov r0,r9,lsr #24			@ Get source value
	orr r0,r0,#0x02			@ Set Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_CB:		@SET 1,E
	mov r0,r9,lsr #16			@ Get source value
	orr r0,r0,#0x02			@ Set Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_CC:		@SET 1,H
	mov r0,r8,lsr #24			@ Get source value
	orr r0,r0,#0x02			@ Set Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_CD:		@SET 1,L
	mov r0,r8,lsr #16			@ Get source value
	orr r0,r0,#0x02			@ Set Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_CE:		@SET 1,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_CF:		@SET 1,A
	mov r0,r8			@ Get source value
	orr r0,r0,#0x02			@ Set Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_D0:		@SET 2,B
	mov r0,r9,lsr #8			@ Get source value
	orr r0,r0,#0x04			@ Set Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_D1:		@SET 2,C
	mov r0,r9			@ Get source value
	orr r0,r0,#0x04			@ Set Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_D2:		@SET 2,D
	mov r0,r9,lsr #24			@ Get source value
	orr r0,r0,#0x04			@ Set Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_D3:		@SET 2,E
	mov r0,r9,lsr #16			@ Get source value
	orr r0,r0,#0x04			@ Set Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_D4:		@SET 2,H
	mov r0,r8,lsr #24			@ Get source value
	orr r0,r0,#0x04			@ Set Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_D5:		@SET 2,L
	mov r0,r8,lsr #16			@ Get source value
	orr r0,r0,#0x04			@ Set Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_D6:		@SET 2,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_D7:		@SET 2,A
	mov r0,r8			@ Get source value
	orr r0,r0,#0x04			@ Set Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_D8:		@SET 3,B
	mov r0,r9,lsr #8			@ Get source value
	orr r0,r0,#0x08			@ Set Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_D9:		@SET 3,C
	mov r0,r9			@ Get source value
	orr r0,r0,#0x08			@ Set Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_DA:		@SET 3,D
	mov r0,r9,lsr #24			@ Get source value
	orr r0,r0,#0x08			@ Set Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_DB:		@SET 3,E
	mov r0,r9,lsr #16			@ Get source value
	orr r0,r0,#0x08			@ Set Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_DC:		@SET 3,H
	mov r0,r8,lsr #24			@ Get source value
	orr r0,r0,#0x08			@ Set Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_DD:		@SET 3,L
	mov r0,r8,lsr #16			@ Get source value
	orr r0,r0,#0x08			@ Set Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_DE:		@SET 3,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_DF:		@SET 3,A
	mov r0,r8			@ Get source value
	orr r0,r0,#0x08			@ Set Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_E0:		@SET 4,B
	mov r0,r9,lsr #8			@ Get source value
	orr r0,r0,#0x10			@ Set Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_E1:		@SET 4,C
	mov r0,r9			@ Get source value
	orr r0,r0,#0x10			@ Set Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_E2:		@SET 4,D
	mov r0,r9,lsr #24			@ Get source value
	orr r0,r0,#0x10			@ Set Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_E3:		@SET 4,E
	mov r0,r9,lsr #16			@ Get source value
	orr r0,r0,#0x10			@ Set Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_E4:		@SET 4,H
	mov r0,r8,lsr #24			@ Get source value
	orr r0,r0,#0x10			@ Set Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_E5:		@SET 4,L
	mov r0,r8,lsr #16			@ Get source value
	orr r0,r0,#0x10			@ Set Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_E6:		@SET 4,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_E7:		@SET 4,A
	mov r0,r8			@ Get source value
	orr r0,r0,#0x10			@ Set Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_E8:		@SET 5,B
	mov r0,r9,lsr #8			@ Get source value
	orr r0,r0,#0x20			@ Set Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_E9:		@SET 5,C
	mov r0,r9			@ Get source value
	orr r0,r0,#0x20			@ Set Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_EA:		@SET 5,D
	mov r0,r9,lsr #24			@ Get source value
	orr r0,r0,#0x20			@ Set Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_EB:		@SET 5,E
	mov r0,r9,lsr #16			@ Get source value
	orr r0,r0,#0x20			@ Set Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_EC:		@SET 5,H
	mov r0,r8,lsr #24			@ Get source value
	orr r0,r0,#0x20			@ Set Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_ED:		@SET 5,L
	mov r0,r8,lsr #16			@ Get source value
	orr r0,r0,#0x20			@ Set Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_EE:		@SET 5,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_EF:		@SET 5,A
	mov r0,r8			@ Get source value
	orr r0,r0,#0x20			@ Set Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_F0:		@SET 6,B
	mov r0,r9,lsr #8			@ Get source value
	orr r0,r0,#0x40			@ Set Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_F1:		@SET 6,C
	mov r0,r9			@ Get source value
	orr r0,r0,#0x40			@ Set Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_F2:		@SET 6,D
	mov r0,r9,lsr #24			@ Get source value
	orr r0,r0,#0x40			@ Set Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_F3:		@SET 6,E
	mov r0,r9,lsr #16			@ Get source value
	orr r0,r0,#0x40			@ Set Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_F4:		@SET 6,H
	mov r0,r8,lsr #24			@ Get source value
	orr r0,r0,#0x40			@ Set Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_F5:		@SET 6,L
	mov r0,r8,lsr #16			@ Get source value
	orr r0,r0,#0x40			@ Set Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_F6:		@SET 6,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_F7:		@SET 6,A
	mov r0,r8			@ Get source value
	orr r0,r0,#0x40			@ Set Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_F8:		@SET 7,B
	mov r0,r9,lsr #8			@ Get source value
	orr r0,r0,#0x80			@ Set Bit
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_F9:		@SET 7,C
	mov r0,r9			@ Get source value
	orr r0,r0,#0x80			@ Set Bit
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_FA:		@SET 7,D
	mov r0,r9,lsr #24			@ Get source value
	orr r0,r0,#0x80			@ Set Bit
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_FB:		@SET 7,E
	mov r0,r9,lsr #16			@ Get source value
	orr r0,r0,#0x80			@ Set Bit
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_FC:		@SET 7,H
	mov r0,r8,lsr #24			@ Get source value
	orr r0,r0,#0x80			@ Set Bit
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_FD:		@SET 7,L
	mov r0,r8,lsr #16			@ Get source value
	orr r0,r0,#0x80			@ Set Bit
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#8
B ENDOPCODES

CBOPCODE_FE:		@SET 7,(HL)
	mov r1,r8,lsr #16			@ Get value of register
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2
	@strb r0,[r3]				@ Store value in memory
	mov r2,#15
B ENDOPCODES

CBOPCODE_FF:		@SET 7,A
	mov r0,r8			@ Get source value
	orr r0,r0,#0x80			@ Set Bit
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDCODES:
	bl MEMFETCH
	add r1,r1,#1		@R1 should still contain the PC so increment
	and r1,r1,r12		@Mask the 16 bits that relate to the PC
	bic r7,r7,r12		@Clear the old PC value
	orr r7,r7,r1		@Store the new PC value
	add r2,r5,#1
	and r2,r2,#127
	bic r5,r5,#127
	orr r5,r5,r2				@ 4 Lines to increase r register!
@	ldr r3,=rpointer
@	ldr r2,[r3]    		@These three lines store the opcode For debugging
@	Str r0,[r2,#40]
	add r15,r15,r0, lsl #2  @Multipy opcode by 4 To get value To add To PC

	nop

			B DDOPCODE_00
			B DDOPCODE_01
			B DDOPCODE_02
			B DDOPCODE_03
			B DDOPCODE_04
			B DDOPCODE_05
			B DDOPCODE_06
			B DDOPCODE_07
			B DDOPCODE_08
			B DDOPCODE_09
			B DDOPCODE_0A
			B DDOPCODE_0B
			B DDOPCODE_0C
			B DDOPCODE_0D
			B DDOPCODE_0E
			B DDOPCODE_0F
			B DDOPCODE_10
			B DDOPCODE_11
			B DDOPCODE_12
			B DDOPCODE_13
			B DDOPCODE_14
			B DDOPCODE_15
			B DDOPCODE_16
			B DDOPCODE_17
			B DDOPCODE_18
			B DDOPCODE_19
			B DDOPCODE_1A
			B DDOPCODE_1B
			B DDOPCODE_1C
			B DDOPCODE_1D
			B DDOPCODE_1E
			B DDOPCODE_1F
			B DDOPCODE_20
			B DDOPCODE_21
			B DDOPCODE_22
			B DDOPCODE_23
			B DDOPCODE_24
			B DDOPCODE_25
			B DDOPCODE_26
			B DDOPCODE_27
			B DDOPCODE_28
			B DDOPCODE_29
			B DDOPCODE_2A
			B DDOPCODE_2B
			B DDOPCODE_2C
			B DDOPCODE_2D
			B DDOPCODE_2E
			B DDOPCODE_2F
			B DDOPCODE_30
			B DDOPCODE_31
			B DDOPCODE_32
			B DDOPCODE_33
			B DDOPCODE_34
			B DDOPCODE_35
			B DDOPCODE_36
			B DDOPCODE_37
			B DDOPCODE_38
			B DDOPCODE_39
			B DDOPCODE_3A
			B DDOPCODE_3B
			B DDOPCODE_3C
			B DDOPCODE_3D
			B DDOPCODE_3E
			B DDOPCODE_3F
			B DDOPCODE_40
			B DDOPCODE_41
			B DDOPCODE_42
			B DDOPCODE_43
			B DDOPCODE_44
			B DDOPCODE_45
			B DDOPCODE_46
			B DDOPCODE_47
			B DDOPCODE_48
			B DDOPCODE_49
			B DDOPCODE_4A
			B DDOPCODE_4B
			B DDOPCODE_4C
			B DDOPCODE_4D
			B DDOPCODE_4E
			B DDOPCODE_4F
			B DDOPCODE_50
			B DDOPCODE_51
			B DDOPCODE_52
			B DDOPCODE_53
			B DDOPCODE_54
			B DDOPCODE_55
			B DDOPCODE_56
			B DDOPCODE_57
			B DDOPCODE_58
			B DDOPCODE_59
			B DDOPCODE_5A
			B DDOPCODE_5B
			B DDOPCODE_5C
			B DDOPCODE_5D
			B DDOPCODE_5E
			B DDOPCODE_5F
			B DDOPCODE_60
			B DDOPCODE_61
			B DDOPCODE_62
			B DDOPCODE_63
			B DDOPCODE_64
			B DDOPCODE_65
			B DDOPCODE_66
			B DDOPCODE_67
			B DDOPCODE_68
			B DDOPCODE_69
			B DDOPCODE_6A
			B DDOPCODE_6B
			B DDOPCODE_6C
			B DDOPCODE_6D
			B DDOPCODE_6E
			B DDOPCODE_6F
			B DDOPCODE_70
			B DDOPCODE_71
			B DDOPCODE_72
			B DDOPCODE_73
			B DDOPCODE_74
			B DDOPCODE_75
			B DDOPCODE_76
			B DDOPCODE_77
			B DDOPCODE_78
			B DDOPCODE_79
			B DDOPCODE_7A
			B DDOPCODE_7B
			B DDOPCODE_7C
			B DDOPCODE_7D
			B DDOPCODE_7E
			B DDOPCODE_7F
			B DDOPCODE_80
			B DDOPCODE_81
			B DDOPCODE_82
			B DDOPCODE_83
			B DDOPCODE_84
			B DDOPCODE_85
			B DDOPCODE_86
			B DDOPCODE_87
			B DDOPCODE_88
			B DDOPCODE_89
			B DDOPCODE_8A
			B DDOPCODE_8B
			B DDOPCODE_8C
			B DDOPCODE_8D
			B DDOPCODE_8E
			B DDOPCODE_8F
			B DDOPCODE_90
			B DDOPCODE_91
			B DDOPCODE_92
			B DDOPCODE_93
			B DDOPCODE_94
			B DDOPCODE_95
			B DDOPCODE_96
			B DDOPCODE_97
			B DDOPCODE_98
			B DDOPCODE_99
			B DDOPCODE_9A
			B DDOPCODE_9B
			B DDOPCODE_9C
			B DDOPCODE_9D
			B DDOPCODE_9E
			B DDOPCODE_9F
			B DDOPCODE_A0
			B DDOPCODE_A1
			B DDOPCODE_A2
			B DDOPCODE_A3
			B DDOPCODE_A4
			B DDOPCODE_A5
			B DDOPCODE_A6
			B DDOPCODE_A7
			B DDOPCODE_A8
			B DDOPCODE_A9
			B DDOPCODE_AA
			B DDOPCODE_AB
			B DDOPCODE_AC
			B DDOPCODE_AD
			B DDOPCODE_AE
			B DDOPCODE_AF
			B DDOPCODE_B0
			B DDOPCODE_B1
			B DDOPCODE_B2
			B DDOPCODE_B3
			B DDOPCODE_B4
			B DDOPCODE_B5
			B DDOPCODE_B6
			B DDOPCODE_B7
			B DDOPCODE_B8
			B DDOPCODE_B9
			B DDOPCODE_BA
			B DDOPCODE_BB
			B DDOPCODE_BC
			B DDOPCODE_BD
			B DDOPCODE_BE
			B DDOPCODE_BF
			B DDOPCODE_C0
			B DDOPCODE_C1
			B DDOPCODE_C2
			B DDOPCODE_C3
			B DDOPCODE_C4
			B DDOPCODE_C5
			B DDOPCODE_C6
			B DDOPCODE_C7
			B DDOPCODE_C8
			B DDOPCODE_C9
			B DDOPCODE_CA
			B DDOPCODE_CB
			B DDOPCODE_CC
			B DDOPCODE_CD
			B DDOPCODE_CE
			B DDOPCODE_CF
			B DDOPCODE_D0
			B DDOPCODE_D1
			B DDOPCODE_D2
			B DDOPCODE_D3
			B DDOPCODE_D4
			B DDOPCODE_D5
			B DDOPCODE_D6
			B DDOPCODE_D7
			B DDOPCODE_D8
			B DDOPCODE_D9
			B DDOPCODE_DA
			B DDOPCODE_DB
			B DDOPCODE_DC
			B DDOPCODE_DD
			B DDOPCODE_DE
			B DDOPCODE_DF
			B DDOPCODE_E0
			B DDOPCODE_E1
			B DDOPCODE_E2
			B DDOPCODE_E3
			B DDOPCODE_E4
			B DDOPCODE_E5
			B DDOPCODE_E6
			B DDOPCODE_E7
			B DDOPCODE_E8
			B DDOPCODE_E9
			B DDOPCODE_EA
			B DDOPCODE_EB
			B DDOPCODE_EC
			B DDOPCODE_ED
			B DDOPCODE_EE
			B DDOPCODE_EF
			B DDOPCODE_F0
			B DDOPCODE_F1
			B DDOPCODE_F2
			B DDOPCODE_F3
			B DDOPCODE_F4
			B DDOPCODE_F5
			B DDOPCODE_F6
			B DDOPCODE_F7
			B DDOPCODE_F8
			B DDOPCODE_F9
			B DDOPCODE_FA
			B DDOPCODE_FB
			B DDOPCODE_FC
			B DDOPCODE_FD
			B DDOPCODE_FE
			B DDOPCODE_FF

DDOPCODE_00:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_01:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_02:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_03:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_04:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_05:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_06:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_07:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_08:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_09:		@ADD IX,BC
	and r0,r9,r12			@ Maskto 16 bits
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	and r1,r10,r12			@ Mask off destination reg to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r2
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r10,r12			@ Get destination register
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r10,r10,r12			@ Clear target short To 0
	orr r10,r10,r2			@ Place value on target register
	mov r2,#15
B ENDOPCODES

DDOPCODE_0A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_0B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_0C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_0D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_0E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_0F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_10:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_11:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_12:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_13:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_14:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_15:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_16:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_17:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_18:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_19:		@ADD IX,DE
	mov r0,r9,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	and r1,r10,r12			@ Mask off destination reg to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r2
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r10,r12			@ Get destination register
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r10,r10,r12			@ Clear target short To 0
	orr r10,r10,r2			@ Place value on target register
	mov r2,#15
B ENDOPCODES

DDOPCODE_1A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_1B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_1C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_1D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_1E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_1F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_20:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_21:		@LD IX,nn
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT
	add r1,r1,#2			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r10,r10,r12			@ Clear target byte To 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#14
B ENDOPCODES

DDOPCODE_22:		@LD (nn),IX
@	mov r0,r10			@ Get source value
	and r0,r10,r12			@ Mask value to a 16 bit number
	and r2,r7,r12			@ Mask PC register
	add r1,r2,#2			@ Store PC + 2 in R1
	and r1,r1,r12			@ Mask new PC to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store incremented value
	bl MEMFETCHSHORT2		@ Get memory location into R1
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#20
B ENDOPCODES

DDOPCODE_23:		@INC IX
	add r0,r10,#1			@ Increase source by 1
	and r0,r0,r12			@ Mask to 16 bits
	bic r10,r10,r12			@ Clear target byte To 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#10
B ENDOPCODES

DDOPCODE_24:		@INC IXH
	mov r0,r10,lsr #8		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibble
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r10,r10,#0x0000FF00		@ Clear target byte to 0
	orr r10,r10,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_25:		@DEC IXH
	mov r0,r10,lsr #8		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibble
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r10,r10,#0x0000FF00		@ Clear target byte to 0
	orr r10,r10,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_26:		@LD IXH,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r10,r10,#0x0000FF00		@ Clear target byte to 0
	orr r10,r10,r0,lsl #8		@ Place value on target register
	mov r2,#11
B ENDOPCODES

DDOPCODE_27:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_28:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_29:		@ADD IX,IX
	and r0,r10,r12			@ Get source value and mask to 16 bits
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	and r1,r0,r12			@ Adjust to low 'nibble'
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r1
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r2,r0,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r10,r10,r12			@ Clear target short To 0
	orr r10,r10,r2			@ Place value on target register
	mov r2,#15
B ENDOPCODES

DDOPCODE_2A:		@LD IX,(nn)
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT2		@ Get address
	add r2,r2,#2			@ Increment PC
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	bl MEMREADSHORT			@ Load 16 bit value from memory
	bic r10,r10,r12			@ Clear target byte To 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#20
B ENDOPCODES

DDOPCODE_2B:		@DEC IX
	sub r0,r10,#1			@ Decrease by 1
	and r0,r0,r12			@ Mask to 16 bits
	bic r10,r10,r12			@ Clear target byte To 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#10
B ENDOPCODES

DDOPCODE_2C:		@INC IXL
	mov r0,r10			@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibble
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r10,r10,#0x000000FF		@ Clear target byte to 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_2D:		@DEC IXL
	mov r0,r10			@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibble
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r10,r10,#0x000000FF		@ Clear target byte to 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_2E:		@LD IXL,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r10,r10,#0x000000FF		@ Clear target byte to 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#11
B ENDOPCODES

DDOPCODE_2F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_30:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_31:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_32:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_33:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_34:		@INC (IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r10,r12			@ Get masked valued of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12
	bl MEMREAD	 		@ load value from memory
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibbl
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2
	@strb r0,[r3] 			@ Store value in memory
	mov r2,#23
B ENDOPCODES

DDOPCODE_35:		@DEC (IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r10,r12			@ Get masked valued of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12
	bl MEMREAD	 		@ Load value from memory
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bl STOREMEM2
	@strb r0,[r3] 			@ Store value in memory
	mov r2,#23
B ENDOPCODES

DDOPCODE_36:		@LD (IX+d),n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH				@ Get displacement
	mov r4,r0
	add r1,r1,#1			@ Increase PC
	bl MEMFETCH				@ Get value
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r2,r10,r12			@ Get masked valued of register
	add r1,r2,r4			@ Add displacement
	tst r4,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

DDOPCODE_37:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_38:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_39:		@ADD IX,SP
	mov r0,r7,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	and r1,r10,r12			@ Mask off destination reg to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r2
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r10,r12			@ Mask off to destination reg to 16 bits
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	and r2,r2,r12			@ Mask back to 16 bits
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r10,r10,r12			@ Clear target short To 0
	orr r10,r10,r2			@ Place value on target register
	mov r2,#15
B ENDOPCODES

DDOPCODE_3A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_3B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_3C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_3D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_3E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_3F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_40:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_41:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_42:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_43:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_44:		@LD B,IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_45:		@LD B,IXL
	and r0,r10,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_46:		@LD B,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	add r1,r10,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#19
B ENDOPCODES

DDOPCODE_47:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_48:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_49:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_4A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_4B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_4C:		@LD C,IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_4D:		@LD C,IXL
	and r0,r10,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_4E:		@LD C,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	add r1,r10,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#19
B ENDOPCODES

DDOPCODE_4F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_50:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_51:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_52:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_53:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_54:		@LD D,IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_55:		@LD D,IXL
	and r0,r10,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_56:		@LD D,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	add r1,r10,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#19
B ENDOPCODES

DDOPCODE_57:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_58:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_59:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_5A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_5B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_5C:		@LD E,IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_5D:		@LD E,IXL
	and r0,r10,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_5E:		@LD E,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	add r1,r10,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#19
B ENDOPCODES

DDOPCODE_5F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_60:		@LD IXH,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x0000FF00		@ Clear target byte to 0
	orr r10,r10,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_61:		@LD IXH,C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x0000FF00		@ Clear target byte to 0
	orr r10,r10,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_62:		@LD IXH,D
	mov r0,r9,lsr #24		@ Get source value
	bic r10,r10,#0x0000FF00		@ Clear target byte to 0
	orr r10,r10,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_63:		@LD IXH,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x0000FF00		@ Clear target byte to 0
	orr r10,r10,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_64:		@LD IXH,IXH
	mov r2,#8
B ENDOPCODES

DDOPCODE_65:		@LD IXH,IXL
	and r0,r10,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x0000FF00		@ Clear target byte to 0
	orr r10,r10,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_66:		@LD H,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	add r1,r10,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#19
B ENDOPCODES

DDOPCODE_67:		@LD IXH,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x0000FF00		@ Clear target byte to 0
	orr r10,r10,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_68:		@LD IXL,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x000000FF		@ Clear target byte to 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_69:		@LD IXL,C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x000000FF		@ Clear target byte to 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_6A:		@LD IXL,D
	mov r0,r9,lsr #24		@ Get source value
	bic r10,r10,#0x000000FF		@ Clear target byte to 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_6B:		@LD IXL,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x000000FF		@ Clear target byte to 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_6C:		@LD IXL,IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x000000FF		@ Clear target byte to 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_6D:		@LD IXL,IXL
	mov r2,#8
B ENDOPCODES

DDOPCODE_6E:		@LD L,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	add r1,r10,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#19
B ENDOPCODES

DDOPCODE_6F:		@LD IXL,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x000000FF		@ Clear target byte to 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_70:		@LD (IX+d),B
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r10			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask to 16 bit
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

DDOPCODE_71:		@LD (IX+d),C
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r10			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask to 16 bit
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

DDOPCODE_72:		@LD (IX+d),D
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	mov r0,r9,lsr #24		@ Get source value
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r10			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask to 16 bit
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

DDOPCODE_73:		@LD (IX+d),E
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r10			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask to 16 bit
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

DDOPCODE_74:		@LD (IX+d),H
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	mov r0,r8,lsr #24			@ Get source value
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r10			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask to 16 bit
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

DDOPCODE_75:		@LD (IX+d),L
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r10			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask to 16 bit
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

DDOPCODE_76:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_77:		@LD (IX+d),A
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r10			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask to 16 bit
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

DDOPCODE_78:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_79:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_7A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_7B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_7C:		@LD A,IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_7D:		@LD A,IXL
	and r0,r10,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_7E:		@LD A,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	add r1,r10,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#19
B ENDOPCODES

DDOPCODE_7F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_80:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_81:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_82:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_83:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_84:		@ADD A,IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128				@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

DDOPCODE_85:		@ADD A,IXL
	and r0,r10,#0xFF		@ Mask off source to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

DDOPCODE_86:		@ADD A,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r10,r12			@ Get masked valued of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#19
B ENDOPCODES

DDOPCODE_87:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_88:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_89:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_8A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_8B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_8C:		@ADC A,IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128				@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

DDOPCODE_8D:		@ADC A,IXL
	and r0,r10,#0xFF		@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

DDOPCODE_8E:		@ADC A,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r10,r12			@ Get masked valued of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#19
B ENDOPCODES

DDOPCODE_8F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_90:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_91:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_92:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_93:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_94:		@SUB A,IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

DDOPCODE_95:		@SUB A,IXL
	and r0,r10,#0xFF		@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

DDOPCODE_96:		@SUB A,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r10,r12			@ Get masked valued of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#19
B ENDOPCODES

DDOPCODE_97:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_98:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_99:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_9A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_9B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_9C:		@SBC A,IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

DDOPCODE_9D:		@SBC A,IXL
	and r0,r10,#0xFF		@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

DDOPCODE_9E:		@SBC A,(IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r10,r12			@ Get masked valued of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#19
B ENDOPCODES

DDOPCODE_9F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_A0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_A1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_A2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_A3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_A4:		@AND IXH
	mov r0,r10,lsr #8		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_A5:		@AND IXL
	mov r0,r10			@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_A6:		@AND (IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r10,r12			@ Get masked valued of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#19
B ENDOPCODES

DDOPCODE_A7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_A8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_A9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_AA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_AB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_AC:		@XOR IXH
	mov r0,r10,lsr #8		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_AD:		@XOR IXL
	mov r0,r10			@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_AE:		@XOR (IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r10,r12			@ Get masked valued of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#19
B ENDOPCODES

DDOPCODE_AF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_B0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_B1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_B2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_B3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_B4:		@OR IXH
	mov r0,r10,lsr #8		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_B5:		@OR IXL
	mov r0,r10			@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

DDOPCODE_B6:		@OR (IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r10,r12			@ Get masked valued of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#19
B ENDOPCODES

DDOPCODE_B7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_B8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_B9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_BA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_BB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_BC:		@CP IXH
	mov r0,r10,lsr #8		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

DDOPCODE_BD:		@CP IXL
	and r0,r10,#0xFF		@ Mask to single byte
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

DDOPCODE_BE:		@CP (IX+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r1,r10,r12			@ Get masked valued of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#19
B ENDOPCODES

DDOPCODE_BF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_C0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_C1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_C2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_C3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_C4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_C5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_C6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_C7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_C8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_C9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_CA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_CB:		@DDCB
	b CBXCODES
B ENDOPCODES

DDOPCODE_CC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_CD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_CE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_CF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_D0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_D1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_D2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_D3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_D4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_D5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_D6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_D7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_D8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_D9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_DA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_DB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_DC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_DD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_DE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_DF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_E0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_E1:		@POP IX
	mov r1,r7,lsr #16		@Put SP in R1
	bl MEMREADSHORT
	add r1,r1,#2			@Increase SP
	and r7,r7,r12			@CLear old SP value
	add r7,r7,r1,lsl #16		@Put SP in Reg 7
	bic r10,r10,r12			@ Clear target byte To 0
	orr r10,r10,r0			@ Place value on target register
	mov r2,#14
B ENDOPCODES

DDOPCODE_E2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_E3:		@EX (SP),IX
	mov r2,r7,lsr #16		@ Get value of SP
	bl MEMREADSHORT2		@ Get value in SP location into R1
	and r0,r10,r12			@ Mask source value to a 16 bit number
	bic r10,r10,r12			@ Clear source byte To 0
	orr r10,r10,r1			@ Place value on target register
	mov r1,r3
	bl MEMSTORESHORT
	@strb r0,[r3] 			@ store low byte in memory
	@mov r0,r0,lsr #8
	@strb r0,[r3,#1]			@ Store high byte of PC
	mov r2,#23
B ENDOPCODES

DDOPCODE_E4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_E5:		@PUSH IX
	and r0,r10,r12			@ Maskto 16 bits
	mov r1,r7,lsr #16		@Put SP into R1
	sub r1,r1,#2			@Decrease stack by 2
	and r1,r1,r12			@Mask to 16 bits
	and r7,r7,r12			@Clear old SP
	orr r7,r7,r1,lsl #16	@Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#15
B ENDOPCODES

DDOPCODE_E6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_E7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_E8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_E9:		@JP (IX)
	and r0,r10,r12			@Move IX into R0
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r0			@ Add new PC
	mov r2,#8
B ENDOPCODES

DDOPCODE_EA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_EB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_EC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_ED:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_EE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_EF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_F0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_F1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_F2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_F3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_F4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_F5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_F6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_F7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_F8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_F9:		@LD SP,IX
	and r0,r10,r12			@ Mask value to a 16 bit number
	and r7,r7,r12			@ Clear target byte to 0
	orr r7,r7,r0,lsl #16		@ Place value on target register
	mov r2,#10
B ENDOPCODES

DDOPCODE_FA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_FB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_FC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_FD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_FE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

DDOPCODE_FF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDCODES:
	bl MEMFETCH
	add r1,r1,#1		@R0 should still contain the PC so increment
	and r1,r1,r12		@Mask the 16 bits that relate to the PC
	bic r7,r7,r12		@Clear the old PC value
	orr r7,r7,r1		@Store the new PC value
	add r2,r5,#1
	and r2,r2,#127
	bic r5,r5,#127
	orr r5,r5,r2				@ 4 Lines to increase r register!
@	ldr r3,=rpointer
@	ldr r2,[r3]    		@These three lines store the opcode For debugging
@	Str r0,[r2,#40]
	add r15,r15,r0, lsl #2  @Multipy opcode by 4 To get value To add To PC

	nop

			B FDOPCODE_00
			B FDOPCODE_01
			B FDOPCODE_02
			B FDOPCODE_03
			B FDOPCODE_04
			B FDOPCODE_05
			B FDOPCODE_06
			B FDOPCODE_07
			B FDOPCODE_08
			B FDOPCODE_09
			B FDOPCODE_0A
			B FDOPCODE_0B
			B FDOPCODE_0C
			B FDOPCODE_0D
			B FDOPCODE_0E
			B FDOPCODE_0F
			B FDOPCODE_10
			B FDOPCODE_11
			B FDOPCODE_12
			B FDOPCODE_13
			B FDOPCODE_14
			B FDOPCODE_15
			B FDOPCODE_16
			B FDOPCODE_17
			B FDOPCODE_18
			B FDOPCODE_19
			B FDOPCODE_1A
			B FDOPCODE_1B
			B FDOPCODE_1C
			B FDOPCODE_1D
			B FDOPCODE_1E
			B FDOPCODE_1F
			B FDOPCODE_20
			B FDOPCODE_21
			B FDOPCODE_22
			B FDOPCODE_23
			B FDOPCODE_24
			B FDOPCODE_25
			B FDOPCODE_26
			B FDOPCODE_27
			B FDOPCODE_28
			B FDOPCODE_29
			B FDOPCODE_2A
			B FDOPCODE_2B
			B FDOPCODE_2C
			B FDOPCODE_2D
			B FDOPCODE_2E
			B FDOPCODE_2F
			B FDOPCODE_30
			B FDOPCODE_31
			B FDOPCODE_32
			B FDOPCODE_33
			B FDOPCODE_34
			B FDOPCODE_35
			B FDOPCODE_36
			B FDOPCODE_37
			B FDOPCODE_38
			B FDOPCODE_39
			B FDOPCODE_3A
			B FDOPCODE_3B
			B FDOPCODE_3C
			B FDOPCODE_3D
			B FDOPCODE_3E
			B FDOPCODE_3F
			B FDOPCODE_40
			B FDOPCODE_41
			B FDOPCODE_42
			B FDOPCODE_43
			B FDOPCODE_44
			B FDOPCODE_45
			B FDOPCODE_46
			B FDOPCODE_47
			B FDOPCODE_48
			B FDOPCODE_49
			B FDOPCODE_4A
			B FDOPCODE_4B
			B FDOPCODE_4C
			B FDOPCODE_4D
			B FDOPCODE_4E
			B FDOPCODE_4F
			B FDOPCODE_50
			B FDOPCODE_51
			B FDOPCODE_52
			B FDOPCODE_53
			B FDOPCODE_54
			B FDOPCODE_55
			B FDOPCODE_56
			B FDOPCODE_57
			B FDOPCODE_58
			B FDOPCODE_59
			B FDOPCODE_5A
			B FDOPCODE_5B
			B FDOPCODE_5C
			B FDOPCODE_5D
			B FDOPCODE_5E
			B FDOPCODE_5F
			B FDOPCODE_60
			B FDOPCODE_61
			B FDOPCODE_62
			B FDOPCODE_63
			B FDOPCODE_64
			B FDOPCODE_65
			B FDOPCODE_66
			B FDOPCODE_67
			B FDOPCODE_68
			B FDOPCODE_69
			B FDOPCODE_6A
			B FDOPCODE_6B
			B FDOPCODE_6C
			B FDOPCODE_6D
			B FDOPCODE_6E
			B FDOPCODE_6F
			B FDOPCODE_70
			B FDOPCODE_71
			B FDOPCODE_72
			B FDOPCODE_73
			B FDOPCODE_74
			B FDOPCODE_75
			B FDOPCODE_76
			B FDOPCODE_77
			B FDOPCODE_78
			B FDOPCODE_79
			B FDOPCODE_7A
			B FDOPCODE_7B
			B FDOPCODE_7C
			B FDOPCODE_7D
			B FDOPCODE_7E
			B FDOPCODE_7F
			B FDOPCODE_80
			B FDOPCODE_81
			B FDOPCODE_82
			B FDOPCODE_83
			B FDOPCODE_84
			B FDOPCODE_85
			B FDOPCODE_86
			B FDOPCODE_87
			B FDOPCODE_88
			B FDOPCODE_89
			B FDOPCODE_8A
			B FDOPCODE_8B
			B FDOPCODE_8C
			B FDOPCODE_8D
			B FDOPCODE_8E
			B FDOPCODE_8F
			B FDOPCODE_90
			B FDOPCODE_91
			B FDOPCODE_92
			B FDOPCODE_93
			B FDOPCODE_94
			B FDOPCODE_95
			B FDOPCODE_96
			B FDOPCODE_97
			B FDOPCODE_98
			B FDOPCODE_99
			B FDOPCODE_9A
			B FDOPCODE_9B
			B FDOPCODE_9C
			B FDOPCODE_9D
			B FDOPCODE_9E
			B FDOPCODE_9F
			B FDOPCODE_A0
			B FDOPCODE_A1
			B FDOPCODE_A2
			B FDOPCODE_A3
			B FDOPCODE_A4
			B FDOPCODE_A5
			B FDOPCODE_A6
			B FDOPCODE_A7
			B FDOPCODE_A8
			B FDOPCODE_A9
			B FDOPCODE_AA
			B FDOPCODE_AB
			B FDOPCODE_AC
			B FDOPCODE_AD
			B FDOPCODE_AE
			B FDOPCODE_AF
			B FDOPCODE_B0
			B FDOPCODE_B1
			B FDOPCODE_B2
			B FDOPCODE_B3
			B FDOPCODE_B4
			B FDOPCODE_B5
			B FDOPCODE_B6
			B FDOPCODE_B7
			B FDOPCODE_B8
			B FDOPCODE_B9
			B FDOPCODE_BA
			B FDOPCODE_BB
			B FDOPCODE_BC
			B FDOPCODE_BD
			B FDOPCODE_BE
			B FDOPCODE_BF
			B FDOPCODE_C0
			B FDOPCODE_C1
			B FDOPCODE_C2
			B FDOPCODE_C3
			B FDOPCODE_C4
			B FDOPCODE_C5
			B FDOPCODE_C6
			B FDOPCODE_C7
			B FDOPCODE_C8
			B FDOPCODE_C9
			B FDOPCODE_CA
			B FDOPCODE_CB
			B FDOPCODE_CC
			B FDOPCODE_CD
			B FDOPCODE_CE
			B FDOPCODE_CF
			B FDOPCODE_D0
			B FDOPCODE_D1
			B FDOPCODE_D2
			B FDOPCODE_D3
			B FDOPCODE_D4
			B FDOPCODE_D5
			B FDOPCODE_D6
			B FDOPCODE_D7
			B FDOPCODE_D8
			B FDOPCODE_D9
			B FDOPCODE_DA
			B FDOPCODE_DB
			B FDOPCODE_DC
			B FDOPCODE_DD
			B FDOPCODE_DE
			B FDOPCODE_DF
			B FDOPCODE_E0
			B FDOPCODE_E1
			B FDOPCODE_E2
			B FDOPCODE_E3
			B FDOPCODE_E4
			B FDOPCODE_E5
			B FDOPCODE_E6
			B FDOPCODE_E7
			B FDOPCODE_E8
			B FDOPCODE_E9
			B FDOPCODE_EA
			B FDOPCODE_EB
			B FDOPCODE_EC
			B FDOPCODE_ED
			B FDOPCODE_EE
			B FDOPCODE_EF
			B FDOPCODE_F0
			B FDOPCODE_F1
			B FDOPCODE_F2
			B FDOPCODE_F3
			B FDOPCODE_F4
			B FDOPCODE_F5
			B FDOPCODE_F6
			B FDOPCODE_F7
			B FDOPCODE_F8
			B FDOPCODE_F9
			B FDOPCODE_FA
			B FDOPCODE_FB
			B FDOPCODE_FC
			B FDOPCODE_FD
			B FDOPCODE_FE
			B FDOPCODE_FF

FDOPCODE_00:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_01:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_02:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_03:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_04:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_05:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_06:		@ILL
@ Illegal Opcode
	sub r1,r1,#1			@ Decrement PC to go to normal 06 opcode
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value

	sub r2,r5,#1
	and r2,r2,#127
	bic r5,r5,#127
	orr r5,r5,r2				@ 4 Lines to decrease r register!

	mov r2,#4
B ENDOPCODES

FDOPCODE_07:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_08:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_09:		@ADD IY,BC
	and r0,r9,r12			@ Maskto 16 bits
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r10,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r2
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r10,lsr #16		@ Get destination register
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r10,r10,r12			@ Clear target short to 0
	orr r10,r10,r2,lsl #16		@ Place value on target register
	mov r2,#15
B ENDOPCODES

FDOPCODE_0A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_0B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_0C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_0D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_0E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_0F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_10:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_11:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_12:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_13:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_14:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_15:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_16:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_17:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_18:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_19:		@ADD IY,DE
	mov r0,r9,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r10,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r2
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r10,lsr #16		@ Get destination register
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r10,r10,r12			@ Clear target short to 0
	orr r10,r10,r2,lsl #16		@ Place value on target register
	mov r2,#15
B ENDOPCODES

FDOPCODE_1A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_1B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_1C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_1D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_1E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_1F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_20:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_21:		@LD IY,nn
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT
	add r1,r1,#2			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	and r10,r10,r12			@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#14
B ENDOPCODES

FDOPCODE_22:		@LD (nn),IY
	mov r0,r10,lsr #16		@ Get source value
	and r2,r7,r12			@ Mask PC register
	add r1,r2,#2			@ Store PC + 2 in R1
	and r1,r1,r12			@ Mask new PC to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store incremented value
	bl MEMFETCHSHORT2		@ Get memory location into R1
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#20
B ENDOPCODES

FDOPCODE_23:		@INC IY
	mov r0,r10,lsr #16		@ Get source value
	add r0,r0,#1			@ Increase by 1
	and r10,r10,r12			@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#10
B ENDOPCODES

FDOPCODE_24:		@INC IYH
	mov r0,r10,lsr #24		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibbl
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r10,r10,#0xFF000000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_25:		@DEC IYH
	mov r0,r10,lsr #24		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r10,r10,#0xFF000000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_26:		@LD IYH,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r10,r10,#0xFF000000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #24		@ Place value on target register
	mov r2,#11
B ENDOPCODES

FDOPCODE_27:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_28:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_29:		@ADD IY,IY
	mov r0,r10,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	and r1,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r1
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r2,r0,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r10,r10,r12			@ Clear target short to 0
	orr r10,r10,r2,lsl #16		@ Place value on target register
	mov r2,#15
B ENDOPCODES

FDOPCODE_2A:		@LD IY,(nn)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCHSHORT			@ Get address
	add r1,r1,#2			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r0			@ Put address to load into R1
	bl MEMREADSHORT			@ Load 16 bit value from memory
	and r10,r10,r12			@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#20
B ENDOPCODES

FDOPCODE_2B:		@DEC IY
	mov r0,r10,lsr #16		@ Get source value
	sub r0,r0,#1			@ Decrease by 1
	and r10,r10,r12			@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#10
B ENDOPCODES

FDOPCODE_2C:		@INC IYL
	mov r0,r10,lsr #16		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibbl
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r10,r10,#0x00FF0000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_2D:		@DEC IYL
	mov r0,r10,lsr #16		@ Get source value
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0			@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bic r10,r10,#0x00FF0000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_2E:		@LD IYL,n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	bic r10,r10,#0x00FF0000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#11
B ENDOPCODES

FDOPCODE_2F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_30:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_31:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_32:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_33:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_34:		@INC (IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12
	bl MEMREAD	 		@ load value from memory
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#127			@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	and r2,r0,#0xF			@ Move R0 to R2 to test half carry and mask lower nibbl
	add r2,r2,#1			@ add 1
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	add r0,r0,#1			@ Increase by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2
	@strb r0,[r3] 			@ Store value in memory
	mov r2,#23
B ENDOPCODES

FDOPCODE_35:		@DEC (IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12
	bl MEMREAD	 			@load value from memory
	bic r8,r8,#0xFE00		@ Clear flags
	cmp r0,#128				@ Test for P flag
	orreq r8,r8,#0x400		@ Set P flag if necessary
	mov r2,r0				@ Move R0 to R2 to test half carry
	and r2,r2,#0xF			@ Mask lower nibbl
	sub r2,r2,#1			@ sub 1
	tst r2,#16				@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	sub r0,r0,#1			@ Decrease by 1
	ands r0,r0,#255			@ Mask to 8 bit
	orreq r8,r8,#0x4000		@ Set Z flag if 0
	tst r0,#128				@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32				@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8				@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N flag
	bl STOREMEM2
	@strb r0,[r3] 			@ Store value in memory
	mov r2,#23
B ENDOPCODES

FDOPCODE_36:		@LD (IY+d),n
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH				@ Get displacement
	mov r4,r0
	add r1,r1,#1			@ Increase PC
	bl MEMFETCH				@ Get value
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r2,r10,lsr #16			@ Get value of register
	add r1,r2,r4			@ Add displacement
	tst r4,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

FDOPCODE_37:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_38:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_39:		@ADD IY,SP
	mov r0,r7,lsr #16		@ Get source value
	bic r12,r12,#0xF000		@ Adjust R12 mask to 0xFFF
	mov r1,r10,lsr #16		@ Get destination register
	and r1,r1,r12			@ Mask off to a low nibble
	and r2,r0,r12
	orr r12,r12,#0xF000		@ restore R12 mask to 0xFFFF
	bic r8,r8,#0x3B00		@ Clear C,N,3,H,5 flags
	add r2,r1,r2
	tst r2,#4096			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	mov r2,r10,lsr #16		@ Get destination register
	add r2,r2,r0			@ Perform addition
	tst r2,#65536			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	and r2,r2,r12			@ Mask back to 16 bits and set flags
	tst r2,#8192			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#2048			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	and r10,r10,r12			@ Clear target short to 0
	orr r10,r10,r2,lsl #16		@ Place value on target register
	mov r2,#15
B ENDOPCODES

FDOPCODE_3A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_3B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_3C:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_3D:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_3E:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_3F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_40:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_41:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_42:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_43:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_44:		@LD B,IYH
	mov r0,r10,lsr #24		@ Get source value
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_45:		@LD B,IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_46:		@LD B,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#19
B ENDOPCODES

FDOPCODE_47:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_48:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_49:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_4A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_4B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_4C:		@LD C,IYH
	mov r0,r10,lsr #24		@ Get source value
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_4D:		@LD C,IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_4E:		@LD C,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#19
B ENDOPCODES

FDOPCODE_4F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_50:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_51:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_52:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_53:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_54:		@LD D,IYH
	mov r0,r10,lsr #24		@ Get source value
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_55:		@LD D,IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_56:		@LD D,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#19
B ENDOPCODES

FDOPCODE_57:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_58:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_59:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_5A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_5B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_5C:		@LD E,IYH
	mov r0,r10,lsr #24		@ Get source value
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_5D:		@LD E,IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_5E:		@LD E,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#19
B ENDOPCODES

FDOPCODE_5F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_60:		@LD IYH,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0xFF000000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_61:		@LD IYH,C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0xFF000000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_62:		@LD IYH,D
	mov r0,r9,lsr #24		@ Get source value
	bic r10,r10,#0xFF000000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_63:		@LD IYH,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0xFF000000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_64:		@LD IYH,IYH
	mov r2,#8
B ENDOPCODES

FDOPCODE_65:		@LD IYH,IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0xFF000000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_66:		@LD H,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#19
B ENDOPCODES

FDOPCODE_67:		@LD IYH,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0xFF000000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #24		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_68:		@LD IYL,B
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x00FF0000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_69:		@LD IYL,C
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x00FF0000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_6A:		@LD IYL,D
	mov r0,r9,lsr #24		@ Get source value
	bic r10,r10,#0x00FF0000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_6B:		@LD IYL,E
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x00FF0000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_6C:		@LD IYL,IYH
	mov r0,r10,lsr #24		@ Get source value
	bic r10,r10,#0x00FF0000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_6D:		@LD IYL,IYL
	mov r2,#8
B ENDOPCODES

FDOPCODE_6E:		@LD L,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#19
B ENDOPCODES

FDOPCODE_6F:		@LD IYL,A
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	bic r10,r10,#0x00FF0000		@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_70:		@LD (IY+d),B
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	mov r0,r9,lsr #8		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	mov r2,r10,lsr #16		@ Get value of register
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r2			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

FDOPCODE_71:		@LD (IY+d),C
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	and r0,r9,#0x000000FF		@ Mask value to a single byte
	mov r2,r10,lsr #16		@ Get value of register
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r2			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

FDOPCODE_72:		@LD (IY+d),D
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	mov r0,r9,lsr #24		@ Get source value
	mov r2,r10,lsr #16		@ Get value of register
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r2			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

FDOPCODE_73:		@LD (IY+d),E
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	mov r0,r9,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	mov r2,r10,lsr #16		@ Get value of register
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r2			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

FDOPCODE_74:		@LD (IY+d),H
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	mov r0,r8,lsr #24		@ Get source value
	mov r2,r10,lsr #16		@ Get value of register
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r2			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

FDOPCODE_75:		@LD (IY+d),L
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	mov r0,r8,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	mov r2,r10,lsr #16		@ Get value of register
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r2			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

FDOPCODE_76:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_77:		@LD (IY+d),A
	and r2,r7,r12			@ Mask PC register
	bl MEMFETCH2
	add r2,r2,#1			@ Increment PC by 1
	and r2,r2,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r2			@ Store new PC value
	and r0,r8,#0x000000FF		@ Mask value to a single byte
	mov r2,r10,lsr #16		@ Get value of register
	tst r1,#128			@ Check sign for 2's displacemen
	add r1,r1,r2			@ Add displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMSTORE 			@ Store value in memory
	mov r2,#19
B ENDOPCODES

FDOPCODE_78:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_79:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_7A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_7B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_7C:		@LD A,IYH
	mov r0,r10,lsr #24		@ Get source value
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_7D:		@LD A,IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0x000000FF		@ Mask value to a single byte
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_7E:		@LD A,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH			@ Load byte from address
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#19
B ENDOPCODES

FDOPCODE_7F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_80:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_81:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_82:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_83:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_84:		@ADD A,IYH
	mov r0,r10,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

FDOPCODE_85:		@ADD A,IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

FDOPCODE_86:		@ADD A,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	add r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#19
B ENDOPCODES

FDOPCODE_87:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_88:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_89:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_8A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_8B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_8C:		@ADC A,IYH
	mov r0,r10,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

FDOPCODE_8D:		@ADC A,IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

FDOPCODE_8E:		@ADC A,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	addne r1,r1,#1			@ If set add 1
	add r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	addne r2,r2,#1			@ If set add 1 to accumulator
	add r2,r2,r0			@ Perform addition
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	mvn r0,r0			@ perform NOT on original value
	and r0,r0,r12			@ mask to 16 bits
	eor r0,r1,r0			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#19
B ENDOPCODES

FDOPCODE_8F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_90:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_91:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_92:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_93:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_94:		@SUB A,IYH
	mov r0,r10,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

FDOPCODE_95:		@SUB A,IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

FDOPCODE_96:		@SUB A,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@ load value from memory
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r2,r0			@ Perform addition
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#19
B ENDOPCODES

FDOPCODE_97:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_98:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_99:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_9A:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_9B:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_9C:		@SBC A,IYH
	mov r0,r10,lsr #24		@ Get source value
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

FDOPCODE_9D:		@SBC A,IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

FDOPCODE_9E:		@SBC A,(IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	tst r8,#0x100			@ Test carry flag
	subne r1,r1,#1			@ If set subtract 1
	sub r2,r1,r2
	mov r1,r8			@ Store old flags in R1
	bic r8,r8,#0xFF00		@ Clear all flags
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r2,r8,#255			@ Mask off to a single byte
	tst r1,#0x100			@ Test old carry flag
	subne r2,r2,#1			@ If set subtract 1 from accumulator
	sub r2,r2,r0			@ Perform substraction
	tst r2,#256			@ Test Carry bit
	orrne r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r2			@ Place value on target register
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#19
B ENDOPCODES

FDOPCODE_9F:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_A0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_A1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_A2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_A3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_A4:		@AND IYH
	mov r0,r10,lsr #24		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_A5:		@AND IYL
	mov r0,r10,lsr #16		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_A6:		@AND (IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	ands r0,r0,r1			@ Perform AND and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,#0x1000		@ Set H flag
	orr r8,r8,r0			@ Place value on target register
	mov r2,#19
B ENDOPCODES

FDOPCODE_A7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_A8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_A9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_AA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_AB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_AC:		@XOR IYH
	mov r0,r10,lsr #24		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_AD:		@XOR IYL
	mov r0,r10,lsr #16		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_AE:		@XOR (IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	eor r0,r0,r1			@ Perform XOR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#19
B ENDOPCODES

FDOPCODE_AF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_B0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_B1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_B2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_B3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_B4:		@OR IYH
	mov r0,r10,lsr #24		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_B5:		@OR IYL
	mov r0,r10,lsr #16		@ Get source value
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#8
B ENDOPCODES

FDOPCODE_B6:		@OR (IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	and r1,r8,#255			@ Mask off to a single byte
	bic r8,r8,#0xFF			@ Clear accumulator byte To 0
	bic r8,r8,#0xFF00		@ Clear all flag
	orr r0,r0,r1			@ Perform OR
	ands r0,r0,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r0,#128			@ test for sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	adrl r2,Parity			@ Get start of parity table
	ldrb r1,[r2,r0]			@ Get parity value
	cmp r1,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	orr r8,r8,r0			@ Place value on target register
	mov r2,#19
B ENDOPCODES

FDOPCODE_B7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_B8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_B9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_BA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_BB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_BC:		@CP IYH
	mov r0,r10,lsr #24		@ Get source value
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

FDOPCODE_BD:		@CP IYL
	mov r0,r10,lsr #16		@ Get source value
	and r0,r0,#0xFF			@ Mask to single byte
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#8
B ENDOPCODES

FDOPCODE_BE:		@CP (IY+d)
@	and r1,r7,r12			@ Mask PC register
	bl MEMFETCH
	add r1,r1,#1			@ Increment PC
	and r1,r1,r12			@ Mask to 16 bits
	bic r7,r7,r12			@ Clear old PC value
	orr r7,r7,r1			@ Store new PC value
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r0			@ Add displacement
	tst r0,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	bl MEMREAD	 		@load value from memory
	bic r8,r8,#0xFF00		@ Clear all flags
	and r1,r8,#15			@ Mask off to a low nibble of accumulator
	and r2,r0,#15
	sub r2,r1,r2
	tst r2,#16			@ Test bit 4 flag
	orrne r8,r8,#0x1000		@ Set H flag if set
	and r1,r8,#255			@ Mask off accumulator to a single byte
	subs r2,r1,r0			@ Compare values
	orrcc r8,r8,#0x100		@ Set C flag
	ands r2,r2,#0xFF		@ Mask back to byte and set flags
	orreq r8,r8,#0x4000		@ Set Zero flag if need be
	tst r2,#128			@ Test sign
	orrne r8,r8,#0x8000		@ Set Sign flag if need be
	tst r2,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r2,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	orr r8,r8,#0x200		@ Set N fla
	mov r1,r8			@ load accumulator in R1
	eor r0,r0,r1			@ Perform XOR between original value and accumulator
	eor r2,r2,r1			@ Perform XOR between result and accumulator
	and r0,r0,r2			@ And the resulting value
	tst r0,#128			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#19
B ENDOPCODES

FDOPCODE_BF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_C0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_C1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_C2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_C3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_C4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_C5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_C6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_C7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_C8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_C9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_CA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_CB:		@FDCB
	b CBYCODES
B ENDOPCODES

FDOPCODE_CC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_CD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_CE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_CF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_D0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_D1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_D2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_D3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_D4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_D5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_D6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_D7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_D8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_D9:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_DA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_DB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_DC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_DD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_DE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_DF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_E0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_E1:		@POP IY
	mov r1,r7,lsr #16		@Put SP in R1
	bl MEMREADSHORT
	add r1,r1,#2			@Increase SP
	and r7,r7,r12			@CLear old SP value
	add r7,r7,r1,lsl #16		@Put SP in Reg 7
	and r10,r10,r12			@ Clear target byte to 0
	orr r10,r10,r0,lsl #16		@ Place value on target register
	mov r2,#14
B ENDOPCODES

FDOPCODE_E2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_E3:		@EX (SP),IY
	mov r2,r7,lsr #16		@ Get value of SP
	bl MEMREADSHORT2		@ Get value in SP location into R1
	mov r0,r10,lsr #16		@ Get source value
	and r10,r10,r12			@ Clear source byte to 0
	orr r10,r10,r1,lsl #16		@ Place value on target register
	mov r1,r3
	bl MEMSTORESHORT
	@strb r0,[r3] 			@ store low byte in memory
	@mov r0,r0,lsr #8
	@strb r0,[r3,#1]			@ Store high byte of PC
	@mov r2,#23
B ENDOPCODES

FDOPCODE_E4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_E5:		@PUSH IY
	mov r0,r10,lsr #16		@ Get source value
	mov r1,r7,lsr #16		@ Put SP into R1
	sub r1,r1,#2			@ Decrease stack by 2
	and r1,r1,r12			@ Mask to 16 bits
	and r7,r7,r12			@ Clear old SP
	orr r7,r7,r1,lsl #16		@ Replace with new SP
	bl MEMSTORESHORT		@ Store value in memory
	mov r2,#15
B ENDOPCODES

FDOPCODE_E6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_E7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_E8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_E9:		@JP (IY)
	mov r0,r10,lsr #16		@ Move IY into R0
	bic r7,r7,r12			@ Clear old PC
	orr r7,r7,r0			@ Add new PC
	mov r2,#8
B ENDOPCODES

FDOPCODE_EA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_EB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_EC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_ED:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_EE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_EF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_F0:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_F1:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_F2:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_F3:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_F4:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_F5:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_F6:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_F7:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_F8:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_F9:		@LD SP,IY
	mov r0,r10,lsr #16		@ Get source value
	and r7,r7,r12			@ Clear target byte to 0
	orr r7,r7,r0,lsl #16		@ Place value on target register
	mov r2,#10
B ENDOPCODES

FDOPCODE_FA:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_FB:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_FC:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_FD:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_FE:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

FDOPCODE_FF:		@ILL
@ Illegal Opcode
	mov r2,#8
B ENDOPCODES

CBXCODES:
	bl MEMFETCH
	mov r2,r0			@load displacement Value into r2
	add r1,r1,#1		@load Next OP-CODE into r0
	bl MEMFETCH
	add r1,r1,#1		@R1 should still contain the PC so increment
	and r1,r1,r12		@Mask the 16 bits that relate to the PC
	bic r7,r7,r12		@Clear the old PC value
	orr r7,r7,r1		@Store the new PC value
	add r1,r5,#1
	and r1,r1,#127
	bic r5,r5,#127
	orr r5,r5,r1				@ 4 Lines to increase r register!
	add r15,r15,r0, lsl #2  @Multipy opcode by 4 To get value To add To PC

	nop

			B CBXOPCODE_00
			B CBXOPCODE_01
			B CBXOPCODE_02
			B CBXOPCODE_03
			B CBXOPCODE_04
			B CBXOPCODE_05
			B CBXOPCODE_06
			B CBXOPCODE_07
			B CBXOPCODE_08
			B CBXOPCODE_09
			B CBXOPCODE_0A
			B CBXOPCODE_0B
			B CBXOPCODE_0C
			B CBXOPCODE_0D
			B CBXOPCODE_0E
			B CBXOPCODE_0F
			B CBXOPCODE_10
			B CBXOPCODE_11
			B CBXOPCODE_12
			B CBXOPCODE_13
			B CBXOPCODE_14
			B CBXOPCODE_15
			B CBXOPCODE_16
			B CBXOPCODE_17
			B CBXOPCODE_18
			B CBXOPCODE_19
			B CBXOPCODE_1A
			B CBXOPCODE_1B
			B CBXOPCODE_1C
			B CBXOPCODE_1D
			B CBXOPCODE_1E
			B CBXOPCODE_1F
			B CBXOPCODE_20
			B CBXOPCODE_21
			B CBXOPCODE_22
			B CBXOPCODE_23
			B CBXOPCODE_24
			B CBXOPCODE_25
			B CBXOPCODE_26
			B CBXOPCODE_27
			B CBXOPCODE_28
			B CBXOPCODE_29
			B CBXOPCODE_2A
			B CBXOPCODE_2B
			B CBXOPCODE_2C
			B CBXOPCODE_2D
			B CBXOPCODE_2E
			B CBXOPCODE_2F
			B CBXOPCODE_30
			B CBXOPCODE_31
			B CBXOPCODE_32
			B CBXOPCODE_33
			B CBXOPCODE_34
			B CBXOPCODE_35
			B CBXOPCODE_36
			B CBXOPCODE_37
			B CBXOPCODE_38
			B CBXOPCODE_39
			B CBXOPCODE_3A
			B CBXOPCODE_3B
			B CBXOPCODE_3C
			B CBXOPCODE_3D
			B CBXOPCODE_3E
			B CBXOPCODE_3F
			B CBXOPCODE_40
			B CBXOPCODE_41
			B CBXOPCODE_42
			B CBXOPCODE_43
			B CBXOPCODE_44
			B CBXOPCODE_45
			B CBXOPCODE_46
			B CBXOPCODE_47
			B CBXOPCODE_48
			B CBXOPCODE_49
			B CBXOPCODE_4A
			B CBXOPCODE_4B
			B CBXOPCODE_4C
			B CBXOPCODE_4D
			B CBXOPCODE_4E
			B CBXOPCODE_4F
			B CBXOPCODE_50
			B CBXOPCODE_51
			B CBXOPCODE_52
			B CBXOPCODE_53
			B CBXOPCODE_54
			B CBXOPCODE_55
			B CBXOPCODE_56
			B CBXOPCODE_57
			B CBXOPCODE_58
			B CBXOPCODE_59
			B CBXOPCODE_5A
			B CBXOPCODE_5B
			B CBXOPCODE_5C
			B CBXOPCODE_5D
			B CBXOPCODE_5E
			B CBXOPCODE_5F
			B CBXOPCODE_60
			B CBXOPCODE_61
			B CBXOPCODE_62
			B CBXOPCODE_63
			B CBXOPCODE_64
			B CBXOPCODE_65
			B CBXOPCODE_66
			B CBXOPCODE_67
			B CBXOPCODE_68
			B CBXOPCODE_69
			B CBXOPCODE_6A
			B CBXOPCODE_6B
			B CBXOPCODE_6C
			B CBXOPCODE_6D
			B CBXOPCODE_6E
			B CBXOPCODE_6F
			B CBXOPCODE_70
			B CBXOPCODE_71
			B CBXOPCODE_72
			B CBXOPCODE_73
			B CBXOPCODE_74
			B CBXOPCODE_75
			B CBXOPCODE_76
			B CBXOPCODE_77
			B CBXOPCODE_78
			B CBXOPCODE_79
			B CBXOPCODE_7A
			B CBXOPCODE_7B
			B CBXOPCODE_7C
			B CBXOPCODE_7D
			B CBXOPCODE_7E
			B CBXOPCODE_7F
			B CBXOPCODE_80
			B CBXOPCODE_81
			B CBXOPCODE_82
			B CBXOPCODE_83
			B CBXOPCODE_84
			B CBXOPCODE_85
			B CBXOPCODE_86
			B CBXOPCODE_87
			B CBXOPCODE_88
			B CBXOPCODE_89
			B CBXOPCODE_8A
			B CBXOPCODE_8B
			B CBXOPCODE_8C
			B CBXOPCODE_8D
			B CBXOPCODE_8E
			B CBXOPCODE_8F
			B CBXOPCODE_90
			B CBXOPCODE_91
			B CBXOPCODE_92
			B CBXOPCODE_93
			B CBXOPCODE_94
			B CBXOPCODE_95
			B CBXOPCODE_96
			B CBXOPCODE_97
			B CBXOPCODE_98
			B CBXOPCODE_99
			B CBXOPCODE_9A
			B CBXOPCODE_9B
			B CBXOPCODE_9C
			B CBXOPCODE_9D
			B CBXOPCODE_9E
			B CBXOPCODE_9F
			B CBXOPCODE_A0
			B CBXOPCODE_A1
			B CBXOPCODE_A2
			B CBXOPCODE_A3
			B CBXOPCODE_A4
			B CBXOPCODE_A5
			B CBXOPCODE_A6
			B CBXOPCODE_A7
			B CBXOPCODE_A8
			B CBXOPCODE_A9
			B CBXOPCODE_AA
			B CBXOPCODE_AB
			B CBXOPCODE_AC
			B CBXOPCODE_AD
			B CBXOPCODE_AE
			B CBXOPCODE_AF
			B CBXOPCODE_B0
			B CBXOPCODE_B1
			B CBXOPCODE_B2
			B CBXOPCODE_B3
			B CBXOPCODE_B4
			B CBXOPCODE_B5
			B CBXOPCODE_B6
			B CBXOPCODE_B7
			B CBXOPCODE_B8
			B CBXOPCODE_B9
			B CBXOPCODE_BA
			B CBXOPCODE_BB
			B CBXOPCODE_BC
			B CBXOPCODE_BD
			B CBXOPCODE_BE
			B CBXOPCODE_BF
			B CBXOPCODE_C0
			B CBXOPCODE_C1
			B CBXOPCODE_C2
			B CBXOPCODE_C3
			B CBXOPCODE_C4
			B CBXOPCODE_C5
			B CBXOPCODE_C6
			B CBXOPCODE_C7
			B CBXOPCODE_C8
			B CBXOPCODE_C9
			B CBXOPCODE_CA
			B CBXOPCODE_CB
			B CBXOPCODE_CC
			B CBXOPCODE_CD
			B CBXOPCODE_CE
			B CBXOPCODE_CF
			B CBXOPCODE_D0
			B CBXOPCODE_D1
			B CBXOPCODE_D2
			B CBXOPCODE_D3
			B CBXOPCODE_D4
			B CBXOPCODE_D5
			B CBXOPCODE_D6
			B CBXOPCODE_D7
			B CBXOPCODE_D8
			B CBXOPCODE_D9
			B CBXOPCODE_DA
			B CBXOPCODE_DB
			B CBXOPCODE_DC
			B CBXOPCODE_DD
			B CBXOPCODE_DE
			B CBXOPCODE_DF
			B CBXOPCODE_E0
			B CBXOPCODE_E1
			B CBXOPCODE_E2
			B CBXOPCODE_E3
			B CBXOPCODE_E4
			B CBXOPCODE_E5
			B CBXOPCODE_E6
			B CBXOPCODE_E7
			B CBXOPCODE_E8
			B CBXOPCODE_E9
			B CBXOPCODE_EA
			B CBXOPCODE_EB
			B CBXOPCODE_EC
			B CBXOPCODE_ED
			B CBXOPCODE_EE
			B CBXOPCODE_EF
			B CBXOPCODE_F0
			B CBXOPCODE_F1
			B CBXOPCODE_F2
			B CBXOPCODE_F3
			B CBXOPCODE_F4
			B CBXOPCODE_F5
			B CBXOPCODE_F6
			B CBXOPCODE_F7
			B CBXOPCODE_F8
			B CBXOPCODE_F9
			B CBXOPCODE_FA
			B CBXOPCODE_FB
			B CBXOPCODE_FC
			B CBXOPCODE_FD
			B CBXOPCODE_FE
			B CBXOPCODE_FF

CBXOPCODE_00:		@LD B,RLC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ ShifT left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_01:		@LD C,RLC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_02:		@LD D,RLC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_03:		@LD E,RLC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_04:		@LD H,RLC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_05:		@LD L,RLC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_06:		@RLC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBXOPCODE_07:		@LD A,RLC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_08:		@LD B,RRC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_09:		@LD C,RRC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_0A:		@LD D,RRC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_0B:		@LD E,RRC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_0C:		@LD H,RRC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_0D:		@LD L,RRC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_0E:		@RRC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBXOPCODE_0F:		@LD A,RRC (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_10:		@LD B,RL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_11:		@LD C,RL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_12:		@LD D,RL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_13:		@LD E,RL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_14:		@LD H,RL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_15:		@LD L,RL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_16:		@RL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBXOPCODE_17:		@LD A,RL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_18:		@LD B,RR (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_19:		@LD C,RR (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_1A:		@LD D,RR (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_1B:		@LD E,RR (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_1C:		@LD H,RR (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_1D:		@LD L,RR (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_1E:		@RR (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBXOPCODE_1F:		@LD A,RR (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_20:		@LD B,SLA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_21:		@LD C,SLA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_22:		@LD D,SLA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_23:		@LD E,SLA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_24:		@LD H,SLA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_25:		@LD L,SLA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_26:		@SLA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBXOPCODE_27:		@LD A,SLA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_28:		@LD B,SRA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 6
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_29:		@LD C,SRA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 6
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_2A:		@LD D,SRA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 6
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_2B:		@LD E,SRA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 6
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_2C:		@LD H,SRA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 6
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_2D:		@LD L,SRA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 6
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_2E:		@SRA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 6
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBXOPCODE_2F:		@LD A,SRA (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 6
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_30:		@LD B,SLL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_31:		@LD C,SLL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_32:		@LD D,SLL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_33:		@LD E,SLL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_34:		@LD H,SLL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_35:		@LD L,SLL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_36:		@SLL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBXOPCODE_37:		@LD A,SLL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_38:		@LD B,SRL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_39:		@LD C,SRL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_3A:		@LD D,SRL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_3B:		@LD E,SRL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_3C:		@LD H,SRL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_3D:		@LD L,SRL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_3E:		@SRL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBXOPCODE_3F:		@LD A,SRL (IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to mem
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_40:		@BIT 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_41:		@BIT 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_42:		@BIT 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_43:		@BIT 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_44:		@BIT 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_45:		@BIT 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_46:		@BIT 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_47:		@BIT 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_48:		@BIT 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_49:		@BIT 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_4A:		@BIT 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_4B:		@BIT 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_4C:		@BIT 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_4D:		@BIT 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_4E:		@BIT 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_4F:		@BIT 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_50:		@BIT 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_51:		@BIT 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_52:		@BIT 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_53:		@BIT 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_54:		@BIT 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_55:		@BIT 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_56:		@BIT 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_57:		@BIT 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_58:		@BIT 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_59:		@BIT 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_5A:		@BIT 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_5B:		@BIT 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_5C:		@BIT 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_5D:		@BIT 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_5E:		@BIT 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_5F:		@BIT 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_60:		@BIT 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_61:		@BIT 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_62:		@BIT 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_63:		@BIT 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_64:		@BIT 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_65:		@BIT 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_66:		@BIT 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_67:		@BIT 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_68:		@BIT 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_69:		@BIT 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_6A:		@BIT 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_6B:		@BIT 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_6C:		@BIT 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_6D:		@BIT 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_6E:		@BIT 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_6F:		@BIT 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_70:		@BIT 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_71:		@BIT 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_72:		@BIT 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_73:		@BIT 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_74:		@BIT 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_75:		@BIT 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_76:		@BIT 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_77:		@BIT 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_78:		@BIT 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_79:		@BIT 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_7A:		@BIT 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_7B:		@BIT 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_7C:		@BIT 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_7D:		@BIT 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_7E:		@BIT 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_7F:		@BIT 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00		@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400		@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000		@ Set H Flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBXOPCODE_80:		@LD B,RES 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_81:		@LD C,RES 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_82:		@LD D,RES 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_83:		@LD E,RES 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_84:		@LD H,RES 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_85:		@LD L,RES 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_86:		@RES 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	mov r2,#23
B ENDOPCODES

CBXOPCODE_87:		@LD A,RES 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_88:		@LD B,RES 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_89:		@LD C,RES 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_8A:		@LD D,RES 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_8B:		@LD E,RES 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_8C:		@LD H,RES 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_8D:		@LD L,RES 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_8E:		@RES 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	mov r2,#23
B ENDOPCODES

CBXOPCODE_8F:		@LD A,RES 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_90:		@LD B,RES 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_91:		@LD C,RES 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_92:		@LD D,RES 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_93:		@LD E,RES 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_94:		@LD H,RES 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_95:		@LD L,RES 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_96:		@RES 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	mov r2,#23
B ENDOPCODES

CBXOPCODE_97:		@LD A,RES 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_98:		@LD B,RES 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_99:		@LD C,RES 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_9A:		@LD D,RES 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_9B:		@LD E,RES 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_9C:		@LD H,RES 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_9D:		@LD L,RES 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_9E:		@RES 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	mov r2,#23
B ENDOPCODES

CBXOPCODE_9F:		@LD A,RES 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_A0:		@LD B,RES 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_A1:		@LD C,RES 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_A2:		@LD D,RES 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_A3:		@LD E,RES 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_A4:		@LD H,RES 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_A5:		@LD L,RES 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_A6:		@RES 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	mov r2,#23
B ENDOPCODES

CBXOPCODE_A7:		@LD A,RES 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_A8:		@LD B,RES 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_A9:		@LD C,RES 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_AA:		@LD D,RES 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_AB:		@LD E,RES 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_AC:		@LD H,RES 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_AD:		@LD L,RES 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_AE:		@RES 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	mov r2,#23
B ENDOPCODES

CBXOPCODE_AF:		@LD A,RES 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_B0:		@LD B,RES 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_B1:		@LD C,RES 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_B2:		@LD D,RES 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_B3:		@LD E,RES 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_B4:		@LD H,RES 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_B5:		@LD L,RES 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_B6:		@RES 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	mov r2,#23
B ENDOPCODES

CBXOPCODE_B7:		@LD A,RES 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_B8:		@LD B,RES 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_B9:		@LD C,RES 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_BA:		@LD D,RES 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_BB:		@LD E,RES 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_BC:		@LD H,RES 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_BD:		@LD L,RES 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_BE:		@RES 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	mov r2,#23
B ENDOPCODES

CBXOPCODE_BF:		@LD A,RES 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacement
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2			@ Store to mem
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_C0:		@LD B,SET 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_C1:		@LD C,SET 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_C2:		@LD D,SET 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_C3:		@LD E,SET 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_C4:		@LD H,SET 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_C5:		@LD L,SET 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_C6:		@SET 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBXOPCODE_C7:		@LD A,SET 0,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_C8:		@LD B,SET 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_C9:		@LD C,SET 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_CA:		@LD D,SET 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_CB:		@LD E,SET 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_CC:		@LD H,SET 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_CD:		@LD L,SET 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_CE:		@SET 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBXOPCODE_CF:		@LD A,SET 1,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_D0:		@LD B,SET 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_D1:		@LD C,SET 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_D2:		@LD D,SET 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_D3:		@LD E,SET 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_D4:		@LD H,SET 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_D5:		@LD L,SET 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_D6:		@SET 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBXOPCODE_D7:		@LD A,SET 2,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_D8:		@LD B,SET 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_D9:		@LD C,SET 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_DA:		@LD D,SET 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_DB:		@LD E,SET 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_DC:		@LD H,SET 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_DD:		@LD L,SET 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_DE:		@SET 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBXOPCODE_DF:		@LD A,SET 3,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_E0:		@LD B,SET 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_E1:		@LD C,SET 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_E2:		@LD D,SET 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_E3:		@LD E,SET 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_E4:		@LD H,SET 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_E5:		@LD L,SET 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_E6:		@SET 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBXOPCODE_E7:		@LD A,SET 4,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_E8:		@LD B,SET 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_E9:		@LD C,SET 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_EA:		@LD D,SET 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_EB:		@LD E,SET 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_EC:		@LD H,SET 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_ED:		@LD L,SET 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_EE:		@SET 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBXOPCODE_EF:		@LD A,SET 5,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_F0:		@LD B,SET 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_F1:		@LD C,SET 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_F2:		@LD D,SET 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_F3:		@LD E,SET 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_F4:		@LD H,SET 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_F5:		@LD L,SET 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_F6:		@SET 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBXOPCODE_F7:		@LD A,SET 6,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_F8:		@LD B,SET 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_F9:		@LD C,SET 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x000000FF		@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_FA:		@LD D,SET 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0xFF000000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_FB:		@LD E,SET 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r9,r9,#0x00FF0000		@ Clear target byte to 0
	orr r9,r9,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_FC:		@LD H,SET 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0xFF000000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #24		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_FD:		@LD L,SET 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x00FF0000		@ Clear target byte to 0
	orr r8,r8,r0,lsl #16		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBXOPCODE_FE:		@SET 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBXOPCODE_FF:		@LD A,SET 7,(IX+d)
	add r1,r10,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2			@ Store value in memory
	bic r8,r8,#0x000000FF		@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYCODES:
	bl MEMREAD
	mov r2,r0			@load displacement Value into r2
	add r1,r1,#1		@load Next OP-CODE into r0
	bl MEMREAD
	add r1,r1,#1		@R1 should still contain the PC so increment
	and r1,r1,r12		@Mask the 16 bits that relate to the PC
	bic r7,r7,r12		@Clear the old PC value
	orr r7,r7,r1		@Store the new PC value
	add r1,r5,#1
	and r1,r1,#127
	bic r5,r5,#127
	orr r5,r5,r1				@ 4 Lines to increase r register!
	add r15,r15,r0, lsl #2  @Multipy opcode by 4 To get value To add To PC

	nop

			B CBYOPCODE_00
			B CBYOPCODE_01
			B CBYOPCODE_02
			B CBYOPCODE_03
			B CBYOPCODE_04
			B CBYOPCODE_05
			B CBYOPCODE_06
			B CBYOPCODE_07
			B CBYOPCODE_08
			B CBYOPCODE_09
			B CBYOPCODE_0A
			B CBYOPCODE_0B
			B CBYOPCODE_0C
			B CBYOPCODE_0D
			B CBYOPCODE_0E
			B CBYOPCODE_0F
			B CBYOPCODE_10
			B CBYOPCODE_11
			B CBYOPCODE_12
			B CBYOPCODE_13
			B CBYOPCODE_14
			B CBYOPCODE_15
			B CBYOPCODE_16
			B CBYOPCODE_17
			B CBYOPCODE_18
			B CBYOPCODE_19
			B CBYOPCODE_1A
			B CBYOPCODE_1B
			B CBYOPCODE_1C
			B CBYOPCODE_1D
			B CBYOPCODE_1E
			B CBYOPCODE_1F
			B CBYOPCODE_20
			B CBYOPCODE_21
			B CBYOPCODE_22
			B CBYOPCODE_23
			B CBYOPCODE_24
			B CBYOPCODE_25
			B CBYOPCODE_26
			B CBYOPCODE_27
			B CBYOPCODE_28
			B CBYOPCODE_29
			B CBYOPCODE_2A
			B CBYOPCODE_2B
			B CBYOPCODE_2C
			B CBYOPCODE_2D
			B CBYOPCODE_2E
			B CBYOPCODE_2F
			B CBYOPCODE_30
			B CBYOPCODE_31
			B CBYOPCODE_32
			B CBYOPCODE_33
			B CBYOPCODE_34
			B CBYOPCODE_35
			B CBYOPCODE_36
			B CBYOPCODE_37
			B CBYOPCODE_38
			B CBYOPCODE_39
			B CBYOPCODE_3A
			B CBYOPCODE_3B
			B CBYOPCODE_3C
			B CBYOPCODE_3D
			B CBYOPCODE_3E
			B CBYOPCODE_3F
			B CBYOPCODE_40
			B CBYOPCODE_41
			B CBYOPCODE_42
			B CBYOPCODE_43
			B CBYOPCODE_44
			B CBYOPCODE_45
			B CBYOPCODE_46
			B CBYOPCODE_47
			B CBYOPCODE_48
			B CBYOPCODE_49
			B CBYOPCODE_4A
			B CBYOPCODE_4B
			B CBYOPCODE_4C
			B CBYOPCODE_4D
			B CBYOPCODE_4E
			B CBYOPCODE_4F
			B CBYOPCODE_50
			B CBYOPCODE_51
			B CBYOPCODE_52
			B CBYOPCODE_53
			B CBYOPCODE_54
			B CBYOPCODE_55
			B CBYOPCODE_56
			B CBYOPCODE_57
			B CBYOPCODE_58
			B CBYOPCODE_59
			B CBYOPCODE_5A
			B CBYOPCODE_5B
			B CBYOPCODE_5C
			B CBYOPCODE_5D
			B CBYOPCODE_5E
			B CBYOPCODE_5F
			B CBYOPCODE_60
			B CBYOPCODE_61
			B CBYOPCODE_62
			B CBYOPCODE_63
			B CBYOPCODE_64
			B CBYOPCODE_65
			B CBYOPCODE_66
			B CBYOPCODE_67
			B CBYOPCODE_68
			B CBYOPCODE_69
			B CBYOPCODE_6A
			B CBYOPCODE_6B
			B CBYOPCODE_6C
			B CBYOPCODE_6D
			B CBYOPCODE_6E
			B CBYOPCODE_6F
			B CBYOPCODE_70
			B CBYOPCODE_71
			B CBYOPCODE_72
			B CBYOPCODE_73
			B CBYOPCODE_74
			B CBYOPCODE_75
			B CBYOPCODE_76
			B CBYOPCODE_77
			B CBYOPCODE_78
			B CBYOPCODE_79
			B CBYOPCODE_7A
			B CBYOPCODE_7B
			B CBYOPCODE_7C
			B CBYOPCODE_7D
			B CBYOPCODE_7E
			B CBYOPCODE_7F
			B CBYOPCODE_80
			B CBYOPCODE_81
			B CBYOPCODE_82
			B CBYOPCODE_83
			B CBYOPCODE_84
			B CBYOPCODE_85
			B CBYOPCODE_86
			B CBYOPCODE_87
			B CBYOPCODE_88
			B CBYOPCODE_89
			B CBYOPCODE_8A
			B CBYOPCODE_8B
			B CBYOPCODE_8C
			B CBYOPCODE_8D
			B CBYOPCODE_8E
			B CBYOPCODE_8F
			B CBYOPCODE_90
			B CBYOPCODE_91
			B CBYOPCODE_92
			B CBYOPCODE_93
			B CBYOPCODE_94
			B CBYOPCODE_95
			B CBYOPCODE_96
			B CBYOPCODE_97
			B CBYOPCODE_98
			B CBYOPCODE_99
			B CBYOPCODE_9A
			B CBYOPCODE_9B
			B CBYOPCODE_9C
			B CBYOPCODE_9D
			B CBYOPCODE_9E
			B CBYOPCODE_9F
			B CBYOPCODE_A0
			B CBYOPCODE_A1
			B CBYOPCODE_A2
			B CBYOPCODE_A3
			B CBYOPCODE_A4
			B CBYOPCODE_A5
			B CBYOPCODE_A6
			B CBYOPCODE_A7
			B CBYOPCODE_A8
			B CBYOPCODE_A9
			B CBYOPCODE_AA
			B CBYOPCODE_AB
			B CBYOPCODE_AC
			B CBYOPCODE_AD
			B CBYOPCODE_AE
			B CBYOPCODE_AF
			B CBYOPCODE_B0
			B CBYOPCODE_B1
			B CBYOPCODE_B2
			B CBYOPCODE_B3
			B CBYOPCODE_B4
			B CBYOPCODE_B5
			B CBYOPCODE_B6
			B CBYOPCODE_B7
			B CBYOPCODE_B8
			B CBYOPCODE_B9
			B CBYOPCODE_BA
			B CBYOPCODE_BB
			B CBYOPCODE_BC
			B CBYOPCODE_BD
			B CBYOPCODE_BE
			B CBYOPCODE_BF
			B CBYOPCODE_C0
			B CBYOPCODE_C1
			B CBYOPCODE_C2
			B CBYOPCODE_C3
			B CBYOPCODE_C4
			B CBYOPCODE_C5
			B CBYOPCODE_C6
			B CBYOPCODE_C7
			B CBYOPCODE_C8
			B CBYOPCODE_C9
			B CBYOPCODE_CA
			B CBYOPCODE_CB
			B CBYOPCODE_CC
			B CBYOPCODE_CD
			B CBYOPCODE_CE
			B CBYOPCODE_CF
			B CBYOPCODE_D0
			B CBYOPCODE_D1
			B CBYOPCODE_D2
			B CBYOPCODE_D3
			B CBYOPCODE_D4
			B CBYOPCODE_D5
			B CBYOPCODE_D6
			B CBYOPCODE_D7
			B CBYOPCODE_D8
			B CBYOPCODE_D9
			B CBYOPCODE_DA
			B CBYOPCODE_DB
			B CBYOPCODE_DC
			B CBYOPCODE_DD
			B CBYOPCODE_DE
			B CBYOPCODE_DF
			B CBYOPCODE_E0
			B CBYOPCODE_E1
			B CBYOPCODE_E2
			B CBYOPCODE_E3
			B CBYOPCODE_E4
			B CBYOPCODE_E5
			B CBYOPCODE_E6
			B CBYOPCODE_E7
			B CBYOPCODE_E8
			B CBYOPCODE_E9
			B CBYOPCODE_EA
			B CBYOPCODE_EB
			B CBYOPCODE_EC
			B CBYOPCODE_ED
			B CBYOPCODE_EE
			B CBYOPCODE_EF
			B CBYOPCODE_F0
			B CBYOPCODE_F1
			B CBYOPCODE_F2
			B CBYOPCODE_F3
			B CBYOPCODE_F4
			B CBYOPCODE_F5
			B CBYOPCODE_F6
			B CBYOPCODE_F7
			B CBYOPCODE_F8
			B CBYOPCODE_F9
			B CBYOPCODE_FA
			B CBYOPCODE_FB
			B CBYOPCODE_FC
			B CBYOPCODE_FD
			B CBYOPCODE_FE
			B CBYOPCODE_FF

CBYOPCODE_00:		@LD B,RLC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_01:		@LD C,RLC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_02:		@LD D,RLC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_03:		@LD E,RLC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_04:		@LD H,RLC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_05:		@LD L,RLC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_06:		@RLC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBYOPCODE_07:		@LD A,RLC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry and bit 0 if old bit 7 was set
	orrne r0,r0,#0x1		@ Set carry and bit 0 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_08:		@LD B,RRC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift left 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_09:		@LD C,RRC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift left 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_0A:		@LD D,RRC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift left 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_0B:		@LD E,RRC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift left 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_0C:		@LD H,RRC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift left 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_0D:		@LD L,RRC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift left 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_0E:		@RRC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift left 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBYOPCODE_0F:		@LD A,RRC (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift left 1
	orrcs r8,r8,#0x100		@ Set carry if old bit 0 was set
	orrcs r0,r0,#0x80		@ Set bit 7 if old bit 0 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_10:		@LD B,RL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_11:		@LD C,RL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_12:		@LD D,RL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_13:		@LD E,RL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_14:		@LD H,RL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_15:		@LD L,RL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_16:		@RL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBYOPCODE_17:		@LD A,RL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	tst r8,#0x100			@ Test current carry flag
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	orrne r0,r0,#1			@ Set bit 0 if carry was set
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_18:		@LD B,RR (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	and r0,r0,#0x7F			@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_19:		@LD C,RR (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	and r0,r0,#0x7F			@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_1A:		@LD D,RR (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	and r0,r0,#0x7F			@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_1B:		@LD E,RR (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	and r0,r0,#0x7F			@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_1C:		@LD H,RR (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	and r0,r0,#0x7F			@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_1D:		@LD L,RR (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	and r0,r0,#0x7F			@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_1E:		@RR (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	and r0,r0,#0x7F			@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBYOPCODE_1F:		@LD A,RR (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	mov r4,r8,lsr #8		@ Move old flags into R1
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift Right 1
	and r0,r0,#0x7F			@ Mask back to byte less bit 7
	orrcs r8,r8,#0x100		@ Set Z80 carry flag is shift cause ARM carry
	tst r4,#1 			@ Test if old carry was set
	orrne r0,r0,#0x80		@ Set bit 7 if so
	cmp r0,#0
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store to memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_20:		@LD B,SLA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_21:		@LD C,SLA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_22:		@LD D,SLA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_23:		@LD E,SLA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_24:		@LD H,SLA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_25:		@LD L,SLA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_26:		@SLA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBYOPCODE_27:		@LD A,SLA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_28:		@LD B,SRA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 8
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_29:		@LD C,SRA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 8
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_2A:		@LD D,SRA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 8
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_2B:		@LD E,SRA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 8
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_2C:		@LD H,SRA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 8
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_2D:		@LD L,SRA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 8
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_2E:		@SRA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 8
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBYOPCODE_2F:		@LD A,SRA (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	bic r0,r0,#128			@ Clear bit 7
	tst r0,#64			@ Test bit 8
	orrne r0,r0,#0x80		@ Set new bit 7 if old bit 7 was set
	ands r0,r0,#0xFF		@ Mask back to byte
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_30:		@LD B,SLL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_31:		@LD C,SLL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_32:		@LD D,SLL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_33:		@LD E,SLL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_34:		@LD H,SLL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_35:		@LD L,SLL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_36:		@SLL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBYOPCODE_37:		@LD A,SLL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	mov r0,r0,lsl #1		@ Shift left 1
	tst r0,#256			@ Test bit 8
	orrne r8,r8,#0x100		@ Set carry flag if old bit 7 was set
	and r0,r0,#0xFF			@ Mask back to byte
	orr r0,r0,#1			@ Insert 1 at end
	tst r0,#128			@ Test S flag
	orrne r8,r8,#0x8000		@ Set S flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_38:		@LD B,SRL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x0000FF00		@ Clear target byte to 0
	orr r9,r9,r0,lsl #8		@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_39:		@LD C,SRL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_3A:		@LD D,SRL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_3B:		@LD E,SRL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_3C:		@LD H,SRL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_3D:		@LD L,SRL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_3E:		@SRL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	mov r2,#23
B ENDOPCODES

CBYOPCODE_3F:		@LD A,SRL (IY+d)
	mov r1,r10,lsr #16		@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128			@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r8,r8,#0xFF00		@ Clear all flag
	movs r0,r0,lsr #1		@ Shift right 1
	orrcs r8,r8,#0x100		@ Set Z80 carry if ARM carry set
	ands r0,r0,#0x7F		@ Mask back to byte and reset bit 7
	orreq r8,r8,#0x4000		@ Set Zero flag
	tst r0,#32			@ Test 5 flag
	orrne r8,r8,#0x2000		@ Set 5 flag
	tst r0,#8			@ Test 3 flag
	orrne r8,r8,#0x800		@ Set 3 flag
	bl STOREMEM2			@ Store value in memory
	adrl r2,Parity			@ Get start of parity table
	ldrb r3,[r2,r0]			@ Get parity value
	cmp r3,#0			@ Test parity value
	orrne r8,r8,#0x400		@ Set parity flag if needs be
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_40:		@BIT 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_41:		@BIT 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_42:		@BIT 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_43:		@BIT 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_44:		@BIT 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_45:		@BIT 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_46:		@BIT 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_47:		@BIT 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x01		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_48:		@BIT 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_49:		@BIT 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_4A:		@BIT 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_4B:		@BIT 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_4C:		@BIT 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_4D:		@BIT 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_4E:		@BIT 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_4F:		@BIT 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x02		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_50:		@BIT 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_51:		@BIT 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_52:		@BIT 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_53:		@BIT 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_54:		@BIT 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_55:		@BIT 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_56:		@BIT 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_57:		@BIT 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x04		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_58:		@BIT 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_59:		@BIT 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_5A:		@BIT 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_5B:		@BIT 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_5C:		@BIT 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_5D:		@BIT 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_5E:		@BIT 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_5F:		@BIT 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x08		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_60:		@BIT 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_61:		@BIT 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_62:		@BIT 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_63:		@BIT 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_64:		@BIT 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_65:		@BIT 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_66:		@BIT 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_67:		@BIT 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x10		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_68:		@BIT 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_69:		@BIT 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_6A:		@BIT 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_6B:		@BIT 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_6C:		@BIT 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_6D:		@BIT 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_6E:		@BIT 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_6F:		@BIT 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x20		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_70:		@BIT 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_71:		@BIT 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_72:		@BIT 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_73:		@BIT 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_74:		@BIT 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_75:		@BIT 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_76:		@BIT 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_77:		@BIT 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x40		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_78:		@BIT 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_79:		@BIT 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_7A:		@BIT 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_7B:		@BIT 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_7C:		@BIT 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_7D:		@BIT 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_7E:		@BIT 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_7F:		@BIT 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	ands r1,r0,#0x80		@ Test Bit
	bic r8,r8,#0xEE00			@ Clear S,Z,5,P,3 and N flags
	orrne r8,r8,#0x8000		@Set S flag if bit was set
	orreq r8,r8,#0x4400				@ Set Z and P flags if bit wasn't set
	orr r8,r8,#0x1000			@ Set H Flag
	tst r0,#32					@ Test 5 flag
	orrne r8,r8,#0x2000			@ Set 5 flag
	tst r0,#8					@ Test 3 flag
	orrne r8,r8,#0x800			@ Set 3 flag
	mov r2,#20
B ENDOPCODES

CBYOPCODE_80:		@LD B,RES 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_81:		@LD C,RES 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_82:		@LD D,RES 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_83:		@LD E,RES 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_84:		@LD H,RES 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_85:		@LD L,RES 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_86:		@RES 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_87:		@LD A,RES 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x01			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_88:		@LD B,RES 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_89:		@LD C,RES 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_8A:		@LD D,RES 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_8B:		@LD E,RES 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_8C:		@LD H,RES 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_8D:		@LD L,RES 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_8E:		@RES 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_8F:		@LD A,RES 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x02			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_90:		@LD B,RES 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_91:		@LD C,RES 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_92:		@LD D,RES 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_93:		@LD E,RES 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_94:		@LD H,RES 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_95:		@LD L,RES 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_96:		@RES 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_97:		@LD A,RES 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x04			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_98:		@LD B,RES 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_99:		@LD C,RES 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_9A:		@LD D,RES 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_9B:		@LD E,RES 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_9C:		@LD H,RES 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_9D:		@LD L,RES 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_9E:		@RES 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_9F:		@LD A,RES 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x08			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_A0:		@LD B,RES 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_A1:		@LD C,RES 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_A2:		@LD D,RES 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_A3:		@LD E,RES 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_A4:		@LD H,RES 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_A5:		@LD L,RES 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_A6:		@RES 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_A7:		@LD A,RES 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x10			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_A8:		@LD B,RES 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_A9:		@LD C,RES 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_AA:		@LD D,RES 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_AB:		@LD E,RES 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_AC:		@LD H,RES 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_AD:		@LD L,RES 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_AE:		@RES 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_AF:		@LD A,RES 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x20			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_B0:		@LD B,RES 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_B1:		@LD C,RES 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_B2:		@LD D,RES 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_B3:		@LD E,RES 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_B4:		@LD H,RES 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_B5:		@LD L,RES 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_B6:		@RES 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_B7:		@LD A,RES 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x40			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_B8:		@LD B,RES 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_B9:		@LD C,RES 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_BA:		@LD D,RES 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_BB:		@LD E,RES 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_BC:		@LD H,RES 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_BD:		@LD L,RES 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_BE:		@RES 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_BF:		@LD A,RES 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	bic r0,r0,#0x80			@ Reset Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_C0:		@LD B,SET 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_C1:		@LD C,SET 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_C2:		@LD D,SET 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_C3:		@LD E,SET 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_C4:		@LD H,SET 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_C5:		@LD L,SET 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_C6:		@SET 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_C7:		@LD A,SET 0,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x01			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_C8:		@LD B,SET 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_C9:		@LD C,SET 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_CA:		@LD D,SET 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_CB:		@LD E,SET 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_CC:		@LD H,SET 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_CD:		@LD L,SET 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_CE:		@SET 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_CF:		@LD A,SET 1,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x02			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_D0:		@LD B,SET 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_D1:		@LD C,SET 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_D2:		@LD D,SET 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_D3:		@LD E,SET 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_D4:		@LD H,SET 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_D5:		@LD L,SET 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_D6:		@SET 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_D7:		@LD A,SET 2,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x04			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_D8:		@LD B,SET 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_D9:		@LD C,SET 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_DA:		@LD D,SET 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_DB:		@LD E,SET 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_DC:		@LD H,SET 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_DD:		@LD L,SET 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_DE:		@SET 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_DF:		@LD A,SET 3,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x08			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_E0:		@LD B,SET 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_E1:		@LD C,SET 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_E2:		@LD D,SET 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_E3:		@LD E,SET 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_E4:		@LD H,SET 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_E5:		@LD L,SET 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_E6:		@SET 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_E7:		@LD A,SET 4,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x10			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_E8:		@LD B,SET 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_E9:		@LD C,SET 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_EA:		@LD D,SET 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_EB:		@LD E,SET 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_EC:		@LD H,SET 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_ED:		@LD L,SET 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_EE:		@SET 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_EF:		@LD A,SET 5,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x20			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_F0:		@LD B,SET 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_F1:		@LD C,SET 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_F2:		@LD D,SET 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_F3:		@LD E,SET 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_F4:		@LD H,SET 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_F5:		@LD L,SET 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_F6:		@SET 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_F7:		@LD A,SET 6,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x40			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_F8:		@LD B,SET 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x0000FF00			@ Clear target byte to 0
	orr r9,r9,r0,lsl #8			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_F9:		@LD C,SET 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x000000FF			@ Clear target byte to 0
	orr r9,r9,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_FA:		@LD D,SET 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0xFF000000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_FB:		@LD E,SET 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r9,r9,#0x00FF0000			@ Clear target byte to 0
	orr r9,r9,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_FC:		@LD H,SET 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0xFF000000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #24			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_FD:		@LD L,SET 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x00FF0000			@ Clear target byte to 0
	orr r8,r8,r0,lsl #16			@ Place value on target register
	mov r2,#23
B ENDOPCODES

CBYOPCODE_FE:		@SET 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	mov r2,#23
B ENDOPCODES

CBYOPCODE_FF:		@LD A,SET 7,(IY+d)
	mov r1,r10,lsr #16			@ Get value of register
	add r1,r1,r2			@ Add displacement
	tst r2,#128				@ Check sign for 2's displacemen
	subne r1,r1,#256 		@ Make amount negative if above 127
	and r1,r1,r12			@ Mask register value to a short (16 bit) value
	bl MEMREAD
	orr r0,r0,#0x80			@ Set Bit
	bl STOREMEM2				@ Store value in memory
	bic r8,r8,#0x000000FF			@ Clear target byte to 0
	orr r8,r8,r0			@ Place value on target register
	mov r2,#23
B ENDOPCODES

ENDOPCODES:






			@tst r5,#0x10000		@Test whether in debug mode
			@bne INTRETURN		@If so exit out of core
			@and r0,r7,r12		@Get PC
			@mov r1,#0x5D00		@Breakpoint
			@add r1,r1,#0xD0
			@cmp r0,r1
			@orreq r5,r5,#0x10000	@ Set debug to true
			@beq INTRETURN


			subs r11,r11,r2		@ Reduce cycles

			bpl CPU_LOOP		@ Keep within CPU core if not reached INT

@			b INTERRUPT		@Call INT Interrupt routine
INTRETURN:
			@ldr r1,=rpointer @Load address For external register storage
			@ldr r0,[r1]
			mov r0,cpucontext

			ldr r4,=ExReg
			ldr r2,[r4,#4]
			ldr r3,[r4,#8]

			str r7,[r0],#4 @Start storing registers
			str r8,[r0],#4
			str r9,[r0],#4
			str r10,[r0],#4
			str r2,[r0],#4
			str r3,[r0],#4
			str r11,[r0],#4
			str r5,[r0]


			ldmfd r13!,{r3-r12,lr}
			bx lr

.ALIGN


INTERRUPT:
	adrl r2,totalcycles				@ Move the new number of cycles back in
	ldr r2,[r2]
	add r11,r11,r2					@ Add total cycles back to NMI cycle count

	@tst r5,#0x800000				@ Is tape loader flag set?
	@bne INTRETURN

	mov r2,#0
	bic r5,r5,#0x20000				@ Clear Halt flag
	tst r5,#0x40000000				@ Test if IFF1 is set
	beq INTRETURN					@ Go back to main routine if not
	bic r5,r5,#0x40000000				@ Clear IFF1 flag
	tst r5,#0x20000000				@ Test Interrupt Mode Bit 2
	bne MODE2					@ Jump to MODE2 if set

	and r0,r7,r12					@ Move PC into R0 and mask to 16 bits
	mov r1,r7,lsr #16				@ Put SP into R1
	sub r1,r1,#2					@ Decrease stack by 2
	and r1,r1,r12					@ Mask to 16 bits
	and r7,r7,r12					@ Clear old SP
	orr r7,r7,r1,lsl #16				@ Replace with new SP
	bl MEMSTORESHORT				@ Store low byte of PC
	bic r7,r7,r12					@ Clear old PC
	orr r7,r7,#0x38					@ Out in address 38H
	sub r11,r11,#12
	tst r5,#0x10000000				@ test IM1 flag
	subne r11,r11,#1
	mov r2,#12					@ It takes 12 cycles to enter interrupt
	addne r2,r2,#1
	b INTRETURN					@ Exit from interrupt

MODE2:
	and r0,r7,r12					@ Move PC into R2 and mask to 16 bits
	mov r1,r7,lsr #16				@ Put SP into R1
	sub r1,r1,#2					@ Decrease stack by 2
	and r1,r1,r12					@ Mask to 16 bits
	and r7,r7,r12					@ Clear old SP
	orr r7,r7,r1,lsl #16				@ Replace with new SP
	bl MEMSTORESHORT
	bic r7,r7,r12					@ Clear old PC
	and r1,r5,#0xFF00				@ Get value of I register
	orr r1,r1,#0x00FF				@ Add 255
	bl MEMREADSHORT
	orr r7,r7,r0					@ Copy to PC
	sub r11,r11,#19
	mov r2,#19					@ It takes 19 cycles to enter interrupt
	b INTRETURN					@ Exit from Interrupt

totalcycles: .word 69888


MEMSTORE:
    ;@ r0 = data, r1 = addr
     stmdb sp!,{r2,r3,r12,lr}
     ldr r3,[cpucontext,#ppMemWrite]		;@ r3 point to ppMemWrite[0]
     mov r2,r1,lsr#8
     ldr r3,[r3,r2,lsl#2]					;@ r3 = ppMemWrite[addr >> 8]

     cmp r3,#0
     strneb r0,[r3,r1]
     bne write8_end

     mov r2,r1								;@ swp r1, r0
     mov r1,r0
     mov r0,r2

     ;@str z80_icount,[cpucontext,#nCyclesLeft]

     mov lr,pc								;@ call z80_write8(r0, r1)
     ldr pc,[cpucontext,#z80_write8]

write8_end:
     ldmia sp!,{r2,r3,r12,lr}
	mov pc,lr				@ Go back


STOREMEM2:
    ;@ r0 = data, r3 = addr
     stmdb sp!,{r1,r2,r12,lr}
     ldr r1,[cpucontext,#ppMemWrite]		;@ r3 point to ppMemWrite[0]
     mov r2,r3,lsr#8
     ldr r1,[r1,r2,lsl#2]					;@ r3 = ppMemWrite[addr >> 8]

     cmp r1,#0
     strneb r0,[r1,r3]
     bne write8_end_2

     mov r2,r3								;@ swp r1, r0
     mov r3,r0
     mov r0,r2

     ;@str z80_icount,[cpucontext,#nCyclesLeft]

     mov lr,pc								;@ call z80_write8(r0, r1)
     ldr pc,[cpucontext,#z80_write8]

write8_end_2:
     ldmia sp!,{r1,r2,r12,lr}
	mov pc,lr				@ Go back


MEMSTORESHORT:

;@ r0 = data, r1 = addr
     stmdb sp!,{r2,r3,r12,lr}

     ldr r3,[cpucontext,#ppMemWrite]		;@ r3 point to ppMemWrite[0]

     cmp r3,#0
     addne r3,r3,r1
     movne r2,r0,lsr#8
     strneb r0,[r3],#1
     strneb r2,[r3]
     bne write16_end

;@     str z80pc,[cpucontext,#z80pc_pointer]
     mov lr,pc								;@ call z80_write8(r0, r1)
     ldr pc,[cpucontext,#z80_write16]

write16_end:
    ldmia sp!,{r2,r3,r12,lr}
	mov pc,lr				@ Go back


MEMREAD:
    @r3=addr
    mov r0,r1

    stmdb sp!,{r2,r3,r12,lr}
    ldr r3,[cpucontext,#ppMemRead]			;@ r3 point to ppMemRead[0]

    mov r2,r0,lsr#8
    ldr r3,[r3,r2,lsl#2]					;@ r3 = ppMemRead[addr >> 8]

    cmp r3,#0
    ldrneb r0,[r3,r0]
    bne read8_1_end

    mov lr,pc								;@ call z80_read8(r0, r1)
    ldr pc,[cpucontext,#z80_read8]
read8_1_end:
     ldmia sp!,{r2,r3,r12,lr}
	mov pc,lr				@ Go back


MEMREADSHORT:
    mov r0,r1
     ;@ r0 = addr
    stmdb sp!,{r1,r2,r3,r12,lr}

    ldr r3,[cpucontext,#ppMemRead]			;@ r3 point to ppMemRead[0]

     mov r2,r0,lsr#8
     ldr r3,[r3,r2,lsl#2]					;@ r3 = ppMemRead[addr >> 8]

     cmp r3,#0
     beq read16_call_1

     add r3,r3,r0
     ldrb r0,[r3],#1
     ldrb r1,[r3]
     orr r0,r0,r1,lsl #8
     b read16_end_1

read16_call_1:

;@     str z80pc,[cpucontext,#z80pc_pointer]

     mov lr,pc								;@ call z80_read8(r0, r1)
     ldr pc,[cpucontext,#z80_read16]
read16_end_1:
     ldmia sp!,{r1,r2,r3,r12,lr}
	mov pc,lr				@ Go back


MEMREAD2:
    stmdb sp!,{r0,r2,r3,r12,lr}
	mov r0,r2
    @r0=addr

    ldr r3,[cpucontext,#ppMemRead]			;@ r3 point to ppMemRead[0]

    mov r2,r0,lsr#8
    ldr r3,[r3,r2,lsl#2]					;@ r3 = ppMemRead[addr >> 8]

    cmp r3,#0
    ldrneb r1,[r3,r0]
    bne read8_2_end

    mov lr,pc								;@ call z80_read8(r0, r1)
    ldr pc,[cpucontext,#z80_read8]
    mov r1,r0
read8_2_end:
     ldmia sp!,{r0,r2,r3,r12,lr}
	mov pc,lr				@ Go back


MEMREADSHORT2:
    stmdb sp!,{r0,r2,r3,r12,lr}
    mov r0,r2
     ;@ r0 = addr


    ldr r3,[cpucontext,#ppMemRead]			;@ r3 point to ppMemRead[0]

     mov r2,r0,lsr#8
     ldr r3,[r3,r2,lsl#2]					;@ r3 = ppMemRead[addr >> 8]

     cmp r3,#0
     beq read16_call_2

     add r3,r3,r0
     ldrb r0,[r3],#1
     ldrb r1,[r3]
     orr r1,r0,r1,lsl #8
     b read16_end_2

read16_call_2:

;@     str z80pc,[cpucontext,#z80pc_pointer]

     mov lr,pc								;@ call z80_read8(r0, r1)
     ldr pc,[cpucontext,#z80_read16]
     mov r1,r0
read16_end_2:
     ldmia sp!,{r0,r2,r3,r12,lr}
	mov pc,lr				@ Go back


MEMREAD3:					@ For OUT and IN operation
    stmdb sp!,{r0,r3,r12,lr}
	mov r0,r1
    @r0=addr

    ldr r3,[cpucontext,#ppMemRead]			;@ r3 point to ppMemRead[0]

    mov r2,r0,lsr#8
    ldr r3,[r3,r2,lsl#2]					;@ r3 = ppMemRead[addr >> 8]

    cmp r3,#0
    ldrneb r2,[r3,r0]
    bne read8_3_end

    mov lr,pc								;@ call z80_read8(r0, r1)
    ldr pc,[cpucontext,#z80_read8]
    mov r2,r0
read8_3_end:
     ldmia sp!,{r0,r3,r12,lr}
	mov pc,lr				@ Go back


MEMREADSHORT3:				@ Especially for POP operation
    stmdb sp!,{r0,r1,r3,r12,lr}
    mov r0,r1
     ;@ r0 = addr

    ldr r3,[cpucontext,#ppMemRead]			;@ r3 point to ppMemRead[0]

     mov r2,r0,lsr#8
     ldr r3,[r3,r2,lsl#2]					;@ r3 = ppMemRead[addr >> 8]

     cmp r3,#0
     beq read16_call_3

     add r3,r3,r0
     ldrb r0,[r3],#1
     ldrb r1,[r3]
     orr r2,r0,r1,lsl #8
     b read16_end_3

read16_call_3:

;@     str z80pc,[cpucontext,#z80pc_pointer]

     mov lr,pc								;@ call z80_read8(r0, r1)
     ldr pc,[cpucontext,#z80_read16]
     mov r2,r0
read16_end_3:
     ldmia sp!,{r0,r1,r3,r12,lr}
	mov pc,lr				@ Go back

MEMFETCH:
    stmdb sp!,{r1,r2,r3}
    mov r2,r1
     ldr r1,[cpucontext,#ppMemFetchData]	;@ r1 point to ppMemFetchData[0]
     mov r0,r2,lsr#8
     ldr r1,[r1,r0,lsl#2]					;@ r1 = ppMemFetchData[addr >> 8]

     ldrb r0,[r1,r2]

     ldmia sp!,{r1,r2,r3}
	mov pc,lr				@ Go back


MEMFETCHSHORT:
    stmdb sp!,{r1,r2,r3}
    mov r2,r1
     ldr r1,[cpucontext,#ppMemFetchData]	;@ r1 point to ppMemFetchData[0]
     mov r0,r2,lsr#8
     ldr r1,[r1,r0,lsl#2]					;@ r1 = ppMemFetchData[addr >> 8]

     ldrb r0,[r1,r2]
     add r2,r2,#1
     ldrb r1,[r1,r2]
     orr r0,r0,r1, lsl #8


     ldmia sp!,{r1,r2,r3}
	mov pc,lr				@ Go back


MEMFETCH2:
    stmdb sp!,{r2,r3}
     ldr r1,[cpucontext,#ppMemFetchData]	;@ r1 point to ppMemFetchData[0]
     mov r0,r2,lsr#8
     ldr r1,[r1,r0,lsl#2]					;@ r1 = ppMemFetchData[addr >> 8]

     ldrb r1,[r1,r2]

     ldmia sp!,{r2,r3}
	mov pc,lr				@ Go back


MEMFETCHSHORT2:
    stmdb sp!,{r2,r3}
     ldr r1,[cpucontext,#ppMemFetchData]	;@ r1 point to ppMemFetchData[0]
     mov r0,r2,lsr#8
     ldr r1,[r1,r0,lsl#2]					;@ r1 = ppMemFetchData[addr >> 8]

     ldrb r0,[r1,r2]
     add r2,r2,#1
     ldrb r1,[r1,r2]
     orr r1,r0,r1, lsl #8


     ldmia sp!,{r2,r3}
	mov pc,lr				@ Go back

MEMFETCH3:
    stmdb sp!,{r1,r3}
    mov r2,r1
     ldr r1,[cpucontext,#ppMemFetchData]	;@ r1 point to ppMemFetchData[0]
     mov r0,r2,lsr#8
     ldr r1,[r1,r0,lsl#2]					;@ r1 = ppMemFetchData[addr >> 8]

     ldrb r2,[r1,r2]

     ldmia sp!,{r1,r3}
	mov pc,lr				@ Go back


MEMFETCHSHORT3:
    stmdb sp!,{r1,r3}
    mov r2,r1
     ldr r1,[cpucontext,#ppMemFetchData]	;@ r1 point to ppMemFetchData[0]
     mov r0,r2,lsr#8
     ldr r1,[r1,r0,lsl#2]					;@ r1 = ppMemFetchData[addr >> 8]

     ldrb r0,[r1,r2]
     add r2,r2,#1
     ldrb r1,[r1,r2]
     orr r2,r0,r1, lsl #8


     ldmia sp!,{r1,r3}
	mov pc,lr				@ Go back

.ALIGN


Flag3:
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.ALIGN

Flag5:
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
.ALIGN

DAA:
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60
.byte 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60
.byte 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60
.byte 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60
.byte 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60
.byte 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60
.byte 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60
.byte 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60
.byte 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60
.byte 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60
.byte 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60
.byte 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60
.byte 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60
.byte 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60, 0x60, 0x60, 0x60
.byte 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x60
.byte 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06
.byte 0x06, 0x06, 0x06, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.byte 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66
.ALIGN

Parity:
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 1, 0, 0, 1, 0, 1, 1, 0
.byte 0, 1, 1, 0, 1, 0, 0, 1
.ALIGN
