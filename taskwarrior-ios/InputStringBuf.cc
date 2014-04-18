//
//  InputStringBuf
//  taskwarrior-ios
//
//  Created by david on 5/7/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#include <fstream>
#include "InputStringBuf.h"

InputStringBuf::InputStringBuf() : _waiting_for_input(false)
{

}

InputStringBuf::int_type InputStringBuf::underflow()
{
    std::unique_lock<std::mutex> lock(_input_mutex);

    _waiting_for_input = true;
    _has_input.wait(lock, [this](){ return !str().empty(); });
    _waiting_for_input = false;

    return basic_stringbuf<char>::underflow();
}


void InputStringBuf::set_str(std::string const &__s)
{
    basic_stringbuf::str(__s + "\n");
    _has_input.notify_one();
}
