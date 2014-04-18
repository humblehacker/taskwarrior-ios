//
//  HHTaskFile
//  taskwarrior-ios
//
//  Created by david on 5/5/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <Foundation/Foundation.h>

class TF2;

@interface HHTaskFile : NSObject

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

- (NSInteger)count;
@end
