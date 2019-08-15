#import <UIKit/UIKit.h>
#import "ScreenLayoutData.h"

typedef NS_ENUM (NSInteger, ViewHandler) {
    ViewHandlerClose,
    ViewHandlerRightBottomResize,
    ViewHandlerLeftBottomResize,
    ViewHandlerRightTopResize,
    ViewHandlerLeftTopResize,
    ViewHandlerMove,
    ViewHandlerSetting
};

typedef NS_ENUM (NSInteger, ViewPosition) {
    ViewPositionTopLeft,
    ViewPositionTopRight,
    ViewPositionCloseTopRight,
    ViewPositionBottomLeft,
    ViewPositionBottomRight,
    ViewPositionSettingTopRight,
};
typedef NS_ENUM (NSInteger, ViewID) {
    CHART_ID,
    NEW_TELOP_ID,
    RATE_LIST_ID,
    RATE_PANEL_ID,
    RATE_PANEL_SMALL_ID,
    RATE_PANEL_ONE,
    QUICK_ID,
    MARGIN_ID,
    ORDER_POS_LIST_ID,
    MENU_ID,
    NEWS_LIST_ID,
    NEWS_LIST_LANDSCAPE_ID,
    EMPTY_ID
};



@class P9ResizeContainerView;
/*
 To dispatch event move, resize, touch and close
 */
@protocol P9ResizeContainerViewDelegate <NSObject>
@optional
- (void)viewDidBeginMoving:(P9ResizeContainerView *)view;
- (void)viewDidChangeMoving:(P9ResizeContainerView *)view;
- (void)viewDidEndMoving:(P9ResizeContainerView *)view;

- (void)viewDidBeginResize:(P9ResizeContainerView *)view;
- (void)viewDidChangedSize:(P9ResizeContainerView *)view andResizeType:(int) type;
- (void)viewDidEndResize:(P9ResizeContainerView *)view;

- (void)viewDidClose:(P9ResizeContainerView *)view;

- (void)viewDidTap:(P9ResizeContainerView *)view;

- (void)viewDidTapSetting:(P9ResizeContainerView *)view andSender:(id)sender;
@end
/*
 This protocol to call refresh screen when resize view.
 */
@protocol P9ResizeContentUpdateDelegate <NSObject>
@optional
- (void)reloadViewWhenResize;
@end
@interface P9ResizeContainerView:UIView
@property (nonatomic, weak) id <P9ResizeContentUpdateDelegate> updateContentWhenResizeDel;
@property (nonatomic, weak) id <P9ResizeContainerViewDelegate> delegate;
/// The contentView inside
@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, assign) BOOL enableClose;
@property (nonatomic, assign) BOOL enableResize;
@property (nonatomic, assign) BOOL enableSetting;
@property (nonatomic, assign) BOOL showEditingHandlers;
@property (nonatomic, assign) CGRect frameForPartnerView;
@property (nonatomic, assign) CGRect frameWhenMagnet;
@property (nonatomic, assign) CGSize minimumSize;
@property (nonatomic, assign) CGSize maximumSize;
@property (nonatomic, assign) BOOL isClose;
@property (nonatomic, assign) BOOL isShowResizeButton;
@property (nonatomic, strong) UIColor *highLightBorderColor;
@property (nonatomic, strong) UIViewController *controller;
//To data at userdefault
@property (nonatomic, strong) ScreenLayoutData* keepData;

- (id)initWithContentView:(UIView *)contentView withID:(int)viewID addTitle:(BOOL)addTitle;
-(id) initWithContentView:(UIView *)contentView withID:(int)viewID addController:(UIViewController *)controller;
// for position of controls: close, resize...
- (void)setPosition:(ViewPosition)position forHandler:(ViewHandler)handler;
- (void)setButtonSize:(NSInteger)size;
- (void) setTitle:(NSString*) title;
@end
