//
//  HHTaskTerminalDataSource
//  taskwarrior-ios
//
//  Created by david on 5/7/14.
//  Copyright 2014 David Whetstone All rights reserved.
//

#import "HHTaskTerminalDataSource.h"
#import "AMR_ANSIEscapeHelper.h"
#import "HHTerminalView.h"


@interface HHTaskTerminalDataSource ()
@property (nonatomic, strong) NSMutableArray *history;
@property (nonatomic, strong) AMR_ANSIEscapeHelper *ansi;
@end

@implementation HHTaskTerminalDataSource

- (id)init
{
    self = [super init];
    if (self)
    {
        self.history = [NSMutableArray new];
        self.ansi = [[AMR_ANSIEscapeHelper alloc] init];
    }

    return self;
}


#pragma mark - Public interface

- (void)addEntry:(NSString *)entry
{
    if (entry.length == 0)
        return;

    NSAttributedString *attributedString = [self.ansi attributedStringWithANSIEscapedString:entry];
    [self.history addObject:attributedString];
}

- (void)removeAllEntries
{
    [self.history removeAllObjects];
}

- (UIColor *)defaultStringColor
{
    return self.ansi.defaultStringColor;
}

- (void)setDefaultStringColor:(UIColor *)defaultStringColor
{
    self.ansi.defaultStringColor = defaultStringColor;
}

- (UIFont *)font
{
    return self.ansi.font;
}

- (void)setFont:(UIFont *)font
{
    self.ansi.font = font;
}

- (NSDictionary *)ansiColors
{
    return self.ansi.ansiColors;
}

- (void)setAnsiColors:(NSDictionary *)ansiColors
{
    self.ansi.ansiColors = [ansiColors mutableCopy];
}


#pragma mark - HHTerminalViewDataSource

- (NSInteger)numberOfItemsInTerminalView:(HHTerminalView *)terminalView
{
    return self.history.count;
}

- (NSAttributedString *)terminalView:(HHTerminalView *)terminalView attributedStringForItemIndex:(NSUInteger)index
{
    return [self.history objectAtIndex:index];
}


@end
