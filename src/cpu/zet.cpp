// Z80 (Zed Eight-Ty) Interface
#include "burnint.h"
//#include "gp2xmemfuncs.h"

#define MAX_Z80		8
static struct ZetExt * ZetCPUContext[MAX_Z80] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };
int cpucore[MAX_Z80];

//extern void DaveZ80EnterCPU(unsigned char *, void *);

typedef UINT8 (__fastcall *pZetInHandler)(UINT16 a);
typedef void (__fastcall *pZetOutHandler)(UINT16 a, UINT8 d);
typedef UINT8 (__fastcall *pZetReadHandler)(UINT16 a);
typedef void (__fastcall *pZetWriteHandler)(UINT16 a, UINT8 d);

/*extern int ZET_IRQSTATUS_NONE;
extern int ZET_IRQSTATUS_ACK;
extern int ZET_IRQSTATUS_AUTO;
*/
struct ZetExt {
	Z80_Regs reg;

	UINT8* pZetMemMap[0x100 * 4];

	pZetInHandler ZetIn;
	pZetOutHandler ZetOut;
	pZetReadHandler ZetRead;
	pZetWriteHandler ZetWrite;

	UINT8 BusReq;

	  unsigned int Z80A;            // 0x00 - A Register:   0xAA------
  unsigned int Z80F;            // 0x04 - F Register:   0x------FF
  unsigned int Z80BC;           // 0x08 - BC Registers: 0xBBCC----
  unsigned int Z80DE;           // 0x0C - DE Registers: 0xDDEE----
  unsigned int Z80HL;           // 0x10 - HL Registers: 0xHHLL----
  unsigned int Z80PC;           // 0x14 - PC Program Counter (Memory Base + PC)
  unsigned int Z80PC_BASE;      // 0x18 - PC Program Counter (Memory Base)
  unsigned int Z80SP;           // 0x1C - SP Stack Pointer (Memory Base + PC)
  unsigned int Z80SP_BASE;      // 0x20 - SP Stack Pointer (Memory Base)
  unsigned int Z80IX;           // 0x24 - IX Index Register
  unsigned int Z80IY;           // 0x28 - IY Index Register
  unsigned int Z80I;            // 0x2C - I Interrupt Register
  unsigned int Z80A2;           // 0x30 - A' Register:    0xAA------
  unsigned int Z80F2;           // 0x34 - F' Register:    0x------FF
  unsigned int Z80BC2;          // 0x38 - B'C' Registers: 0xBBCC----
  unsigned int Z80DE2;          // 0x3C - D'E' Registers: 0xDDEE----
  unsigned int Z80HL2;          // 0x40 - H'L' Registers: 0xHHLL----
  unsigned char Z80_IRQ;        // 0x44 - Set IRQ Number
  unsigned char Z80IF;          // 0x45 - Interrupt Flags:  bit1=_IFF1, bit2=_IFF2, bit3=_HALT
  unsigned char Z80IM;          // 0x46 - Set IRQ Mode
  unsigned char spare;          // 0x47 - N/A
  unsigned int z80irqvector;    // 0x48 - Set IRQ Vector i.e. 0xFF=RST

  int nEI;
  int nCyclesLeft;
  int nCyclesTotal;
  int nCyclesSegment;
  int nInterruptLatch;

  void (*z80_irq_callback )(void);

  //void (*z80_write8 )(unsigned char d,unsigned short a);
  void (*z80_write8 )(unsigned short a, unsigned char d);
  void (*z80_write16 )(unsigned short d,unsigned short a);

  unsigned char (*z80_in)(unsigned short p);
  void (*z80_out )(unsigned short p,unsigned char d);

  unsigned char (*z80_read8)(unsigned short a);
  unsigned short (*z80_read16)(unsigned short a);

  unsigned int (*z80_rebaseSP)(unsigned short new_sp);
  unsigned int (*z80_rebasePC)(unsigned short new_pc);

  // Memory access
  unsigned char ** ppMemFetch;
  unsigned char ** ppMemFetchData;
  unsigned char ** ppMemRead;
  unsigned char ** ppMemWrite;

  void (*debugCallback)(unsigned short pc, unsigned int d);

};

static INT32 nZetCyclesDone[MAX_Z80];
static INT32 nZetCyclesTotal;
static INT32 nZ80ICount[MAX_Z80];
static UINT32 Z80EA[MAX_Z80];


#ifdef EMU_DRZ80

struct DrZ80 Doze;
//struct DrZ80 *ZetCPUContext = NULL;
#endif // EMU_DRZ80



static int nOpenedCPU = -1;
static int nCPUCount = 0;

int nHasZet=-1;

unsigned char __fastcall ZetDummyReadHandler(unsigned short) { return 0; }
void __fastcall ZetDummyWriteHandler(unsigned short, unsigned char) { }
unsigned char __fastcall ZetDummyInHandler(unsigned short) { return 0; }
void __fastcall ZetDummyOutHandler(unsigned short, unsigned char) { }



UINT8 __fastcall ZetReadIO(UINT32 a)
{
	return ZetCPUContext[nOpenedCPU]->ZetIn(a);
}

void __fastcall ZetWriteIO(UINT32 a, UINT8 d)
{
	ZetCPUContext[nOpenedCPU]->ZetOut(a, d);
}

UINT8 __fastcall ZetReadProg(UINT32 a)
{
	// check mem map
	UINT8 * pr = ZetCPUContext[nOpenedCPU]->pZetMemMap[0x000 | (a >> 8)];
	if (pr != NULL) {
		return pr[a & 0xff];
	}

	// check handler
	if (ZetCPUContext[nOpenedCPU]->ZetRead != NULL) {
		return ZetCPUContext[nOpenedCPU]->ZetRead(a);
	}

	return 0;
}

void __fastcall ZetWriteProg(UINT32 a, UINT8 d)
{
	// check mem map
	UINT8 * pr = ZetCPUContext[nOpenedCPU]->pZetMemMap[0x100 | (a >> 8)];
	if (pr != NULL) {
		pr[a & 0xff] = d;
		return;
	}

	// check handler
	if (ZetCPUContext[nOpenedCPU]->ZetWrite != NULL) {
		ZetCPUContext[nOpenedCPU]->ZetWrite(a, d);
		return;
	}
}

UINT8 __fastcall ZetReadOp(UINT32 a)
{
	// check mem map
	UINT8 * pr = ZetCPUContext[nOpenedCPU]->pZetMemMap[0x200 | (a >> 8)];
	if (pr != NULL) {
		return pr[a & 0xff];
	}

	// check read handler
	if (ZetCPUContext[nOpenedCPU]->ZetRead != NULL) {
		return ZetCPUContext[nOpenedCPU]->ZetRead(a);
	}

	return 0;
}

UINT8 __fastcall ZetReadOpArg(UINT32 a)
{
	// check mem map
	UINT8 * pr = ZetCPUContext[nOpenedCPU]->pZetMemMap[0x300 | (a >> 8)];
	if (pr != NULL) {
		return pr[a & 0xff];
	}

	// check read handler
	if (ZetCPUContext[nOpenedCPU]->ZetRead != NULL) {
		return ZetCPUContext[nOpenedCPU]->ZetRead(a);
	}

	return 0;
}


