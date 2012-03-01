// Run module
#include "burner.h"
#include "gamewidget.h"
#include "snd.h"
#include "font.h"
#include "pandorasdk.h"
//#include "gp2xmemfuncs.h"
#include "config.h"
#include "SDL/SDL.h"


extern int fps;
extern unsigned int FBA_KEYPAD[4];
extern CFG_OPTIONS config_options;
extern void do_keypad();

static int VideoBufferWidth = 0;
static int VideoBufferHeight = 0;
static int PhysicalBufferWidth = 0;


//static unsigned short BurnVideoBuffer[384 * 224];	// think max enough
static unsigned short * BurnVideoBuffer = NULL;	// think max enough
static bool BurnVideoBufferAlloced = false;

bool bShowFPS = false;
bool bPauseOn = false;

int InpMake(unsigned int[]);
void uploadfb(void);
void VideoBufferUpdate(void);
void VideoTrans();

int RunReset()
{
/*	if (VideoBufferWidth == 384 && (config_options.option_rescale == 2 || VideoBufferHeight == 240))
		gp2x_setvideo_mode(384,240);
	else
	if (VideoBufferWidth == 448)
		gp2x_setvideo_mode(448,240);*/
	nFramesEmulated = 0;
	nCurrentFrame = 0;
	nFramesRendered = 0;

	return 0;
}
/*
static int GetInput(bool bCopy)
{
	static int i = 0;
	InputMake(bCopy); 						// get input

	// Update Input dialog ever 3 frames
	if (i == 0) {
		//InpdUpdate();
	}

	i++;

	if (i >= 3) {
		i = 0;
	}

	// Update Input Set dialog
	//InpsUpdate();
	return 0;
}
*/

int RunOneFrame(bool bDraw, int fps)
{
    //long profile=SDL_GetTicks();
	do_keypad();
	InpMake(FBA_KEYPAD);
	if (bPauseOn==false)
	{
    //printf("keyboard %2d  ",(SDL_GetTicks()-profile));
	nFramesEmulated++;
	nCurrentFrame++;
//	GetInput(true);

	pBurnDraw = NULL;
	if ( bDraw )
	{
		nFramesRendered++;
		VideoBufferUpdate();
		pBurnDraw = (unsigned char *)&BurnVideoBuffer[0];
	}
//    printf("vbupdate %2d  ",(SDL_GetTicks()-profile));
	BurnDrvFrame();
 //   printf("bdframe %2d  \n",(SDL_GetTicks()-profile));
	pBurnDraw = NULL;
	if ( bDraw )
	{
		VideoTrans();
		if (bShowFPS)
		{
			char buf[10];
			int x;
			sprintf(buf, "FPS: %2d", fps);
			//draw_text(buf, x, 0, 0xBDF7, 0x2020);
			DrawRect((uint16 *) (unsigned short *) &VideoBuffer[0],0, 0, 60, 9, 0,PhysicalBufferWidth);
			DrawString (buf, (unsigned short *) &VideoBuffer[0], 0, 0,PhysicalBufferWidth);
		}

		gp2x_video_flip();
	}
	}
	if (bPauseOn)
	{
	//    GetInput(false);
	    DrawString ("PAUSED", (unsigned short *) &VideoBuffer[0], (PhysicalBufferWidth>>1)-24, 120,PhysicalBufferWidth);
	    gp2x_video_flip();
	}
/*	if (config_options.option_sound_enable)
		SndPlay();
*/	return 0;
}

// --------------------------------

static unsigned int HighCol16(int r, int g, int b, int  /* i */)
{
	unsigned int t;

	t  = (r << 8) & 0xF800;
	t |= (g << 3) & 0x07E0;
	t |= (b >> 3) & 0x001F;

	return t;
}

static void BurnerVideoTransDemo(){}

static void (*BurnerVideoTrans) () = BurnerVideoTransDemo;

//typedef unsigned long long UINT64;
/*
static void BurnerVideoTrans384x224Clip()
{
	// CPS1 & CPS2 384x224
	unsigned short * p = &VideoBuffer[3072];
	unsigned short * q = &BurnVideoBuffer[32];

	//for (int i=0; i<224; i++,p+=384,q+=384)
	//{
		memcpy(p,q,640*224);
	//}
}*/

