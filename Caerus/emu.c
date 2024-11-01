//
//  emu.c
//  Caerus
//
//  Created by Snoolie Keffaber on 2024/10/31.
//

#include "emu.h"
#include <dispatch/queue.h>

/* Global variables */
SDL_Renderer* rend;
char *vram;
int running = 1;
uint8_t *emuRAM;
uint16_t pc = 0x200;
uint8_t registers[16];
uint16_t ri; /* The 16-bit register I */
uint16_t stack[16];
uint8_t keyPressed = 0;
int cycle = 1;

int draw_pixel(int x, int y) {
    /* Like a CRT, each line from left to right then another line */
    int pixelId = (y * SCREEN_WIDTH) + x;
    char pixel = vram[pixelId];
    int pixelDrew;
    if (pixel) {
        /* Pixel set on, turn it off! */
        SDL_SetRenderDrawColor(rend, 0, 0, 0, 255);
        pixelDrew = 0;
    } else {
        /* Pixel set off, turn it on! */
        SDL_SetRenderDrawColor(rend, 255, 255, 255, 255);
        pixelDrew = 1;
    }
    vram[pixelId] = pixelDrew;
    SDL_RenderDrawPoint(rend, x, y);
    return pixelDrew;
}

void cls(void) {
    /* Support 128x64 later */
    int SCREEN_WIDTH = 64;
    int SCREEN_HEIGHT = 64;
    memset(vram,0, SCREEN_WIDTH * SCREEN_HEIGHT);
    SDL_SetRenderDrawColor(rend, 0, 0, 0, 255);
    SDL_RenderClear(rend);
}

void redraw(void) {
    /* Support 128x64 later */
    int SCREEN_WIDTH = 64;
    int SCREEN_HEIGHT = 64;
    /* Like a CRT, each line from left to right then another line */
    int pixelId = 0;
    for (int y = 0; y < SCREEN_HEIGHT; y++) {
        for (int x = 0; x < SCREEN_WIDTH; x++) {
            if (vram[pixelId]) {
                SDL_SetRenderDrawColor(rend, 255, 255, 255, 255);
                SDL_RenderDrawPoint(rend, x, y);
            } else {
                SDL_SetRenderDrawColor(rend, 0, 0, 0, 255);
                SDL_RenderDrawPoint(rend, x, y);
            }
            pixelId++;
        }
    }
}

void render(void) {
    SDL_SetRenderDrawColor(rend, 0, 0, 0, 255);
    SDL_RenderClear(rend);
    redraw();
    SDL_RenderPresent(rend);
}

