#ifndef _CONFIG_H_
#define _CONFIG_H_

typedef struct
{
	int option_sound_enable;
	int option_rescale;
	int option_samplerate;
	int option_showfps;
	int option_forcem68k;
    int option_forcec68k;
    int option_z80core;
	char option_frontend[MAX_PATH];
	int option_create_lists;
	char option_startspeed[6];
	char option_selectspeed[6];
} CFG_OPTIONS;

#endif