static void Z80DebugCallback(unsigned short pc, unsigned int d)
{
	printf("z80 error at PC: 0x%08x   OpCodes: %08X\n", pc, d);
	exit(0);
}

static unsigned int z80_rebasePC(unsigned short address)
{
	Doze.Z80PC_BASE	= (unsigned int) Doze.ppMemFetch[ address >> 8 ];
	Doze.Z80PC		= Doze.Z80PC_BASE + address;
	return Doze.Z80PC;
}

static void z80_write8(unsigned short a, unsigned char d)
{
	//printf("z80_write8(0x%04x, 0x%04x);\n", d, a);
	unsigned char * p = Doze.ppMemWrite[ a >> 8 ];
	if ( p )
		* (p + a) = d;
	else
		; //Z80.WriteHandler(d, a);
}

void ZetWriteByte(unsigned short a, unsigned char d)
{
    if (nOpenedCPU < 0) return;
    if (cpucore[nOpenedCPU]==0)
    z80_write8(a, d);
    else
    ZetWriteProg(a, d);
}

void ZetWriteRom(unsigned short address,unsigned char data)
{
    if (nOpenedCPU < 0) return;
    if (cpucore[nOpenedCPU]==0)

    z80_write8( address, data);
    else
    {
        	if (ZetCPUContext[nOpenedCPU]->pZetMemMap[0x200 | (address >> 8)] != NULL) {
		ZetCPUContext[nOpenedCPU]->pZetMemMap[0x200 | (address >> 8)][address] = data;
	}

	if (ZetCPUContext[nOpenedCPU]->pZetMemMap[0x300 | (address >> 8)] != NULL) {
		ZetCPUContext[nOpenedCPU]->pZetMemMap[0x300 | (address >> 8)][address] = data;
	}

	ZetWriteProg(address, data);

    }
}


static void z80_write16(unsigned short d,unsigned short a)
{
//	printf("z80_write16(0x%04x, 0x%04x);\n", a, d);
	unsigned char * p = Doze.ppMemWrite[ a >> 8 ];
	if ( p ) {
		p+=a;	*p = d & 0xff;
		p++;	*p = d >> 8;
	} else {
//		printf("z80_write16(0x%04x, 0x%04x); error at pc: 0x%04x\n", d, a, Doze.Z80PC - Doze.Z80PC_BASE);
		//z80_write8( (unsigned char)(d & 0xFF), a );
		//z80_write8( (unsigned char)(d >> 8), a + 1 );
		//Doze.z80_write8 ( a, d & 0xff );
		//Doze.z80_write8 ( a + 1, d >> 8 );
	}
}



unsigned char ZetBc(int n)
{
    if (cpucore[nOpenedCPU]==0)
    {
    if (n<0) return Doze.Z80BC;
    else return ZetCPUContext[n]->Z80BC;
    }
    else
    {
        if (n < 0) {
		return ActiveZ80GetPC();
        } else {
		return ZetCPUContext[n]->reg.bc.w.l;
	}

    }
    return 0;
}

unsigned char ZetHL(int n)
{
    if (cpucore[nOpenedCPU]==0)
    {
    if (n<0) return Doze.Z80HL;
    else return ZetCPUContext[n]->Z80HL;
    }
    else
    {
        if (n < 0) {
		return ActiveZ80GetPC();
        } else {
		return ZetCPUContext[n]->reg.hl.w.l;
	}

    }
    return 0;
}

unsigned char ZetDe(int n)
{
    if (cpucore[nOpenedCPU]==0)
    {
    if (n<0) return Doze.Z80DE;
    else return ZetCPUContext[n]->Z80DE;
    }
    else
    {
        if (n < 0) {
		return ActiveZ80GetPC();
        } else {
		return ZetCPUContext[n]->reg.de.w.l;
	}

    }
    return 0;
}

static unsigned char z80_read8(unsigned short a)
{
	//printf("z80_read8(0x%04x);  PC: %08x\n", a, Doze.Z80PC - Doze.Z80PC_BASE);
	unsigned char * p = Doze.ppMemRead[ a >> 8 ];
	if ( p )
		return *(p + a);
	else
		return 0; // Doze.ReadHandler(a);
}

unsigned char ZetReadByte(unsigned short address)
{
	if (nOpenedCPU < 0) return 0;
    if (cpucore[nOpenedCPU]==0)
    return z80_read8(address);
    else
    return ZetReadProg(address);
}


static unsigned short z80_read16(unsigned short a)
{
//	printf("z80_read16(0x%04x);\n", a);

	unsigned short d = 0;
	unsigned char * p = Doze.ppMemRead[ a >> 8 ];
	if ( p ) {
		p+=a;	d = *p;
		p++;	d |= (*p) << 8;
	} else {
		printf("z80_read16(0x%04x); error at pc: 0x%04x\n", a, Doze.Z80PC - Doze.Z80PC_BASE);
		//return z80_read8(a) | (z80_read8(a+1) << 8) ;
	}
	return d;
}

static void z80_irq_callback(void)
{
	//printf("z80_irq_callback();\n");
	Doze.Z80_IRQ = 0x00;
}

void ZetSetReadHandler(unsigned char (__fastcall *pHandler)(unsigned short))
{
	//printf("ZetSetReadHandler(%p);\n", pHandler);
	if (cpucore[nOpenedCPU]==0)
	Doze.z80_read8 = pHandler;
	else
	{
    #if defined FBA_DEBUG
	if (!DebugCPU_ZetInitted) bprintf(PRINT_ERROR, _T("ZetSetReadHandler called without init\n"));
	if (nOpenedCPU == -1) bprintf(PRINT_ERROR, _T("ZetSetReadHandler called when no CPU open\n"));
    #endif

	ZetCPUContext[nOpenedCPU]->ZetRead = pHandler;

	}
}

void ZetSetWriteHandler(void (__fastcall *pHandler)(unsigned short, unsigned char))
{
	//printf("ZetSetWriteHandler(%p);\n", pHandler);
	if (cpucore[nOpenedCPU]==0)
	Doze.z80_write8 = pHandler;
	else
	{
    #if defined FBA_DEBUG
	if (!DebugCPU_ZetInitted) bprintf(PRINT_ERROR, _T("ZetSetWriteHandler called without init\n"));
	if (nOpenedCPU == -1) bprintf(PRINT_ERROR, _T("ZetSetWriteHandler called when no CPU open\n"));
    #endif

	ZetCPUContext[nOpenedCPU]->ZetWrite = pHandler;

	}
}

