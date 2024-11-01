//
//  defs.h
//  Caerus
//
//  Created by Snoolie Keffaber on 2024/10/31.
//

#ifndef defs_h
#define defs_h

#ifndef DEFS_H
#define DEFS_H

#include <stdio.h>

#define DEBUGLOG 1
/* Peppermint Errors */
#define CSError(...) \
            do { fprintf(stderr, __VA_ARGS__); exit(1); } while (0)

#if DEBUGLOG
#define CSDLog(fmt, ...) printf("%s: " fmt, __FUNCTION__, __VA_ARGS__);
#else /* DEBUGLOG */
#define CSDLog(fmt, ...)
#endif /* DEBUGLOG */

#endif /* DEFS_H */

#endif /* defs_h */
