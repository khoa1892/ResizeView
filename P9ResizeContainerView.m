#import "P9ResizeContainerView.h"
#import "P9MarketCTabViewCtrl.h"

#define LIMIT_EDGE_MOVING 100
#define TITLE_HEIGHT 40

CG_INLINE CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}
@interface P9ResizeContainerView()<UIGestureRecognizerDelegate> {
    NSInteger buttonSize;
    CGSize defaultMinimumSize;
    /**
     *  Variables for moving view
     */
    CGPoint beginningPoint;
    
    /**
     *  Variables for rotating and resizing view
     */
    CGRect initFrame;
    CGPoint initalTouchPoint;
    /**
     * to control add title or not
     * Almost screen in P9 already had it's title or header to, there is some of them are not.
     * Ex: Chart & Rate Panel
     * Adding title allow user to drag/drop view on title if there is a lot of gesture on view
     **/
    bool isAddTitle;
    UILabel* screenTitle;
}
@property (nonatomic, strong, readwrite) UIView *contentView;
@property (nonatomic, strong) UIPanGestureRecognizer *moveGesture;
@property (nonatomic, strong) UIImageView *resizeRightBottomImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *resizeRightBottomGesture;
@property (nonatomic, strong) UIImageView *resizeLeftBottomImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *resizeLeftBottomGesture;
@property (nonatomic, strong) UIImageView *resizeRightTopImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *resizeRightTopGesture;
@property (nonatomic, strong) UIImageView *resizeLeftTopImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *resizeLeftTopGesture;
@property (nonatomic, strong) UIImageView *closeImageView;
@property (nonatomic, strong) UIImageView *moveImageView;
@property (nonatomic, strong) UITapGestureRecognizer *closeGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIImageView *settingImageView;
@property (nonatomic, strong) UITapGestureRecognizer *settingGesture;
@end
@implementation P9ResizeContainerView
#pragma mark - Properties

- (UIPanGestureRecognizer *)moveGesture {
    if (!_moveGesture) {
        _moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveGesture:)];
    }
    return _moveGesture;
}

- (UIPanGestureRecognizer *)rotateRightBottomGesture {
    if (!_resizeRightBottomGesture) {
        _resizeRightBottomGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizeBottomRightGesture:)];
        _resizeRightBottomGesture.delegate = self;
    }
    return _resizeRightBottomGesture;
}

- (UIPanGestureRecognizer *)rotateLeftBottomGesture {
    if (!_resizeLeftBottomGesture) {
        _resizeLeftBottomGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizeLeftBottomGesture:)];
        _resizeLeftBottomGesture.delegate = self;
    }
    return _resizeLeftBottomGesture;
}

- (UIPanGestureRecognizer *)rotateRightTopGesture {
    if (!_resizeRightTopGesture) {
        _resizeRightTopGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizeRightTopGesture:)];
        _resizeRightTopGesture.delegate = self;
    }
    return _resizeRightTopGesture;
}

- (UIPanGestureRecognizer *)rotateLeftTopGesture {
    if (!_resizeLeftTopGesture) {
        _resizeLeftTopGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizeLeftTopGesture:)];
        _resizeLeftTopGesture.delegate = self;
    }
    return _resizeLeftTopGesture;
}

- (UITapGestureRecognizer *)closeGesture {
    if (!_closeGesture) {
        _closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseGesture:)];
        _closeGesture.delegate = self;
    }
    return _closeGesture;
}

- (UITapGestureRecognizer *)settingGesture {
    if (!_settingGesture) {
        _settingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingGesture:)];
        _settingGesture.delegate = self;
    }
    return _settingGesture;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    }
    return _tapGesture;
}

- (UIImageView *)closeImageView {
    if (!_closeImageView) {
        _closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, buttonSize * 2, buttonSize * 2)];
        _closeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _closeImageView.image = [UIImage imageNamed:@"close_icon_new"];
        _closeImageView.backgroundColor = [UIColor clearColor];
        _closeImageView.userInteractionEnabled = YES;
        [_closeImageView addGestureRecognizer:self.closeGesture];
    }
    return _closeImageView;
}

-(UIImageView *)moveImageView {
    if (!_moveImageView) {
        _moveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, buttonSize * 2, buttonSize * 2)];
        _moveImageView.contentMode = UIViewContentModeScaleAspectFit;
        _moveImageView.image = [UIImage imageNamed:@"move-icon"];
        _moveImageView.backgroundColor = [UIColor clearColor];
        _moveImageView.userInteractionEnabled = YES;
    }
    return _moveImageView;
}