void ZetSetInHandler(unsigned char (__fastcall *pHandler)(unsigned short))
{
	//printf("ZetSetInHandler(%p);\n", pHandler);
	if (cpucore[nOpenedCPU]==0)
	Doze.z80_in = pHandler;
	else
	{
    #if defined FBA_DEBUG
	if (!DebugCPU_ZetInitted) bprintf(PRINT_ERROR, _T("ZetSetInHandler called without init\n"));
	if (nOpenedCPU == -1) bprintf(PRINT_ERROR, _T("ZetSetInHandler called when no CPU open\n"));
    #endif

	ZetCPUContext[nOpenedCPU]->ZetIn = pHandler;
	}
}

void ZetSetOutHandler(void (__fastcall *pHandler)(unsigned short, unsigned char))
{
	//printf("ZetSetOutHandler(%p);\n", pHandler);
	if (cpucore[nOpenedCPU]==0)
	Doze.z80_out = pHandler;
	else
	{
    #if defined FBA_DEBUG
	if (!DebugCPU_ZetInitted) bprintf(PRINT_ERROR, _T("ZetSetOutHandler called without init\n"));
	if (nOpenedCPU == -1) bprintf(PRINT_ERROR, _T("ZetSetOutHandler called when no CPU open\n"));
    #endif

	ZetCPUContext[nOpenedCPU]->ZetOut = pHandler;

	}
}

void ZetNewFrame()
{
//	printf("ZetNewFrame();\n");
if (cpucore[nOpenedCPU]==0){
	for (int i = 0; i < nCPUCount; i++) {
		ZetCPUContext[i]->nCyclesTotal = 0;
	}
	Doze.nCyclesTotal = 0;}
	else
	{
        for (INT32 i = 0; i < nCPUCount; i++) {
		nZetCyclesDone[i] = 0;
	}
        nZetCyclesTotal = 0;

	}
}

int ZetInit(int nCount)
{
    //if (nCount<1)
    int nCPU=nCount;
    if (bBurnZ80Core==0)
    {
        ZET_IRQSTATUS_NONE= 0x8000;
        ZET_IRQSTATUS_ACK=  0x1000;
        ZET_IRQSTATUS_AUTO =0x2000;

    printf("DRZ80 Core for CPU #%d\n",nCPU);
    cpucore[nCPU]=0;
    nCount++;
	ZetCPUContext[nCPU] = (struct ZetExt*)BurnMalloc(sizeof(ZetExt));
    memset (ZetCPUContext[nCPU], 0, sizeof(ZetExt));

	//ZetCPUContext[0].Z80PC_BASE=(unsigned int)&ZetCPUContext;

    //for (int i = 0; i < nCount; i++)
	//{
	int i=nCount-1;
        ZetCPUContext[i]->Z80SP=0xFFFE;
		ZetCPUContext[i]->z80_in			= ZetDummyInHandler;
		ZetCPUContext[i]->z80_out		= ZetDummyOutHandler;
		ZetCPUContext[i]->z80_rebasePC	= z80_rebasePC;
		//Doze.z80_rebaseSP	= z80_rebaseSP;
		ZetCPUContext[i]->z80_read8		= z80_read8;
		ZetCPUContext[i]->z80_read16		= z80_read16;
		ZetCPUContext[i]->z80_write8		= z80_write8;
		ZetCPUContext[i]->z80_write16	= z80_write16;
/*
		ZetCPUContext[i]->z80_read8		= ZetDummyReadHandler;
		ZetCPUContext[i]->z80_read16		= z80_read16;
		ZetCPUContext[i]->z80_write8		= ZetDummyWriteHandler;
		ZetCPUContext[i]->z80_write16	= z80_write16;
*/
		ZetCPUContext[i]->z80_irq_callback=z80_irq_callback;
		ZetCPUContext[i]->debugCallback	= Z80DebugCallback;

		ZetCPUContext[i]->nInterruptLatch = -1;

		ZetCPUContext[i]->ppMemFetch = (unsigned char**)malloc(0x0100 * sizeof(char*));
		ZetCPUContext[i]->ppMemFetchData = (unsigned char**)malloc(0x0100 * sizeof(char*));
		ZetCPUContext[i]->ppMemRead = (unsigned char**)malloc(0x0100 * sizeof(char*));
		ZetCPUContext[i]->ppMemWrite = (unsigned char**)malloc(0x0100 * sizeof(char*));

		if (ZetCPUContext[i]->ppMemFetch == NULL || ZetCPUContext[i]->ppMemFetchData == NULL || ZetCPUContext[i]->ppMemRead == NULL || ZetCPUContext[i]->ppMemWrite == NULL) {
			ZetExit();
			return 1;
		}

		memset( ZetCPUContext[i]->ppMemFetch, 0, 0x0400 );
		memset( ZetCPUContext[i]->ppMemFetchData, 0, 0x0400 );
		memset( ZetCPUContext[i]->ppMemRead, 0, 0x0400 );
		memset( ZetCPUContext[i]->ppMemWrite, 0, 0x0400 );
	//}

    nCPUCount = nCount;
	nHasZet = nCPUCount;

	ZetOpen(i);


}
    else
    {
        ZET_IRQSTATUS_NONE= 0;
        ZET_IRQSTATUS_ACK=  1;
        ZET_IRQSTATUS_AUTO =2;


        printf("C Z80 Core for CPU #%d\n",nCPU);
        printf("ZET_IRQSTATUS_AUTO %d\n",ZET_IRQSTATUS_AUTO);
        cpucore[nCPU]=1;
        ZetCPUContext[nCPU] = (struct ZetExt*)BurnMalloc(sizeof(ZetExt));
        memset (ZetCPUContext[nCPU], 0, sizeof(ZetExt));

    if (nCPU == 0) { // not safe!
		Z80Init();
	}

	{
		ZetCPUContext[nCPU]->ZetIn = ZetDummyInHandler;
		ZetCPUContext[nCPU]->ZetOut = ZetDummyOutHandler;
		ZetCPUContext[nCPU]->ZetRead = ZetDummyReadHandler;
		ZetCPUContext[nCPU]->ZetWrite = ZetDummyWriteHandler;
		ZetCPUContext[nCPU]->BusReq = 0;
		// TODO: Z80Init() will set IX IY F regs with default value, so get them ...
		Z80GetContext(&ZetCPUContext[nCPU]->reg);

		nZetCyclesDone[nCPU] = 0;
		nZ80ICount[nCPU] = 0;

		for (INT32 j = 0; j < (0x0100 * 4); j++) {
			ZetCPUContext[nCPU]->pZetMemMap[j] = NULL;
		}
	}

	nZetCyclesTotal = 0;

	Z80SetIOReadHandler(ZetReadIO);
	Z80SetIOWriteHandler(ZetWriteIO);
	Z80SetProgramReadHandler(ZetReadProg);
	Z80SetProgramWriteHandler(ZetWriteProg);
	Z80SetCPUOpReadHandler(ZetReadOp);
	Z80SetCPUOpArgReadHandler(ZetReadOpArg);

    nCPUCount = (nCPU+1) % MAX_Z80;

	nHasZet = nCPU+1;

	CpuCheatRegister(0x0004, nCPU);


    }






	return 0;
}

