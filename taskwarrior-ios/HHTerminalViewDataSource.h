//
//  HHTerminalViewDataSource
//  taskwarrior-ios
//
//  Created by david on 5/6/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HHTerminalView;

@protocol HHTerminalViewDataSource <NSObject>

- (NSInteger)numberOfItemsInTerminalView:(HHTerminalView *)terminalView;
- (NSAttributedString *)terminalView:(HHTerminalView *)terminalView attributedStringForItemIndex:(NSUInteger)index;

- (void)addEntry:(NSString *)entry;
- (void)removeAllEntries;

@end
