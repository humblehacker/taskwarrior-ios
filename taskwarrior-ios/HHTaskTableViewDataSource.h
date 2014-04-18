//
//  HHTaskTableViewDataSource
//  taskwarrior-ios
//
//  Created by david on 5/5/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TaskCellIdentifier;

@class HHTask;
@class HHTaskFile;

class Task;

@interface HHTaskTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) HHTaskFile *pendingTasks;
- (HHTask *)taskForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