void ZetClose()
{
    if (cpucore[nOpenedCPU]==0)
	{
	    ZetCPUContext[nOpenedCPU]->Z80A=Doze.Z80A;     // 0x00 - A Register:   0xAA------
        ZetCPUContext[nOpenedCPU]->Z80F=Doze.Z80F;            // 0x04 - F Register:   0x------FF
        ZetCPUContext[nOpenedCPU]->Z80BC=Doze.Z80BC;           // 0x08 - BC Registers: 0xBBCC----
        ZetCPUContext[nOpenedCPU]->Z80DE=Doze.Z80DE;           // 0x0C - DE Registers: 0xDDEE----
        ZetCPUContext[nOpenedCPU]->Z80HL=Doze.Z80HL;           // 0x10 - HL Registers: 0xHHLL----
        ZetCPUContext[nOpenedCPU]->Z80PC=Doze.Z80PC; // 0x14 - PC Program Counter (Memory Base + PC)
        ZetCPUContext[nOpenedCPU]->Z80PC_BASE=Doze.Z80PC_BASE;      // 0x18 - PC Program Counter (Memory Base)
        ZetCPUContext[nOpenedCPU]->Z80SP=Doze.Z80SP;           // 0x1C - SP Stack Pointer (Memory Base + PC)
        ZetCPUContext[nOpenedCPU]->Z80SP_BASE=Doze.Z80SP_BASE;      // 0x20 - SP Stack Pointer (Memory Base)
        ZetCPUContext[nOpenedCPU]->Z80IX=Doze.Z80IX;           // 0x24 - IX Index Register
        ZetCPUContext[nOpenedCPU]->Z80IY=Doze.Z80IY;           // 0x28 - IY Index Register
        ZetCPUContext[nOpenedCPU]->Z80I=Doze.Z80I;// 0x2C - I Interrupt Register
        ZetCPUContext[nOpenedCPU]->Z80A2=Doze.Z80A2;// 0x30 - A' Register:    0xAA------
        ZetCPUContext[nOpenedCPU]->Z80F2=Doze.Z80F2;// 0x34 - F' Register:    0x------FF
        ZetCPUContext[nOpenedCPU]->Z80BC2=Doze.Z80BC2;// 0x38 - B'C' Registers: 0xBBCC----
        ZetCPUContext[nOpenedCPU]->Z80DE2=Doze.Z80DE2;// 0x3C - D'E' Registers: 0xDDEE----
        ZetCPUContext[nOpenedCPU]->Z80HL2=Doze.Z80HL2;// 0x40 - H'L' Registers: 0xHHLL----
        ZetCPUContext[nOpenedCPU]->Z80_IRQ=Doze.Z80_IRQ;        // 0x44 - Set IRQ Number
        ZetCPUContext[nOpenedCPU]->Z80IF=Doze.Z80IF;// 0x45 - Interrupt Flags:  bit1=_IFF1, bit2=_IFF2, bit3=_HALT
        ZetCPUContext[nOpenedCPU]->Z80IM=Doze.Z80IM;// 0x46 - Set IRQ Mode
        ZetCPUContext[nOpenedCPU]->spare=Doze.spare;// 0x47 - N/A
        ZetCPUContext[nOpenedCPU]->z80irqvector=Doze.z80irqvector;// 0x48 - Set IRQ Vector i.e. 0xFF=RST

        ZetCPUContext[nOpenedCPU]->nEI=Doze.nEI;
        ZetCPUContext[nOpenedCPU]->nCyclesLeft=Doze.nCyclesLeft;
        ZetCPUContext[nOpenedCPU]->nCyclesTotal=Doze.nCyclesTotal;
        ZetCPUContext[nOpenedCPU]->nCyclesSegment=Doze.nCyclesSegment;
        ZetCPUContext[nOpenedCPU]->nInterruptLatch=Doze.nInterruptLatch;

        ZetCPUContext[nOpenedCPU]->z80_irq_callback=Doze.z80_irq_callback;

  //void (*z80_write8 )(unsigned char d,unsigned short a);
        ZetCPUContext[nOpenedCPU]->z80_write8=Doze.z80_write8;
        ZetCPUContext[nOpenedCPU]->z80_write16=Doze.z80_write16;
        ZetCPUContext[nOpenedCPU]->z80_in=Doze.z80_in;
        ZetCPUContext[nOpenedCPU]->z80_out=Doze.z80_out;
        ZetCPUContext[nOpenedCPU]->z80_read8=Doze.z80_read8;
        ZetCPUContext[nOpenedCPU]->z80_read16=Doze.z80_read16;

        ZetCPUContext[nOpenedCPU]->z80_rebaseSP=Doze.z80_rebaseSP;
        ZetCPUContext[nOpenedCPU]->z80_rebasePC=Doze.z80_rebasePC;

        ZetCPUContext[nOpenedCPU]->ppMemFetch=Doze.ppMemFetch;
        ZetCPUContext[nOpenedCPU]->ppMemFetchData=Doze.ppMemFetchData;
        ZetCPUContext[nOpenedCPU]->ppMemRead=Doze.ppMemRead;
        ZetCPUContext[nOpenedCPU]->ppMemWrite=Doze.ppMemWrite;

        ZetCPUContext[nOpenedCPU]->debugCallback=Doze.debugCallback;

	}
	else
	{
	    	Z80GetContext(&ZetCPUContext[nOpenedCPU]->reg);
	nZetCyclesDone[nOpenedCPU] = nZetCyclesTotal;
	nZ80ICount[nOpenedCPU] = z80_ICount;
	Z80EA[nOpenedCPU] = EA;

	}
	nOpenedCPU = -1;
}

