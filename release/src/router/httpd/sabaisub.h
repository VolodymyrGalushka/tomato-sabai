#ifndef SABAISUB_H
#define SABAISUB_H

#define SABAIVPNVERSION "5"
#define STRONGTF 0

#define T_ISITAMAC(T_START,T_MAC) ( (T_MAC[T_START+2]==':')&&(T_MAC[T_START+5]==':')&&(T_MAC[T_START+8]==':')&&(T_MAC[T_START+11]==':')&&(T_MAC[T_START+14]==':') )

#include "sabai_system.h"
#include "sabai_page_reg.h"
#include "sabai_page_dual.h"
#include "sabai_page_hma.h"
#include "sabai_page_home.h"
#include "sabai_page_sabai.h"
#include "sabai_page_strong.h"
#include "sabai_page_vypr.h"
#include "sabai_page_vpns.h"

char cadaeic[] = "One|A Poem|A Raven|Midnights so dreary, tired and weary,|Silently pondering volumes extolling all by-now obsolete lore.|During my rather long nap - the weirdest tap!|An ominous vibrating sound disturbing my chamber's antedoor.|'This', I whispered quietly, 'I ignore'.";

#endif
