//
//  OutputStringBuf
//  taskwarrior-ios
//
//  Created by david on 5/7/14.
//  Copyright 2014 David Whetstone All rights reserved.
//

#include "OutputStringBuf.h"

OutputStringBuf::OutputStringBuf()
{

}

int OutputStringBuf::overflow(int __c)
{
    return basic_stringbuf::overflow(__c);
}

int OutputStringBuf::sync()
{
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ProcessStandardOutputNotification object:nil];
    });

    return 0;
}

NSString *const ProcessStandardOutputNotification = @"process_standard_output";
