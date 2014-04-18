//
//  OutputStringBuf
//  taskwarrior-ios
//
//  Created by david on 5/7/14.
//  Copyright 2014 David Whetstone All rights reserved.
//


#ifndef __OutputStringBuf_H_
#define __OutputStringBuf_H_

#import <sstream>

class OutputStringBuf : public std::basic_stringbuf<char>
{
public:
    OutputStringBuf();

protected:
    virtual int_type overflow(int __c) override;
    virtual int sync() override;
};


extern NSString *const ProcessStandardOutputNotification;

#endif //__OutputStringBuf_H_