- (UIImageView *)resizeRightBottomImageView {
    if (!_resizeRightBottomImageView) {
        _resizeRightBottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, buttonSize * 2, buttonSize * 2)];
        _resizeRightBottomImageView.contentMode = UIViewContentModeScaleAspectFit;
        _resizeRightBottomImageView.backgroundColor = [UIColor clearColor];
        _resizeRightBottomImageView.userInteractionEnabled = YES;
        _resizeRightBottomImageView.image = [UIImage imageNamed:@"resize-bottom-right"];
        [_resizeRightBottomImageView addGestureRecognizer:self.rotateRightBottomGesture];
    }
    return _resizeRightBottomImageView;
}

- (UIImageView *)resizeLeftBottomImageView {
    if (!_resizeLeftBottomImageView) {
        _resizeLeftBottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, buttonSize * 2, buttonSize * 2)];
        _resizeLeftBottomImageView.contentMode = UIViewContentModeScaleAspectFit;
        _resizeLeftBottomImageView.backgroundColor = [UIColor clearColor];
        _resizeLeftBottomImageView.userInteractionEnabled = YES;
        _resizeLeftBottomImageView.image = [UIImage imageNamed:@"resize-bottom-left"];
        [_resizeLeftBottomImageView addGestureRecognizer:self.rotateLeftBottomGesture];
    }
    return _resizeLeftBottomImageView;
}

- (UIImageView *)resizeRightTopImageView {
    if (!_resizeRightTopImageView) {
        _resizeRightTopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, buttonSize * 2, buttonSize * 2)];
        _resizeRightTopImageView.contentMode = UIViewContentModeScaleAspectFit;
        _resizeRightTopImageView.backgroundColor = [UIColor clearColor];
        _resizeRightTopImageView.userInteractionEnabled = YES;
        _resizeRightTopImageView.image = [UIImage imageNamed:@"resize-top-right"];
        [_resizeRightTopImageView addGestureRecognizer:self.rotateRightTopGesture];
    }
    return _resizeRightTopImageView;
}

- (UIImageView *)resizeLeftTopImageView {
    if (!_resizeLeftTopImageView) {
        _resizeLeftTopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, buttonSize * 2, buttonSize * 2)];
        _resizeLeftTopImageView.contentMode = UIViewContentModeScaleAspectFit;
        _resizeLeftTopImageView.backgroundColor = [UIColor clearColor];
        _resizeLeftTopImageView.userInteractionEnabled = YES;
        _resizeLeftTopImageView.image = [UIImage imageNamed:@"resize-top-left"];
        [_resizeLeftTopImageView addGestureRecognizer:self.rotateLeftTopGesture];
    }
    return _resizeLeftTopImageView;
}

- (UIImageView *)settingImageView {
    if (!_settingImageView) {
        _settingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, buttonSize * 2, buttonSize * 2)];
        _settingImageView.contentMode = UIViewContentModeScaleAspectFit;
        _settingImageView.backgroundColor = [UIColor clearColor];
        _settingImageView.userInteractionEnabled = YES;
        _settingImageView.image = [[UIImage imageNamed:@"setting_ic"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
#ifdef LIONFXIPAD
        _settingImageView.tintColor = [UIColor blackColor];;
#elif MTRADERFXIPAD
       _settingImageView.tintColor = [UIColor whiteColor];
#else //ACTIVEFXIPAD
        _settingImageView.tintColor = [UIColor whiteColor];
#endif
        [_settingImageView addGestureRecognizer:self.settingGesture];
    }
    return _settingImageView;
}


- (void)setEnableClose:(BOOL)enableClose {
    _enableClose = enableClose;
    if (self.showEditingHandlers) {
        [self _setEnableClose:enableClose];
    }
}

- (void)setEnableResize:(BOOL)enableResize {
    _enableResize = enableResize;
    if (self.showEditingHandlers) {
        [self _setEnableResize:enableResize];
    }
}

//TODO:
- (void)setEnableSetting:(BOOL)enableSetting{
    _enableSetting = enableSetting;
    if (self.showEditingHandlers) {
        [self _setEnableSetting:enableSetting];
    }
}

-(void)setIsShowResizeButton:(BOOL)isShowResizeButton {
    if (self.keepData.viewID == NEW_TELOP_ID) {
        self.resizeRightTopImageView.hidden = !isShowResizeButton;
        self.resizeLeftTopImageView.hidden = !isShowResizeButton;
    }
}

