//
//  HHTerminalCommandLine
//  taskwarrior-ios
//
//  Created by david on 5/8/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HHTerminalCommandLineDelegate;

@interface HHTerminalCommandLine : UIView

@property (nonatomic, weak) id<HHTerminalCommandLineDelegate> delegate;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, copy) NSString *prompt;

@end

@protocol HHTerminalCommandLineDelegate <NSObject>

- (void)commandLine:(HHTerminalCommandLine *)commandLine processCommand:(NSString*)command;
- (void)clearScreenFromCommandLine:(HHTerminalCommandLine *)commandLine;

@end