static void BurnerVideoTrans384x224SW()
{
#define COLORMIX(a, b) ( ((((a & 0xF81F) + (b & 0xF81F)) >> 1) & 0xF81F) | ((((a & 0x07E0) + (b & 0x07E0)) >> 1) & 0x07E0) )
	// CPS1 & CPS2 384x224
	unsigned short * p = &VideoBuffer[3072];
	unsigned short * q = BurnVideoBuffer;

	for (int i=0; i<224; i++)
		for (int j=0; j<64; j++) {
			//*((UINT64 *)p) = *((UINT64 *)q);
			p[0] = q[0];
			p[1] = q[1];
			p[2] = q[2];
			p[3] = COLORMIX(q[3],q[4]);
			p[4] = q[5];
			p += 6;
			q += 6;
		}
}

static void BurnerVideoTrans304x224()
{
	// SNK Neogeo 308x224
	unsigned short * p = &VideoBuffer[3112];
	unsigned short * q = &BurnVideoBuffer[0];
	for (int i=0; i<224; i ++) {
		memcpy( p, q, 304 * 2 );
		p += 384;
		q += 304;
	}
	//printf("304x224\n");
}




static void BurnerVideoTrans320x240()
{
	// Cave & Toaplan
	unsigned short * p = &VideoBuffer[32];
	unsigned short * q = &BurnVideoBuffer[0];

	for (int i=0; i<240; i++,p+=384,q+=320)
	{
		memcpy(p,q,640);
	}
}

static void BurnerVideoTrans320x240_rotate()
{
	// Cave & Toaplan
	unsigned short * p = &VideoBuffer[7680];
	unsigned short * q = &BurnVideoBuffer[319];
    for (int j=0; j<320; j++,q-=76801)
	for (int i=0; i<240; i++)//,q-=76800
	{
		memcpy(p,q,2);
		p++;
		q+=320;
	}
}

static void BurnerVideoTrans352x240()
{
	unsigned short * p = &VideoBuffer[16];
	unsigned short * q = &BurnVideoBuffer[0];

	for (int i=0; i<240; i++,p+=384,q+=352)
	{
		memcpy(p,q,704);
	}
}

static void BurnerVideoTrans352x240_rotate()
{
	unsigned short * p = &VideoBuffer[7680];
	unsigned short * q = &BurnVideoBuffer[351];
    for (int j=0; j<352; j++,q-=76801)
	for (int i=0; i<240; i++)//,q-=76800
	{
		memcpy(p,q,2);
		p++;
		q+=352;
	}
}

static void BurnerVideoTrans320x232()
{
	// blaze on
	unsigned short * p = &VideoBuffer[(384*4)+32];
	unsigned short * q = &BurnVideoBuffer[0];

	for (int i=0; i<232; i++,p+=384,q+=320)
	{
		memcpy(p,q,640);
	}
}

static void BurnerVideoTrans320x232_rotate()
{
	unsigned short * p = &VideoBuffer[7684];
	unsigned short * q = &BurnVideoBuffer[319];
    for (int j=0; j<320; j++,q-=(320*232+1))
    {
        for (int i=0; i<232; i++)//,q-=76800
        {
            memcpy(p,q,2);
            p++;
            q+=320;
        }
        p+=8;
    }
}


static void BurnerVideoTrans320x224()
{
	// Cave & Toaplan
	unsigned short * p = &VideoBuffer[3104];
	unsigned short * q = &BurnVideoBuffer[0];

	for (int i=0; i<224; i++,p+=384,q+=320)
	{
		memcpy(p,q,640);
	}
}

static void BurnerVideoTrans384x256()
{
	// Cave & Toaplan
	unsigned short * p = &VideoBuffer[0];
	unsigned short * q = &BurnVideoBuffer[0];

	for (int i=0; i<240; i++,p+=384,q+=384)
	{
		memcpy(p,q,768);
	}
}


static void BurnerVideoTrans320x224_rotate()
{
	// Cave & Toaplan
	unsigned short * p = &VideoBuffer[0];
	unsigned short * q = &BurnVideoBuffer[319];
    for (int j=0; j<320; j++,q-=71681)
    {
        for (int i=0; i<224; i++)//,q-=76800
        {
            memcpy(p,q,2);
            p++;
            q+=320;
        }
        p+=16;
    }
}

