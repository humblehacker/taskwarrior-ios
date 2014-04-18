//
//  HHAppDelegate.m
//  taskwarrior-ios
//
//  Created by david on 4/18/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import "HHAppDelegate.h"
#import "HHTaskViewController.h"


@implementation HHAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupLogging];
    [self startupUI];
    return YES;
}

- (void)setupLogging
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (void)startupUI
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.translatesAutoresizingMaskIntoConstraints = NO;
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = [[HHTaskViewController alloc] init];
    [self.window makeKeyAndVisible];
}

@end
