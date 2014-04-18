//
//  InputStringBuf
//  taskwarrior-ios
//
//  Created by david on 5/7/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//


#import <sstream>

#ifndef __InputStringBuf_H_
#define __InputStringBuf_H_


class InputStringBuf : public std::basic_stringbuf<char>
{
    virtual int_type underflow() override;

    std::mutex _input_mutex;
    std::condition_variable _has_input;

public:
    InputStringBuf();

    void set_str(const string_type &__s);

    bool _waiting_for_input;
};


#endif //__InputStringBuf_H_
