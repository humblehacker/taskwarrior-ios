//
//  HHTaskTerminalDataSource
//  taskwarrior-ios
//
//  Created by david on 5/7/14.
//  Copyright 2014 David Whetstone All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHTerminalViewDataSource.h"

@class AMR_ANSIEscapeHelper;


@interface HHTaskTerminalDataSource : NSObject <HHTerminalViewDataSource>

@property (nonatomic, copy) UIColor *defaultStringColor;
@property (nonatomic, copy) UIFont *font;
@property (nonatomic, strong) NSDictionary *ansiColors;

@end
