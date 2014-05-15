//
//  HHTerminalView
//  taskwarrior-ios
//
//  Created by david on 5/6/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//


#import <AutoLayoutDSL/AutoLayoutDSL.h>
#import <UIView+AutoLayoutDSLSugar.h>
#import "HHTerminalView.h"
#import "HHTerminalTableViewCell.h"
#import "HHTerminalViewDataSource.h"
#import "HHTerminalViewDelegate.h"
#import "HHTerminalCommandLine.h"


NSString *const HHTerminalCellID = @"HHTerminalCellID";

@interface HHTerminalView () <UITableViewDelegate, UITableViewDataSource, HHTerminalCommandLineDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) HHTerminalCommandLine *commandLine;
@end

@implementation HHTerminalView

- (id)init
{
    self = [super initWithFrame:CGRectInfinite];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
        [self _addTableView];
        [self _addCommandLine];

        self.prompt = @"> ";
    }

    return self;
}

- (void)_addTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectInfinite style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.allowsSelection = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[HHTerminalTableViewCell class] forCellReuseIdentifier:HHTerminalCellID];

    [self addSubview:tableView];

    self.tableView = tableView;
}

- (void)_addCommandLine
{
    HHTerminalCommandLine *input = [[HHTerminalCommandLine alloc] init];
    input.textColor = [UIColor whiteColor];
    input.delegate = self;
    input.layoutID = @"commandLine";

    [self addSubview:input];
    self.commandLine = input;
}


#pragma mark - External interface

- (UIFont*)font
{
    return self.commandLine.font;
}

- (void)setFont:(UIFont *)font
{
    self.commandLine.font = font;
}

- (NSString *)prompt
{
    return self.commandLine.prompt;
}

- (void)setPrompt:(NSString *)prompt
{
    self.commandLine.prompt = prompt;
}

- (void)reloadData
{
    [self.tableView reloadData];
    NSInteger lastRow = [self.dataSource numberOfItemsInTerminalView:self] - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    CGFloat heightDelta = self.tableView.frame.size.height - self.tableView.contentSize.height;
    if (heightDelta > 0.f)
        self.tableView.contentInset = UIEdgeInsetsMake(heightDelta, 0.f, 0.f, 0.f);
    else
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (CGSize)terminalSize
{
    CGSize charSize = [@"W" sizeWithFont:self.font];

    CGSize terminalSize = CGSizeZero;
    if (!CGRectIsEmpty(self.frame) && !CGRectIsInfinite(self.frame) && !CGSizeEqualToSize(charSize, CGSizeZero))
    {
        terminalSize.width = self.frame.size.width / charSize.width;
        terminalSize.height = self.frame.size.height / charSize.height;
    }
    return terminalSize;
}

#pragma mark - UITableView delegate and dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource numberOfItemsInTerminalView:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAttributedString *attributedString = [self _attributedStringAtIndexPath:indexPath];

    HHTerminalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HHTerminalCellID];
    cell.font = self.font;

    cell.attributedString = attributedString;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAttributedString *attributedString = [self _attributedStringAtIndexPath:indexPath];
    NSInteger options = (NSStringDrawingOptions)NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                                 options:(NSStringDrawingOptions)options
                                                 context:nil];

    CGSize charSize = [@"W" sizeWithFont:self.font];

    return rect.size.height + charSize.height;
}


#pragma mark - Convenience methods

- (NSAttributedString *)_attributedStringAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource terminalView:self attributedStringForItemIndex:(NSUInteger)indexPath.row];
}


#pragma mark - Overrides

- (void)updateConstraints
{
    [super updateConstraints];

    BeginConstraints

        self.tableView.top == View().top;
        self.tableView.left == View().left;
        self.tableView.width == View().width;

        self.commandLine.top == self.tableView.bottom;
        self.commandLine.bottom == View().bottom;
        self.commandLine.left == View().left;
        self.commandLine.width == View().width;

    EndConstraints
}

- (BOOL)becomeFirstResponder
{
    return [self.commandLine becomeFirstResponder];
}


#pragma mark - HHTerminalPromptDelegate

- (void)commandLine:(HHTerminalCommandLine *)commandLine processCommand:(NSString *)command
{
    [self.dataSource addEntry:[self.prompt stringByAppendingString:command]];

    [self.delegate terminalView:self processCommand:command];
}

- (void)clearScreenFromCommandLine:(HHTerminalCommandLine *)commandLine
{
    [self.dataSource removeAllEntries];
    [self.tableView reloadData];
}

@end