static void BurnerVideoTrans384x224_rotate()
{
	// Cave & Toaplan
	unsigned short * p = &VideoBuffer[8];
	unsigned short * q = &BurnVideoBuffer[383];
    for (int j=0; j<384; j++,q-=86017)
    {
        for (int i=0; i<224; i++)
        {
            memcpy(p,q,2);
            p++;
            q+=384;
        }
        p+=16;
    }
}




/*
static void BurnerVideoTrans320x240()
{
	// Cave & Toaplan 320x240
	unsigned short * p = &VideoBuffer[0][0];
	unsigned short * q = &BurnVideoBuffer[0];
	memcpy( p, q, 320 * 240 * 2 );
}

*/

static void BurnerVideoTrans256x224()
{
	// 256x224

	unsigned short * p = &VideoBuffer[3136];
	unsigned short * q = &BurnVideoBuffer[0];
	for (int i=0; i<224; i ++) {
		memcpy( p, q, 256 * 2 );
		p += 384;
		q += 256;
	}

}

static void BurnerVideoTrans256x224_rotate()
{
	unsigned short * p = &VideoBuffer[15368];
	unsigned short * q = &BurnVideoBuffer[255];
    for (int j=0; j<256; j++,q-=57345)
    {
        for (int i=0; i<224; i++)
        {
            memcpy(p,q,2);
            p++;
            q+=256;
        }
        p+=16;
    }
}


static void BurnerVideoTrans240x224()
{
	// 240x224

	unsigned short * p = &VideoBuffer[3144];
	unsigned short * q = &BurnVideoBuffer[0];
	for (int i=0; i<224; i ++) {
		memcpy( p, q, 240 * 2 );
		p += 384;
		q += 240;
	}

}

static void BurnerVideoTrans240x224_rotate()
{
	unsigned short * p = &VideoBuffer[15368];
	unsigned short * q = &BurnVideoBuffer[239];
    for (int j=0; j<240; j++,q-=53761)
    {
        for (int i=0; i<224; i++)
        {
            memcpy(p,q,2);
            p++;
            q+=240;
        }
        p+=16;
    }
}

static void BurnerVideoTrans288x224()
{
	// 240x224

	unsigned short * p = &VideoBuffer[3120];
	unsigned short * q = &BurnVideoBuffer[0];
	for (int i=0; i<224; i ++) {
		memcpy( p, q, 288 * 2 );
		p += 384;
		q += 288;
	}

}

static void BurnerVideoTrans288x224_rotate()
{
	unsigned short * p = &VideoBuffer[15368];
	unsigned short * q = &BurnVideoBuffer[287];
    for (int j=0; j<288; j++,q-=64513)
    {
        for (int i=0; i<224; i++)
        {
            memcpy(p,q,2);
            p++;
            q+=288;
        }
        p+=16;
    }
}

static void BurnerVideoTrans288x224Flipped()
{
	unsigned short * p = &VideoBuffer[15368];
	unsigned short * q = &BurnVideoBuffer[64224];
    for (int j=0; j<288; j++,q+=(64225+288))
    {
        for (int i=0; i<224; i++)
        {
            memcpy(p,q,2);
            p++;
            q-=288;
        }
        p+=16;
    }
}



static void BurnerVideoTrans384x240Flipped()
{
	// 384x240
	register unsigned short * p = &VideoBuffer[0];
	register unsigned short * q = &BurnVideoBuffer[92159]; //384*240-1
	for (int x = 92160; x > 0; x --) {
		*p++ = *q--;
	}
}



static void BurnerVideoTrans256x224Flipped()
{
	unsigned short * p = &VideoBuffer[15368];
	unsigned short * q = &BurnVideoBuffer[57088];
    for (int j=0; j<256; j++,q+=(57089+256))
    {
        for (int i=0; i<224; i++)
        {
            memcpy(p,q,2);
            p++;
            q-=256;
        }
        p+=16;
    }
}
static void BurnerVideoTrans256x256()
{
	// 256x256
	unsigned short * p = &VideoBuffer[64];
	unsigned short * q = &BurnVideoBuffer[0];
	for (int i=0; i<240; i ++) {
		memcpy( p, q, 256 * 2 );
		p += 384;
		q += 256;
	}
}