void handle_events(void) {
    SDL_Event event;
    SDL_PollEvent(&event);
    /* This should probably be a switch case... */
    if (event.type == SDL_QUIT) {
        running = 0;
    } else if (event.type == SDL_KEYDOWN) {
        cycle = 1;
        const char *key = SDL_GetKeyName(event.key.keysym.sym);
        const char keyfast = *key;
        /* imagine using switch cases smh */
        if (keyfast == '1') {
            keyPressed = 1;
        } else if (keyfast == '2') {
            keyPressed = 2;
        } else if (keyfast == '3') {
            keyPressed = 3;
        } else if (keyfast == '4') {
            keyPressed = 12;
        } else if (keyfast == 'q') {
            keyPressed = 4;
        } else if (keyfast == 'w') {
            keyPressed = 5;
        } else if (keyfast == 'e') {
            keyPressed = 6;
        } else if (keyfast == 'r') {
            keyPressed = 13;
        } else if (keyfast == 'a') {
            keyPressed = 7;
        } else if (keyfast == 's') {
            keyPressed = 8;
        } else if (keyfast == 'd') {
            keyPressed = 9;
        } else if (keyfast == 'f') {
            keyPressed = 14;
        } else if (keyfast == 'z') {
            keyPressed = 10;
        } else if (keyfast == 'x') {
            keyPressed = 0;
        } else if (keyfast == 'c') {
            keyPressed = 11;
        } else if (keyfast == 'v') {
            keyPressed = 15;
        }
    }
    if (!cycle) {
        /* Paused; return */
        return;
    }

    /* execute instruction */
    uint16_t instr = emuRAM[pc] << 8 | emuRAM[pc+1];
    pc += 2;
    uint8_t x = (instr & 0x0F00) >> 8;
    uint8_t y = (instr & 0x00F0) >> 4;
    uint16_t opcode = instr & 0xF000;
    uint8_t lowByte = instr & 0xFF;
    /* printf("executing %02x\n",instr); */
    if (!opcode) {
        if (instr == 0x00E0) {
            /* Clear screen */
            cls();
            return;
        }
        if (instr == 0x00EE) {
            /* return (pop from stack, store in program counter */
            printf("RET (IMPLEMENT LATER)\n");
            return;
        }
    }
    if (opcode == 0x1000) {
        /* JP addr */
        pc = instr & 0xFFF;
    } else if (opcode == 0x3000) {
        if (registers[x] == lowByte) {
            pc += 2;
        }
    } else if (opcode == 0x4000) {
        if (registers[x] != lowByte) {
            pc += 2;
        }
    } else if (opcode == 0x5000) {
        if (registers[x] == registers[y]) {
            pc += 2;
        }
    } else if (opcode == 0x6000) {
        /* LD Vx, byte */
        registers[x] = lowByte;
    } else if (opcode == 0x7000) {
        /* ADD Vx, byte */
        registers[x] = (registers[x]+lowByte) & 0xFF;
    } else if (opcode == 0x8000) {
        uint8_t nibble = instr & 0xF;
        if (nibble == 0) {
            registers[x] = registers[y];
        } else if (nibble == 1) {
            registers[x] |= registers[y];
        } else if (nibble == 2) {
            registers[x] &= registers[y];
        } else if (nibble == 3) {
            registers[x] ^= registers[y];
        } else if (nibble == 4) {
            int temp = registers[x] + registers[y];
            registers[15] = (temp > 0xFF);
            registers[x] = temp & 0xFF;
        } else if (nibble == 5) {
            registers[15] = (registers[x] > registers[y]);
            registers[x] = (registers[x] - registers[y]) & 0xFF;
        } else if (nibble == 6) {
            int temp = registers[x] & 1;
            registers[x] = (registers[x] >> 1) & 0xFF;
            registers[15] = temp;
        } else if (nibble == 7) {
            registers[15] = (registers[y] > registers[x]);
            registers[x] = (registers[y] - registers[x]) & 0xFF;
        } else if (nibble == 15) {
            int temp = (registers[x] % 0x80) >> 7;
            registers[x] = (registers[x] << 1) & 0xFF;
            registers[15] = temp;
        }
    } else if (opcode == 0x9000) {
        if (registers[x] != registers[y]) {
            pc += 2;
        }
    } else if (opcode == 0xA000) {
        ri = instr & 0xFFF;
    } else if (opcode == 0xB000) {
        pc = (opcode & 0xFFF) + registers[0];
    } else if (opcode == 0xD000) {
        /* DRW Vx, Vy, nibble */
        uint8_t nibble = instr & 0xF;
        registers[15] = 0;
        for (int row = 0; row < nibble; row++) {
            uint8_t sprite = emuRAM[ri+row];
            for (int col = 0; col < 8; col++) {
                if ((sprite & 0x80) > 0) {
                    if (draw_pixel(registers[x]+col, registers[y]+row) == 0) {
                        registers[15] = 1;
                    }
                }
                sprite <<= 1;
            }
        }
    } else if (opcode == 0xE000) {
        if (lowByte == 0x9E) {
            if (keyPressed == registers[x]) {
                pc += 2;
            }
        } else if (lowByte == 0xA1) {
            if (keyPressed != registers[x]) {
                pc += 2;
            }
        }
    }
}

void emulator_loop(void) {
    /* Main emu loop */
    while (running) {
        /* Handle events */
        handle_events();

        /* Render game state */
        render();

        SDL_Delay(10);
    }
}
