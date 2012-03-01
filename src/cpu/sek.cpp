// 680x0 (Sixty Eight K) Interface

// Sek with Dave's Cyclone CORE
// Write by OopsWare 2007.1

#include "burnint.h"
#include "sekdebug.h"

#ifdef EMU_M68K
INT32 nSekM68KContextSize[SEK_MAX];
INT8* SekM68KContext[SEK_MAX];
#endif


extern int nSekCount=-1;

struct Cyclone PicoCpu[SEK_MAX];
static bool bCycloneInited = false;

struct SekExt *SekExt[SEK_MAX] = { NULL, }, *pSekExt = NULL;

int nSekActive = -1;								// The cpu which is currently being emulated
int nSekCyclesTotal, nSekCyclesScanline, nSekCyclesSegment, nSekCyclesDone, nSekCyclesToDo;

int nSekCPUType[SEK_MAX], nSekCycles[SEK_MAX], nSekIRQPending[SEK_MAX];
//int nSekCPUType = 0x68000;
//int nSekIRQPending;

// ----------------------------------------------------------------------------
// Default memory access handlers

unsigned char __fastcall DefReadByte(unsigned int) { return 0; }
void __fastcall DefWriteByte(unsigned int, unsigned char) { }

#define DEFWORDHANDLERS(i)																				\
	unsigned short __fastcall DefReadWord##i(unsigned int a) { SEK_DEF_READ_WORD(i, a) }				\
	void __fastcall DefWriteWord##i(unsigned int a, unsigned short d) { SEK_DEF_WRITE_WORD(i, a ,d) }
#define DEFLONGHANDLERS(i)																				\
	unsigned int __fastcall DefReadLong##i(unsigned int a) { SEK_DEF_READ_LONG(i, a) }					\
	void __fastcall DefWriteLong##i(unsigned int a, unsigned int d) { SEK_DEF_WRITE_LONG(i, a , d) }

DEFWORDHANDLERS(0);
DEFLONGHANDLERS(0);

#if SEK_MAXHANDLER >= 2
 DEFWORDHANDLERS(1);
 DEFLONGHANDLERS(1);
#endif

#if SEK_MAXHANDLER >= 3
 DEFWORDHANDLERS(2);
 DEFLONGHANDLERS(2);
#endif

#if SEK_MAXHANDLER >= 4
 DEFWORDHANDLERS(3);
 DEFLONGHANDLERS(3);
#endif

#if SEK_MAXHANDLER >= 5
 DEFWORDHANDLERS(4);
 DEFLONGHANDLERS(4);
#endif

#if SEK_MAXHANDLER >= 6
 DEFWORDHANDLERS(5);
 DEFLONGHANDLERS(5);
#endif

#if SEK_MAXHANDLER >= 7
 DEFWORDHANDLERS(6);
 DEFLONGHANDLERS(6);
#endif

#if SEK_MAXHANDLER >= 8
 DEFWORDHANDLERS(7);
 DEFLONGHANDLERS(7);
#endif

/*#ifdef EMU_M68K
#if SEK_MAXHANDLER >= 9
 DEFWORDHANDLERS(8)
 DEFLONGHANDLERS(8)
#endif

#if SEK_MAXHANDLER >= 10
 DEFWORDHANDLERS(9)
 DEFLONGHANDLERS(9)
#endif
#endif
*/
// ----------------------------------------------------------------------------
// Memory access functions

// Mapped Memory lookup (               for read)
#define FIND_R(x) pSekExt->MemMap[ x >> SEK_SHIFT]
// Mapped Memory lookup (+ SEK_WADD     for write)
#define FIND_W(x) pSekExt->MemMap[(x >> SEK_SHIFT) + SEK_WADD]
// Mapped Memory lookup (+ SEK_WADD * 2 for fetch)
#define FIND_F(x) pSekExt->MemMap[(x >> SEK_SHIFT) + SEK_WADD * 2]

// Normal memory access functions
inline static unsigned char ReadByte(unsigned int a)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

//	bprintf(PRINT_NORMAL, _T("read8 0x%08X\n"), a);
	//dprintf("read8(0x%08x);\n", a);

	pr = FIND_R(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
		a ^= 1;
		return pr[a & SEK_PAGEM];
	}
	return pSekExt->ReadByte[(unsigned int)pr](a);
}

inline static unsigned char FetchByte(unsigned int a)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

//	bprintf(PRINT_NORMAL, _T("fetch8 0x%08X\n"), a);
//	dprintf("fetch8(0x%08x);\n", a);

	pr = FIND_F(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
		a ^= 1;
		return pr[a & SEK_PAGEM];
	}
	return pSekExt->ReadByte[(unsigned int)pr](a);
}

inline static void WriteByte(unsigned int a, unsigned char d)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

//	bprintf(PRINT_NORMAL, _T("write8 0x%08X\n"), a);
//	dprintf("write8(0x%08X, 0x%08X); cyc: %d\n", a, d, PicoCpu.cycles);

	pr = FIND_W(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
		a ^= 1;
		pr[a & SEK_PAGEM] = (unsigned char)d;
		return;
	}
	pSekExt->WriteByte[(unsigned int)pr](a, d);
}

inline static void WriteByteROM(unsigned int a, unsigned char d)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

	pr = FIND_R(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
		a ^= 1;
		pr[a & SEK_PAGEM] = (unsigned char)d;
		return;
	}
	pSekExt->WriteByte[(unsigned int)pr](a, d);
}

inline static unsigned short ReadWord(unsigned int a)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

