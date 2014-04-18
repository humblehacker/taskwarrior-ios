//
//  HHTerminalTableViewCell
//  taskwarrior-ios
//
//  Created by david on 5/6/14.
//  Copyright 2014 David Whetstone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMR_ANSIEscapeHelper;

extern NSString *const HHTerminalCellID;

@interface HHTerminalTableViewCell : UITableViewCell

@property (nonatomic, copy) NSAttributedString *attributedString;
@property (nonatomic, strong) UIFont *font;
@end
