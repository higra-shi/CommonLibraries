//
//  HSSelectDateViewController.m
//  CommonLibraries
//
//  Created by 原田 周作 on 2014/04/20.
//  Copyright (c) 2014年 Shusaku HARADA. All rights reserved.
//

#import "HSSelectDateViewController.h"

@interface HSSelectDateViewController () {
    UIPopoverController *popoverController__;
    NSDate *selectedDate__;
    UIView *brankView__;
    HSSelectDateView *selectDateView__;
}

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) UIView *brankView;
@property (nonatomic, strong) HSSelectDateView *selectDateView;

@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation HSSelectDateViewController

@synthesize popoverController = popoverController__;
@synthesize selectedDate = selectedDate__;
@synthesize brankView = brankView__;
@synthesize selectDateView = selectDateView__;

#pragma mark - Select date view control

- (void)destroySelectDateView
{
    if (self.selectDateView && [self.selectDateView superview]) {
        NSLog(@"remove select date view");
        [self.selectDateView removeFromSuperview];
    }
    self.selectDateView.delegate = nil;
    self.selectDateView = nil;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:HSSelectDateViewDidSelectDateNotification object:NULL];
    [nc removeObserver:self name:HSSelectDateViewDidDismissSelectDateViewNotification object:NULL];
}

- (void)destroyPopoverController
{
    if (self.popoverController) {
        self.popoverController.delegate = nil;
    }
    self.popoverController = nil;
    
    [self destroySelectDateView];
}

- (void)didHideBrankView:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    self.brankView.hidden = YES;
    [self destroySelectDateView];
}

- (void)didCloseSelectedView:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [UIView beginAnimations:@"hideBrankView" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didHideBrankView:finished:context:)];
    
    self.brankView.alpha = 0.0;
    
    [UIView commitAnimations];
}

- (void)showSelectDateView:(UIButton *)sender
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didSelectDateNotification:)
               name:HSSelectDateViewDidSelectDateNotification
             object:NULL];
    [nc addObserver:self selector:@selector(didDismissSelectDateViewNotification:)
               name:HSSelectDateViewDidDismissSelectDateViewNotification
             object:NULL];
    if (!self.selectDateView) {
        self.selectDateView = [[HSSelectDateView alloc] initWithFrame:CGRectZero datePickerMode:UIDatePickerModeDate canChangeDatePickerMode:YES];
        self.selectDateView.delegate = self;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIViewController *vc = [[UIViewController alloc] init];
        [vc.view addSubview:self.selectDateView];
        [vc setPreferredContentSize:self.selectDateView.frame.size];
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        [self.popoverController presentPopoverFromRect:sender.frame inView:[sender superview]
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += viewFrame.size.height;
        viewFrame.size = self.selectDateView.frame.size;
        self.selectDateView.frame = viewFrame;
        if (![self.selectDateView superview]) {
            [self.view addSubview:self.selectDateView];
        }
        self.brankView.hidden = NO;
        self.brankView.alpha = 0.0;
        
        [UIView beginAnimations:@"showingSelectDate" context:NULL];
        
        viewFrame.origin.y -= viewFrame.size.height;
        self.selectDateView.frame = viewFrame;
        self.brankView.alpha = 0.3;
        
        [UIView commitAnimations];
    }
}

#pragma mark - Date control

- (NSString *)stringFromDate:(NSDate *)aDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    return [formatter stringFromDate:aDate];
}

#pragma mark - View life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.popoverController = nil;
    self.selectDateView = nil;
    
    self.selectedDate = [NSDate date];
    
    CGRect viewFrame = CGRectMake(32, 32, 128, 32);
    viewFrame.origin.y += 44;
    UIButton *button = [[UIButton alloc] initWithFrame:viewFrame];
    button.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    [button setTitle:[self stringFromDate:self.selectedDate] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showSelectDateView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.brankView = [[UIView alloc] initWithFrame:self.view.frame];
    self.brankView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    self.brankView.alpha = 0.3;
    self.brankView.hidden = YES;
    [self.view addSubview:self.brankView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *currentToutch = [touches anyObject];
    if ([currentToutch.view isEqual:self.brankView]) {
        [self selectDateViewDidDismissSelectDateView:self.selectDateView];
    }
}

#pragma mark - Popover controller delegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"dismissed popover controller");
    [self destroyPopoverController];
}

#pragma mark - Select date view delegate

- (void)didSelectDateNotification:(NSNotification *)notification
{
    NSLog(@"didSelectDateNotification:%@", notification);
    self.selectedDate = [notification object];
}

- (void)didDismissSelectDateViewNotification:(NSNotification *)notification
{
    NSLog(@"didDismissSelectDateViewNotification:%@", notification);
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        [self destroyPopoverController];
    }
    else {
        CGRect viewFrame = self.selectDateView.frame;
        
        [UIView beginAnimations:@"closingSelectDateView" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didCloseSelectedView:finished:context:)];
        
        viewFrame.origin.y += viewFrame.size.height;
        self.selectDateView.frame = viewFrame;
        
        [UIView commitAnimations];
    }
}

- (void)selectDateViewDidSelectDate:(NSDate *)aSelectedDate
{
    NSLog(@"selected date: %@", aSelectedDate);
    [self didSelectDateNotification:[NSNotification notificationWithName:HSSelectDateViewDidSelectDateNotification object:aSelectedDate]];
}

- (void)selectDateViewDidDismissSelectDateView:(UIView *)aSelectDateView
{
    NSLog(@"dismissed select date view");
    [self didDismissSelectDateViewNotification:[NSNotification notificationWithName:HSSelectDateViewDidDismissSelectDateViewNotification object:aSelectDateView]];
}

@end
