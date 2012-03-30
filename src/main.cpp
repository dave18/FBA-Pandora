/*
 * NES for MOTO EZX Modile Phone
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
 * SPECIAL THANKS:
 *   Sam Revitch  	http://lsb.blogdns.net/ezx-devkit
 *
 * $Id: main.cpp,v 0.10 2006/06/07 $
 *
 */

#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <getopt.h>
#include "main.h"
#include "fba_player.h"
//#include "gp2xmemfuncs.h"
#include "burner.h"
#include "snd.h"
#include "config.h"

extern "C"
{
#include "pandorasdk.h"
};

CFG_OPTIONS config_options;
CFG_KEYMAP config_keymap;

char szAppBurnVer[16];

char nub0[11];
char nub1[11];

int nAppVirtualFps = 6000;			// App fps * 100
bool bRunPause=0;
bool bAlwaysProcessKeyboardInput=0;


unsigned short *fb;



int FindDrvByFileName(const char * fn)
{
	char sfn[60] = {0, };
	for (int i=strlen(fn)-1; i>=0; i-- ) {
		if (fn[i] == '/' || fn[i] == '\\' ) {
			strcpy( sfn, fn + i + 1 );
			break;
		}
	}
	if (sfn[0] == 0 ) strcpy( sfn, fn );
	char * p = strrchr( sfn, '.' );
	if (p) *p = 0;

	for (nBurnDrvSelect[0]=0; nBurnDrvSelect[0]<nBurnDrvCount; nBurnDrvSelect[0]++)
		if ( strcasecmp(sfn, BurnDrvGetText(DRV_NAME)) == 0 )
			return nBurnDrvSelect[0];
	nBurnDrvSelect[0] = 0;
	return -1;
}


void parse_cmd(int argc, char *argv[], char *path)
{
	int option_index, c;
	int val;
	char *p;
	printf("num args: %d\n",argc);
	for (c=0;c<argc;c++)
	{
	    printf("args %d is %s\n",c,argv[c]);
	}

	static struct option long_opts[] = {
		{"sound-sdl", 0, &config_options.option_sound_enable, 2},
		{"sound-dsp", 0, &config_options.option_sound_enable, 1},
		{"no-sound", 0, &config_options.option_sound_enable, 0},
		{"samplerate", required_argument, 0, 'r'},
		{"clock", required_argument, 0, 'c'},
		{"scaling", required_argument, 0, 'a'},
		{"rotate", required_argument, 0, 'o'},
		{"sense", required_argument, 0, 'd'},
		{"showfps", 0, &config_options.option_showfps, 1},
		{"no-showfps", 0, &config_options.option_showfps, 0},
		{"create-lists", 0, &config_options.option_create_lists, 1},
		{"force-m68k", 0, &config_options.option_forcem68k, 1},
		{"force-c68k", 0, &config_options.option_forcec68k, 1},
		{"filter", required_argument, 0, 's'},
		{"z80core", required_argument, 0, 'z'},
		{"frontend", required_argument, 0, 'f'}
	};

	option_index=optind=0;

	int z2;

	while((c=getopt_long(argc, argv, "", long_opts, &option_index))!=EOF) {
		switch(c) {
			case 'r':
				if(!optarg) continue;
				if(strcmp(optarg, "11025") == 0) config_options.option_samplerate = 0;
				if(strcmp(optarg, "22050") == 0) config_options.option_samplerate = 1;
				if(strcmp(optarg, "44100") == 0) config_options.option_samplerate = 2;
				break;
            case 'z':
				if(!optarg) continue;
				z2=0;
				sscanf(optarg,"%d",&z2);
				if ((z2>2) || (z2<0)) z2=0;
				config_options.option_z80core = z2;
				break;
            case 'a':
				if(!optarg) continue;
				z2=0;
				sscanf(optarg,"%d",&z2);
				if ((z2>3) || (z2<0)) z2=0;
				config_options.option_rescale = z2;
				break;
            case 'o':
				if(!optarg) continue;
				z2=0;
				sscanf(optarg,"%d",&z2);
				if ((z2>2) || (z2<0)) z2=0;
				config_options.option_rotate = z2;
				break;
            case 'd':
				if(!optarg) continue;
				z2=0;
				sscanf(optarg,"%d",&z2);
				if ((z2>100) || (z2<10)) z2=100;
				config_options.option_sense = z2;
				break;
            case 'c':
				if(!optarg) continue;
				int tst;
				if (EOF == sscanf(optarg,"%d",&tst))
				{
				    printf("Invalid clockspeed\n");
				}
				else
				{
				    int clk;
				    strcpy(config_options.option_selectspeed,optarg);
                    clk = open("/proc/pandora/cpu_mhz_max", O_RDWR);
                    read (clk,config_options.option_startspeed,5);
                    write (clk,config_options.option_selectspeed,strlen(config_options.option_selectspeed)+1);
                    close(clk);
                    printf("start speed=%s   new speed=%s\n",config_options.option_startspeed,config_options.option_selectspeed);
				}
				break;
			case 'f':
				if(!optarg) continue;
				p = strrchr(optarg, '/');
				if(p == NULL)
					sprintf(config_options.option_frontend, "%s%s", "./", optarg);
				else
					strcpy(config_options.option_frontend, optarg);
				break;
		}
	}

	if(optind < argc) {
		strcpy(path, argv[optind]);
	}
}

