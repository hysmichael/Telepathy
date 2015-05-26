
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"

#import "PanelController.h"
#import "StatusItemView.h"
#import "MenubarController.h"

#import "ClockWidgetController.h"
#import "EmotionChartController.h"
#import "MessageController.h"
#import "EventWidgetController.h"
#import "AnniversaryController.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1

#define kPanelWidth 300.0

#define kPanelHeight 502.0
#define kPaenlHieghtPriorLogin 420.0

@interface PanelController()

@property (nonatomic, retain) ClockWidgetController  *clockWidget;
@property (nonatomic, retain) AnniversaryController  *anniversaryWidget;
@property (nonatomic, retain) MessageController      *messageWidget;
@property (nonatomic, retain) EventWidgetController  *eventWidget;
@property (nonatomic, retain) EmotionChartController *emotionChartWidget;

@end


#pragma mark -

@implementation PanelController

#pragma mark - Initialization

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Once Time Setup

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    self.mainInterfaceContainerView = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, kPanelWidth, kPanelHeight)];
    [[panel contentView] addSubview:self.mainInterfaceContainerView];
    self.mainInterfaceContainerView.hidden = true;
    
    self.formValid = false;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    
    // set up login screen
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        self.genderOption = ([currentUser[@"gender"] isEqualToString:@"male"] ? 1 : 0);
        self.emailField.stringValue = currentUser.username;
        [self.passwordField becomeFirstResponder];
        [PFUser logOut];
    } else {
        self.genderOption = 0;
    }
    [self setColorThemeForLoginScreen:false];
    
    // set up main user interface in background
    [self setupMainUserInterface];
}

- (void) setupMainUserInterface {
    self.clockWidget = [[ClockWidgetController alloc] initWithViewFrame:NSMakeRect(20.0, 390.0, 260.0, 80.0)
                                                             parentView:self.mainInterfaceContainerView];
    self.emotionChartWidget = [[EmotionChartController alloc] initWithViewFrame:NSMakeRect(25.0, 350.0, 250.0, 30.0)
                                                                     parentView:self.mainInterfaceContainerView];
    self.messageWidget = [[MessageController alloc] initWithViewFrame:NSMakeRect(20.0, 190.0, 260.0, 150.0)
                                                           parentView:self.mainInterfaceContainerView];
    self.eventWidget = [[EventWidgetController alloc] initWithViewFrame:NSMakeRect(20.0, 70.0, 260.0, 100.0)
                                                             parentView:self.mainInterfaceContainerView];
    self.anniversaryWidget = [[AnniversaryController alloc] initWithViewFrame:NSMakeRect(20.0, 20.0, 260.0, 30.0)
                                                                   parentView:self.mainInterfaceContainerView];
    
    [self.mainInterfaceContainerView strokeLineFromPoint:NSMakePoint(25.0, 60.0) length:250.0 width:1.0 color:[TPColor seperatorBlue]];
    [self.mainInterfaceContainerView strokeLineFromPoint:NSMakePoint(25.0, 180.0) length:250.0 width:1.0 color:[TPColor seperatorBlue]];
}

#pragma mark - NSWindow Basics (Frame, Notification)

- (void)windowWillClose:(NSNotification *)notification {
    self.hasActivePanel = NO;
}


/* Close the panel when user clicked somewhere else */
- (void)windowDidResignKey:(NSNotification *)notification; {
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
}

- (NSRect) statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

#pragma mark - NSPanel Basics (Open, Close, Resize)

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag {
    if (_hasActivePanel != flag) {
        _hasActivePanel = flag;
        if (_hasActivePanel) {
            [self openPanel];
        } else {
            [self closePanel];
        }
    }
}

- (void) openPanel {
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];
    
    NSRect panelRect = [panel frame];
    panelRect.size.width = kPanelWidth;
    panelRect.size.height = ([PFUser currentUser] ? kPanelHeight : kPaenlHieghtPriorLogin);
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:YES];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel setFrame:panelRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    [self updateMainUserInterface];
    
    // animate to open
    NSTimeInterval openDuration = OPEN_DURATION;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (void) closePanel {
    
    [[DataManager sharedManager] commitUserState];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        [self.window orderOut:nil];
    });
}

- (void) reopenPanel {
    [self.window orderOut:nil];
    [self openPanel];
}


#pragma mark - Login Screen Logics

-(void) setColorThemeForLoginScreen:(BOOL) animated {
    CGColorRef colorRef;
    if (self.genderOption == 0) {
        colorRef = CGColorCreateGenericRGB(184/255.0, 119/255.0, 250/155.0, 0.2);
    } else {
        colorRef = CGColorCreateGenericRGB(109/255.0, 176/255.0, 244/255.0, 0.2);
    }
    
    CALayer *layer = self.loginContainerView.layer;
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        animation.fromValue = (__bridge id)(layer.backgroundColor);
        animation.toValue = (__bridge id)(colorRef);
        animation.duration = 0.5;
        [layer addAnimation:animation forKey:@"backgroundColor"];
    }
    layer.backgroundColor = colorRef;
    
    [self.logoImageView setImage:[NSImage imageNamed:(self.genderOption == 0 ? @"logo_female" : @"logo_male")]];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    self.formValid = ([self.emailField.stringValue length] > 0 && [self.emailField.stringValue containsString:@"@"] &&
                      [self.passwordField.stringValue length] > 0);
}

- (void)signup:(id)sender {
    PFUser *user = [PFUser user];
    
    user.username = self.emailField.stringValue;
    user.password = self.passwordField.stringValue;
    user.email = self.emailField.stringValue;
    
    user[@"gender"] = (self.genderOption == 0 ? @"female" : @"male");
    user[@"currentEIndex"] = @(3);
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self reopenPanel];
        } else {
            NSNumber *errorCode = [error userInfo][@"code"];
            if ([errorCode intValue] == 202) {
                self.errorLabel.stringValue = @"Email Registered";
            } else {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"SINGUP ERROR: %@", errorString);
                self.errorLabel.stringValue = @"Unknown Error";
            }
        }
    }];
}

- (void)login:(id)sender {
    [PFUser logInWithUsernameInBackground:self.emailField.stringValue
                                 password:self.passwordField.stringValue
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            [self reopenPanel];
                                        } else {
                                            self.errorLabel.stringValue = @"Login Failed";
                                        }
                                    }];
}

- (void)switchGenderTheme:(id)sender {
    [self setColorThemeForLoginScreen: true];
}


#pragma mark - Main Interface Logics

- (void) updateMainUserInterface {
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        self.loginContainerView.hidden = true;
        self.mainInterfaceContainerView.hidden = false;
        
        [[DataManager sharedManager] prepareUserData:^(int status) {
            if (status == STATUS_UserDataAllReady) {
                [self.clockWidget updateClockWidget];
                [self.emotionChartWidget updateEmotionChartWidget];
                [self.messageWidget updateMessageWidget];
                [self.eventWidget updateEventWidget];
                [self.anniversaryWidget updateAnniversaryWidget];
                
                /* pull active tokens from server */
                [[DataManager sharedManager] getPartnerActiveTokensSinceDays:7];
                
                /* register recurrent event to pull new notifications from the server */
                AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                [delegate registerRecurrentEvents];
            }
        }];
    } else {
        self.loginContainerView.hidden = false;
        self.mainInterfaceContainerView.hidden = true;
    }
}



@end
