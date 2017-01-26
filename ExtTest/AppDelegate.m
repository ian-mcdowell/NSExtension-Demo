//
//  AppDelegate.m
//  ExtTest
//
//  Created by Ian McDowell on 12/18/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Enable extended extension logging to the console. Hopefully this will help us see more of what is going on.
    CFPreferencesSetValue(CFSTR("NSExtensionAssertionLoggingEnabled"), (__bridge CFPropertyListRef _Nullable)([NSNumber numberWithBool:YES]), kCFPreferencesAnyApplication, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    
    CFPreferencesSetValue(CFSTR("NSExtensionDiscoveryLoggingEnabled"), (__bridge CFPropertyListRef _Nullable)([NSNumber numberWithBool:YES]), kCFPreferencesAnyApplication, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    
    // Set the root view controller, since we aren't using a storyboard.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    ViewController *viewController = [[ViewController alloc] init];
    [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:viewController]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
