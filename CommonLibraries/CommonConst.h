//
//  CommonConst.h
//  CommonLibraries
//
//  Created by 原田　周作 on 2014/05/30.
//  Copyright (c) 2014年 i-enter. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef CommonLibraries_CommonConst_h
#define CommonLibraries_CommonConst_h

CGSize swapSize(CGSize input) {CGFloat swap = input.height; input.height = input.width; input.width = swap; return input; }

#endif
