//
//  HSSelectDateViewController.m
//  CommonLibraries
//
//  Created by 原田 周作 on 2014/04/20.
//  Copyright (c) 2014年 Shusaku HARADA. All rights reserved.
//

#import "HSSelectDateViewController.h"
#import "CommonConst.h"

@interface HSSelectDateViewController () {
}

@property (nonatomic, weak) UIButton *dateButton;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, weak) UIView *brankView;
@property (nonatomic, weak) HSSelectDateView *selectDateView;

@end

@implementation HSSelectDateViewController

@synthesize dateButton;
@synthesize popoverController;
@synthesize selectedDate;
@synthesize brankView;
@synthesize selectDateView;

#pragma mark - Select date view control

- (void)destroySelectDateView
{
    if (self.selectDateView) {
        self.selectDateView.delegate = nil;
        if ([self.selectDateView superview]) {
            NSLog(@"remove select date view");
            [self.selectDateView removeFromSuperview];
        }
    }
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
    HSSelectDateView *dateView = nil;
    if (!self.selectDateView) {
        dateView = [[HSSelectDateView alloc] initWithFrame:self.view.frame datePickerMode:UIDatePickerModeDate canChangeDatePickerMode:YES];
        self.selectDateView = dateView;
        self.selectDateView.delegate = self;
    }
    [self.selectDateView setSelectedDate:self.selectedDate animated:NO];

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
    self.dateButton = button;

    UIView *dummyView = [[UIView alloc] initWithFrame:self.view.frame];
    dummyView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    dummyView.alpha = 0.3;
    dummyView.hidden = YES;
    dummyView.autoresizingMask = (1 << 6) - 1;
    [self.view addSubview:dummyView];
    self.brankView = dummyView;

    viewFrame = self.navigationController.navigationBar.frame;
    viewFrame.origin = CGPointZero;
    UIView *headerView = [[UIView alloc] initWithFrame:viewFrame];
    headerView.backgroundColor = [UIColor redColor];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.navigationItem setTitleView:headerView];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self.selectDateView setAlpha:0.0];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    
    CGRect viewFrame = CGRectZero;

    viewFrame.size = [self.selectDateView resizeView];
    viewFrame.origin.y = self.view.frame.size.height - viewFrame.size.height;
    self.selectDateView.frame = viewFrame;

    [self.selectDateView setAlpha:1.0];
}

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
    [self.dateButton setTitle:[self stringFromDate:self.selectedDate] forState:UIControlStateNormal];
}

- (void)didDismissSelectDateViewNotification:(NSNotification *)notification
{
    NSLog(@"didDismissSelectDateViewNotification:%@", notification);
    if (self.popoverController) {
        if ([self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        }
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