//	bprintf(PRINT_NORMAL, _T("read16 0x%08X\n"), a);
	//if (a & 1) printf(" !!! read16(0x%08x); \n", a);


	pr = FIND_R(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
	    if (bBurnUseASMCPUEmulation)
		return *((unsigned short*)(pr + (a & SEK_PAGEM)));
		else
		return BURN_ENDIAN_SWAP_INT16(*((UINT16*)(pr + (a & SEK_PAGEM))));
	}

	return pSekExt->ReadWord[(unsigned int)pr](a);
}

inline static unsigned short FetchWord(unsigned int a)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

//	bprintf(PRINT_NORMAL, _T("fetch16 0x%08X\n"), a);
	//if (a & 1) printf(" !!! fetch16(0x%08x);\n", a);

	pr = FIND_F(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
	    if (bBurnUseASMCPUEmulation)
		return *((unsigned short*)(pr + (a & SEK_PAGEM)));
		else
        return BURN_ENDIAN_SWAP_INT16(*((UINT16*)(pr + (a & SEK_PAGEM))));

	}
	return pSekExt->ReadWord[(unsigned int)pr](a);
}

inline static void WriteWord(unsigned int a, unsigned short d)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

//	bprintf(PRINT_NORMAL, _T("write16 0x%08X\n"), a);
	//if (a & 1) printf(" !!! write16(0x%08x, 0x%04x); pc: 0x%08x\n", a, d, PicoCpu.pc - PicoCpu.membase );

	pr = FIND_W(a);

	if ((unsigned int)pr >= SEK_MAXHANDLER) {
	    if (bBurnUseASMCPUEmulation)
		*((unsigned short*)(pr + (a & SEK_PAGEM))) = (unsigned short)d;
		else
		*((UINT16*)(pr + (a & SEK_PAGEM))) = (UINT16)BURN_ENDIAN_SWAP_INT16(d);
		return;
	}
	pSekExt->WriteWord[(unsigned int)pr](a, d);
}


inline static void WriteWordROM(unsigned int a, unsigned short d)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

	//if (a & 1) printf(" !!! write16ROM(0x%08x, 0x%04x); pc: 0x%08x\n", a, d, PicoCpu.pc - PicoCpu.membase );

	pr = FIND_R(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
	    if (bBurnUseASMCPUEmulation)
		*((unsigned short*)(pr + (a & SEK_PAGEM))) = (unsigned short)d;
		else
		*((UINT16*)(pr + (a & SEK_PAGEM))) = (UINT16)d;
		return;
	}
	pSekExt->WriteWord[(unsigned int)pr](a, d);
}

inline static unsigned int ReadLong(unsigned int a)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

//	bprintf(PRINT_NORMAL, _T("read32 0x%08X\n"), a);

	// if (a & 1) printf(" !!!!!! read32(0x%08x);\n", a);

	pr = FIND_R(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
if (!bBurnUseASMCPUEmulation)
{
		unsigned int r = *((unsigned int*)(pr + (a & SEK_PAGEM)));
		r = (r >> 16) | (r << 16);
		return BURN_ENDIAN_SWAP_INT32(r);
}
else
{
		unsigned int r = ( *((unsigned short*)(pr + (a & SEK_PAGEM))) ) << 16;
		r |= *((unsigned short*)(pr + (a & SEK_PAGEM) + 2));
		return r;
}

	}
	return pSekExt->ReadLong[(unsigned int)pr](a);
}

inline static unsigned int FetchLong(unsigned int a)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

//	bprintf(PRINT_NORMAL, _T("fetch32 0x%08X\n"), a);
	//if ( a & 1 ) printf(" !!!!!! fetch32(0x%08x);\n", a);

	pr = FIND_F(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
if (!bBurnUseASMCPUEmulation)
{
		unsigned int r = *((unsigned int*)(pr + (a & SEK_PAGEM)));
		r = (r >> 16) | (r << 16);
		return BURN_ENDIAN_SWAP_INT32(r);
}
else
{
        unsigned int r = ( *((unsigned short*)(pr + (a & SEK_PAGEM))) ) << 16;
		r |= *((unsigned short*)(pr + (a & SEK_PAGEM) + 2));
		return r;
}
	}
	return pSekExt->ReadLong[(unsigned int)pr](a);
}

inline static void WriteLong(unsigned int a, unsigned int d)
{
	unsigned char* pr;

	a &= 0xFFFFFF;

//	bprintf(PRINT_NORMAL, _T("write32 0x%08X\n"), a);
	//if (a & 1) printf(" !!!!!! write32(0x%08x, 0x%08x);\n", a, d);

	pr = FIND_W(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
if (!bBurnUseASMCPUEmulation)
{
		d = (d >> 16) | (d << 16);
		*((unsigned int*)(pr + (a & SEK_PAGEM))) = BURN_ENDIAN_SWAP_INT32(d);
		return;
}
else
{
		*((unsigned short*)(pr + (a & SEK_PAGEM))) = d >> 16;
		*((unsigned short*)(pr + (a & SEK_PAGEM) + 2)) = d & 0xffff;
		return;
}

	}
	pSekExt->WriteLong[(unsigned int)pr](a, d);
}

inline static void WriteLongROM(unsigned int a, unsigned int d)
{
	unsigned char* pr;
	a &= 0xFFFFFF;

	//if (a & 1) printf(" !!! write32ROM(0x%08x, 0x%08x);\n", a, d);

	pr = FIND_R(a);
	if ((unsigned int)pr >= SEK_MAXHANDLER) {
if (!bBurnUseASMCPUEmulation)
{
		d = (d >> 16) | (d << 16);
		*((unsigned int*)(pr + (a & SEK_PAGEM))) = d;
		return;
}
else
{
		*((unsigned short*)(pr + (a & SEK_PAGEM))) = d >> 16;
		*((unsigned short*)(pr + (a & SEK_PAGEM) + 2)) = d & 0xffff;
		return;
}

	}
	pSekExt->WriteLong[(unsigned int)pr](a, d);
}

