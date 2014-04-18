//
//  HHTaskTableViewCell
//  taskwarrior-ios
//
//  Created by david on 5/5/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <task/Task.h>

@class HHTask;


@interface HHTaskTableViewCell : UITableViewCell
@property (nonatomic) HHTask *task;
+ (UIFont *)defaultFont;
+ (void)setDefaultFont:(UIFont *)defaultFont;
@end
