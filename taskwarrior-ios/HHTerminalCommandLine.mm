//
//  HHTerminalCommandLine
//  taskwarrior-ios
//
//  Created by david on 5/8/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <AutoLayoutDSL/AutoLayoutDSL.h>
#import <UIView+AutoLayoutDSLSugar.h>
#import <algorithm>
#import "HHTerminalCommandLine.h"

typedef enum
{
    HHTerminalKeyCommand_Up,
    HHTerminalKeyCommand_Down,
    HHTerminalKeyCommand_ClearHistory
} HHTerminalKeyCommand;

@interface HHTerminalTextField : UITextField
@property (nonatomic, copy) void (^onKeyCommand)(HHTerminalKeyCommand command);
@end

@interface HHTerminalCommandLine () <UITextFieldDelegate>
@property (nonatomic, weak) UILabel *promptView;
@property (nonatomic, weak) HHTerminalTextField *textField;
@property (nonatomic, strong) NSMutableArray *history;
@end

@implementation HHTerminalCommandLine
{
    NSUInteger _historyIndex;
}

- (id)init
{
    self = [super initWithFrame:CGRectInfinite];
    if (self)
    {
        self.history = [NSMutableArray new];
        [self _addPromptView];
        [self _addTextField];
    }

    return self;
}

- (void)_addTextField
{
    HHTerminalTextField *textField = [[HHTerminalTextField alloc] initWithFrame:CGRectInfinite];
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;

    // TODO: Make history persistent
    textField.onKeyCommand = ^(HHTerminalKeyCommand command)
    {
        if (self.history.count > 0)
        {
            switch (command)
            {
                case HHTerminalKeyCommand_Up:
                    self.textField.text = [self _prevHistoryItem];
                    break;

                case HHTerminalKeyCommand_Down:
                    self.textField.text = [self _nextHistoryItem];
                    break;

                case HHTerminalKeyCommand_ClearHistory:
                    [self.delegate clearScreenFromCommandLine:self];
                    break;
            }
        }
    };

    [self addSubview:textField];
    self.textField = textField;
}

- (void)_addPromptView
{
    UILabel *promptView = [[UILabel alloc] init];
    promptView.backgroundColor = [UIColor clearColor];
    promptView.textColor = [UIColor whiteColor];

    [self addSubview:promptView];
    self.promptView = promptView;
}

- (void)updateConstraints
{
    [super updateConstraints];

    BeginConstraints

        [self.promptView setContentCompressionResistancePriority:501 forAxis:UILayoutConstraintAxisHorizontal];
        [self.promptView setContentHuggingPriority:501 forAxis:UILayoutConstraintAxisHorizontal];

        self.promptView.top == View().top;
        self.promptView.height == self.textField.height;
        self.promptView.left == View().left;

        self.textField.top == View().top;
        self.textField.right == View().right;

        self.textField.left == self.promptView.right;
        self.textField.height == View().height;

    EndConstraints
}


#pragma mark - History

- (void)_appendToHistory:(NSString *)command
{
    [self.history addObject:command];
    _historyIndex = self.history.count;
}

NSUInteger clamp(NSInteger value, NSInteger lower, NSInteger upper)
{
    return (NSUInteger)std::max(lower, std::min(upper, value));
}

- (NSString *)_nextHistoryItem
{
    _historyIndex = clamp(++_historyIndex, 0, self.history.count);

    NSString *item = @"";
    if (_historyIndex < self.history.count)
        item = self.history[_historyIndex];
    return item;
}

- (NSString *)_prevHistoryItem
{
    _historyIndex = clamp(--_historyIndex, 0, self.history.count);
    return self.history[_historyIndex];
}


#pragma mark - Public interface

- (UIColor *)textColor
{
    return self.textField.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.textField.textColor = textColor;
}

- (UIFont *)font
{
    return self.textField.font;
}

- (void)setFont:(UIFont *)font
{
    self.promptView.font = font;
    self.textField.font = font;
}

- (NSString *)prompt
{
    return self.promptView.text;
}

- (void)setPrompt:(NSString *)prompt
{
    self.promptView.text = prompt;
    [self.promptView sizeToFit];
    [self setNeedsLayout];
}

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *command = self.textField.text;
    if ([self.delegate respondsToSelector:@selector(commandLine:processCommand:)])
        [self.delegate commandLine:self processCommand:command];

    [self _appendToHistory:command];

    self.textField.text = nil;

    return NO;
}

@end

#pragma mark -
#pragma mark - HHTerminalTextField implementation

@implementation HHTerminalTextField

- (NSArray *)keyCommands
{
    static UIKeyCommand *upArrow;
    static UIKeyCommand *downArrow;
    static UIKeyCommand *ctrlP;
    static UIKeyCommand *ctrlN;
    static UIKeyCommand *ctrlD;
    static UIKeyCommand *ctrlL;

    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^
    {
        upArrow = [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow
                                      modifierFlags:0
                                             action:@selector(processUpKey:)];

        downArrow = [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow
                                        modifierFlags:0
                                               action:@selector(processDownKey:)];

        ctrlP = [UIKeyCommand keyCommandWithInput:@"p"
                                        modifierFlags:UIKeyModifierControl
                                               action:@selector(processUpKey:)];

        ctrlN = [UIKeyCommand keyCommandWithInput:@"n"
                                         modifierFlags:UIKeyModifierControl
                                                action:@selector(processDownKey:)];

        ctrlD = [UIKeyCommand keyCommandWithInput:@"d"
                                         modifierFlags:UIKeyModifierControl
                                                action:@selector(processDeleteKey:)];

        ctrlL = [UIKeyCommand keyCommandWithInput:@"l"
                                         modifierFlags:UIKeyModifierControl
                                                action:@selector(processClearKey:)];
    });

    return @[upArrow, downArrow, ctrlP, ctrlN, ctrlD, ctrlL];
}

- (NSRange)selectedRange
{
    UITextPosition* beginning = self.beginningOfDocument;

    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;

    NSUInteger location = (NSUInteger)[self offsetFromPosition:beginning toPosition:selectionStart];
    NSUInteger length = (NSUInteger)[self offsetFromPosition:selectionStart toPosition:selectionEnd];

    return NSMakeRange(location, length);
}

- (void)processDeleteKey:(UIKeyCommand*)processDeleteKey
{
    NSMutableString *text = [self.text mutableCopy];

    UITextRange *selectedRange = self.selectedTextRange;

    NSRange range = [self selectedRange];

    if (range.length > 0)
    {
        [text deleteCharactersInRange:range];
    }
    else if (range.length == 0 && range.location < self.text.length)
    {
        NSRange forward = NSMakeRange(range.location, 1);
        [text deleteCharactersInRange:forward];
    }
    self.text = text;

    self.selectedTextRange = selectedRange;
}

- (void)processDownKey:(UIKeyCommand*)processDownKey
{
    if (self.onKeyCommand)
        self.onKeyCommand(HHTerminalKeyCommand_Down);
}

- (void)processUpKey:(UIKeyCommand*)processUpKey
{
    if (self.onKeyCommand)
        self.onKeyCommand(HHTerminalKeyCommand_Up);
}

- (void)processClearKey:(id)processClearKey
{
    if (self.onKeyCommand)
        self.onKeyCommand(HHTerminalKeyCommand_ClearHistory);
}

@end