- (void)setShowEditingHandlers:(BOOL)showEditingHandlers {
    _showEditingHandlers = showEditingHandlers;
    if (showEditingHandlers) {
        [self _setEnableClose:self.enableClose];
        [self _setEnableResize:self.enableResize];
        [self _setEnableSetting:self.enableSetting];
        self.layer.borderWidth = 2;
        self.layer.borderColor = _highLightBorderColor.CGColor;
    } else {
        [self _setEnableClose:NO];
        [self _setEnableResize:NO];
        [self _setEnableSetting:NO];
        self.layer.borderWidth = 1;
        self.layer.borderColor =  [UIColor blackColor].CGColor;
    }
}

-(void) setFrameWhenMagnet:(CGRect)frameWhenMagnet {
    self.contentView.frame = frameWhenMagnet;
}

-(void) setFrameForPartnerView:(CGRect)frameForPartnerView {
    self.frame = frameForPartnerView;
    self.contentView.frame = frameForPartnerView;
}

- (void)setMinimumSize:(CGSize)minimumSize {
    _minimumSize = minimumSize;
}

-(void)setMaximumSize:(CGSize)maximumSize {
    _maximumSize = maximumSize;
}

-(void)setIsClose:(BOOL)isClose {
    if (isClose && self.keepData.viewID == MENU_ID) {
        [self.contentView removeFromSuperview];
        [self removeFromSuperview];
    }
}

- (void)setOutlineBorderColor:(UIColor *)outlineBorderColor {
    _highLightBorderColor = outlineBorderColor;
    self.contentView.layer.borderColor = _highLightBorderColor.CGColor;
}

#pragma mark - Private Methods

- (void)_setEnableClose:(BOOL)enableClose {
    self.closeImageView.hidden = !enableClose;
    self.closeImageView.userInteractionEnabled = enableClose;
}

- (void)_setEnableResize:(BOOL)enableResize {
    self.resizeRightBottomImageView.hidden = !enableResize;
    self.resizeRightBottomImageView.userInteractionEnabled = enableResize;
    self.resizeLeftBottomImageView.hidden = !enableResize;
    self.resizeLeftBottomImageView.userInteractionEnabled = enableResize;
    self.resizeRightTopImageView.hidden = !enableResize;
    self.resizeRightTopImageView.userInteractionEnabled = enableResize;
    self.resizeLeftTopImageView.hidden = !enableResize;
    self.resizeLeftTopImageView.userInteractionEnabled = enableResize;
}

- (void)_setEnableSetting:(BOOL)enableSetting {
    self.settingImageView.hidden = !enableSetting;
    self.settingImageView.userInteractionEnabled = enableSetting;
}
#pragma mark - UIView
- (id)initWithContentView:(UIView *)contentView withID:(int)viewID addTitle:(BOOL)addTitle{
    if (!contentView) {
        return nil;
    }
    isAddTitle = addTitle;
    self.keepData = [[ScreenLayoutData alloc] initWithId:viewID];
    if (viewID == CHART_ID || viewID == NEW_TELOP_ID) {
        buttonSize = 20;
    } else {
        buttonSize = 11;
    }
    defaultMinimumSize = CGSizeMake(300,300);
    
    CGRect frame = contentView.frame;
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if(isAddTitle){
        frame = CGRectMake(0, 0, frame.size.width, frame.size.height+TITLE_HEIGHT);
    }
    else{
        frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:self.moveGesture];
        [self addGestureRecognizer:self.tapGesture];
        // Setup content view
        self.contentView = contentView;
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if ([self.contentView.layer respondsToSelector:@selector(setAllowsEdgeAntialiasing:)]) {
            [self.contentView.layer setAllowsEdgeAntialiasing:YES];
        }
        
        if(isAddTitle){
            screenTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, TITLE_HEIGHT)];
            [screenTitle setTextColor:[UIColor whiteColor]];
            [screenTitle setBackgroundColor:[UIColor blueColor]];
            screenTitle.font = [UIFont boldSystemFontOfSize:18];
            [screenTitle setTextAlignment:NSTextAlignmentCenter];
            screenTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.contentView.center = CGRectGetCenter(CGRectMake(0, TITLE_HEIGHT, frame.size.width, frame.size.height-TITLE_HEIGHT));
            [self addSubview:screenTitle];
        }
        else{
            self.contentView.center = CGRectGetCenter(self.bounds);
        }
        //        if (self.keepData.viewID == MENU_ID) {
        //            [self addSubview:self.contentView];
        //        }
        // Setup editing handlers
        //        if (viewID == MENU_ID) {
        //            if (viewID == MENU_ID) {
        //                [self setPosition:ViewPositionTopLeft forHandler:ViewHandlerMove];
        //                [self addSubview:self.moveImageView];
        //            }
        //        }
        [self setPosition:ViewPositionCloseTopRight forHandler:ViewHandlerClose];
        [self addSubview:self.closeImageView];
        [self setPosition:ViewPositionTopRight forHandler:ViewHandlerRightTopResize];
        [self addSubview:self.resizeRightTopImageView];
        [self setPosition:ViewPositionTopLeft forHandler:ViewHandlerLeftTopResize];
        [self addSubview:self.resizeLeftTopImageView];
        [self setPosition:ViewPositionBottomRight forHandler:ViewHandlerRightBottomResize];
        [self addSubview:self.resizeRightBottomImageView];
        [self setPosition:ViewPositionBottomLeft forHandler:ViewHandlerLeftBottomResize];
        [self addSubview:self.resizeLeftBottomImageView];
        [self setPosition:ViewPositionSettingTopRight forHandler:ViewHandlerSetting];
        [self addSubview:self.settingImageView];
        
        if (self.keepData.viewID == NEW_TELOP_ID) {
            self.resizeRightTopImageView.hidden = YES;
            self.resizeLeftTopImageView.hidden = YES;
        }
        
        self.showEditingHandlers = YES;
        self.enableClose = YES;
        
        if(self.keepData.viewID == QUICK_ID){
            self.enableResize = NO;
        }
        else{
            self.enableResize = YES;
        }
        
        if (self.keepData.viewID == QUICK_ID) {
            self.enableSetting = YES;
        }else{
            self.enableSetting = NO;
        }
        
        self.minimumSize = defaultMinimumSize;
        self.outlineBorderColor = [UIColor brownColor];
    }
    self.clipsToBounds = YES;
    return self;
}