#ifdef EMU_M68K
extern "C" {
UINT32 __fastcall M68KReadByte(UINT32 a) { return (UINT32)ReadByte(a); }
UINT32 __fastcall M68KReadWord(UINT32 a) { return (UINT32)ReadWord(a); }
UINT32 __fastcall M68KReadLong(UINT32 a) { return               ReadLong(a); }

UINT32 __fastcall M68KFetchByte(UINT32 a) { return (UINT32)FetchByte(a); }
UINT32 __fastcall M68KFetchWord(UINT32 a) { return (UINT32)FetchWord(a); }
UINT32 __fastcall M68KFetchLong(UINT32 a) { return               FetchLong(a); }

#ifdef FBA_DEBUG
UINT32 __fastcall M68KReadByteBP(UINT32 a) { return (UINT32)ReadByteBP(a); }
UINT32 __fastcall M68KReadWordBP(UINT32 a) { return (UINT32)ReadWordBP(a); }
UINT32 __fastcall M68KReadLongBP(UINT32 a) { return               ReadLongBP(a); }

void __fastcall M68KWriteByteBP(UINT32 a, UINT32 d) { WriteByteBP(a, d); }
void __fastcall M68KWriteWordBP(UINT32 a, UINT32 d) { WriteWordBP(a, d); }
void __fastcall M68KWriteLongBP(UINT32 a, UINT32 d) { WriteLongBP(a, d); }

void M68KCheckBreakpoint() { CheckBreakpoint_PC(); }
void M68KSingleStep() { SingleStep_PC(); }

UINT32 (__fastcall *M68KReadByteDebug)(UINT32);
UINT32 (__fastcall *M68KReadWordDebug)(UINT32);
UINT32 (__fastcall *M68KReadLongDebug)(UINT32);

void (__fastcall *M68KWriteByteDebug)(UINT32, UINT32);
void (__fastcall *M68KWriteWordDebug)(UINT32, UINT32);
void (__fastcall *M68KWriteLongDebug)(UINT32, UINT32);
#endif

void __fastcall M68KWriteByte(UINT32 a, UINT32 d) { WriteByte(a, d); }
void __fastcall M68KWriteWord(UINT32 a, UINT32 d) { WriteWord(a, d); }
void __fastcall M68KWriteLong(UINT32 a, UINT32 d) { WriteLong(a, d); }
}
#endif


#ifdef EMU_M68K
extern "C" INT32 M68KIRQAcknowledge(INT32 nIRQ)
{
	if (nSekIRQPending[nSekActive] & SEK_IRQSTATUS_AUTO) {
		m68k_set_irq(0);
		nSekIRQPending[nSekActive] = 0;
	}

	if (pSekExt->IrqCallback) {
		return pSekExt->IrqCallback(nIRQ);
	}

	return M68K_INT_ACK_AUTOVECTOR;
}

extern "C" void M68KResetCallback()
{
	if (pSekExt->ResetCallback) {
		pSekExt->ResetCallback();
	}
}

extern "C" void M68KRTECallback()
{
	if (pSekExt->RTECallback) {
		pSekExt->RTECallback();
	}
}

extern "C" void M68KcmpildCallback(UINT32 val, INT32 reg)
{
	if (pSekExt->CmpCallback) {
		pSekExt->CmpCallback(val, reg);
	}
}
#endif

#ifdef EMU_M68K
static INT32 SekInitCPUM68K(INT32 nCount, INT32 nCPUType)
{
	nSekCPUType[nCount] = nCPUType;

	switch (nCPUType) {
		case 0x68000:
			m68k_set_cpu_type(M68K_CPU_TYPE_68000);
			break;
		case 0x68010:
			m68k_set_cpu_type(M68K_CPU_TYPE_68010);
			break;
		case 0x68EC020:
			m68k_set_cpu_type(M68K_CPU_TYPE_68EC020);
			break;
		default:
			return 1;
	}

	nSekM68KContextSize[nCount] = m68k_context_size();
	SekM68KContext[nCount] = (INT8*)malloc(nSekM68KContextSize[nCount]);
	if (SekM68KContext[nCount] == NULL) {
		return 1;
	}
	memset(SekM68KContext[nCount], 0, nSekM68KContextSize[nCount]);
	m68k_get_context(SekM68KContext[nCount]);

	return 0;
}
#endif

// ----------------------------------------------------------------------------
// Memory accesses (non-emu specific)

unsigned int SekReadByte(unsigned int a) { return (unsigned int)ReadByte(a); }
unsigned int SekReadWord(unsigned int a) { return (unsigned int)ReadWord(a); }
unsigned int SekReadLong(unsigned int a) { return ReadLong(a); }

unsigned int SekFetchByte(unsigned int a) { return (unsigned int)FetchByte(a); }
unsigned int SekFetchWord(unsigned int a) { return (unsigned int)FetchWord(a); }
unsigned int SekFetchLong(unsigned int a) { return FetchLong(a); }

void SekWriteByte(unsigned int a, unsigned char d) { WriteByte(a, d); }
void SekWriteWord(unsigned int a, unsigned short d) { WriteWord(a, d); }
void SekWriteLong(unsigned int a, unsigned int d) { WriteLong(a, d); }

void SekWriteByteROM(unsigned int a, unsigned char d) { WriteByteROM(a, d); }
void SekWriteWordROM(unsigned int a, unsigned short d) { WriteWordROM(a, d); }
void SekWriteLongROM(unsigned int a, unsigned int d) { WriteLongROM(a, d); }