static void BurnerVideoTrans224x224()
{
	// 224x224
	unsigned short * p = &VideoBuffer[64];
	unsigned short * q = &BurnVideoBuffer[0];
	for (int i=0; i<224; i ++) {
		memcpy( p, q, 224 * 2 );
		p += 384;
		q += 224;
	}
}

static void BurnerVideoTrans256x192()
{
	// 256x256
	unsigned short * p = &VideoBuffer[9216+64];
	unsigned short * q = &BurnVideoBuffer[0];
	for (int i=0; i<192; i ++) {
		memcpy( p, q, 256 * 2 );
		p += 384;
		q += 256;
	}
}


static void BurnerVideoTrans256x240()
{
	// 256x240
	unsigned short * p = &VideoBuffer[64];
	unsigned short * q = &BurnVideoBuffer[0];
	for (int i=0; i<240; i ++) {
		memcpy( p, q, 256 * 2 );
		p += 384;
		q += 256;
	}
}

static void BurnerVideoTrans256x240_rotate()
{
	unsigned short * p = &VideoBuffer[64];
	unsigned short * q = &BurnVideoBuffer[61184];
    for (int j=0; j<256; j++,q+=(61185+256))
    {
        for (int i=0; i<240; i++)
        {
            memcpy(p,q,2);
            p++;
            q-=256;
        }
        //p+=16;
    }
}

static void BurnerVideoTrans256x240Flipped()
{
	unsigned short * p = &VideoBuffer[72];
	unsigned short * q = &BurnVideoBuffer[61184];
    for (int j=0; j<256; j++,q+=(61185+256))
    {
        for (int i=0; i<240; i++)
        {
            memcpy(p,q,2);
            p++;
            q-=256;
        }
        p+=144;
    }
}

static void BurnerVideoTrans280x240()
{
	// 256x240
	unsigned short * p = &VideoBuffer[52];
	unsigned short * q = &BurnVideoBuffer[0];
	for (int i=0; i<240; i ++) {
		memcpy( p, q, 280 * 2 );
		p += 384;
		q += 280;
	}
}

static void BurnerVideoTrans280x240_rotate()
{
	unsigned short * p = &VideoBuffer[12480];
	unsigned short * q = &BurnVideoBuffer[66920];
    for (int j=0; j<280; j++,q+=(66921+280))
    {
        for (int i=0; i<240; i++)
        {
            memcpy(p,q,2);
            p++;
            q-=280;
        }
        //p+=16;
    }
}

static void BurnerVideoTrans280x240Flipped()
{
	unsigned short * p = &VideoBuffer[12480];
	unsigned short * q = &BurnVideoBuffer[279];
    for (int j=0; j<280; j++,q-=(67201))
    {
        for (int i=0; i<240; i++)
        {
            memcpy(p,q,2);
            p++;
            q+=280;
        }
        //p+=144;
    }
}


static void BurnerVideoTrans448x224()
{
	// IGS 448x224
/*
	unsigned short * p = &VideoBuffer[2560];
	unsigned short * q = BurnVideoBuffer;

	for (int i=0; i<224; i++)
		for (int j=0; j<64; j++) {
			p[0] = q[0];
			p[1] = q[1];
			p[2] = q[3];
			p[3] = q[4];
			p[4] = q[6];
			p += 5;
			q += 7;
		}
*/
	memcpy(&VideoBuffer[0],BurnVideoBuffer,448*224*2);
}