-(id) initWithContentView:(UIView *)contentView withID:(int)viewID addController:(UIViewController *)controller {
    if (!contentView) {
        return nil;
    }
    self.controller = controller;
    self.keepData = [[ScreenLayoutData alloc] initWithId:viewID];
    if (viewID == CHART_ID || viewID == NEW_TELOP_ID) {
        buttonSize = 20;
    } else {
        buttonSize = 11;
    }
    defaultMinimumSize = CGSizeMake(300,300);
    
    CGRect frame = contentView.frame;
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if(isAddTitle){
        frame = CGRectMake(0, 0, frame.size.width, frame.size.height+TITLE_HEIGHT);
    }
    else{
        frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:self.moveGesture];
        [self addGestureRecognizer:self.tapGesture];
        // Setup content view
        self.contentView = contentView;
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if ([self.contentView.layer respondsToSelector:@selector(setAllowsEdgeAntialiasing:)]) {
            [self.contentView.layer setAllowsEdgeAntialiasing:YES];
        }
        
        if(isAddTitle){
            screenTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, TITLE_HEIGHT)];
            [screenTitle setTextColor:[UIColor whiteColor]];
            [screenTitle setBackgroundColor:[UIColor blueColor]];
            screenTitle.font = [UIFont boldSystemFontOfSize:18];
            [screenTitle setTextAlignment:NSTextAlignmentCenter];
            screenTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.contentView.center = CGRectGetCenter(CGRectMake(0, TITLE_HEIGHT, frame.size.width, frame.size.height-TITLE_HEIGHT));
            [self addSubview:screenTitle];
        }
        else{
            self.contentView.center = CGRectGetCenter(self.bounds);
        }
        [self setPosition:ViewPositionCloseTopRight forHandler:ViewHandlerClose];
        [self addSubview:self.closeImageView];
        [self setPosition:ViewPositionTopRight forHandler:ViewHandlerRightTopResize];
        [self addSubview:self.resizeRightTopImageView];
        [self setPosition:ViewPositionTopLeft forHandler:ViewHandlerLeftTopResize];
        [self addSubview:self.resizeLeftTopImageView];
        [self setPosition:ViewPositionBottomRight forHandler:ViewHandlerRightBottomResize];
        [self addSubview:self.resizeRightBottomImageView];
        [self setPosition:ViewPositionBottomLeft forHandler:ViewHandlerLeftBottomResize];
        [self addSubview:self.resizeLeftBottomImageView];
        [self setPosition:ViewPositionSettingTopRight forHandler:ViewHandlerSetting];
        [self addSubview:self.settingImageView];
        
        if (self.keepData.viewID == NEW_TELOP_ID) {
            self.resizeRightTopImageView.hidden = YES;
            self.resizeLeftTopImageView.hidden = YES;
        }
        
        self.showEditingHandlers = YES;
        self.enableClose = YES;
        
        if(self.keepData.viewID == QUICK_ID){
            self.enableResize = NO;
        }
        else{
            self.enableResize = YES;
        }
        
        if (self.keepData.viewID == QUICK_ID) {
            self.enableSetting = YES;
        }else{
            self.enableSetting = NO;
        }
        
        self.minimumSize = defaultMinimumSize;
        self.outlineBorderColor = [UIColor brownColor];
    }
    self.clipsToBounds = YES;
    return self;
}