void ZetOpen(int nCPU)
{
    if (nCPU>=nCPUCount) ZetInit(nCPU);
    if (cpucore[nCPU]==0)
	{
	    Doze.Z80A=ZetCPUContext[nCPU]->Z80A;     // 0x00 - A Register:   0xAA------
        Doze.Z80F=ZetCPUContext[nCPU]->Z80F;            // 0x04 - F Register:   0x------FF
        Doze.Z80BC=ZetCPUContext[nCPU]->Z80BC;           // 0x08 - BC Registers: 0xBBCC----
        Doze.Z80DE=ZetCPUContext[nCPU]->Z80DE;           // 0x0C - DE Registers: 0xDDEE----
        Doze.Z80HL=ZetCPUContext[nCPU]->Z80HL;           // 0x10 - HL Registers: 0xHHLL----
        Doze.Z80PC=ZetCPUContext[nCPU]->Z80PC; // 0x14 - PC Program Counter (Memory Base + PC)
        Doze.Z80PC_BASE=ZetCPUContext[nCPU]->Z80PC_BASE;      // 0x18 - PC Program Counter (Memory Base)
        Doze.Z80SP=ZetCPUContext[nCPU]->Z80SP;           // 0x1C - SP Stack Pointer (Memory Base + PC)
        Doze.Z80SP_BASE=ZetCPUContext[nCPU]->Z80SP_BASE;      // 0x20 - SP Stack Pointer (Memory Base)
        Doze.Z80IX=ZetCPUContext[nCPU]->Z80IX;           // 0x24 - IX Index Register
        Doze.Z80IY=ZetCPUContext[nCPU]->Z80IY;           // 0x28 - IY Index Register
        Doze.Z80I=ZetCPUContext[nCPU]->Z80I;// 0x2C - I Interrupt Register
        Doze.Z80A2=ZetCPUContext[nCPU]->Z80A2;// 0x30 - A' Register:    0xAA------
        Doze.Z80F2=ZetCPUContext[nCPU]->Z80F2;// 0x34 - F' Register:    0x------FF
        Doze.Z80BC2=ZetCPUContext[nCPU]->Z80BC2;// 0x38 - B'C' Registers: 0xBBCC----
        Doze.Z80DE2=ZetCPUContext[nCPU]->Z80DE2;// 0x3C - D'E' Registers: 0xDDEE----
        Doze.Z80HL2=ZetCPUContext[nCPU]->Z80HL2;// 0x40 - H'L' Registers: 0xHHLL----
        Doze.Z80_IRQ=ZetCPUContext[nCPU]->Z80_IRQ;        // 0x44 - Set IRQ Number
        Doze.Z80IF=ZetCPUContext[nCPU]->Z80IF;// 0x45 - Interrupt Flags:  bit1=_IFF1, bit2=_IFF2, bit3=_HALT
        Doze.Z80IM=ZetCPUContext[nCPU]->Z80IM;// 0x46 - Set IRQ Mode
        Doze.spare=ZetCPUContext[nCPU]->spare;// 0x47 - N/A
        Doze.z80irqvector=ZetCPUContext[nCPU]->z80irqvector;// 0x48 - Set IRQ Vector i.e. 0xFF=RST

        Doze.nEI=ZetCPUContext[nCPU]->nEI;
        Doze.nCyclesLeft=ZetCPUContext[nCPU]->nCyclesLeft;
        Doze.nCyclesTotal=ZetCPUContext[nCPU]->nCyclesTotal;
        Doze.nCyclesSegment=ZetCPUContext[nCPU]->nCyclesSegment;
        Doze.nInterruptLatch=ZetCPUContext[nCPU]->nInterruptLatch;

        Doze.z80_irq_callback=ZetCPUContext[nCPU]->z80_irq_callback;

  //void (*z80_write8 )(unsigned char d,unsigned short a);
        Doze.z80_write8=ZetCPUContext[nCPU]->z80_write8;
        Doze.z80_write16=ZetCPUContext[nCPU]->z80_write16;
        Doze.z80_in=ZetCPUContext[nCPU]->z80_in;
        Doze.z80_out=ZetCPUContext[nCPU]->z80_out;
        Doze.z80_read8=ZetCPUContext[nCPU]->z80_read8;
        Doze.z80_read16=ZetCPUContext[nCPU]->z80_read16;

        Doze.z80_rebaseSP=ZetCPUContext[nCPU]->z80_rebaseSP;
        Doze.z80_rebasePC=ZetCPUContext[nCPU]->z80_rebasePC;

        Doze.ppMemFetch=ZetCPUContext[nCPU]->ppMemFetch;
        Doze.ppMemFetchData=ZetCPUContext[nCPU]->ppMemFetchData;
        Doze.ppMemRead=ZetCPUContext[nCPU]->ppMemRead;
        Doze.ppMemWrite=ZetCPUContext[nCPU]->ppMemWrite;

        Doze.debugCallback=ZetCPUContext[nCPU]->debugCallback;

	}
	else
	{
    Z80SetContext(&ZetCPUContext[nCPU]->reg);
	nZetCyclesTotal = nZetCyclesDone[nCPU];
	z80_ICount = nZ80ICount[nCPU];
	EA = Z80EA[nCPU];
	}


	nOpenedCPU = nCPU;

}

int ZetSetVector(int vector) //needs implementing
{
    if (cpucore[nOpenedCPU]==0)
    //printf("call to ZetSetVector\n");
    Doze.Z80I|=((vector<<8) & 0xFF00);
    else
    Z80Vector = vector;
    return 0;
}

void ZetSetBUSREQLine(int nStatus) //needs implementing
{
    if (cpucore[nOpenedCPU]==0)
    printf("call to ZetSetBUSREQLine\n");
    else
    {
    	if (nOpenedCPU < 0) return;

        ZetCPUContext[nOpenedCPU]->BusReq = nStatus;
    }


}

void ZetRaiseIrq(int n)
{
    ZetSetIRQLine(n, ZET_IRQSTATUS_AUTO);
}

void ZetLowerIrq()
{
    if (cpucore[nOpenedCPU]==0)
    ZetSetIRQLine(0, ZET_IRQSTATUS_NONE);
    else
    ZetSetIRQLine(0, Z80_CLEAR_LINE);
}


void ZetSetIRQLine(const int line, const int status)
{
    if (cpucore[nOpenedCPU]==0)
    {
        Doze.nInterruptLatch = line | status;
    }
    else
    {
        if (status == ZET_IRQSTATUS_NONE) zZ80SetIrqLine(0, 0);
		if (status == ZET_IRQSTATUS_ACK )zZ80SetIrqLine(line, 1);
		if (status == ZET_IRQSTATUS_AUTO)
		{
			zZ80SetIrqLine(line, 1);
			Z80Execute(0);
			zZ80SetIrqLine(0, 0);
			Z80Execute(0);
		}
	}


}

void Z80SetIrqLine(int irqline, int state)
{
    if (cpucore[nOpenedCPU]==0)
    ZetSetIRQLine(irqline,state);
    else
    zZ80SetIrqLine(irqline, state);
}

int ZetGetActive()
{
    return nOpenedCPU;
}

#ifdef EMU_DRZ80

void DozeAsmCall(unsigned short a)
{
	//printf("DozeAsmCall(0x%04x); PC: 0x%04x SP: 0x%04x\n", a, Doze.Z80PC-Doze.Z80PC_BASE, Doze.Z80SP);

	int pc = Doze.Z80PC-Doze.Z80PC_BASE;

	Doze.Z80SP -= 2;
	Doze.Z80SP &=0xFFFF;

	unsigned char * p = Doze.ppMemWrite[ (Doze.Z80SP >> 8) ];
	//printf("dozez80 %d %d\n",Doze.Z80SP,(Doze.Z80SP >> 8));
	if ( p ) {
		p += Doze.Z80SP;
		*p = pc & 0xff;
		p++;
		*p = pc >> 8;
		//*((unsigned char *)Doze.Z80SP) = pc & 0xff;
		//*((unsigned char *)(Doze.Z80SP+1)) = pc >> 8;
	} else {

		printf("DozeAsmCall Error PUSH PC!\n");
	}

	Doze.Z80PC  = Doze.z80_rebasePC( a );

	//IFLOG printf("-> 0x%04x 0x%04x\n", Doze.Z80PC-Doze.Z80PC_BASE, Doze.Z80SP);
}