// ----------------------------------------------------------------------------
// Initialisation/exit/reset

void SekNewFrame()
{
    for (int i = 0; i <= nSekCount; i++) {
		nSekCycles[i] = 0;
	}

	nSekCyclesTotal = 0;
}

void SekSetCyclesScanline(int nCycles)
{
	nSekCyclesScanline = nCycles;
}

#ifdef EMU_C68K

unsigned int PicoCheckPc(unsigned int pc)
{
	//dprintf("PicoCheckPc(0x%08X); membase: 0x%08X\n", pc, (int) FIND_F(pc) - (pc & ~SEK_PAGEM) );
	//dprintf("PicoCheckPc(0x%08x);\n", pc - PicoCpu.membase);

	pc -= PicoCpu[nSekActive].membase; // Get real pc
	pc &= 0xffffff;

	PicoCpu[nSekActive].membase = (int)FIND_F(pc) - (pc & ~SEK_PAGEM); //PicoMemBase(pc);

	return PicoCpu[nSekActive].membase + pc;
}

static void PicoIrqCallback(int int_level)
{
//	printf("PicoIrqCallback(%d)  irq=0x%04x 0x%08x;\n", int_level, PicoCpu.irq, nSekIRQPending );

	if (nSekIRQPending[nSekActive] & SEK_IRQSTATUS_AUTO)
		//PicoCpu.irq &= 0x78;
		PicoCpu[nSekActive].irq = 0;

	nSekIRQPending[nSekActive] = 0;
}

static void PicoResetCallback()
{
	//dprintf("ResetCallback();\n" );

	if (pSekExt->ResetCallback) {
		pSekExt->ResetCallback();
	}
}

static int UnrecognizedCallback()
{
	printf("UnrecognizedCallback();\n");
	return 0;
}


#endif

int SekInit(int nCount, int nCPUType)
{
//	dprintf("SekInit(%d, %x);\n", nCount, nCPUType);
if (bBurnUseASMCPUEmulation)
{
    //#ifndef m68k_ICount
        //#define	m68k_ICount PicoCpu[0].cycles
    //#endif
    bBurnUseASMCPUEmulation=true;

}
else
{
    bBurnUseASMCPUEmulation=false;
}

	struct SekExt* ps = NULL;

	if (nSekActive >= 0) {
		SekClose();
		nSekActive = -1;
	}

	if (nCount > nSekCount)
		nSekCount = nCount;

//	if (nCount > 0 || nCPUType != 0x68000) {
//		printf("Sorry, it support ONE 68000 cpu ONLY!\n");
//		return 1;
//	}

	// Allocate cpu extenal data (memory map etc)
	SekExt[nCount] = (struct SekExt*)malloc(sizeof(struct SekExt));
	if (SekExt[nCount] == NULL) {
		SekExit();
		return 1;
	}
	//memset(&tSekExt, 0, sizeof(struct SekExt));
	memset(SekExt[nCount], 0, sizeof(struct SekExt));

	// Put in default memory handlers
	//ps = &tSekExt;
	ps = SekExt[nCount];

	for (int j = 0; j < SEK_MAXHANDLER; j++) {
		ps->ReadByte[j]  = DefReadByte;
		ps->WriteByte[j] = DefWriteByte;
	}

	ps->ReadWord[0]  = DefReadWord0;
	ps->WriteWord[0] = DefWriteWord0;
	ps->ReadLong[0]  = DefReadLong0;
	ps->WriteLong[0] = DefWriteLong0;

#if SEK_MAXHANDLER >= 2
	ps->ReadWord[1]  = DefReadWord1;
	ps->WriteWord[1] = DefWriteWord1;
	ps->ReadLong[1]  = DefReadLong1;
	ps->WriteLong[1] = DefWriteLong1;
#endif

#if SEK_MAXHANDLER >= 3
	ps->ReadWord[2]  = DefReadWord2;
	ps->WriteWord[2] = DefWriteWord2;
	ps->ReadLong[2]  = DefReadLong2;
	ps->WriteLong[2] = DefWriteLong2;
#endif

#if SEK_MAXHANDLER >= 4
	ps->ReadWord[3]  = DefReadWord3;
	ps->WriteWord[3] = DefWriteWord3;
	ps->ReadLong[3]  = DefReadLong3;
	ps->WriteLong[3] = DefWriteLong3;
#endif

#if SEK_MAXHANDLER >= 5
	ps->ReadWord[4]  = DefReadWord4;
	ps->WriteWord[4] = DefWriteWord4;
	ps->ReadLong[4]  = DefReadLong4;
	ps->WriteLong[4] = DefWriteLong4;
#endif

#if SEK_MAXHANDLER >= 6
	ps->ReadWord[5]  = DefReadWord5;
	ps->WriteWord[5] = DefWriteWord5;
	ps->ReadLong[5]  = DefReadLong5;
	ps->WriteLong[5] = DefWriteLong5;
#endif

#if SEK_MAXHANDLER >= 7
	ps->ReadWord[6]  = DefReadWord6;
	ps->WriteWord[6] = DefWriteWord6;
	ps->ReadLong[6]  = DefReadLong6;
	ps->WriteLong[6] = DefWriteLong6;
#endif

#if SEK_MAXHANDLER >= 8
	ps->ReadWord[7]  = DefReadWord7;
	ps->WriteWord[7] = DefWriteWord7;
	ps->ReadLong[7]  = DefReadLong7;
	ps->WriteLong[7] = DefWriteLong7;
#endif

#if SEK_MAXHANDLER >= 9
	for (int j = 8; j < SEK_MAXHANDLER; j++) {
		ps->ReadWord[j]  = DefReadWord0;
		ps->WriteWord[j] = DefWriteWord0;
		ps->ReadLong[j]  = DefReadLong0;
		ps->WriteLong[j] = DefWriteLong0;
	}
#endif


	// Map the normal memory handlers

if ((bBurnUseASMCPUEmulation) && (nCPUType == 0x68000))
{
    printf("c68k\n");
	if (!bCycloneInited) {
		CycloneInit();
		bCycloneInited = true;
	}
	memset(&PicoCpu[nCount], 0, sizeof(Cyclone));

	PicoCpu[nCount].read8	= ReadByte;
	PicoCpu[nCount].read16	= ReadWord;
	PicoCpu[nCount].read32	= ReadLong;

	PicoCpu[nCount].write8	= WriteByte;
	PicoCpu[nCount].write16	= WriteWord;
	PicoCpu[nCount].write32	= WriteLong;

	PicoCpu[nCount].fetch8	= FetchByte;
	PicoCpu[nCount].fetch16	= FetchWord;
	PicoCpu[nCount].fetch32	= FetchLong;

	PicoCpu[nCount].checkpc = PicoCheckPc;

	PicoCpu[nCount].IrqCallback = PicoIrqCallback;
	PicoCpu[nCount].ResetCallback = PicoResetCallback;
	PicoCpu[nCount].UnrecognizedCallback = UnrecognizedCallback;

	pSekExt=SekExt[nCount];

}
else
{
        printf("m68k\n");
		m68k_init();
		if (SekInitCPUM68K(nCount, nCPUType)) {
			SekExit();
			return 1;
		}
}



/*	//nSekIRQPending[nSekActive] = 0;
	nSekIRQPending[nCount] = 0;

	nSekCyclesTotal = 0;
	nSekCyclesScanline = 0;

	//pSekExt = &tSekExt;
	pSekExt=SekExt[nCount];*/

	nSekCycles[nCount] = 0;
	nSekIRQPending[nCount] = 0;

	nSekCyclesTotal = 0;
	nSekCyclesScanline = 0;

	CpuCheatRegister(0x0000, nCount);

	return 0;

}

