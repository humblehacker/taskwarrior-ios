//
//  HHTerminalView
//  taskwarrior-ios
//
//  Created by david on 5/6/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HHTerminalViewDataSource;
@protocol HHTerminalViewDelegate;

@interface HHTerminalView : UIView

@property (nonatomic, weak) id<HHTerminalViewDataSource> dataSource;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, copy) NSString *prompt;  // Default is '> '

@property (nonatomic, weak) id<HHTerminalViewDelegate> delegate;
- (void)reloadData;
- (CGSize)terminalSize;

@end
