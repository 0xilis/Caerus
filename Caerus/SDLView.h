//
//  SDLView.h
//  Caerus
//
//  Created by Snoolie Keffaber on 2024/10/31.
//

#import <UIKit/UIKit.h>
#include <SDL2/SDL.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDLView : UIView {
    SDL_Window *sdlWindow;
    SDL_Renderer *sdlRenderer;
}

- (void)startSDL;

@end

NS_ASSUME_NONNULL_END
