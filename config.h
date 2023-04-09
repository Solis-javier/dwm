/* See LICENSE file for copyright and license details. */
#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 3;        /* border pixel of windows */
static const Gap default_gap        = {.isgap = 1, .realgap = 3, .gappx = 3};
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft  = 0;   /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;        /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
//static const char *fonts[]          = { "monospace:size=10" };
#define ICONSIZE 16   /* icon size */
#define ICONSPACING 5 /* space between icon and title */
static const char *fonts[]          = { "Font Awesome 5 Free Solid:size=10" };
static const char dmenufont[]       = "monospace:size=10";
//static const char col_gray1[]       = "#0b5345";//#222222 color de la barra en off/sin usar/titulos/escritorios
//static const char col_gray2[]       = "#444444";//#444444
//static const char col_gray3[]       = "#bbbbbb";//#bbbbbb/escritorio no seleccionado
//static const char col_gray4[]       = "#eeeeee";//#eeeeee/escritorio seleccionado
//static const char col_cyan[]        = "#af601a";//#005577 color default-/en on-en activo/barra de titulos/selector escritorio.
//__//__///__//__//__//__//__//__//__//__//__//__//__//__//__//__//__//__//
//*****Audio
static const char *upvol[]   = { "/usr/bin/pactl", "set-sink-volume", "0", "+5%",     NULL };
static const char *downvol[] = { "/usr/bin/pactl", "set-sink-volume", "0", "-5%",     NULL };
static const char *mutevol[] = { "/usr/bin/pactl", "set-sink-mute",   "0", "toggle",  NULL };
//Mis Colores
static const char Negro[]        = "#000000";
static const char Blanco[]       = "#FFFFFF";
static const char Menta[]        = "#0b5345";
static const char Gris[]         = "#bbbbbb";
static const char Vino[]         = "#7A1F1F";
static const char Tomato[]       = "#FF6347";
static const char Cyan[]         = "#47E3FF";

static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { Gris, Negro, Gris },
	[SchemeSel]  = { Gris, Negro,  Menta  },
	[SchemeStatus]  = { Gris, Negro,  "#000000"  }, // Statusbar right {text,background,not used but cannot be empty}
	[SchemeTagsSel]  = { Gris, Menta,  "#000000"  }, // Tagbar left selected {text,background,not used but cannot be empty}
	[SchemeTagsNorm]  = { Gris, Negro,  "#000000"  }, // Tagbar left unselected {text,background,not used but cannot be empty}
	[SchemeInfoSel]  = { Negro, Negro,  "#000000"  }, // infobar middle  selected {text,background,not used but cannot be empty}
	[SchemeInfoNorm]  = { Negro, Negro,  "#000000"  }, // infobar middle  unselected {text,background,not used but cannot be empty}
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

/* launcher commands (They must be NULL terminated) */
//static const char* surf[]      = { "surf", "duckduckgo.com", NULL };
static const char* pavucontrol[]      = {"pavucontrol", NULL };

static const Launcher launchers[] = {
    /* command       name to display */
	{ pavucontrol,         "     |" },
};

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       NULL,            NULL,           NULL },
	//{ "Firefox",  NULL,       NULL,       1 << 8,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
	{ "TTT",      bstack },
	{ "===",      bstackhoriz },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *dmenucmd[] = { "dmenu_run", "-fn", dmenufont, "-nb", Menta, "-nf", Gris, "-sb", Tomato, "-sf", Blanco, NULL };
static const char *termcmd[]  = { "alacritty", NULL };
static const char *firefox[]  = { "firefox", NULL };
static const char *thunar[]   = { "thunar", NULL };
static const char *sublime_text[]  = { "/opt/sublime_text/sublime_text", NULL };
static const char *rofi[] = { "/home/javier/suckless/dwm/rofi/bin/launcher", NULL };
static const char *picom_toggle[] = { "/home/javier/suckless/dwm/scripts/picom-toggle.sh", NULL };
static const char *flameshotgui[] = { "flameshot","gui", NULL };
static const char *flameshotcap[] = { "flameshot","full","-p","/home/javier/Imágenes/captura", NULL };
static const char *archlogout[] = { "archlinux-logout", NULL };

#include "movestack.c"
static const Key keys[] = {
	/* modifier                     key        function        argument */
	{ 0,                            XF86XK_AudioLowerVolume, spawn, {.v = downvol } },
	{ 0,                            XF86XK_AudioMute, spawn, {.v = mutevol } },
	{ 0,                            XF86XK_AudioRaiseVolume, spawn, {.v = upvol   } },
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_w,      spawn,          {.v = firefox } },
	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = thunar } },
	{ MODKEY,                       XK_e,      spawn,          {.v = sublime_text } },
	{ MODKEY,                       XK_d,      spawn,          {.v = rofi } },
	{ MODKEY|ShiftMask,             XK_p,      spawn,          {.v = picom_toggle} },
	{ MODKEY,                       XK_Print,  spawn,          {.v = flameshotgui} },
	{ 0,                            XK_Print,  spawn,          {.v = flameshotcap} },
	{ MODKEY,                       XK_x,      spawn,          {.v = archlogout} },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_o,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_j,      movestack,      {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_k,      movestack,      {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_u,      setlayout,      {.v = &layouts[3]} },
	{ MODKEY,                       XK_o,      setlayout,      {.v = &layouts[4]} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	{ MODKEY|ControlMask,           XK_j,      setgaps,        {.i = -5 } },
	{ MODKEY|ControlMask,           XK_k,      setgaps,        {.i = +5 } },
	{ MODKEY|ControlMask,           XK_r,      setgaps,        {.i = GAP_RESET } },
	{ MODKEY|ControlMask,           XK_g,      setgaps,        {.i = GAP_TOGGLE} },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
