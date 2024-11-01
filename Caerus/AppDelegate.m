//
//  AppDelegate.m
//  Caerus
//
//  Created by Snoolie Keffaber on 2024/10/04.
//

#import "AppDelegate.h"
#import "HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    // Embed in a UINavigationController
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeVC];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
