//
//  HHTaskTableViewCell
//  taskwarrior-ios
//
//  Created by david on 5/5/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import "HHTaskTableViewCell.h"
#import "HHTask.h"


static UIFont *gDefaultFont;

@implementation HHTaskTableViewCell
{

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [HHTaskTableViewCell defaultFont];
        self.textLabel.textColor = [UIColor whiteColor];
    }

    return self;
}

+ (UIFont *)defaultFont
{
    return gDefaultFont;
}

+ (void)setDefaultFont:(UIFont *)defaultFont
{
    gDefaultFont = defaultFont;
}


- (void)setTask:(HHTask *)task
{
    if (task == _task)
        return;

    _task = task;

    NSString *description = task.description;
    if (task.deleted)
        description = [description stringByAppendingString:@" (deleted)"];
    self.textLabel.text = description;
}

@end