static unsigned char DozeAsmRead(int a)
{
	unsigned char * p = Doze.ppMemRead[ a >> 8 ];
	if ( p )
		return *(p + a);
	else
		return 0; // Doze.ReadHandler(a);
}

static int Interrupt(int nVal)
{
	//if ((Z80.Z80IF & 0x03) == 0) 					// ????
	if ((Doze.Z80IF & 0xFF) == 0) 					// not enabled
		return 0;

	//IFLOG printf("    IRQ taken  nIF: %02x  nIM: %02x PC: 0x%04x OpCode: 0x%02x\n", Doze.Z80IF, Doze.Z80IM, Doze.Z80PC-Doze.Z80PC_BASE, DozeAsmRead(Doze.Z80PC-Doze.Z80PC_BASE) );

	if ( DozeAsmRead(Doze.Z80PC-Doze.Z80PC_BASE) == 0x76 )
		Doze.Z80PC ++;

	Doze.Z80IF = 0;

	if (Doze.Z80IM == 0) {
		DozeAsmCall((unsigned short)(nVal & 0x38));	// rst nn
		return 13;									// cycles done
	} else {
		if (Doze.Z80IM == 2) {
			int nTabAddr = 0, nIntAddr = 0;
printf("Doze.Z80IM == 2\n");
			// Get interrupt address from table (I points to the table)
			nTabAddr = (Doze.Z80I & 0xFF00) + nVal;

			// Read 16-bit table value
			nIntAddr  = DozeAsmRead((unsigned short)(nTabAddr + 1)) << 8;
			nIntAddr |= DozeAsmRead((unsigned short)(nTabAddr));

			DozeAsmCall((unsigned short)(nIntAddr));
			return 19;								// cycles done
		} else {
			DozeAsmCall(0x38);						// rst 38h
			return 13;								// cycles done
		}
	}
}

static inline void TryInt()
{
	int nDid;

	if (Doze.nInterruptLatch & ZET_IRQSTATUS_NONE) return;

	nDid = Interrupt(Doze.nInterruptLatch & 0xFF);	// Success! we did some cycles, and took the interrupt
	if (nDid > 0 && (Doze.nInterruptLatch & ZET_IRQSTATUS_AUTO)) {
		Doze.nInterruptLatch = ZET_IRQSTATUS_NONE;
	}

	Doze.nCyclesLeft -= nDid;
}

static void DozeRun()
{
	TryInt();
    //printf("dcycles: %d\n",Doze.nCyclesLeft);
	if (Doze.nCyclesLeft < 0) {
		//printf("DozeRun() -- (nCyclesLeft < 0)\n");
		return;
	}

	if (DozeAsmRead(Doze.Z80PC-Doze.Z80PC_BASE) == 0x76) {

		//IFLOG printf("DozeRun() -- (*pc == 0x76)\n");

		// cpu is halted (repeatedly doing halt inst.)
		int nDid = (Doze.nCyclesLeft >> 2) + 1;
		Doze.Z80I = (unsigned short)(((Doze.Z80I + nDid) & 0x7F) | (Doze.Z80I & 0xFF80)); // Increase R register
		Doze.nCyclesLeft -= nDid;
		return;
	}

	// Find out about mid-exec EIs
	Doze.nEI = 1;
	//for (int tst=0;tst<(Doze.nCyclesLeft>>2);tst++)
	//{
    //    printf("entering drz80 hl=%d de=%d bc=%d mematpc=%d sp=%d\n",Doze.Z80HL >> 16,Doze.Z80DE >> 16,Doze.Z80BC >> 16,z80_read8(Doze.Z80PC-Doze.Z80PC_BASE),Doze.Z80SP);
    //    DrZ80Run(&Doze, 4);
	//}
	DrZ80Run(&Doze, Doze.nCyclesLeft);

#if 0
	IFLOG printf("CyclesLeft %d\n", Doze.nCyclesLeft );
	IFLOG printf(" AF: 0x%04x BC: 0x%04x DE: 0x%04x HL: 0x%04x\n", Doze.Z80A >> 16 | Doze.Z80F, Doze.Z80BC >> 16,  Doze.Z80DE >> 16,  Doze.Z80HL >> 16 );
	IFLOG printf(" AF' 0x%04x BC' 0x%04x DE' 0x%04x HL' 0x%04x\n", Doze.Z80A2 >> 16 | Doze.Z80F2, Doze.Z80BC2 >> 16,  Doze.Z80DE2 >> 16,  Doze.Z80HL2 >> 16 );
	IFLOG printf(" IX: 0x%04x IY: 0x%04x PC: 0x%04x SP: 0x%04x\n", Doze.Z80IX >> 16,  Doze.Z80IY >> 16,  Doze.Z80PC-Doze.Z80PC_BASE,  Doze.Z80SP );
	IFLOG printf(" IR: 0x%08x IF: 0x%02x IM: 0x%02x\n", Doze.Z80I,  Doze.Z80IF,  Doze.Z80IM );
#endif

//IFLOG printf("Find out about mid-exec EIs: 0x%08x\n", Doze.nEI );

	// Just enabled interrupts
	while (Doze.nEI == 2) {


		//printf("    EI executed\n");
		// (do one more instruction before interrupt)
		int nTodo = Doze.nCyclesLeft;
		Doze.nCyclesLeft = 0;
		Doze.nEI = 0;

		DrZ80Run(&Doze, Doze.nCyclesLeft);

#if 0
	IFLOG printf("CyclesLeft %d\n", Doze.nCyclesLeft );
	IFLOG printf(" AF: 0x%04x BC: 0x%04x DE: 0x%04x HL: 0x%04x\n", Doze.Z80A >> 16 | Doze.Z80F, Doze.Z80BC >> 16,  Doze.Z80DE >> 16,  Doze.Z80HL >> 16 );
	IFLOG printf(" AF' 0x%04x BC' 0x%04x DE' 0x%04x HL' 0x%04x\n", Doze.Z80A2 >> 16 | Doze.Z80F2, Doze.Z80BC2 >> 16,  Doze.Z80DE2 >> 16,  Doze.Z80HL2 >> 16 );
	IFLOG printf(" IX: 0x%04x IY: 0x%04x PC: 0x%04x SP: 0x%04x\n", Doze.Z80IX >> 16,  Doze.Z80IY >> 16,  Doze.Z80PC-Doze.Z80PC_BASE,  Doze.Z80SP );
	IFLOG printf(" IR: 0x%08x IF: 0x%02x IM: 0x%02x\n", Doze.Z80I,  Doze.Z80IF,  Doze.Z80IM );
#endif

		Doze.nCyclesLeft += nTodo;

		TryInt();

		// And continue the rest of the exec
		DrZ80Run(&Doze, Doze.nCyclesLeft);
#if 0
	IFLOG printf("CyclesLeft %d\n", Doze.nCyclesLeft );
	IFLOG printf(" AF: 0x%04x BC: 0x%04x DE: 0x%04x HL: 0x%04x\n", Doze.Z80A >> 16 | Doze.Z80F, Doze.Z80BC >> 16,  Doze.Z80DE >> 16,  Doze.Z80HL >> 16 );
	IFLOG printf(" AF' 0x%04x BC' 0x%04x DE' 0x%04x HL' 0x%04x\n", Doze.Z80A2 >> 16 | Doze.Z80F2, Doze.Z80BC2 >> 16,  Doze.Z80DE2 >> 16,  Doze.Z80HL2 >> 16 );
	IFLOG printf(" IX: 0x%04x IY: 0x%04x PC: 0x%04x SP: 0x%04x\n", Doze.Z80IX >> 16,  Doze.Z80IY >> 16,  Doze.Z80PC-Doze.Z80PC_BASE,  Doze.Z80SP );
	IFLOG printf(" IR: 0x%08x IF: 0x%02x IM: 0x%02x\n", Doze.Z80I,  Doze.Z80IF,  Doze.Z80IM );
#endif

	}

//IFLOG printf("DozeRun(); %d  PC: %04x  PS: %04x\n", Doze.nCyclesLeft, Doze.Z80PC - Doze.Z80PC_BASE, Doze.Z80SP );
}

