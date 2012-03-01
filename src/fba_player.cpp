/*
 * FinalBurn Alpha for MOTO EZX Modile Phone
 * Copyright (C) 2006 OopsWare. CHINA.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * $Id: fba_player.cpp,v 0.10 2006/12/03 $
 */

#define CALC_FPS

#include <stdio.h>
#include <stdlib.h>
#include "fba_player.h"
#include "ezxaudio.h"
#include "font.h"
#include "snd.h"
//#include "burner.h"

#include "burnint.h"
//#include "gp2xmemfuncs.h"
#include "config.h"
#include "cache.h"
#include "SDL/SDL.h"

#ifndef DRV_NAME
#define DRV_NAME		 (0)
#endif

extern INT32 create_datfile(TCHAR* szFilename, INT32 bType);

extern char nub0[11];
extern char nub1[11];

extern "C"
{
#include "pandorasdk.h"
};

void uploadfb(void);
extern char szAppBurnVer[16];

const int fwidth=384;

extern unsigned int nFramesRendered;
static int frame_count = 0;
unsigned int FBA_KEYPAD[4];
signed int FBA_AXIS[4] [4];
unsigned char ServiceRequest = 0;
unsigned char P1P2Start = 0;
unsigned short titlefb[fwidth][240];
extern bool bShowFPS;
void ChangeFrameskip();
extern SDL_Joystick *joys[4];
extern char joyCount;
//extern SDL_Surface* SDL_VideoBuffer;
//extern SDL_Surface* myscreen;
extern CFG_OPTIONS config_options;
extern volatile short *pOutput[];
extern bool bPauseOn;
int pausecnt=0;

int joyMap[8] = {0x0040,0x0080,0x0100,0x0200,0x0400,0x0800,0x10,0x20};
/*struct keymap_item FBA_KEYMAP[] = {
		{"-----",	0, false },
		{"START",	1, false },
		{"COIN",	2, false },
		{"A",		3, false },
		{"B", 		4, false },
		{"C",		5, false },
		{"D",		6, false },
		{"E",		7, false },
		{"F",		8, false },

		{"A+B",		9, false },
		{"C+D",	   10, false },
		{"A+B+C",  11, false },

		{"A-Turbo",	3, true  },
		{"B-Turbo",	4, true  },
		{"C-Turbo",	5, true  },
		{"D-Turbo",	6, true  },
		{"E-Turbo",	7, true  },
		{"F-Turbo",	8, true  } 	};
*/

