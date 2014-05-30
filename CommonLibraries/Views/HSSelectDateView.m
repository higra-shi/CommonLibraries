//
//  HSSelectDateView.m
//  CommonLibraries
//
//  Created by 原田 周作 on 2014/04/20.
//  Copyright (c) 2014年 Shusaku HARADA. All rights reserved.
//

#import "HSSelectDateView.h"

NSString *const HSSelectDateViewDidSelectDateNotification = @"didSelectDateNotification";
NSString *const HSSelectDateViewDidDismissSelectDateViewNotification = @"didDissmissSelectDateViewNotification";

@interface HSSelectDateView () {
}

@property (nonatomic, weak) UIToolbar *viewControlToolBar;
@property (nonatomic, weak) UIDatePicker *datePicker;
@property (nonatomic, weak) UIToolbar *pickerModeToolBar;
@property (nonatomic, weak) UISegmentedControl *pickerModeControl;

@end

@implementation HSSelectDateView

@synthesize viewControlToolBar;
@synthesize datePicker;
@synthesize pickerModeToolBar;
@synthesize pickerModeControl;

#pragma mark - Selected date

- (void)setSelectedDate:(NSDate *)aSelectedDate animated:(BOOL)aAnimated
{
    if ([self.datePicker isKindOfClass:[UIDatePicker class]]) {
        [self.datePicker setDate:aSelectedDate animated:aAnimated];
    }
}

- (NSDate *)selectedDate
{
    if ([self.datePicker isKindOfClass:[UIDatePicker class]]) {
        return [self.datePicker date];
    }
    
    return NULL;
}

#pragma mark - Button events

- (void)didDismissSelectDateView
{
}

- (void)cancelButtonTapped:(id)sender
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(selectDateViewDidDismissSelectDateView:)]) {
        [self.delegate selectDateViewDidDismissSelectDateView:self];
    }
    else {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:HSSelectDateViewDidDismissSelectDateViewNotification object:self];
    }
}

- (void)doneButtonTapped:(id)sender
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(selectDateViewDidSelectDate:)]) {
        [self.delegate selectDateViewDidSelectDate:self.selectedDate];
    }
    else {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:HSSelectDateViewDidSelectDateNotification object:self.selectedDate];
    }
    
    [self cancelButtonTapped:sender];
}

- (void)changeDatePickerMode:(id)sender
{
    UIDatePickerMode datePickerMode = UIDatePickerModeDate;
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {
            case 0:
                datePickerMode = UIDatePickerModeTime;
                break;
            case 1:
                datePickerMode = UIDatePickerModeDate;
                break;
            case 2:
                datePickerMode = UIDatePickerModeDateAndTime;
                break;
            case 3:
                datePickerMode = UIDatePickerModeCountDownTimer;
                break;
            default:
                break;
        }
    }
    self.datePicker.datePickerMode = datePickerMode;
}

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame datePickerMode:(UIDatePickerMode)aDatePickerMode canChangeDatePickerMode:(BOOL)canChangeDatePickerMode
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.viewControlToolBar = NULL;
        self.datePicker = NULL;
        self.pickerModeToolBar = NULL;
        self.pickerModeControl = NULL;

        CGRect viewFrame = CGRectZero;
        UIDatePicker *picker = [[UIDatePicker alloc] init];
        picker.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        picker.datePickerMode = aDatePickerMode;
        [picker sizeToFit];
        [self addSubview:picker];
        self.datePicker = picker;

        UIBarButtonItem *barButtonItem = nil;
        NSMutableArray *buttons = [NSMutableArray array];
        // cancel button
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                      target:self action:@selector(cancelButtonTapped:)];
        [buttons addObject:barButtonItem];
        barButtonItem = nil;
        // flexible space
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                      target:NULL action:NULL];
        [buttons addObject:barButtonItem];
        barButtonItem = nil;
        // done button
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                      target:self action:@selector(doneButtonTapped:)];
        [buttons addObject:barButtonItem];
        barButtonItem = nil;
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:viewFrame];
        [toolBar setItems:buttons];
        [toolBar sizeToFit];
        [self addSubview:toolBar];
        self.viewControlToolBar = toolBar;
        toolBar = nil;

        if (canChangeDatePickerMode) {
            [buttons removeAllObjects];

            // flexible space
            barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:NULL action:NULL];
            [buttons addObject:barButtonItem];
            barButtonItem = nil;
            // change date picker mode
            NSMutableArray *titles = [NSMutableArray array];
            [titles addObject:NSLocalizedString(@"Time", NULL)];
            [titles addObject:NSLocalizedString(@"Date", NULL)];
            [titles addObject:NSLocalizedString(@"Date & Time", NULL)];
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:titles];
            [segmentedControl sizeToFit];
            switch (aDatePickerMode) {
                case UIDatePickerModeTime:
                    [segmentedControl setSelectedSegmentIndex:0];
                    break;
                case UIDatePickerModeDate:
                    [segmentedControl setSelectedSegmentIndex:1];
                    break;
                    
                default:
                    break;
            }
            [segmentedControl addTarget:self action:@selector(changeDatePickerMode:) forControlEvents:UIControlEventValueChanged];
            [segmentedControl sizeToFit];
            barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
            [buttons addObject:barButtonItem];
            self.pickerModeControl = segmentedControl;
            barButtonItem = nil;
            // flexible space
            barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:NULL action:NULL];
            [buttons addObject:barButtonItem];
            barButtonItem = nil;

            toolBar = [[UIToolbar alloc] initWithFrame:viewFrame];
            [toolBar setItems:buttons];
            [toolBar sizeToFit];
            [self addSubview:toolBar];
            self.pickerModeToolBar = toolBar;
            toolBar = nil;
        }

        frame.size = [self resizeView];
        self.frame = frame;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame datePickerMode:UIDatePickerModeDate canChangeDatePickerMode:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGSize)resizeView
{
    CGRect viewFrame = CGRectZero;
    [self.datePicker sizeToFit];
    viewFrame.size = self.datePicker.frame.size;

    [self.viewControlToolBar sizeToFit];
    viewFrame.size.height = self.viewControlToolBar.frame.size.height;
    self.viewControlToolBar.frame = viewFrame;
    viewFrame.origin.y += viewFrame.size.height;

    if (self.pickerModeToolBar) {
        [self.pickerModeToolBar sizeToFit];
        viewFrame.size.height = self.pickerModeToolBar.frame.size.height;
        self.pickerModeToolBar.frame = viewFrame;
        viewFrame.origin.y += viewFrame.size.height;
    }

    viewFrame.size = self.datePicker.frame.size;
    self.datePicker.frame = viewFrame;

    viewFrame.size.height += viewFrame.origin.y;
    return viewFrame.size;
}

@end
