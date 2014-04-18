//
//  HHTask
//  taskwarrior-ios
//
//  Created by david on 5/5/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <task/Task.h>
#import "HHTask.h"


@interface HHTask ()
@property (nonatomic) Task const *task;
@end

@implementation HHTask

- (id)initWithTask:(Task const *)task
{
    self = [super init];
    if (self)
    {
        self.task = task;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%s", self.task->get("description").c_str()];
}

- (BOOL)deleted
{
    return self.task->getStatus() == Task::deleted;
}


@end