#pragma mark - Gesture Handlers

- (void)handleMoveGesture:(UIPanGestureRecognizer *)recognizer {
    CGPoint touchLocation = [recognizer locationInView:self.superview];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            //TODO- NEED TO dispatch event to inside view!!!!!!!!
            if(isAddTitle){
                CGPoint location = [recognizer locationInView:self];
                BOOL withinBounds = CGRectContainsPoint(screenTitle.bounds, location);
                if(!withinBounds){
                    initFrame = CGRectNull;
                    return;
                }
            }
            initFrame = self.frame;
            beginningPoint = touchLocation;
            if ([self.delegate respondsToSelector:@selector(viewDidBeginMoving:)]) {
                [self.delegate viewDidBeginMoving:self];
            }
            
            break;
            
        case UIGestureRecognizerStateChanged:{
            //TODO- NEED TO dispatch event to inside view!!!!!!!!
            if(CGRectEqualToRect(initFrame,CGRectNull)){
                return;
            }
            CGPoint originalPoint;
            originalPoint = CGPointMake(initFrame.origin.x + (touchLocation.x - beginningPoint.x),
                                        initFrame.origin.y + (touchLocation.y - beginningPoint.y));
            self.frame = CGRectMake(originalPoint.x, originalPoint.y, self.frame.size.width, self.frame.size.height);
            self.contentView.frame = self.frame;
            if ([self.delegate respondsToSelector:@selector(viewDidChangeMoving:)]) {
                [self.delegate viewDidChangeMoving:self];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            //TODO- NEED TO dispatch event to inside view!!!!!!!!
            if(CGRectEqualToRect(initFrame,CGRectNull)){
                return;
            }
            self.keepData.savedFrame = self.frame;
            if ([self.delegate respondsToSelector:@selector(viewDidEndMoving:)]) {
                [self.delegate viewDidEndMoving:self];
            }
            break;
            
        default:
            break;
    }
}
-(bool) moveToReachedLimit:(CGPoint)newOriginal{
    CGRect frame = self.frame;
    CGRect currFrame = initFrame;
    bool isLimit = false;
    if(newOriginal.x  < 0 && (fabs(newOriginal.x + frame.size.width)<self.frame.size.width)){
        newOriginal.x = self.frame.size.width - initFrame.size.width;
        isLimit = true;
    }
    if(newOriginal.x  > 0 && newOriginal.x >self.superview.frame.size.width - self.frame.size.width){
        newOriginal.x = self.superview.frame.size.width - self.frame.size.width;
        isLimit = true;
    }
    if(newOriginal.y  < 0 && (fabs(newOriginal.y + frame.size.height)<self.frame.size.height)){
        newOriginal.y = self.frame.size.height - initFrame.size.height;
        isLimit = true;
    }
    if(newOriginal.y  > 0 && newOriginal.y >self.superview.frame.size.height - self.frame.size.height){
        newOriginal.y = self.superview.frame.size.height - self.frame.size.height;
        isLimit = true;
    }
    currFrame.origin = newOriginal;
    self.frame = currFrame;
    self.contentView.frame = currFrame;
    return isLimit;
    
}

- (void)handleResizeBottomRightGesture:(UIPanGestureRecognizer *)recognizer {
    CGPoint touchLocation = [recognizer locationInView:self.superview];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            initFrame = self.frame;
            initalTouchPoint = touchLocation;
            if ([self.delegate respondsToSelector:@selector(viewDidBeginResize:)]) {
                [self.delegate viewDidBeginResize:self];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            double scalex = initFrame.size.width + (touchLocation.x - initalTouchPoint.x);
            double scaley = initFrame.size.height + (touchLocation.y - initalTouchPoint.y);
            if(scalex < _minimumSize.width){
                scalex = _minimumSize.width;
            }
            if(scaley < _minimumSize.height){
                scaley = _minimumSize.height;
            }
            if (self.keepData.viewID == MARGIN_ID) {
                if (scaley > _maximumSize.height) {
                    scaley = _maximumSize.height;
                }
            }
            CGRect scaledBounds = CGRectMake(initFrame.origin.x, initFrame.origin.y,scalex , scaley);
            if (initFrame.origin.x + scalex >= self.superview.frame.size.width && initFrame.origin.y + scaley >= self.superview.frame.size.height) {
                scaledBounds = CGRectMake(initFrame.origin.x, initFrame.origin.y, self.superview.frame.size.width - initFrame.origin.x, self.superview.frame.size.height - initFrame.origin.y);
            } else if (initFrame.origin.x + scalex >= self.superview.frame.size.width) {
                scaledBounds = CGRectMake(initFrame.origin.x, initFrame.origin.y, self.superview.frame.size.width - initFrame.origin.x, scaley);
            } else if (initFrame.origin.y + scaley >= self.superview.frame.size.height) {
                scaledBounds = CGRectMake(initFrame.origin.x, initFrame.origin.y, scalex, self.superview.frame.size.height - initFrame.origin.y);
            }
            self.frame = scaledBounds;
            self.contentView.frame = scaledBounds;
            [self setNeedsDisplay];
            if ([self.delegate respondsToSelector:@selector(viewDidChangedSize: andResizeType:)]) {
                [self.delegate viewDidChangedSize:self andResizeType:ViewHandlerRightBottomResize];
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            self.keepData.savedFrame = self.frame;
            if ([self.delegate respondsToSelector:@selector(viewDidEndResize:)]) {
                [self.delegate viewDidEndResize:self];
            }
            break;
            
        default:
            break;
    }
}

-(void) handleResizeLeftBottomGesture: (UIPanGestureRecognizer *)recognizer {
    
    CGPoint touchLocation = [recognizer locationInView:self.superview];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            initFrame = self.frame;
            initalTouchPoint = touchLocation;
            if ([self.delegate respondsToSelector:@selector(viewDidBeginResize:)]) {
                [self.delegate viewDidBeginResize:self];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint scalePoint = [recognizer translationInView:self];
            double scalex = initFrame.size.width - scalePoint.x;
            double scaley = initFrame.size.height + (touchLocation.y - initalTouchPoint.y);
            double positionX = initFrame.origin.x + scalePoint.x;
            double positionY = initFrame.origin.y;
            if(scalex < _minimumSize.width){
                scalex = _minimumSize.width;
                positionX = initFrame.origin.x + (initFrame.size.width - _minimumSize.width);
            }
            if(scaley < _minimumSize.height){
                scaley = _minimumSize.height;
            }
            if (self.keepData.viewID == MARGIN_ID) {
                if (scaley > _maximumSize.height) {
                    scaley = _maximumSize.height;
                }
            }
            CGRect scaledBounds = CGRectMake(positionX , positionY,scalex, scaley);
            if (initFrame.origin.x + scalePoint.x < 0 && initFrame.origin.y + scaley >= self.superview.frame.size.height) {
                scaledBounds = CGRectMake(0, initFrame.origin.y, self.frame.size.width, self.frame.size.height);
            }else if (initFrame.origin.x + scalePoint.x < 0) {
                scaledBounds = CGRectMake(0, positionY, self.frame.size.width, scaley);
            }else if (initFrame.origin.y + scaley >= self.superview.frame.size.height){
                scaledBounds = CGRectMake(positionX, initFrame.origin.y, scalex, self.superview.frame.size.height - initFrame.origin.y);
            }
            self.frame = scaledBounds;
            self.contentView.frame = scaledBounds;
            [self setNeedsDisplay];
            if ([self.delegate respondsToSelector:@selector(viewDidChangedSize:andResizeType:)]) {
                [self.delegate viewDidChangedSize:self andResizeType:ViewHandlerLeftBottomResize];
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            self.keepData.savedFrame = self.frame;
            if ([self.delegate respondsToSelector:@selector(viewDidEndResize:)]) {
                [self.delegate viewDidEndResize:self];
            }
            break;
            
        default:
            break;
    }
}

-(void) handleResizeLeftTopGesture:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint touchLocation = [recognizer locationInView:self.superview];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            initFrame = self.frame;
            initalTouchPoint = touchLocation;
            if ([self.delegate respondsToSelector:@selector(viewDidBeginResize:)]) {
                [self.delegate viewDidBeginResize:self];
            }
            break;
        }

        case UIGestureRecognizerStateChanged: {
            CGPoint scalePoint = [recognizer translationInView:self];
            double scalex = initFrame.size.width - scalePoint.x;
            double scaley = initFrame.size.height - scalePoint.y;
            double positionX = initFrame.origin.x + scalePoint.x;
            double positionY = initFrame.origin.y + scalePoint.y;
            if(scalex < _minimumSize.width){
                scalex = _minimumSize.width;
                positionX = initFrame.origin.x + (initFrame.size.width - _minimumSize.width);
            }
            if(scaley < _minimumSize.height){
                scaley = _minimumSize.height;
                positionY = initFrame.origin.y + (initFrame.size.height - _minimumSize.height);
            }
            if (self.keepData.viewID == MARGIN_ID) {
                if (scaley > _maximumSize.height) {
                    scaley = _maximumSize.height;
                    positionY = initFrame.origin.y + (initFrame.size.height - _maximumSize.height);
                }
            }
            CGRect scaledBounds = CGRectMake(positionX , positionY,scalex, scaley);
            NSLog(@"%f", positionX);
            if (positionX < 0 && positionY < 0) {
                scaledBounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            }else if (positionX < 0) {
                scaledBounds = CGRectMake(0, positionY, self.frame.size.width, scaley);
            }else if (positionY < 0){
                scaledBounds = CGRectMake(positionX, 0, scalex, self.frame.size.height);
            }
            self.frame = scaledBounds;
            self.contentView.frame = self.frame;
            NSLog(@"%f", self.frame.origin.x);
            [self setNeedsDisplay];
            if ([self.delegate respondsToSelector:@selector(viewDidChangedSize:andResizeType:)]) {
                [self.delegate viewDidChangedSize:self andResizeType:ViewHandlerLeftTopResize];
            }
            break;
        }

        case UIGestureRecognizerStateEnded:
            self.keepData.savedFrame = self.frame;
            if ([self.delegate respondsToSelector:@selector(viewDidEndResize:)]) {
                [self.delegate viewDidEndResize:self];
            }
            break;

        default:
            break;
    }
}


