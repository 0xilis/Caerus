//
//  SDLViewController.m
//  Caerus
//
//  Created by Snoolie Keffaber on 2024/10/31.
//

#import "SDLViewController.h"
#import "SDLView.h"
#include "emu.h"

@implementation SDLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create and add the SDLView to the view controller's view
    SDLView *sdlView = [[SDLView alloc] initWithFrame:self.view.bounds];
    sdlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // Make it resize with the view controller
    [self.view addSubview:sdlView];
}

@end