#ifdef EMU_C68K
static void PicoReset()
{
	//memset(&PicoCpu,0,PicoCpu.pad1-PicoCpu.d); // clear all regs
	memset(&PicoCpu[nSekActive], 0, 22 * 4); // clear all regs

	PicoCpu[nSekActive].stopped	= 0;
	PicoCpu[nSekActive].srh		= 0x27; // Supervisor mode
	PicoCpu[nSekActive].a[7]	= FetchLong(0); // Stack Pointer
	PicoCpu[nSekActive].membase	= 0;
	PicoCpu[nSekActive].pc		= PicoCpu[nSekActive].checkpc(FetchLong(4)); // Program Counter
}
#endif

#ifdef EMU_M68K
static void SekCPUExitM68K(INT32 i)
{
		if(SekM68KContext[i]) {
			free(SekM68KContext[i]);
			SekM68KContext[i] = NULL;
		}
}
#endif


int SekExit()
{
	// Deallocate cpu extenal data (memory map etc)
	for (int i = 0; i <= nSekCount; i++) {

//		SekCPUExitA68K(i);
if (!bBurnUseASMCPUEmulation)
{

		SekCPUExitM68K(i);
}


		// Deallocate other context data
		if (SekExt[i]) {
			free(SekExt[i]);
			SekExt[i] = NULL;
		}
	}

	pSekExt = NULL;

	nSekActive = -1;
	nSekCount = -1;

	DebugCPU_SekInitted = 0;

	return 0;

}

void SekReset()
{
//	dprintf("SekReset();\n");

if (!bBurnUseASMCPUEmulation)
{

	m68k_pulse_reset();
}

if (bBurnUseASMCPUEmulation)
{
	PicoReset();
}
}

// ----------------------------------------------------------------------------
// Control the active CPU

// Open a CPU
void SekOpen(const int i)
{
	//nSekActive = i;
//	pSekExt = &tSekExt;						// Point to cpu context
	if (i != nSekActive) {
		nSekActive = i;

		pSekExt = SekExt[nSekActive];						// Point to cpu context

if (!bBurnUseASMCPUEmulation)
{

			m68k_set_context(SekM68KContext[nSekActive]);
}


/*		if (nSekCPUType[nSekActive] == 0) {
			//memcpy(&M68000_regs, SekRegs[nSekActive], sizeof(M68000_regs));
			//A68KChangePC(M68000_regs.pc);
		} else {


		}*/

		nSekCyclesTotal = nSekCycles[nSekActive];
	}

}

// Close the active cpu
void SekClose()
{
    if (!bBurnUseASMCPUEmulation)
{

		m68k_get_context(SekM68KContext[nSekActive]);
}

	nSekCycles[nSekActive] = nSekCyclesTotal;
	//memcpy(SekRegs[nSekActive], &M68000_regs, sizeof(M68000_regs));
	nSekActive=-1;
}

// Get the current CPU
int SekGetActive()
{
#if defined FBA_DEBUG
	if (!DebugCPU_SekInitted) bprintf(PRINT_ERROR, _T("SekGetActive called without init\n"));
#endif

	return nSekActive;
}


