//
//  HHTerminalViewDelegate
//  taskwarrior-ios
//
//  Created by david on 5/7/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HHTerminalView;

@protocol HHTerminalViewDelegate <NSObject>
- (void)terminalView:(HHTerminalView *)view processCommand:(NSString *)command;
@end