/*
 * application main()
 */

int main( int argc, char **argv )
{
    strcpy(szAppBurnVer,"0.2.97.24");
char path[MAX_PATH];



	if (argc < 2)
	{
		int c;
		printf ("Usage: %s <path to rom><shortname>.zip\n   ie: %s ./uopoko.zip\n Note: Path and .zip extension are mandatory.\n\n",argv[0], argv[0]);
		printf ("Supported (but not necessarily working via fba-gp2x) roms:\n\n");
		config_options.option_create_lists=1;
		BurnLibInit();
		for (nBurnDrvSelect[0]=0; nBurnDrvSelect[0]<nBurnDrvCount; nBurnDrvSelect[0]++)
		{
		    nBurnDrvActive=nBurnDrvSelect[0];
			printf ("%-20s ", BurnDrvGetTextA(DRV_NAME)); c++;
			if (c == 3)
			{
				c = 0;
				printf ("\n");
			}
		}
		printf ("\n\n");
		return 0;
	}


/*    int tmp;
    tmp = open("/proc/pandora/nub0/mode", O_RDWR);
    read (tmp,nub0,10);
    write (tmp,"absolute",9);
    close(tmp);
    printf("Changed nub 0 to joystick\n");
    tmp = open("/proc/pandora/nub1/mode", O_RDWR);
    read (tmp,nub1,10);
    write (tmp,"absolute",9);
    close(tmp);
    printf("Changed nub 1 to joystick\n");

    FILE * joyexists;
    joyexists=NULL;
    long timeout;
    timeout=0;
    while ((joyexists==NULL) && (timeout<100000))
    {
     //   printf(".");
        joyexists=fopen("/dev/input/js0","r");
        usleep(20);
        timeout++;
    }
    if (joyexists)
    {
        printf("js0 now exists\n");
        fclose(joyexists);
    }
    else
    {
        printf("timeout creating js0... reverting nub 0 to original setting\n");
        tmp = open("/proc/pandora/nub0/mode", O_WRONLY);
        write (tmp,nub0,10);
        close(tmp);
    }

    joyexists=NULL;
    timeout=0;
    while ((joyexists==NULL) && (timeout<100000))
    {
        joyexists=fopen("/dev/input/js1","r");
        usleep(20);
        timeout++;
    }
    if (joyexists)
    {
        printf("js1 now exists\n");
        fclose(joyexists);
    }
    else
    {
        printf("timeout creating js1... reverting nub 1 to original setting\n");
        tmp = open("/proc/pandora/nub1/mode", O_WRONLY);
        write (tmp,nub1,10);
        close(tmp);
    }
*/
	//Initialize configuration options
	config_options.option_sound_enable = 2;
	config_options.option_rescale = 2;
	config_options.option_rotate = 0;
	config_options.option_samplerate = 0;
	config_options.option_showfps = 1;
	config_options.option_create_lists=0;
	config_options.option_forcem68k=0;
	config_options.option_forcec68k=0;
	config_options.option_z80core=0;
	config_options.option_sense=100;
	strcpy(config_options.option_startspeed,"NULL");
	strcpy(config_options.option_selectspeed,"NULL");
	strcpy(config_options.option_frontend, "./capex.sh");
	printf("about to parse cmd\n");
	parse_cmd(argc, argv,path);
	printf("finshed parsing\n");

	config_keymap.up=SDLK_UP;
	config_keymap.down=SDLK_DOWN;
	config_keymap.left=SDLK_LEFT;
	config_keymap.right=SDLK_RIGHT;
	config_keymap.fire1=SDLK_HOME; //a
	config_keymap.fire2=SDLK_PAGEDOWN; //x
	config_keymap.fire3=SDLK_END; //b
	config_keymap.fire4=SDLK_PAGEUP; //y
	config_keymap.fire5=SDLK_RSHIFT;
	config_keymap.fire6=SDLK_RCTRL;
	config_keymap.coin1=SDLK_LCTRL;
	config_keymap.start1=SDLK_LALT;
	config_keymap.pause=SDLK_p;
	config_keymap.quit=SDLK_q;



//	gp2x_initialize();
//	printf("platform init finished\n");

	//Initialize sound thread
		run_fba_emulator (path);

/*    	if (strcmp(config_options.option_startspeed,config_options.option_selectspeed))
	{
	    printf("resetting cpu speed to %s\n",config_options.option_startspeed);
	    int clk;
	    clk = open("/proc/pandora/cpu_mhz_max", O_WRONLY);
	    write (clk,config_options.option_startspeed,strlen(config_options.option_startspeed)+1);
	    close(clk);

	}

	gp2x_terminate(config_options.option_frontend);

*/
	return 0;
}


