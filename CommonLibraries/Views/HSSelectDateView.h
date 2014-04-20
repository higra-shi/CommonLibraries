//
//  HSSelectDateView.h
//  CommonLibraries
//
//  Created by 原田 周作 on 2014/04/20.
//  Copyright (c) 2014年 Shusaku HARADA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HSSelectDateViewDelegate <NSObject>

- (void)selectDateViewDidSelectDate:(NSDate *)aSelectedDate;
- (void)selectDateViewDidDismissSelectDateView:(UIView *)aSelectDateView;

@end

@interface HSSelectDateView : UIView {
    
}

@property (nonatomic, weak) id<HSSelectDateViewDelegate> delegate;

- (void)setSelectedDate:(NSDate *)aSelectedDate animated:(BOOL)aAnimated;
- (NSDate *)selectedDate;

- (id)initWithFrame:(CGRect)frame datePickerMode:(UIDatePickerMode)aDatePickerMode canChangeDatePickerMode:(BOOL)canChangeDatePickerMode;


UIKIT_EXTERN NSString *const HSSelectDateViewDidSelectDateNotification;
UIKIT_EXTERN NSString *const HSSelectDateViewDidDismissSelectDateViewNotification;

@end
