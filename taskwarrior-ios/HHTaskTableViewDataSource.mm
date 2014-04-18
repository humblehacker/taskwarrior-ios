//
//  HHTaskTableViewDataSource
//  taskwarrior-ios
//
//  Created by david on 5/5/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import "HHTaskFile.h"
#import "HHTaskWarriorContext.h"
#import "HHTaskTableViewDataSource.h"
#import "HHTask.h"
#import "HHTaskTableViewCell.h"

NSString *const TaskCellIdentifier = @"taskCell";

@implementation HHTaskTableViewDataSource

- (id)init
{
    self = [super init];
    if (self)
    {
        self.pendingTasks = [HHTaskWarriorContext sharedContext].pendingTasks;
    }

    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pendingTasks.count;
}

- (HHTask *)taskForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.pendingTasks[(NSUInteger)indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HHTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TaskCellIdentifier forIndexPath:indexPath];

    cell.task = [self taskForRowAtIndexPath:indexPath];

    return cell;
}

@end