#endif

int ZetRun(int nCycles)
{
    //printf("cycles: %d\n",nCycles);
	if (nCycles <= 0) {
		return 0;
	}

//	DaveZ80EnterCPU(ZetCPUContext[nOpenedCPU]->pZetMemMap[0], ZetCPUContext[nOpenedCPU]);

//	printf("ocpu %d\n",nCPUCount);
    if (cpucore[nOpenedCPU]==0)
    {
	Doze.nCyclesTotal += nCycles;
	Doze.nCyclesSegment = nCycles;
	Doze.nCyclesLeft = nCycles;

	DozeRun();
	nCycles = Doze.nCyclesSegment - Doze.nCyclesLeft;

	Doze.nCyclesTotal -= Doze.nCyclesLeft;
	Doze.nCyclesLeft = 0;
	Doze.nCyclesSegment = 0;
    }
    else
    {
        if (ZetCPUContext[nOpenedCPU]->BusReq) {
		nZetCyclesTotal += nCycles;
		return nCycles;
        }

	nCycles = Z80Execute(nCycles);

	nZetCyclesTotal += nCycles;

    }

	return nCycles;
}

void ZetRunAdjust(int nCycles)
{
	//printf("ZetRunAdjust(%d);\n", nCycles);
    if (cpucore[nOpenedCPU]==0)
    {
	if (nCycles < 0 && Doze.nCyclesLeft < -nCycles) {
		nCycles = 0;
	}

	Doze.nCyclesTotal += nCycles;
	Doze.nCyclesSegment += nCycles;
	Doze.nCyclesLeft += nCycles;
    }
}

void ZetRunEnd()
{
//	printf("ZetRunEnd();\n");
    if (cpucore[nOpenedCPU]==0)
    {
	Doze.nCyclesTotal -= Doze.nCyclesLeft;
	Doze.nCyclesSegment -= Doze.nCyclesLeft;
	Doze.nCyclesLeft = 0;
    }
}

// This function will make an area callback ZetRead/ZetWrite
int ZetMemCallback(int nStart, int nEnd, int nMode)
{
//	printf("ZetMemCallback(0x%04x, 0x%04x, %d);\n", nStart, nEnd, nMode);
    if (cpucore[nOpenedCPU]==0)
    {
	nStart >>= 8;
	nEnd += 0xff;
	nEnd >>= 8;

	// Leave the section out of the memory map, so the Doze* callback with be used
	for (int i = nStart; i < nEnd; i++) {
		switch (nMode) {
			case 0:
				Doze.ppMemRead[i] = NULL;
				break;
			case 1:
				Doze.ppMemWrite[i] = NULL;
				break;
			case 2:
				Doze.ppMemFetch[i] = NULL;
				break;
		}
	}
    }
    else
    {
    UINT8 cStart = (nStart >> 8);
	UINT8 **pMemMap = ZetCPUContext[nOpenedCPU]->pZetMemMap;

	for (UINT16 i = cStart; i <= (nEnd >> 8); i++) {
		switch (nMode) {
			case 0:
				pMemMap[0     + i] = NULL;
				break;
			case 1:
				pMemMap[0x100 + i] = NULL;
				break;
			case 2:
				pMemMap[0x200 + i] = NULL;
				pMemMap[0x300 + i] = NULL;
				break;
		}
	}

    }

	return 0;
}

int ZetMemEnd()
{
    if (cpucore[nOpenedCPU]==0) z80_rebasePC(0);
	return 0;
}

void ZetExit()
{
    if (cpucore[nOpenedCPU]==0)
    {
	for (int i = 0; i < nCPUCount; i++) {
		free(ZetCPUContext[i]->ppMemFetch);
		ZetCPUContext[i]->ppMemFetch = NULL;
		free(ZetCPUContext[i]->ppMemFetchData);
		ZetCPUContext[i]->ppMemFetchData = NULL;
		free(ZetCPUContext[i]->ppMemRead);
		ZetCPUContext[i]->ppMemRead = NULL;
		free(ZetCPUContext[i]->ppMemWrite);
		ZetCPUContext[i]->ppMemWrite = NULL;
		BurnFree (ZetCPUContext[i])
	}

	//free(ZetCPUContext);
	//ZetCPUContext = NULL;
	//memset(&Doze, 0, sizeof(Doze));
	nCPUCount = 0;
    }
    else
    {
        	Z80Exit();

	for (INT32 i = 0; i < MAX_Z80; i++) {
		if (ZetCPUContext[i]) {
			BurnFree (ZetCPUContext[i]);
		}
	}

	nCPUCount = 0;
	nHasZet = -1;

	DebugCPU_ZetInitted = 0;

    }
}

int ZetMapArea(int nStart, int nEnd, int nMode, unsigned char *Mem)
{
	//printf("ZetMapArea(0x%04x, 0x%04x, %d, %p);\n", nStart, nEnd, nMode, Mem);
    if (cpucore[nOpenedCPU]==0)
    {
	int s = nStart >> 8;
	int e = (nEnd + 0xFF) >> 8;

	// Put this section in the memory map, giving the offset from Z80 memory to PC memory
	for (int i = s; i < e; i++) {
		switch (nMode) {
			case 0:
				Doze.ppMemRead[i] = Mem - nStart;
				break;
			case 1:
				Doze.ppMemWrite[i] = Mem - nStart;
				break;
			case 2:
				Doze.ppMemFetch[i] = Mem - nStart;
				Doze.ppMemFetchData[i] = Mem - nStart;
				break;
		}
	}
    }
    else
    {
    UINT8 cStart = (nStart >> 8);
	UINT8 **pMemMap = ZetCPUContext[nOpenedCPU]->pZetMemMap;

	for (UINT16 i = cStart; i <= (nEnd >> 8); i++) {
		switch (nMode) {
			case 0: {
				pMemMap[0     + i] = Mem + ((i - cStart) << 8);
				break;
			}

			case 1: {
				pMemMap[0x100 + i] = Mem + ((i - cStart) << 8);
				break;
			}

			case 2: {
				pMemMap[0x200 + i] = Mem + ((i - cStart) << 8);
				pMemMap[0x300 + i] = Mem + ((i - cStart) << 8);
				break;
			}
		}
	}

    }

	return 0;
}

