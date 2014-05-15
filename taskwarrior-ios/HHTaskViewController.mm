//
//  HHTaskViewController.m
//  taskwarrior-ios
//
//  Created by david on 4/18/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#include <task/Task.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import <AutoLayoutDSL/AutoLayoutDSL.h>
#import <AutoLayoutDSL/HHMainView.h>
#import <UIView+AutoLayoutDSLSugar.h>
#import "HHTaskTableViewDataSource.h"
#import "HHLog.h"
#import "HHTaskViewController.h"
#import "HHTaskWarriorContext.h"
#import "NSArray+BlocksKit.h"
#import "HHTaskTableViewCell.h"
#import "NSObject+BKBlockObservation.h"
#import "HHTerminalView.h"
#import "HHTerminalViewDataSource.h"
#import "HHTerminalViewDelegate.h"
#import "HHTaskTerminalDataSource.h"

const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface HHTaskViewController () <UITextFieldDelegate, UITableViewDelegate, HHTerminalViewDelegate>
@property (nonatomic, weak) HHTerminalView *terminalView;
@property (nonatomic, weak) UITableView *tasksTable;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) HHTaskTableViewDataSource *taskTableViewDataSource;
@property (nonatomic, strong) HHTaskTerminalDataSource *terminalDataSource;
@end

/*
    TODO: - Add meta commands (start with !)
 */

@implementation HHTaskViewController


- (void)dealloc
{
}

- (void)loadView
{
    [super loadView];
    HHMainView *mainView = [[HHMainView alloc] init];
    mainView.layoutID = @"mainView";
    self.contentView = mainView.contentView;
    self.view = mainView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self _setupTerminalDataSource];
    [self _addTerminalView];
    [self _addTasksTableView];
    [self _updateTerminalSizeWhenTerminalBoundsChange];
}

- (void)_setupTerminalDataSource
{
    self.terminalDataSource = [HHTaskTerminalDataSource new];
    self.terminalDataSource.font = self._defaultFont;
    self.terminalDataSource.defaultStringColor = [UIColor whiteColor];

    HHTaskWarriorContext *context = [HHTaskWarriorContext sharedContext];
    context.updateStandardStreams = ^(NSString *outputText, NSString *errorText)
        {
            [self _addEntryWithOutputText:outputText errorText:errorText];
            self.terminalView.prompt = @"? ";
        };
}

- (void)_addTasksTableView
{
    self.taskTableViewDataSource = [HHTaskTableViewDataSource new];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectInfinite style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self.taskTableViewDataSource;
    tableView.backgroundColor = [UIColor blackColor];
    tableView.layoutID = @"tasksTable";
    tableView.rowHeight = 20.0;
    tableView.layer.borderWidth = 1.0;
    [tableView registerClass:[HHTaskTableViewCell class] forCellReuseIdentifier:TaskCellIdentifier];
    [HHTaskTableViewCell setDefaultFont:self._defaultFont];

    [self.contentView addSubview:tableView];
    self.tasksTable = tableView;
}

- (void)_addTerminalView
{
    HHTerminalView *terminal = [[HHTerminalView alloc] init];
    terminal.font = self._defaultFont;
    terminal.delegate = self;
    terminal.dataSource = self.terminalDataSource;
    terminal.prompt = @"task > ";
    terminal.layoutID = @"terminalView";

    [self.contentView addSubview:terminal];
    self.terminalView = terminal;
}

- (void)_updateTerminalSizeWhenTerminalBoundsChange
{
    [self.terminalView bk_addObserverForKeyPath:@"bounds" task:^(id target)
            {
                [HHTaskWarriorContext sharedContext].terminalSize = self.terminalView.terminalSize;
            }];
}

- (UIFont *)_defaultFont
{
    BOOL iPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    return [UIFont fontWithName:@"Menlo" size:iPhone ? 9.f : 14.f];
}

- (void)_addConstraints
{
    BOOL const iPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;

    UIEdgeInsets margin;
    if (iPhone)
        margin = UIEdgeInsetsMake(25.f, 5.f, 0.f, 5.f);
    else
        margin = UIEdgeInsetsMake(25.f, 20.f, 5.f, 20.f);

    BeginConstraints

    self.terminalView.left == View().left + margin.left;
    self.terminalView.right == View().right - margin.right;
    self.terminalView.top == View().top + margin.top;
    self.terminalView.height == View().height * 0.7;

    self.tasksTable.left == View().left + margin.left;
    self.tasksTable.right == View().right - margin.right;
    self.tasksTable.top == self.terminalView.bottom + StandardVerticalGap;
    self.tasksTable.bottom == View().bottom - margin.bottom;

    EndConstraints

    #ifdef DEBUG
    [self _logAllConstraints];
    [self.contentView logAmbiguities];
    #endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateViewConstraints];
    [self.terminalView becomeFirstResponder];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self _logAllFrames];
}

- (void)_logAllConstraints
{
    [self.contentView.allConstraints bk_each:^(NSLayoutConstraint *constraint)
    {
        HHLogInfo(@"%@", constraint.equationString);
    }];
}

- (void)_logAllFrames
{
    HHLogInfo(@"%@: %@", self.view.layoutID, NSStringFromCGRect(self.view.frame));
    [self.view bk_eachSubview:^(UIView *subview)
    {
        HHLogInfo(@"%@: %@", subview.layoutID, NSStringFromCGRect(subview.frame));
    }];
}

- (void)updateViewConstraints
{
    [self _removeAllConstraints];
    [self _addConstraints];
    [super updateViewConstraints];
}

- (void)_removeAllConstraints
{
    [self.contentView.constraints bk_each:^(NSLayoutConstraint * constraint)
    {
        [constraint remove];
    }];
}

- (void)_addEntryWithOutputText:(NSString *)outputText errorText:(NSString *)errorText
{
    [self.terminalDataSource addEntry:outputText];
    [self.terminalDataSource addEntry:errorText];

    [self.terminalView reloadData];
    [self.tasksTable reloadData];
}


#pragma mark - UITextField delegate methods

- (void)terminalView:(HHTerminalView *)view processCommand:(NSString *)command
{
    HHLogInfo(@"%@", command);

    [[HHTaskWarriorContext sharedContext] processInputText:command
                                                completion:^(NSString *outputText, NSString *errorText)
            {
                [self _addEntryWithOutputText:outputText errorText:errorText];
                self.terminalView.prompt = @"task > ";
            }];
}


#pragma mark - Overrides

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