-(void) handleResizeRightTopGesture:(UIPanGestureRecognizer *)recognizer {
    CGPoint touchLocation = [recognizer locationInView:self.superview];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            initFrame = self.frame;
            initalTouchPoint = touchLocation;
            if ([self.delegate respondsToSelector:@selector(viewDidBeginResize:)]) {
                [self.delegate viewDidBeginResize:self];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint scalePoint = [recognizer translationInView:self];
            double scalex = initFrame.size.width + (touchLocation.x - initalTouchPoint.x);
            double scaley = initFrame.size.height - scalePoint.y;
            double positionX = initFrame.origin.x;
            double positionY = initFrame.origin.y + scalePoint.y;
            if(scalex < _minimumSize.width){
                scalex = _minimumSize.width;
            }
            if(scaley < _minimumSize.height){
                scaley = _minimumSize.height;
                positionY = initFrame.origin.y + (initFrame.size.height - _minimumSize.height);
            }
            if (self.keepData.viewID == MARGIN_ID) {
                if (scaley > _maximumSize.height) {
                    scaley = _maximumSize.height;
                    positionY = initFrame.origin.y + (initFrame.size.height - _maximumSize.height);
                }
            }
            CGRect scaledBounds = CGRectMake(positionX , positionY,scalex, scaley);
            if (initFrame.origin.x + scalex >= self.superview.frame.size.width && positionY < 0) {
                scaledBounds = CGRectMake(initFrame.origin.x, 0, self.frame.size.width, self.frame.size.height);
            } else if (initFrame.origin.x + scalex >= self.superview.frame.size.width) {
                scaledBounds = CGRectMake(self.frame.origin.x, positionY, self.superview.frame.size.width - self.frame.origin.x, scaley);
            } else if (positionY < 0) {
                scaledBounds = CGRectMake(positionX, 0, scalex, self.frame.size.height);
            }
            self.frame = scaledBounds;
            self.contentView.frame = scaledBounds;
            [self setNeedsDisplay];
            if ([self.delegate respondsToSelector:@selector(viewDidChangedSize:andResizeType:)]) {
                [self.delegate viewDidChangedSize:self andResizeType:ViewHandlerRightTopResize];
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            self.keepData.savedFrame = self.frame;
            if ([self.delegate respondsToSelector:@selector(viewDidEndResize:)]) {
                [self.delegate viewDidEndResize:self];
            }
            break;
            
        default:
            break;
    }
}

- (void)handleCloseGesture:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(viewDidClose:)]) {
        [self.delegate viewDidClose:self];
    }
    [self.contentView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)handleSettingGesture:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(viewDidTapSetting:andSender:)]) {
        [self.delegate viewDidTapSetting:self andSender:_settingImageView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.contentView]) {
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    return YES;
}

