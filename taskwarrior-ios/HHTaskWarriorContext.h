//
//  HHTaskWarriorContext
//  taskwarrior-ios
//
//  Created by david on 4/19/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "InputStringBuf.h"

@class HHTaskFile;

typedef void (^ProcessCompletionBlock)(NSString *, NSString *);

@interface HHTaskWarriorContext : NSObject

@property (nonatomic, assign) CGSize terminalSize;
@property (nonatomic, strong) ProcessCompletionBlock updateStandardStreams;

+ (instancetype)sharedContext;

- (void)processInputText:(NSString *)inputText completion:(ProcessCompletionBlock)completion;

- (HHTaskFile *)pendingTasks;
- (HHTaskFile *)completedTasks;
- (HHTaskFile *)undoTasks;
- (HHTaskFile *)backlogTasks;

@end