int ZetMapArea(int nStart, int nEnd, int nMode, unsigned char *Mem01, unsigned char *Mem02)
{
    if (cpucore[nOpenedCPU]==0)
    {
	//printf("ZetMapArea(0x%04x, 0x%04x, %d, %p, %p);\n", nStart, nEnd, nMode, Mem01, Mem02);

	int s = nStart >> 8;
	int e = (nEnd + 0xFF) >> 8;

	if (nMode != 2) {
		return 1;
	}

	// Put this section in the memory map, giving the offset from Z80 memory to PC memory
	for (int i = s; i < e; i++) {
		Doze.ppMemFetch[i] = Mem01 - nStart;
		Doze.ppMemFetchData[i] = Mem02 - nStart;
	}
    }
    else
    {
    UINT8 cStart = (nStart >> 8);
	UINT8 **pMemMap = ZetCPUContext[nOpenedCPU]->pZetMemMap;

	if (nMode != 2) {
		return 1;
	}

	for (UINT16 i = cStart; i <= (nEnd >> 8); i++) {
		pMemMap[0x200 + i] = Mem01 + ((i - cStart) << 8);
		pMemMap[0x300 + i] = Mem02 + ((i - cStart) << 8);
	}

    }

	return 0;
}

int ZetReset()
{
	//printf("ZetReset();\n");
	if (cpucore[nOpenedCPU]==0)
    {

	Doze.spare			= 0;
	Doze.z80irqvector	= 0;

  	Doze.Z80A			= 0x00 <<24;
  	Doze.Z80F			= (1<<2); /* set ZFlag */
  	Doze.Z80BC			= 0x0000<<16;
  	Doze.Z80DE			= 0x0000<<16;
  	Doze.Z80HL			= 0x0000<<16;
  	Doze.Z80A2			= 0x00<<24;
  	Doze.Z80F2			= 1<<2;  /* set ZFlag */
  	Doze.Z80BC2			= 0x0000<<16;
  	Doze.Z80DE2			= 0x0000<<16;
  	Doze.Z80HL2			= 0x0000<<16;
  	Doze.Z80IX			= 0xFFFF<<16;
  	Doze.Z80IY			= 0xFFFF<<16;
	Doze.Z80I			= 0x00;
  	Doze.Z80IM			= 0x00;
  	Doze.Z80_IRQ		= 0x00;
  	Doze.Z80IF			= 0x00;
  	Doze.Z80PC			= Doze.z80_rebasePC(0);
  	//Doze.Z80SP			= 0Doze.z80_rebaseSP(0xffff); /* 0xf000 */
  	Doze.Z80SP			= 0x0000;

  	//Doze.nInterruptLatch = 0;
  	//Doze.nEI			= 0;
  	//Doze.nCyclesLeft	= 0;
  	//Doze.nCyclesTotal	= 0;
  	//Doze.nCyclesSegment	= 0;
    }
    else Z80Reset();

	return 0;
}


int ZetNmi()
{
//	printf("ZetNmi();\n");

    if (cpucore[nOpenedCPU]==0)
    {

	//Doze.iff &= 0xFF00;						// reset iff1
	//DozeAsmCall((unsigned short)0x66);		// Do nmi
	Doze.Z80IF &= 0x02;						// reset iff1
	DozeAsmCall((unsigned short)0x66);		// Do nmi
	Doze.nCyclesTotal += 12;
	return 12;
    }
    else
    {
    Z80SetIrqLine(Z80_INPUT_LINE_NMI, 1);
	Z80Execute(0);
	Z80SetIrqLine(Z80_INPUT_LINE_NMI, 0);
	Z80Execute(0);
	INT32 nCycles = 12;
	nZetCyclesTotal += nCycles;

	return nCycles;

    }
    return 0;
}


int ZetPc(int n)
{
	//printf("ZetPc(%d);\n", n);
	if (cpucore[nOpenedCPU]==0)
    {
	if (n < 0) {
		return Doze.Z80PC - Doze.Z80PC_BASE;
	} else {
		return ZetCPUContext[n]->Z80PC -ZetCPUContext[n]->Z80PC_BASE;
	}
	return Doze.Z80PC - Doze.Z80PC_BASE;
    }
    else
    {
        if (n < 0) {
		return ActiveZ80GetPC();
        } else {
		return ZetCPUContext[n]->reg.pc.w.l;
	}

    }
    return 0;
}

int ZetScan(int nAction)
{
	//printf("ZetScan(%d);\n", nAction);


	if ((nAction & ACB_DRIVER_DATA) == 0) {
		return 0;
	}

	char szText[] = "Z80 #0";
	for (int i = 0; i < nCPUCount; i++) {
		szText[5] = '1' + i;
        if (cpucore[nOpenedCPU]==0)
        ScanVar(&Doze, 19 * 4 + 16, szText);
        else
        {
        ScanVar(&ZetCPUContext[i]->reg, sizeof(Z80_Regs), szText);
		SCAN_VAR(Z80EA[i]);
		SCAN_VAR(nZ80ICount[i]);
		SCAN_VAR(nZetCyclesDone[i]);

        }
	}
	if (cpucore[nOpenedCPU]==1) SCAN_VAR(nZetCyclesTotal);


	return 0;
}

INT32 ZetIdle(INT32 nCycles)
{
#if defined FBA_DEBUG
	if (!DebugCPU_ZetInitted) bprintf(PRINT_ERROR, _T("ZetIdle called without init\n"));
	if (nOpenedCPU == -1) bprintf(PRINT_ERROR, _T("ZetIdle called when no CPU open\n"));
#endif
    if (cpucore[nOpenedCPU]==0)
    Doze.nCyclesTotal += nCycles;
    else
	nZetCyclesTotal += nCycles;

	return nCycles;
}

INT32 ZetSegmentCycles()
{
#if defined FBA_DEBUG
	if (!DebugCPU_ZetInitted) bprintf(PRINT_ERROR, _T("ZetSegmentCycles called without init\n"));
	if (nOpenedCPU == -1) bprintf(PRINT_ERROR, _T("ZetSegmentCycles called when no CPU open\n"));
#endif
    if (cpucore[nOpenedCPU]==0)
    return Doze.nCyclesSegment - Doze.nCyclesLeft;
    else
	return 0;
}

INT32 ZetTotalCycles()
{
#if defined FBA_DEBUG
	if (!DebugCPU_ZetInitted) bprintf(PRINT_ERROR, _T("ZetTotalCycles called without init\n"));
	if (nOpenedCPU == -1) bprintf(PRINT_ERROR, _T("ZetTotalCycles called when no CPU open\n"));
#endif
    if (cpucore[nOpenedCPU]==0)
    return Doze.nCyclesTotal - Doze.nCyclesLeft;
    else
	return nZetCyclesTotal;
}
