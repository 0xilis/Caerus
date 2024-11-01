//
//  emu.h
//  Caerus
//
//  Created by Snoolie Keffaber on 2024/10/31.
//

#ifndef emu_h
#define emu_h

#include <stdio.h>
#include <SDL2/SDL.h>

extern SDL_Renderer* rend;
extern char *vram;
extern uint8_t *emuRAM;

void emulator_loop(void);
void render(void);

#endif /* emu_h */