void do_keypad()
{
	static unsigned int turbo = 0;
	unsigned long joy = gp2x_joystick_read();
	int bVert = (BurnDrvGetFlags() & BDF_ORIENTATION_VERTICAL) && (config_options.option_rescale<=2);
	//int bVert=config_options.option_rescale<=2;
	turbo ++;

	FBA_KEYPAD[0] = 0;
	FBA_KEYPAD[1] = 0;
	FBA_KEYPAD[2] = 0;
	FBA_KEYPAD[3] = 0;
	ServiceRequest =0;
	P1P2Start = 0;

	/*FBA_AXIS[0] [0]=SDL_JoystickGetAxis(0,0);
	FBA_AXIS[0] [1]=SDL_JoystickGetAxis(0,1);
	FBA_AXIS[0] [2]=SDL_JoystickGetAxis(0,2);
	FBA_AXIS[0] [3]=SDL_JoystickGetAxis(0,3);*/

	if ( joy & MY_UP  ) FBA_KEYPAD[0] |= bVert?0x0004:0x0001;
	if ( joy & MY_DOWN  ) FBA_KEYPAD[0] |= bVert?0x0008:0x0002;
	if ( joy & MY_LEFT  ) FBA_KEYPAD[0] |= bVert?0x0002:0x0004;
	if ( joy & MY_RIGHT ) FBA_KEYPAD[0] |= bVert?0x0001:0x0008;

	if ( joy & MY_SELECT )	FBA_KEYPAD[0] |= 0x0010;
	if ( joy & MY_START )		FBA_KEYPAD[0] |= 0x0020;

	if ( joy & MY_BUTT_A )	FBA_KEYPAD[0] |= 0x0040;	// A
	if ( joy & MY_BUTT_X )  FBA_KEYPAD[0] |= 0x0080;	// B
		//if (bVert)
			//ezx_change_volume(1);
		//else
			//FBA_KEYPAD[0] |= 0x0080;	// B
	if ( joy & MY_BUTT_B )	FBA_KEYPAD[0] |= 0x0100;	// C
	if ( joy & MY_BUTT_Y ) FBA_KEYPAD[0] |= 0x0200;	// D
		//if (bVert)
			//ezx_change_volume(-1);
		//else
//			FBA_KEYPAD[0] |= 0x0200;	// D
	if ( joy & MY_BUTT_SL )	FBA_KEYPAD[0] |= 0x0400;						// E
		//if (bVert)
			//FBA_KEYPAD[0] |= 0x0100;
		//else
		//	FBA_KEYPAD[0] |= 0x0400;
	if ( joy & MY_BUTT_SR )	FBA_KEYPAD[0] |= 0x0800;						// F
		//if (bVert)
			//FBA_KEYPAD[0] |= 0x0200;
		//else
			//FBA_KEYPAD[0] |= 0x0800;
	/*if ( joy & MY_VOL_UP )
		if (bVert)
			FBA_KEYPAD[0] |= 0x0040;
		else
			ezx_change_volume(1);
	if ( joy & MY_VOL_DOWN )
		if (bVert)
			FBA_KEYPAD[0] |= 0x0080;
		else
			ezx_change_volume(-1);*/
    if (joy & MY_QT) GameLooping=false;
    if (pausecnt>0) pausecnt--;
    if ((joy & MY_PAUSE) && (pausecnt==0))
    {
        bPauseOn=!bPauseOn;
        pausecnt=20;
        if (config_options.option_sound_enable) SDL_PauseAudio(bPauseOn);
    }
    //if (joy & MY_KS) ServiceRequest=1:
	if ((joy & MY_BUTT_SL) && (joy & MY_BUTT_SR))
	{
		if (joy & MY_BUTT_Y) ChangeFrameskip();
		else
		if (joy & MY_START) GameLooping = false;
		else
		if ( joy & MY_SELECT) ServiceRequest = 1;
		else
		if ( joy & MY_BUTT_X)
		{
		    FILE * filterfile;
		    filterfile=fopen("/etc/pandora/conf/dss_fir/none_up","r");
		    if (filterfile)
		    {
		        int i;
		        char f [161];
		        int tmp;
		        fgets(f,160,filterfile);
		        fgets(f,160,filterfile);
                fread(f,20,8,filterfile);
		        f[160]=0;
                tmp = open("/sys/devices/platform/omapdss/overlay1/filter_coef_up_h", O_WRONLY);
                if (tmp) printf("success %d\n",strlen(f)); else printf("failed\n");
                printf("%d\n",write (tmp,f,strlen(f)+1));
                close(tmp);
                fgets(f,160,filterfile);
                fread(f,20,8,filterfile);
		        f[160]=0;
                tmp = open("/sys/devices/platform/omapdss/overlay1/filter_coef_up_v3", O_WRONLY);
                write (tmp,f,strlen(f)+1);
                close(tmp);
                fgets(f,160,filterfile);
                fread(f,20,8,filterfile);
		        f[160]=0;
                tmp = open("/sys/devices/platform/omapdss/overlay1/filter_coef_up_v5", O_WRONLY);
                write (tmp,f,strlen(f)+1);
                close(tmp);
		        //printf(f);

                fclose(filterfile);


		    }
		}
	}
	else
		if (joy & MY_START && joy & MY_SELECT) P1P2Start = 1;

/*	for (int i=0;i<joyCount;i++)
	{
	int numButtons = joy_buttons(joys[i]);
		if (numButtons > 8)
			numButtons = 8;
		joy_update(joys[i]);
		if(joy_getaxe(JOYUP, joys[i])) FBA_KEYPAD[i] |= bVert?0x0004:0x0001;
		if(joy_getaxe(JOYDOWN, joys[i])) FBA_KEYPAD[i] |= bVert?0x0008:0x0002;
		if(joy_getaxe(JOYLEFT, joys[i])) FBA_KEYPAD[i] |= bVert?0x0002:0x0004;
		if(joy_getaxe(JOYRIGHT, joys[i])) FBA_KEYPAD[i] |= bVert?0x0001:0x0008;

		for (int nButton = 0; nButton < numButtons; nButton++) {
			if(joy_getbutton(nButton, joys[i]))
				FBA_KEYPAD[i] |= joyMap[nButton];
		}
	}*/
}

