
#import "StatusItemView.h"
#import "BackgroundView.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate, NSTextFieldDelegate>
{
    BOOL _hasActivePanel;
}

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, readonly) id<PanelControllerDelegate> delegate;

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;

@property (nonatomic, retain) IBOutlet NSView *loginContainerView;
@property (nonatomic, retain) NSView *mainInterfaceContainerView;

@property (nonatomic, retain) IBOutlet NSImageView *logoImageView;
@property (nonatomic, retain) IBOutlet NSTextField *emailField;
@property (nonatomic, retain) IBOutlet NSTextField *passwordField;
@property (nonatomic, retain) IBOutlet NSTextField *errorLabel;

@property (nonatomic, retain) IBOutlet NSMatrix *genderMatrix;
@property NSUInteger genderOption;

@property BOOL formValid;

- (IBAction) login:(id)sender;
- (IBAction) signup:(id)sender;
- (IBAction) switchGenderTheme:(id)sender;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;

@end