/* const */ TCHAR* ANSIToTCHAR(const char* pszInString, TCHAR* pszOutString, int nOutSize)
{
#if defined (UNICODE)
	static TCHAR szStringBuffer[1024];

	TCHAR* pszBuffer = pszOutString ? pszOutString : szStringBuffer;
	int nBufferSize  = pszOutString ? nOutSize * 2 : sizeof(szStringBuffer);

	if (MultiByteToWideChar(CP_ACP, 0, pszInString, -1, pszBuffer, nBufferSize)) {
		return pszBuffer;
	}

	return NULL;
#else
	if (pszOutString) {
		_tcscpy(pszOutString, pszInString);
		return pszOutString;
	}

	return (TCHAR*)pszInString;
#endif
}


/* const */ char* TCHARToANSI(const TCHAR* pszInString, char* pszOutString, int nOutSize)
{
#if defined (UNICODE)
	static char szStringBuffer[1024];
	memset(szStringBuffer, 0, sizeof(szStringBuffer));

	char* pszBuffer = pszOutString ? pszOutString : szStringBuffer;
	int nBufferSize = pszOutString ? nOutSize * 2 : sizeof(szStringBuffer);

	if (WideCharToMultiByte(CP_ACP, 0, pszInString, -1, pszBuffer, nBufferSize, NULL, NULL)) {
		return pszBuffer;
	}

	return NULL;
#else
	if (pszOutString) {
		strcpy(pszOutString, pszInString);
		return pszOutString;
	}

	return (char*)pszInString;
#endif
}


bool AppProcessKeyboardInput()
{
	return true;
}