// Set the status of an IRQ line on the active CPU
void SekSetIRQLine(const int line, const int status)
{
//	dprintf("SekSetIRQLine(%d, 0x%08x);\n", line, status);

	if (status) {
		nSekIRQPending[nSekActive] = line | status;

        if (!bBurnUseASMCPUEmulation)
        {

			m68k_set_irq(line);
        }

        if (bBurnUseASMCPUEmulation)
        {

            nSekCyclesTotal += (nSekCyclesToDo - nSekCyclesDone) - PicoCpu[nSekActive].cycles;
            nSekCyclesDone += (nSekCyclesToDo - nSekCyclesDone) - PicoCpu[nSekActive].cycles;

            PicoCpu[nSekActive].irq = line;
            PicoCpu[nSekActive].cycles = nSekCyclesToDo = -1;
        }
		return;

	}

	nSekIRQPending[nSekActive] = 0;
    if (!bBurnUseASMCPUEmulation)
    {

		m68k_set_irq(0);
    }

    if (bBurnUseASMCPUEmulation)
    {
        //PicoCpu.irq &= 0x78;
        PicoCpu[nSekActive].irq = 0;
    }
}

// Adjust the active CPU's timeslice
void SekRunAdjust(const int nCycles)
{
//	dprintf("SekRunAdjust(%d);\n", nCycles);
    if (bBurnUseASMCPUEmulation)
    {

        if (nCycles < 0 && PicoCpu[nSekActive].cycles < -nCycles) {
            SekRunEnd();
            return;
        }

        PicoCpu[nSekActive].cycles += nCycles;
        nSekCyclesToDo += nCycles;
        nSekCyclesSegment += nCycles;
    }

    if (!bBurnUseASMCPUEmulation)
    {

		if (nCycles < 0 && m68k_ICount < -nCycles) {
		SekRunEnd();
		return;
        }

		nSekCyclesToDo += nCycles;
		m68k_modify_timeslice(nCycles);
    }





}

// End the active CPU's timeslice
void SekRunEnd()
{
//	dprintf("SekRunEnd();\n");

    if (!bBurnUseASMCPUEmulation)
    {

		m68k_end_timeslice();
    }

    if (bBurnUseASMCPUEmulation)
    {

        nSekCyclesTotal += (nSekCyclesToDo - nSekCyclesDone) - PicoCpu[nSekActive].cycles;
        nSekCyclesDone += (nSekCyclesToDo - nSekCyclesDone) - PicoCpu[nSekActive].cycles;
        nSekCyclesSegment = nSekCyclesDone;
        PicoCpu[nSekActive].cycles = nSekCyclesToDo = -1;						// Force A68K to exit
    }

}

// Run the active CPU
int SekRun(const int nCycles)
{
//	dprintf("SekRun(%d);\n", nCycles);
if (!bBurnUseASMCPUEmulation)
{

		nSekCyclesToDo = nCycles;

		nSekCyclesSegment = m68k_execute(nCycles);

		nSekCyclesTotal += nSekCyclesSegment;
		nSekCyclesToDo = m68k_ICount = -1;

		return nSekCyclesSegment;
}

if (bBurnUseASMCPUEmulation)
{


	nSekCyclesDone = 0;
	nSekCyclesSegment = nCycles;
	do {
		PicoCpu[nSekActive].cycles = nSekCyclesToDo = nSekCyclesSegment - nSekCyclesDone;

		if (PicoCpu[nSekActive].irq == 0x80) {						// Cpu is in stopped state till interrupt
			// dprintf("Cpu is in stopped state till interrupt\n", nCycles);
			nSekCyclesDone = nSekCyclesSegment;
			nSekCyclesTotal += nSekCyclesSegment;
		} else {
			CycloneRun(&PicoCpu[nSekActive]);
			nSekCyclesDone += nSekCyclesToDo - PicoCpu[nSekActive].cycles;
			nSekCyclesTotal += nSekCyclesToDo - PicoCpu[nSekActive].cycles;
		}
	} while (nSekCyclesDone < nSekCyclesSegment);

	nSekCyclesSegment = nSekCyclesDone;
	nSekCyclesToDo = PicoCpu[nSekActive].cycles = -1;
	nSekCyclesDone = 0;

	return nSekCyclesSegment;
}
}


// Memory map setup

// Note - each page is 1 << SEK_BITS.
int SekMapMemory(unsigned char* pMemory, unsigned int nStart, unsigned int nEnd, int nType)
{
#if defined FBA_DEBUG
	if (!DebugCPU_SekInitted) bprintf(PRINT_ERROR, _T("SekMapMemory called without init\n"));
	if (nSekActive == -1) bprintf(PRINT_ERROR, _T("SekMapMemory called when no CPU open\n"));
#endif

	unsigned char* Ptr = pMemory - nStart;
	unsigned char** pMemMap = pSekExt->MemMap + (nStart >> SEK_SHIFT);

	// Special case for ROM banks
	if (nType == SM_ROM) {
		for (unsigned int i = (nStart & ~SEK_PAGEM); i <= nEnd; i += SEK_PAGE_SIZE, pMemMap++) {
			pMemMap[0]			  = Ptr + i;
			pMemMap[SEK_WADD * 2] = Ptr + i;
		}

		return 0;
	}
	for (unsigned int i = (nStart & ~SEK_PAGEM); i <= nEnd; i += SEK_PAGE_SIZE, pMemMap++) {

		if (nType & SM_READ) {					// Read
			pMemMap[0]			  = Ptr + i;
		}
		if (nType & SM_WRITE) {					// Write
			pMemMap[SEK_WADD]	  = Ptr + i;
		}
		if (nType & SM_FETCH) {					// Fetch
			pMemMap[SEK_WADD * 2] = Ptr + i;
		}
	}

	return 0;
}