/*static void BurnerVideoTrans352x240()
{
	// V-System 352x240
	unsigned short * p = &VideoBuffer[0];
	unsigned short * q = BurnVideoBuffer;

	for (int i=0; i<240; i++)
		for (int j=0; j<32; j++) {
			p[0] = q[0];
			p[1] = q[1];
			p[2] = q[2];
			p[3] = q[3];
			p[4] = q[4];
			p[5] = q[5];
			p[6] = q[6];
			p[7] = q[7];
			p[8] = q[8];
			p[9] = q[10];
			p += 10;
			q += 11;
		}
}
*/
int VideoInit()
{
	BurnDrvGetFullSize(&VideoBufferWidth, &VideoBufferHeight);
    printf("w=%d h=%d\n",VideoBufferWidth, VideoBufferHeight);
//	printf("Screen Size: %d x %d\n", VideoBufferWidth, VideoBufferHeight);

	nBurnBpp = 2;
	BurnHighCol = HighCol16;

	BurnRecalcPal();

	if (VideoBufferWidth == 384 && VideoBufferHeight == 224) {
		// CPS1 & CPS2
		nBurnPitch  = VideoBufferWidth * 2;
		switch(config_options.option_rescale)
		{
			case 0:
				BurnVideoBuffer = &VideoBuffer[3072];
				BurnVideoBufferAlloced = false;
				BurnerVideoTrans = BurnerVideoTransDemo;
				PhysicalBufferWidth	= VideoBufferWidth;
			break;
			case 1:
				BurnVideoBuffer = &VideoBuffer[3072];
				BurnVideoBufferAlloced = false;
				BurnerVideoTrans = BurnerVideoTransDemo;
				PhysicalBufferWidth	= VideoBufferWidth;
			break;
			case 3:
                BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
                BurnVideoBufferAlloced = true;
                nBurnPitch  = VideoBufferWidth * 2;
                BurnerVideoTrans = BurnerVideoTrans384x224_rotate;
                PhysicalBufferWidth = 240;
            break;
            case 4:
                BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
                BurnVideoBufferAlloced = true;
                nBurnPitch  = VideoBufferWidth * 2;
                BurnerVideoTrans = BurnerVideoTrans384x224_rotate;
                PhysicalBufferWidth = 240;
            break;
			default:
				BurnVideoBuffer = &VideoBuffer[3072];
				BurnVideoBufferAlloced = false;
				BurnerVideoTrans = BurnerVideoTransDemo;
				PhysicalBufferWidth	= VideoBufferWidth;
		}
	} else
	if (VideoBufferWidth == 384 && VideoBufferHeight == 240) {
		// Cave
		nBurnPitch  = VideoBufferWidth * 2;

		if (BurnDrvGetFlags() & BDF_ORIENTATION_FLIPPED)
		{
			BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
			BurnVideoBufferAlloced = true;
			BurnerVideoTrans = BurnerVideoTrans384x240Flipped;
		}
		else
		{
			BurnVideoBuffer = &VideoBuffer[0];
			BurnVideoBufferAlloced = false;
			BurnerVideoTrans = BurnerVideoTransDemo;
		}
		PhysicalBufferWidth	= VideoBufferWidth;
	} else
    if (VideoBufferWidth == 384 && VideoBufferHeight == 256) {
		// Cave
		nBurnPitch  = VideoBufferWidth * 2;

/*		if (BurnDrvGetFlags() & BDF_ORIENTATION_FLIPPED)
		{
			BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
			BurnVideoBufferAlloced = true;
			BurnerVideoTrans = BurnerVideoTrans384x240Flipped;
		}
		else
		{*/
			BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
			BurnVideoBufferAlloced = true;
			BurnerVideoTrans = BurnerVideoTrans384x256;
		//}
		PhysicalBufferWidth	= VideoBufferWidth;
    } else
		if (VideoBufferWidth == 352 && VideoBufferHeight == 240) {

		nBurnPitch  = VideoBufferWidth * 2;

		if (BurnDrvGetFlags() & BDF_ORIENTATION_FLIPPED)
		{
			BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
			BurnVideoBufferAlloced = true;
			BurnerVideoTrans = BurnerVideoTrans352x240_rotate;
		}
		else
		{
			BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
			BurnVideoBufferAlloced = true;
			BurnerVideoTrans = BurnerVideoTrans352x240;
		}
		PhysicalBufferWidth	= VideoBufferWidth;
	} else
	if (VideoBufferWidth == 304 && VideoBufferHeight == 224) {
		// Neogeo
		BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
		BurnVideoBufferAlloced = true;
		nBurnPitch  = VideoBufferWidth * 2;
		BurnerVideoTrans = BurnerVideoTrans304x224;
		PhysicalBufferWidth = 384;
	} else
	if (VideoBufferWidth == 320 && VideoBufferHeight == 224) {
        if (config_options.option_rescale>=3)
	    {
	        // Cave gaia & Neogeo with NEO_DISPLAY_OVERSCAN
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans320x224_rotate;
            PhysicalBufferWidth = 240;
	    }
	    else
	    {
            // Cave gaia & Neogeo with NEO_DISPLAY_OVERSCAN
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans320x224;
            PhysicalBufferWidth = 384;
	    }
	} else
	if (VideoBufferWidth == 320 && VideoBufferHeight == 240) {
	    if (config_options.option_rescale>=3)
	    {
	        // Cave & Toaplan
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans320x240_rotate;
            PhysicalBufferWidth = 240;
	    }
	    else
	    {
            // Cave & Toaplan
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans320x240;
            PhysicalBufferWidth = 384;
	    }
	} else
	if (VideoBufferWidth == 256 && VideoBufferHeight == 240) {
	    if (config_options.option_rescale>=3)
	    {
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans256x240_rotate;
            PhysicalBufferWidth = 240;
	    }
	    else
	    {
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            if (BurnDrvGetFlags() & BDF_ORIENTATION_FLIPPED)
            {
                BurnerVideoTrans = BurnerVideoTrans256x240Flipped;
            }
            else
            {
                BurnerVideoTrans = BurnerVideoTrans256x240;
            }
            PhysicalBufferWidth = 384;
	    }
	} else
	if (VideoBufferWidth == 280 && VideoBufferHeight == 240) {
	    if (config_options.option_rescale>=3)
	    {
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            if (BurnDrvGetFlags() & BDF_ORIENTATION_FLIPPED)
            BurnerVideoTrans = BurnerVideoTrans280x240_rotate;
            else
            BurnerVideoTrans = BurnerVideoTrans280x240Flipped;
            PhysicalBufferWidth = 240;
	    }
	    else
	    {
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans280x240;

            PhysicalBufferWidth = 384;
	    }
	} else
	if (VideoBufferWidth == 320 && VideoBufferHeight == 232) {
	    if (config_options.option_rescale>=3)
	    {
	        // Cave & Toaplan
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans320x232_rotate;
            PhysicalBufferWidth = 240;
	    }
	    else
	    {
            // Cave & Toaplan
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans320x232;
            PhysicalBufferWidth = 384;
	    }
	} else
		if (VideoBufferWidth == 288 && VideoBufferHeight == 224) {
	    if (config_options.option_rescale>=3)
	    {

            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            //BurnerVideoTrans = BurnerVideoTrans288x224_rotate;
            BurnerVideoTrans = BurnerVideoTrans288x224Flipped;
            PhysicalBufferWidth = 240;
	    }
	    else
	    {

            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans288x224;
            PhysicalBufferWidth = 384;
	    }
		/*
		BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
		BurnVideoBufferAlloced = true;
		nBurnPitch  = VideoBufferWidth * 2;
		if (BurnDrvGetFlags() & BDF_ORIENTATION_FLIPPED)
			BurnerVideoTrans = BurnerVideoTrans256x224Flipped;
		else
			BurnerVideoTrans = BurnerVideoTrans256x224;
		PhysicalBufferWidth = 384;
		*/
	} else
	if (VideoBufferWidth == 256 && VideoBufferHeight == 224) {
	    if (config_options.option_rescale>=3)
	    {
	        // Galpanic
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            //BurnerVideoTrans = BurnerVideoTrans256x224_rotate;
            if (BurnDrvGetFlags() & BDF_ORIENTATION_FLIPPED)
            BurnerVideoTrans = BurnerVideoTrans256x224Flipped;
            else
            BurnerVideoTrans = BurnerVideoTrans256x224_rotate;
            PhysicalBufferWidth = 240;
	    }
	    else
	    {
            // Galpanic
            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans256x224;
            PhysicalBufferWidth = 384;
	    }
		/*
		BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
		BurnVideoBufferAlloced = true;
		nBurnPitch  = VideoBufferWidth * 2;
		if (BurnDrvGetFlags() & BDF_ORIENTATION_FLIPPED)
			BurnerVideoTrans = BurnerVideoTrans256x224Flipped;
		else
			BurnerVideoTrans = BurnerVideoTrans256x224;
		PhysicalBufferWidth = 384;
		*/
	} else
	if (VideoBufferWidth == 240 && VideoBufferHeight == 224) {
	    if (config_options.option_rescale>=3)
	    {

            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans240x224_rotate;
            //BurnerVideoTrans = BurnerVideoTrans256x224Flipped;
            PhysicalBufferWidth = 240;
	    }
	    else
	    {

            BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );;
            BurnVideoBufferAlloced = true;
            nBurnPitch  = VideoBufferWidth * 2;
            BurnerVideoTrans = BurnerVideoTrans240x224;
            PhysicalBufferWidth = 384;
	    }
	} else
	if (VideoBufferWidth == 256 && VideoBufferHeight == 256) {
		BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
		BurnVideoBufferAlloced = true;
		nBurnPitch  = VideoBufferWidth * 2;
		BurnerVideoTrans = BurnerVideoTrans256x256;
		PhysicalBufferWidth = 384;
	} else
	if (VideoBufferWidth == 256 && VideoBufferHeight == 192) {
		BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
		BurnVideoBufferAlloced = true;
		nBurnPitch  = VideoBufferWidth * 2;
		BurnerVideoTrans = BurnerVideoTrans256x192;
		PhysicalBufferWidth = 384;
	} else
	if (VideoBufferWidth == 224 && VideoBufferHeight == 224) {
		BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
		BurnVideoBufferAlloced = true;
		nBurnPitch  = VideoBufferWidth * 2;
		BurnerVideoTrans = BurnerVideoTrans224x224;
		PhysicalBufferWidth = 384;
	} else
	if (VideoBufferWidth == 448 && VideoBufferHeight == 224) {
		// IGS
		nBurnPitch  = VideoBufferWidth * 2;
		BurnVideoBuffer = &VideoBuffer[3584];
		BurnVideoBufferAlloced = false;
		BurnerVideoTrans = BurnerVideoTransDemo;
		PhysicalBufferWidth	= VideoBufferWidth;
	} else
	/*if (VideoBufferWidth == 352 && VideoBufferHeight == 240) {
		// V-Systom
		BurnVideoBuffer = (unsigned short *)malloc( VideoBufferWidth * VideoBufferHeight * 2 );
		BurnVideoBufferAlloced = true;
		nBurnPitch  = VideoBufferWidth * 2;
		BurnerVideoTrans = BurnerVideoTrans352x240;
		PhysicalBufferWidth = 384;
	} else*/ {
		BurnVideoBuffer = NULL;
		BurnVideoBufferAlloced = false;
		nBurnPitch  = VideoBufferWidth * 2;
		BurnerVideoTrans = BurnerVideoTransDemo;
		PhysicalBufferWidth = 384;
	}

	return 0;
}