int DrvInit(int nDrvNum, bool bRestore);
int DrvExit();

int RunReset();
int RunOneFrame(bool bDraw, int fps);

int VideoInit();
void VideoExit();

int InpInit();
int InpExit();
void InpDIP();

extern char szAppRomPath[];
extern int nBurnFPS;
int fps=0;

void show_rom_loading_text(char * szText, int nSize, int nTotalSize)
{
    int pwidth=fwidth;
    int doffset=20;
    if (config_options.option_rescale>=3)
    {
        pwidth=240;
        doffset=0;
    }
	static long long size = 0;
	//printf("!!! %s, %d / %d\n", szText, size + nSize, nTotalSize);

	DrawRect((uint16 *) titlefb, doffset, 120, 300, 20, 0, pwidth);

	if (szText)
		DrawString (szText, (uint16 *) titlefb, doffset, 120, pwidth);

	if (nTotalSize == 0) {
		size = 0;
		DrawRect((uint16 *) titlefb, doffset, 140, 280, 12, 0x00FFFFFF, pwidth);
		DrawRect((uint16 *) titlefb, doffset+1, 141, 278, 10, 0x00808080, pwidth);
	} else {
		size += nSize;
		if (size > nTotalSize) size = nTotalSize;
		DrawRect((uint16 *) titlefb, doffset+1, 141, size * 278 / nTotalSize, 10, 0x00FFFF00, pwidth);
	}

	if (config_options.option_rescale<3) memcpy (VideoBuffer, titlefb, pwidth*240*2); else memcpy (VideoBuffer, titlefb, pwidth*384*2);
	gp2x_video_flip();

}

void show_rom_error_text(char * szText)
{
    int pwidth=fwidth;
    int doffset=20;
    if (config_options.option_rescale>=3)
    {
        pwidth=240;
        doffset=0;
    }
	static long long size = 0;
	//printf("!!! %s, %d / %d\n", szText, size + nSize, nTotalSize);

	DrawRect((uint16 *) titlefb, doffset, 120, 300, 20, 0, pwidth);

    DrawString ("Error loading rom:", (uint16 *) titlefb, doffset, 160, pwidth);
	if (szText)
		DrawString (szText, (uint16 *) titlefb, doffset, 180, pwidth);
    DrawString ("Exiting - press any key", (uint16 *) titlefb, doffset, 200, pwidth);


	if (config_options.option_rescale<3) memcpy (VideoBuffer, titlefb, pwidth*240*2); else memcpy (VideoBuffer, titlefb, pwidth*384*2);
	gp2x_video_flip();
	SDL_Event event;
	SDL_WaitEvent(&event);

}

void CreateCapexLists()
{
    printf("Create rom lists (%d)\n",nBurnDrvCount);
    FILE * zipf;
    FILE * romf;
    zipf=fopen("zipname.fba","w");
    romf=fopen("rominfo.fba","w");
    char * fullname;
    int j;
    for (int i=0;i<nBurnDrvCount;i++)
    {
        nBurnDrvActive=i;
        fullname=(char*)malloc(strlen(BurnDrvGetTextA(DRV_FULLNAME))+1);
        strcpy(fullname,BurnDrvGetTextA(DRV_FULLNAME));
        for (j=0;j<strlen(fullname);j++)
        {
            if (fullname[j]==',') fullname[j]=' ';
        }
        if (BurnDrvGetTextA(DRV_PARENT)) fprintf(romf,"FILENAME( %s %s %s \"%s\" )\n",BurnDrvGetTextA(DRV_NAME),BurnDrvGetTextA(DRV_PARENT),BurnDrvGetTextA(DRV_DATE),BurnDrvGetTextA(DRV_MANUFACTURER)); else fprintf(romf,"FILENAME( %s fba %s \"%s\" )\n",BurnDrvGetTextA(DRV_NAME),BurnDrvGetTextA(DRV_DATE),BurnDrvGetTextA(DRV_MANUFACTURER));
        fprintf(zipf,"%s,%s,%s %s\n",BurnDrvGetTextA(DRV_NAME),fullname,BurnDrvGetTextA(DRV_DATE),BurnDrvGetTextA(DRV_MANUFACTURER));
        free(fullname);
    }
    fclose(zipf);
    fclose(romf);
    char temp[24];
    strcpy(temp,"FBA ");
    strcat(temp,szAppBurnVer);
    strcat(temp,".dat");
    create_datfile(temp, 0);

}