//int SekMapHandler(uintptr_t nHandler, unsigned int nStart,unsigned int nEnd, unsigned int nType)
int SekMapHandler(unsigned int nHandler, unsigned int nStart,unsigned int nEnd, int nType)
{
#if defined FBA_DEBUG
	if (!DebugCPU_SekInitted) bprintf(PRINT_ERROR, _T("SekMapHander called without init\n"));
	if (nSekActive == -1) bprintf(PRINT_ERROR, _T("SekMapHandler called when no CPU open\n"));
#endif

	unsigned char** pMemMap = pSekExt->MemMap + (nStart >> SEK_SHIFT);

	// Add to memory map
	for (unsigned int i = (nStart & ~SEK_PAGEM); i <= nEnd; i += SEK_PAGE_SIZE, pMemMap++) {

		if (nType & SM_READ) {					// Read
			pMemMap[0]			  = (unsigned char*)nHandler;
		}
		if (nType & SM_WRITE) {					// Write
			pMemMap[SEK_WADD]	  = (unsigned char*)nHandler;
		}
		if (nType & SM_FETCH) {					// Fetch
			pMemMap[SEK_WADD * 2] = (unsigned char*)nHandler;
		}
	}

	return 0;
}

#ifdef EMU_M68K
// Set callbacks
INT32 SekSetResetCallback(pSekResetCallback pCallback)
{
#if defined FBA_DEBUG
	if (!DebugCPU_SekInitted) bprintf(PRINT_ERROR, _T("SekSetResetCallback called without init\n"));
	if (nSekActive == -1) bprintf(PRINT_ERROR, _T("SekSetResetCallback called when no CPU open\n"));
#endif

	pSekExt->ResetCallback = pCallback;

	return 0;
}

INT32 SekSetRTECallback(pSekRTECallback pCallback)
{
#if defined FBA_DEBUG
	if (!DebugCPU_SekInitted) bprintf(PRINT_ERROR, _T("SekSetRTECallback called without init\n"));
	if (nSekActive == -1) bprintf(PRINT_ERROR, _T("SekSetRTECallback called when no CPU open\n"));
#endif

	pSekExt->RTECallback = pCallback;

	return 0;
}

INT32 SekSetIrqCallback(pSekIrqCallback pCallback)
{
#if defined FBA_DEBUG
	if (!DebugCPU_SekInitted) bprintf(PRINT_ERROR, _T("SekSetIrqCallback called without init\n"));
	if (nSekActive == -1) bprintf(PRINT_ERROR, _T("SekSetIrqCallback called when no CPU open\n"));
#endif

	pSekExt->IrqCallback = pCallback;

	return 0;
}

INT32 SekSetCmpCallback(pSekCmpCallback pCallback)
{
#if defined FBA_DEBUG
	if (!DebugCPU_SekInitted) bprintf(PRINT_ERROR, _T("SekSetCmpCallback called without init\n"));
	if (nSekActive == -1) bprintf(PRINT_ERROR, _T("SekSetCmpCallback called when no CPU open\n"));
#endif

	pSekExt->CmpCallback = pCallback;

	return 0;
}
#endif
// Set handlers
int SekSetReadByteHandler(int i, pSekReadByteHandler pHandler)
{
//	dprintf("SekSetReadByteHandler(%d, %p);\n", i, pHandler);

	if (i >= SEK_MAXHANDLER) {
		return 1;
	}

	pSekExt->ReadByte[i] = pHandler;

	return 0;
}

int SekSetWriteByteHandler(int i, pSekWriteByteHandler pHandler)
{
//	dprintf("SekSetWriteByteHandler(%d, %p);\n", i, pHandler);

	if (i >= SEK_MAXHANDLER) {
		return 1;
	}

	pSekExt->WriteByte[i] = pHandler;

	return 0;
}

int SekSetReadWordHandler(int i, pSekReadWordHandler pHandler)
{
//	dprintf("SekSetReadWordHandler(%d, %p);\n", i, pHandler);

	if (i >= SEK_MAXHANDLER) {
		return 1;
	}

	pSekExt->ReadWord[i] = pHandler;

	return 0;
}

int SekSetWriteWordHandler(int i, pSekWriteWordHandler pHandler)
{
//	dprintf("SekSetWriteWordHandler(%d, %p);\n", i, pHandler);

	if (i >= SEK_MAXHANDLER) {
		return 1;
	}

	pSekExt->WriteWord[i] = pHandler;

	return 0;
}

int SekSetReadLongHandler(int i, pSekReadLongHandler pHandler)
{
//	dprintf("SekSetReadLongHandler(%d, %p);\n", i, pHandler);

	if (i >= SEK_MAXHANDLER) {
		return 1;
	}

	pSekExt->ReadLong[i] = pHandler;

	return 0;
}

int SekSetWriteLongHandler(int i, pSekWriteLongHandler pHandler)
{
//	dprintf("SekSetWriteLongHandler(%d, %p);\n", i, pHandler);

	if (i >= SEK_MAXHANDLER) {
		return 1;
	}

	pSekExt->WriteLong[i] = pHandler;

	return 0;
}

// ----------------------------------------------------------------------------
// Query register values

int SekGetPC(int)
{
//	dprintf("SekGetPC(); = 0x%08x\n", PicoCpu.pc-PicoCpu.membase);
if (!bBurnUseASMCPUEmulation)
{

		return m68k_get_reg(NULL, M68K_REG_PC);
}
if (bBurnUseASMCPUEmulation)
{

	return PicoCpu[nSekActive].pc-PicoCpu[nSekActive].membase;
}
}

