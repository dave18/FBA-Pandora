// Z80 (Zed Eight-Ty) Interface
//#define EMU_DOZE					// Use Dave's 'Doze' Assembler Z80 emulator
#define EMU_DRZ80					// Use Reesy's Assembler Z80 Emulator
#define EMU_DAVEZ80

#ifdef EMU_DOZE
 #include "doze.h"
#endif

#ifdef EMU_DRZ80
 #include "DrZ80.h"



 extern struct DrZ80 Doze;

extern int ZET_IRQSTATUS_NONE;
extern int ZET_IRQSTATUS_ACK;
extern int ZET_IRQSTATUS_AUTO;


#endif

#ifdef EMU_DAVEZ80
 #include "davez80.h"
#endif

#include "z80.h"

extern int nHasZet;
int ZetInit(int nCount);
void ZetExit();
void ZetNewFrame();
void ZetOpen(int nCPU);
void ZetClose();
int ZetMemCallback(int nStart,int nEnd,int nMode);
int ZetMemEnd();
int ZetMapArea(int nStart, int nEnd, int nMode, unsigned char *Mem);
int ZetMapArea(int nStart, int nEnd, int nMode, unsigned char *Mem01, unsigned char *Mem02);
int ZetReset();
int ZetPc(int n);
int ZetScan(int nAction);
unsigned char ZetReadByte(unsigned short a);
void ZetWriteRom(unsigned short a,unsigned char d);
void ZetWriteByte(unsigned short a,unsigned char d);
int ZetGetActive();
void Z80SetIrqLine(const int line, const int status);
int ZetSetVector(int irq);
void ZetSetBUSREQLine(int i);
unsigned char ZetBc(int n);
unsigned char ZetHL(int n);
unsigned char ZetDe(int n);


#if defined(EMU_DOZE)
#define ZET_IRQSTATUS_NONE DOZE_IRQSTATUS_NONE
#define ZET_IRQSTATUS_AUTO DOZE_IRQSTATUS_AUTO
#define ZET_IRQSTATUS_ACK  DOZE_IRQSTATUS_ACK


#endif

#ifndef EMU_DRZ80

inline static int ZetNmi()
{
#ifdef EMU_DOZE
	int nCycles = DozeNmi();
	Doze.nCyclesTotal += nCycles;
	return nCycles
#else
	return 12;
#endif
}

#else

int ZetNmi();

#endif

void ZetSetIRQLine(const int line, const int status);
void Z80SetIrqLine(int irqline, int state);
/*
inline static void ZetSetIRQLine(const int line, const int status)
{
#if defined(EMU_DOZE) || defined(EMU_DRZ80)
	Doze.nInterruptLatch = line | status;
#endif
}*/

void ZetRaiseIrq(int n);
void ZetLowerIrq();

int ZetRun(int nCycles);
void ZetRunEnd();
int ZetIdle(int nCycles);
int ZetSegmentCycles();
int ZetTotalCycles();
/*
inline static int ZetIdle(int nCycles)
{
#if defined(EMU_DOZE) || defined(EMU_DRZ80)
	Doze.nCyclesTotal += nCycles;
#endif
	return nCycles;
}*/
/*
inline static int ZetSegmentCycles()
{
#if defined(EMU_DOZE) || defined(EMU_DRZ80)
	return Doze.nCyclesSegment - Doze.nCyclesLeft;
#else
	return 0;
#endif
}*/

/*inline static int ZetTotalCycles()
{
#if defined(EMU_DOZE) || defined(EMU_DRZ80)
	return Doze.nCyclesTotal - Doze.nCyclesLeft;
#else
	return 0;
#endif
}*/

void ZetSetReadHandler(unsigned char (__fastcall *pHandler)(unsigned short));
void ZetSetWriteHandler(void (__fastcall *pHandler)(unsigned short, unsigned char));
void ZetSetInHandler(unsigned char (__fastcall *pHandler)(unsigned short));
void ZetSetOutHandler(void (__fastcall *pHandler)(unsigned short, unsigned char));