- (void)handleFlipGesture:(UITapGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.transform = CGAffineTransformScale(self.contentView.transform, -1, 1);
    }];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(viewDidTap:)]) {
        [self.delegate viewDidTap:self];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    /**
     * ref: http://stackoverflow.com/questions/19095165/should-superviews-gesture-cancel-subviews-gesture-in-ios-7/
     *
     * The `gestureRecognizer` would be either closeGestureRecognizer or rotateGestureRecognizer,
     * `otherGestureRecognizer` should work only when `gestureRecognizer` is failed.
     * So, we always return YES here.
     */
    return YES;
}

#pragma mark - Public Methods
- (void)setPosition:(ViewPosition)position forHandler:(ViewHandler)handler {
    CGPoint origin = self.frame.origin;
    CGSize size = self.contentView.frame.size;
    UIImageView *handlerView = nil;
    
    switch (handler) {
        case ViewHandlerClose:
            handlerView = self.closeImageView;
            break;
        case ViewHandlerRightBottomResize:
            handlerView = self.resizeRightBottomImageView;
            break;
        case ViewHandlerLeftBottomResize:
            handlerView = self.resizeLeftBottomImageView;
            break;
        case ViewHandlerRightTopResize:
            handlerView = self.resizeRightTopImageView;
            break;
        case ViewHandlerLeftTopResize:
            handlerView = self.resizeLeftTopImageView;
            break;
        case ViewHandlerMove:
            handlerView = self.moveImageView;
            break;
        case ViewHandlerSetting:
            handlerView = self.settingImageView;
            break;
    }
    
    switch (position) {
        case ViewPositionTopLeft:
            handlerView.center = CGPointMake(origin.x + buttonSize, origin.y+buttonSize);
            handlerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
            
        case ViewPositionTopRight:
            handlerView.center = CGPointMake(size.width-buttonSize,buttonSize);
            handlerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
            
        case ViewPositionCloseTopRight:
            switch (self.keepData.viewID) {
                case QUICK_ID:
                    handlerView.center = CGPointMake(origin.x + size.width - buttonSize, buttonSize);
                    break;
                default:
                     handlerView.center = CGPointMake(size.width-buttonSize - 50,buttonSize);
                    break;
            }
            handlerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
            
        case ViewPositionBottomLeft:
            handlerView.center = CGPointMake(origin.x+ buttonSize, origin.y + size.height- buttonSize);
            handlerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            break;
            
        case ViewPositionBottomRight:
            handlerView.center = CGPointMake(origin.x + size.width-buttonSize, origin.y + size.height- buttonSize);
            handlerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            break;
            
        case ViewPositionSettingTopRight:
            handlerView.center = CGPointMake(size.width-buttonSize - 50,buttonSize);
            handlerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
    }
    
    handlerView.tag = position;
}