int SekDbgGetCPUType()
{
if (!bBurnUseASMCPUEmulation)
{

	switch (nSekCPUType[nSekActive]) {
		case 0:
		case 0x68000:
			return M68K_CPU_TYPE_68000;
		case 0x68010:
			return M68K_CPU_TYPE_68010;
		case 0x68EC020:
			return M68K_CPU_TYPE_68EC020;
	}

	return 0;
}
else
{
	return 0x68000;
}
}

int SekDbgGetPendingIRQ()
{
	return nSekIRQPending[nSekActive] & 7;
}

unsigned int SekDbgGetRegister(SekRegister nRegister)
{
if (!bBurnUseASMCPUEmulation)
{

	switch (nRegister) {
		case SEK_REG_D0:
			return m68k_get_reg(NULL, M68K_REG_D0);
		case SEK_REG_D1:
			return m68k_get_reg(NULL, M68K_REG_D1);
		case SEK_REG_D2:
			return m68k_get_reg(NULL, M68K_REG_D2);
		case SEK_REG_D3:
			return m68k_get_reg(NULL, M68K_REG_D3);
		case SEK_REG_D4:
			return m68k_get_reg(NULL, M68K_REG_D4);
		case SEK_REG_D5:
			return m68k_get_reg(NULL, M68K_REG_D5);
		case SEK_REG_D6:
			return m68k_get_reg(NULL, M68K_REG_D6);
		case SEK_REG_D7:
			return m68k_get_reg(NULL, M68K_REG_D7);

		case SEK_REG_A0:
			return m68k_get_reg(NULL, M68K_REG_A0);
		case SEK_REG_A1:
			return m68k_get_reg(NULL, M68K_REG_A1);
		case SEK_REG_A2:
			return m68k_get_reg(NULL, M68K_REG_A2);
		case SEK_REG_A3:
			return m68k_get_reg(NULL, M68K_REG_A3);
		case SEK_REG_A4:
			return m68k_get_reg(NULL, M68K_REG_A4);
		case SEK_REG_A5:
			return m68k_get_reg(NULL, M68K_REG_A5);
		case SEK_REG_A6:
			return m68k_get_reg(NULL, M68K_REG_A6);
		case SEK_REG_A7:
			return m68k_get_reg(NULL, M68K_REG_A7);

		case SEK_REG_PC:
			return m68k_get_reg(NULL, M68K_REG_PC);

		case SEK_REG_SR:
			return m68k_get_reg(NULL, M68K_REG_SR);

		case SEK_REG_SP:
			return m68k_get_reg(NULL, M68K_REG_SP);
		case SEK_REG_USP:
			return m68k_get_reg(NULL, M68K_REG_USP);
		case SEK_REG_ISP:
			return m68k_get_reg(NULL, M68K_REG_ISP);
		case SEK_REG_MSP:
			return m68k_get_reg(NULL, M68K_REG_MSP);

		case SEK_REG_VBR:
			return m68k_get_reg(NULL, M68K_REG_VBR);

		case SEK_REG_SFC:
			return m68k_get_reg(NULL, M68K_REG_SFC);
		case SEK_REG_DFC:
			return m68k_get_reg(NULL, M68K_REG_DFC);

		case SEK_REG_CACR:
			return m68k_get_reg(NULL, M68K_REG_CACR);
		case SEK_REG_CAAR:
			return m68k_get_reg(NULL, M68K_REG_CAAR);

		default:
			return 0;
	}
}
else
{
	return 0;
}
}

bool SekDbgSetRegister(SekRegister nRegister, unsigned int nValue)
{
if (!bBurnUseASMCPUEmulation)
{
	switch (nRegister) {
		case SEK_REG_D0:
		case SEK_REG_D1:
		case SEK_REG_D2:
		case SEK_REG_D3:
		case SEK_REG_D4:
		case SEK_REG_D5:
		case SEK_REG_D6:
		case SEK_REG_D7:
			break;

		case SEK_REG_A0:
		case SEK_REG_A1:
		case SEK_REG_A2:
		case SEK_REG_A3:
		case SEK_REG_A4:
		case SEK_REG_A5:
		case SEK_REG_A6:
		case SEK_REG_A7:
			break;

		case SEK_REG_PC:
			if (nSekCPUType[nSekActive] == 0) {
			} else {
				m68k_set_reg(M68K_REG_PC, nValue);
			}
			SekClose();
			return true;

		case SEK_REG_SR:
			break;

		case SEK_REG_SP:
		case SEK_REG_USP:
		case SEK_REG_ISP:
		case SEK_REG_MSP:
			break;

		case SEK_REG_VBR:
			break;

		case SEK_REG_SFC:
		case SEK_REG_DFC:
			break;

		case SEK_REG_CACR:
		case SEK_REG_CAAR:
			break;

		default:
			break;
	}

	return false;
}
else
{
	return false;
}
}

// ----------------------------------------------------------------------------
// Savestate support

int SekScan(int nAction)
{
	// Scan the 68000 states

	struct BurnArea ba;

	if ((nAction & ACB_DRIVER_DATA) == 0) {
		return 1;
	}

	memset(&ba, 0, sizeof(ba));

	nSekActive = -1;

	for (int i = 0; i <= nSekCount; i++) {
if (bBurnUseASMCPUEmulation)
{

		char szName[] = "Cyclone #n";
		int nType = nSekCPUType[i];	//nSekCPUType[i];

		szName[9] = '0' + i;

		SCAN_VAR(nSekCPUType[i]);

		//if (nSekCPUType != 0) {
			ba.Data = & PicoCpu;
			//ba.nLen = nSekM68KContextSize[i];
			ba.nLen = 24 * 4;
			ba.szName = szName;
			BurnAcb(&ba);
		//}
}
	}

	return 0;
}

