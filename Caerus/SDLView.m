//
//  SDLView.m
//  Caerus
//
//  Created by Snoolie Keffaber on 2024/10/31.
//

#import "SDLView.h"
#import <UIKit/UIKit.h>
#include "resource_management.h"
#include "emu.h"
#include "defs.h"

@implementation SDLView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self startSDL];
    }
    return self;
}

- (void)startSDL {
    SDL_SetMainReady();
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        CSError("SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        return;
    }

    // Create SDL window
    sdlWindow = SDL_CreateWindow("Chippy",
                                 SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                  self.bounds.size.width,
                                  self.bounds.size.height,
                                 SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
    
    // Create SDL renderer
    sdlRenderer = SDL_CreateRenderer(sdlWindow, -1, SDL_RENDERER_ACCELERATED);
    
    // Set emu.c SDL_Renderer
    rend = sdlRenderer;
    
    // Show the SDL window
    SDL_ShowWindow(sdlWindow);
    
    // Set up / Load bootROM into Chippy
    char *resource = find_resource("boot.ch8");
    if (access(resource, F_OK) == 0) {
        CSDLog("ROM path: %s\n", resource);
        
        // Support 128x64 later
        int SCREEN_WIDTH = 64;
        int SCREEN_HEIGHT = 64;
        vram = malloc(SCREEN_WIDTH * SCREEN_HEIGHT);
        if (!vram) {
            CSError("unable to allocate the 8KB VRAM\n");
            SDL_DestroyRenderer(rend);
            return;
        }
        // initialize the initial vram to be all black at first.
        memset(vram, 0, SCREEN_WIDTH * SCREEN_HEIGHT);
        
        // Load ROM into 4KB memory
        emuRAM = malloc(4096);
        if (!emuRAM) {
            CSError("unable to allocate the 4KB emuRAM\n");
            free(vram);
            return;
        }
        memset(emuRAM,0,4096);
        FILE *fp = fopen(resource, "r");
        if (!fp) {
            CSError("unable to open file input\n");
            free(vram);
            SDL_DestroyRenderer(rend);
            return;
        }
        fseek(fp, 0, SEEK_END);
        size_t binarySize = ftell(fp);
        fseek(fp, 0, SEEK_SET);
        size_t bytesRead = fread(emuRAM + 0x200, 1, binarySize, fp);
        fclose(fp);
        if (bytesRead < binarySize) {
            CSError("failed to read entire file, read %zd, expected %zu\n",bytesRead,binarySize);
            free(vram);
            free(emuRAM);
            return;
        }
    } else {
        CSError("no jumpstart / bootstrap ROM present\n");
        return;
    }
    free(resource);
    resource = NULL;
    
    // Support 128x64 later
    int SCREEN_WIDTH = 64;
    int SCREEN_HEIGHT = 64;
    SDL_RenderSetLogicalSize(rend, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    // Start Chippy emulator loop
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        emulator_loop();
    });
}

// Override the drawRect method to perform SDL rendering
/*- (void)drawRect:(CGRect)rect {
    // Clear the renderer with a color
    SDL_SetRenderDrawColor(sdlRenderer, 255, 0, 0, 255); // Red
    SDL_RenderClear(sdlRenderer);
    
    // Present the renderer
    SDL_RenderPresent(sdlRenderer);
}*/

/*- (void)startRenderLoop {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            [self renderFrame];
            SDL_Delay(16); // ~60 FPS
        }
    });
}

- (void)renderFrame {
    SDL_SetRenderDrawColor(sdlRenderer, 255, 0, 0, 255); // Red
    SDL_RenderClear(sdlRenderer);
    SDL_RenderPresent(sdlRenderer);
}*/

// Make sure to clean up SDL resources
- (void)dealloc {
    printf("dealloc SDLView...\n");
    SDL_DestroyRenderer(sdlRenderer);
    SDL_DestroyWindow(sdlWindow);
    SDL_Quit();
}

@end