void shutdown()
{
    printf("---- Shutdown Finalburn Alpha plus ----\n\n");
	DrvExit();

	BurnLibExit();

	if (config_options.option_sound_enable)
		SndExit();

	VideoExit();

	InpExit();

	    	if (strcmp(config_options.option_startspeed,config_options.option_selectspeed))
	{
	    printf("resetting cpu speed to %s\n",config_options.option_startspeed);
	    int clk;
	    clk = open("/proc/pandora/cpu_mhz_max", O_WRONLY);
	    write (clk,config_options.option_startspeed,strlen(config_options.option_startspeed)+1);
	    close(clk);

	}

	int tmp;
    tmp = open("/proc/pandora/nub0/mode", O_WRONLY);
    write (tmp,nub0,10);
    close(tmp);
    printf("Revert nub 0 to %s\n",nub0);
    tmp = open("/proc/pandora/nub1/mode", O_WRONLY);
    write (tmp,nub1,10);
    close(tmp);
    printf("Revert nub 1 to %s\n",nub1);

	gp2x_terminate(config_options.option_frontend);


}

void run_fba_emulator(const char *fn)
{
    atexit(shutdown);
    int pwidth=fwidth;
    int doffset=20;
    if (config_options.option_rescale>=3)
    {
        pwidth=240;
        doffset=0;
    }
    if (config_options.option_forcem68k) bBurnUseASMCPUEmulation=false;
    bBurnZ80Core=config_options.option_z80core;
	// process rom path and name
	printf("about to load rom\n");
	char romname[MAX_PATH];
/*	if (BurnCacheInit(fn, romname))
		goto finish;
*/
	strcpy(szAppRomPath, fn);
	char * p = strrchr(szAppRomPath, '/');
	if (p) {
		p++;
		strcpy(romname, p);

		*p = 0;
		p = strrchr(romname, '.');
		if (p) *p = 0;
		else {
			// error
			goto finish;
		}
	} else {
		// error
		goto finish;
	}

    printf("about to burnlibinit()\n");
	BurnLibInit();
	printf("completed burnlibinit()\n");


	// find rom by name
	for (nBurnDrvSelect[0]=0; nBurnDrvSelect[0]<nBurnDrvCount; nBurnDrvSelect[0]++)
	{
	    nBurnDrvActive=nBurnDrvSelect[0];
		if ( strcasecmp(romname, BurnDrvGetTextA(DRV_NAME)) == 0 )
			break;
	}
	if (nBurnDrvSelect[0] >= nBurnDrvCount)
	{
		// unsupport rom ...
		nBurnDrvSelect[0] = ~0U;
		nBurnDrvActive=nBurnDrvSelect[0];
		printf ("rom not supported!\n");
		goto finish;
	}

	if (config_options.option_create_lists)
	{
	    unsigned int tmp=nBurnDrvActive;
	    CreateCapexLists();
	    nBurnDrvActive=tmp;
	}

	printf("Attempt to initialise '%s'\n", BurnDrvGetTextA(DRV_FULLNAME));

	if (config_options.option_rescale<3) memset (titlefb, 0, pwidth*240*2); else memset (titlefb, 0, pwidth*384*2);
	DrawString ("Finalburn Alpha for Pandora (v 0.2.97.21)", (uint16*)&titlefb, 10, 20, pwidth);
	DrawString ("Based on FinalBurnAlpha", (uint16*)&titlefb, 10, 35, pwidth);
	DrawString ("Now loading ... ", (uint16 *)&titlefb, 10, 105, pwidth);
	show_rom_loading_text("Open Zip", 0, 0);
	memcpy (VideoBuffer, titlefb, pwidth*240*2); gp2x_video_flip();

	InpInit();
	InpDIP();





	VideoInit();
	printf("completed videoinit()\n");



	if (DrvInit(nBurnDrvSelect[0], false) != 0)
	{
		printf ("Driver initialisation failed! Likely causes are:\n- Corrupt/Missing ROM(s)\n- I/O Error\n- Memory error\n\n");
		goto finish;
	}


	RunReset();


	frame_count = 0;
	GameLooping = true;

	if (BurnDrvGetFlags() & BDF_ORIENTATION_FLIPPED) printf("flipped!\n");

    {
        printf ("Lets go!\n");

        gp2x_clear_framebuffers();

if (config_options.option_sound_enable==2)
{
        /*nBurnFPS=6000;
        unsigned int frame_limit = nBurnFPS/100, frametime = 100000000/nBurnFPS;
        int fps = 0;

        fprintf(stderr,"frametime=%d, frame_limit=%d\n",frametime,frame_limit);

*/
        if (!config_options.option_sound_enable || SndOpen() == 0)
        {
            EZX_StartTicks();

          //  nBurnFPS=6000;
        int now, done=0, timer = 0, ticks=0, tick=0, i=0, fps = 0;
	unsigned int frame_limit = nBurnFPS/100, frametime = 100000000/nBurnFPS;
        while (GameLooping)
		{
			timer = EZX_GetTicks()/frametime;;
			if(timer-tick>frame_limit && bShowFPS)
			{
				fps = nFramesRendered;
				nFramesRendered = 0;
				tick = timer;
			}
			now = timer;
			ticks=now-done;
			if(ticks<1) continue;
			if(ticks>10) ticks=10;
			for (i=0; i<ticks-1; i++)
			{
				RunOneFrame(false,fps);
				SndFrameRendered();
			}
			if(ticks>=1)
			{
				RunOneFrame(true,fps);
				SndFrameRendered();
			}

			done = now;
		}
        }
}

	if (config_options.option_sound_enable==1)
	{
	int aim=0, done=0, timer = 0, tick=0, i=0, fps = 0;
	unsigned int frame_limit = nBurnFPS/100, frametime = 100000000/nBurnFPS;
	bool bRenderFrame;

		if (SndOpen() == 0)
		{
			while (GameLooping)
			{
				for (i=10;i;i--)
				{
					if (bShowFPS)
					{
						timer = EZX_GetTicks();
						if(timer-tick>1000000)
						{
							fps = nFramesRendered;
							nFramesRendered = 0;
							tick = timer;
						}
					}
					aim=SegAim();
					if (done!=aim)
					{
						//We need to render more audio:
						pBurnSoundOut=(short *)pOutput[done];
						done++; if (done>=8) done=0;

						if ((done==aim))
							bRenderFrame=true; // Render last frame
						else
							bRenderFrame=false; // Render last frame
						RunOneFrame(bRenderFrame,fps);
					}

					if (done==aim) break; // Up to date now
				}
				done=aim; // Make sure up to date
			}
		}
	}
	if (config_options.option_sound_enable==0)
	{
	int now, done=0, timer = 0, ticks=0, tick=0, i=0, fps = 0;
	unsigned int frame_limit = nBurnFPS/100, frametime = 100000000/nBurnFPS;

		while (GameLooping)
		{
			timer = EZX_GetTicks()/frametime;;
			if(timer-tick>frame_limit && bShowFPS)
			{
				fps = nFramesRendered;
				nFramesRendered = 0;
				tick = timer;
			}
			now = timer;
			ticks=now-done;
			if(ticks<1) continue;
			if(ticks>10) ticks=10;
			for (i=0; i<ticks-1; i++)
			{
				RunOneFrame(false,fps);
			}
			if(ticks>=1)
			{
				RunOneFrame(true,fps);
			}

			done = now;
		}
	}


    }

	printf ("Finished emulating\n");

finish:
	printf("---- Shutdown Finalburn Alpha plus ----\n\n");
/*	DrvExit();
	printf("DrvExit()\n");
	BurnLibExit();
	printf("BurnLibExit()\n");
	if (config_options.option_sound_enable)
		SndExit();
		printf("SndExit()\n");
	VideoExit();
	printf("VideoExit()\n");
	InpExit();
	printf("InpExit()\n");*/
//	BurnCacheExit();
}

int BurnStateLoad(const char * szName, int bAll, int (*pLoadGame)());
int BurnStateSave(const char * szName, int bAll);



