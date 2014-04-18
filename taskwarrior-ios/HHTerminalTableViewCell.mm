//
//  HHTerminalTableViewCell
//  taskwarrior-ios
//
//  Created by david on 5/6/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import "HHTerminalTableViewCell.h"


@interface HHTerminalTableViewCell ()
@property (nonatomic, weak) UITextView *textView;
@end

@implementation HHTerminalTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self addTextView];
    }

    return self;
}

- (void)addTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:self.bounds];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor redColor];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.scrollEnabled = NO;

    [self addSubview:textView];

    self.textView = textView;
}

- (NSAttributedString *)attributedString
{
    return self.textView.attributedText;
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
    self.textView.attributedText = attributedString;
}

- (UIFont *)font
{
    return self.textView.font;
}

- (void)setFont:(UIFont *)font
{
    self.textView.font = font;
}


@end
