//
//  HHTaskFile
//
//  Created by david on 5/5/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <task/TDB2.h>
#import "HHTaskFile.h"
#import "HHTask.h"


@interface HHTaskFile ()
@property (nonatomic) TF2 *tf2;
@end

@interface HHTask (Friend)
- (id)initWithTask:(Task const *)task;
@end

@implementation HHTaskFile
{

}

- (id)initWithTF2:(TF2*)tf2
{
    self = [super init];
    if (self)
    {
        self.tf2 = tf2;
    }
    return self;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    Task const *task = &self.tf2->get_tasks()[idx];
    HHTask *hhTask = [[HHTask alloc] initWithTask:task];
    return hhTask;
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{

}

- (NSInteger)count
{
    return self.tf2->get_tasks().size();
}

@end
