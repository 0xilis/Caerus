//
//  main.m
//  Caerus
//
//  Created by Snoolie Keffaber on 2024/10/04.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <SDL2/SDL.h>
#include "defs.h"
#include "resource_management.h"
#include <SDL2/SDL_main.h>

#ifndef SDL_MAIN_HANDLED
#ifdef main
#undef main
#endif

int main(int argc, char * argv[]) {
    /* find resources folder */
    if (argv) {
        char *executablePath = argv[0];
        if (executablePath) {
            resourcesPath = find_resource_path(executablePath);
        } else {
            CSError("argv[0] returned NULL\n");
        }
    } else {
        CSError("no argv present?\n");
    }
    CSDLog("resourcesPath: %s\n", resourcesPath);
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
#endif /* !SDL_MAIN_HANDLED */