// 'VideoBuffer' is updated each frame due to double buffering, so we sometimes need to ensure BurnVideoBuffer is updated too.
void VideoBufferUpdate (void)
{
	if (BurnVideoBufferAlloced == false)
	{
		if (VideoBufferWidth == 384 && VideoBufferHeight == 224)
		{
			BurnVideoBuffer = &VideoBuffer[3072];
		}
		else if (VideoBufferWidth == 384 && VideoBufferHeight == 240)
		{
			BurnVideoBuffer = &VideoBuffer[0];
		}
		else if (VideoBufferWidth == 320 && VideoBufferHeight == 240)
		{
			BurnVideoBuffer = &VideoBuffer[0];
		}
		else if (VideoBufferWidth == 320 && VideoBufferHeight == 224)
		{
			BurnVideoBuffer = &VideoBuffer[2560];
			//BurnVideoBuffer = &VideoBuffer[0];
		}
		else if (VideoBufferWidth == 448)
		{
			BurnVideoBuffer = &VideoBuffer[3584];
		}
		else
		{
			BurnVideoBuffer = NULL;
		}
	}
}

void VideoTrans()
{
	BurnerVideoTrans();
}

void VideoExit()
{
	if ( BurnVideoBufferAlloced )
		free(BurnVideoBuffer);
	BurnVideoBuffer = NULL;
	BurnVideoBufferAlloced = false;
	BurnerVideoTrans = BurnerVideoTransDemo;
}

void ChangeFrameskip()
{
	bShowFPS = !bShowFPS;
//	DrawRect((uint16 *) (unsigned short *) &VideoBuffer[0],0, 0, 60, 9, 0,VideoBufferWidth);
	gp2x_clear_framebuffers();
	nFramesRendered = 0;
}