- (void)setButtonSize:(NSInteger)size {
    if (size <= 0) {
        return;
    }
    
    buttonSize = round(size / 2);
    
    CGPoint originalCenter = self.center;
    CGAffineTransform originalTransform = self.transform;
    CGRect frame = self.contentView.frame;
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    if(isAddTitle){
        self.contentView.center = CGRectGetCenter(CGRectMake(0, TITLE_HEIGHT, frame.size.width, frame.size.height));
    }
    else{
        self.contentView.center = CGRectGetCenter(self.bounds);
    }
    
    [self.contentView removeFromSuperview];
    
    self.transform = CGAffineTransformIdentity;
    self.frame = frame;
    [self addSubview:self.contentView];
    [self sendSubviewToBack:self.contentView];
    
    CGRect handlerFrame = CGRectMake(0, 0, buttonSize * 2, buttonSize * 2);
    self.closeImageView.frame = handlerFrame;
    [self setPosition:self.closeImageView.tag forHandler:ViewHandlerClose];
    self.resizeRightBottomImageView.frame = handlerFrame;
    [self setPosition:self.resizeRightBottomImageView.tag forHandler:ViewHandlerRightBottomResize];
    self.resizeLeftBottomImageView.frame = handlerFrame;
    [self setPosition:self.resizeLeftBottomImageView.tag forHandler:ViewHandlerLeftBottomResize];
    self.resizeRightTopImageView.frame = handlerFrame;
    [self setPosition:self.resizeRightTopImageView.tag forHandler:ViewHandlerRightTopResize];
    self.resizeLeftTopImageView.frame = handlerFrame;
    [self setPosition:self.resizeLeftTopImageView.tag forHandler:ViewHandlerLeftTopResize];
    self.settingImageView.frame = handlerFrame;
    [self setPosition:self.settingImageView.tag forHandler:ViewHandlerSetting];
    
    self.center = originalCenter;
    self.transform = originalTransform;
}

- (void) setTitle:(NSString*) title{
    [screenTitle setText:title];
}

@end
