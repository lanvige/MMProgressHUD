//
//  MMProgressHUD.m
//  MMProgressHUD Demo
//
//  Created by Lanvige Jiang on 7/24/13.
//  Copyright (c) 2013 Lanvige Jiang. All rights reserved.
//

#if !__has_feature(objc_arc)
#error MMProgressHUD is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
#define MMTextAlignmentCenter NSTextAlignmentCenter
#else
#define MMTextAlignmentCenter UITextAlignmentCenter
#endif


#import "MMProgressHUD.h"
#import <QuartzCore/QuartzCore.h>


CGFloat MMProgressHUDRingRadius = 14;
CGFloat MMProgressHUDRingThickness = 6;


@interface MMProgressHUD ()

@property (nonatomic, strong) UIButton *overlayView;
@property (nonatomic, strong) UIView *hudView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign, readwrite) CGFloat progress;
@property (nonatomic, assign, readwrite) NSUInteger activityCount;

@property (nonatomic, strong) CAShapeLayer *backgroundRingLayer;
@property (nonatomic, strong) CAShapeLayer *ringLayer;


@property (nonatomic, strong, readwrite) UIColor *hudBackgroundColor;
@property (nonatomic, retain, readwrite) UIColor *hudForegroundColor;
@property (nonatomic, strong, readwrite) UIColor *hudStatusShadowColor;
@property (nonatomic, strong, readwrite) UIFont *hudFont;
@property (nonatomic, strong, readwrite) UIImage *hudSuccessImage;
@property (nonatomic, strong, readwrite) UIImage *hudErrorImage;

@end


@implementation MMProgressHUD

#pragma mark -
#pragma mark NSObject

+ (MMProgressHUD *)sharedView
{
    static dispatch_once_t once;
    static MMProgressHUD *sharedView;
    
    dispatch_once(&once, ^ {
        sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    
    return sharedView;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.activityCount = 0;
    }
	
    return self;
}

#pragma mark -
#pragma mark View lifecycle

+ (BOOL)isVisible
{
    return ([self sharedView].alpha == 1);
}



#pragma mark -
#pragma mark Lazy load view

// whole screen view
- (UIButton *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIButton alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
        [_overlayView setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
        [_overlayView setBackgroundImage:[UIImage new] forState:UIControlStateDisabled];
    }
    
    return _overlayView;
}

- (UIView *)hudView
{
    if (!_hudView) {
        _hudView = [[UIView alloc] initWithFrame:CGRectZero];
        _hudView.bounds = CGRectMake(0.f, 0.f, 146.f, 146.f);
        _hudView.layer.cornerRadius = 2;
        _hudView.layer.masksToBounds = YES;
        
        // UIAppearance is used when iOS >= 5.0
		_hudView.backgroundColor = self.hudBackgroundColor;
        _hudView.alpha = .8f;
        
        _hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:_hudView];
    }
    
    return _hudView;
}

- (UILabel *)statusLabel
{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_statusLabel.backgroundColor = [UIColor clearColor];
		_statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.textAlignment = MMTextAlignmentCenter;
		_statusLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        
        // UIAppearance is used when iOS >= 5.0
		_statusLabel.textColor = [UIColor whiteColor];
		_statusLabel.font = [UIFont systemFontOfSize:16.f];
        _statusLabel.frame = CGRectMake(0.f, 104.f, 146.f, 28.f);
        _statusLabel.numberOfLines = 1;
    }
    
    if (!_statusLabel.superview) {
        [self.hudView addSubview:_statusLabel];
    }
    
    return _statusLabel;
}

- (UIImageView *)imageView
{
    if (_imageView == nil)
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
        _imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 52);
    
    if (!_imageView.superview) {
        [self.hudView addSubview:_imageView];
    }
    
    return _imageView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, 40.5);
		_indicatorView.hidesWhenStopped = YES;
		_indicatorView.bounds = CGRectMake(0, 0, 35, 35);
        _indicatorView.color = [UIColor whiteColor];
    }
    
    if (!_indicatorView.superview) {
        [self.hudView addSubview:_indicatorView];
    }
    
    return _indicatorView;
}



- (UIImage *)hudSuccessImage
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if (_hudSuccessImage == nil) {
        _hudSuccessImage = [[[self class] appearance] hudSuccessImage];
    }
    
    if (_hudSuccessImage != nil) {
        return _hudSuccessImage;
    }
#endif
    
    return [UIImage imageNamed:@"MMProgressHUD.bundle/mmhud_success.png"];
}

- (UIImage *)hudErrorImage
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if (_hudErrorImage == nil) {
        _hudErrorImage = [[[self class] appearance] hudErrorImage];
    }
    
    if (_hudErrorImage != nil) {
        return _hudErrorImage;
    }
#endif
    
    return [UIImage imageNamed:@"MMProgressHUD.bundle/mmhud_error.png"];
}

- (UIColor *)hudBackgroundColor
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if (_hudBackgroundColor == nil) {
        _hudBackgroundColor = [[[self class] appearance] hudBackgroundColor];
    }
    
    if (_hudBackgroundColor != nil) {
        return _hudBackgroundColor;
    }
#endif
    
    return [UIColor colorWithWhite:0 alpha:0.8];
}


- (CAShapeLayer *)ringLayer
{
    if (!_ringLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(_hudView.frame)/2, CGRectGetHeight(_hudView.frame)/2);
        _ringLayer = [self createRingLayerWithCenter:center radius:MMProgressHUDRingRadius lineWidth:MMProgressHUDRingThickness color:[UIColor whiteColor]];
        [self.hudView.layer addSublayer:_ringLayer];
    }
    return _ringLayer;
}

- (CAShapeLayer *)backgroundRingLayer
{
    if (!_backgroundRingLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(_hudView.frame)/2, CGRectGetHeight(_hudView.frame)/2);
        _backgroundRingLayer = [self createRingLayerWithCenter:center radius:MMProgressHUDRingRadius lineWidth:MMProgressHUDRingThickness color:[UIColor darkGrayColor]];
        _backgroundRingLayer.strokeEnd = 1;
        _backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), 36);
        [self.hudView.layer addSublayer:_backgroundRingLayer];
    }
    
    return _backgroundRingLayer;
}


- (void)cancelRingLayerAnimation
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_hudView.layer removeAllAnimations];
    
    _ringLayer.strokeEnd = 0.0f;
    if (_ringLayer.superlayer) {
        [_ringLayer removeFromSuperlayer];
    }
    _ringLayer = nil;
    
    if (_backgroundRingLayer.superlayer) {
        [_backgroundRingLayer removeFromSuperlayer];
    }
    _backgroundRingLayer = nil;
    
    [CATransaction commit];
}

- (CGPoint)pointOnCircleWithCenter:(CGPoint)center radius:(double)radius angleInDegrees:(double)angleInDegrees
{
    float x = (float)(radius * cos(angleInDegrees * M_PI / 180)) + radius;
    float y = (float)(radius * sin(angleInDegrees * M_PI / 180)) + radius;
    
    return CGPointMake(x, y);
}


- (UIBezierPath *)createCirclePathWithCenter:(CGPoint)center radius:(CGFloat)radius sampleCount:(NSInteger)sampleCount
{
    UIBezierPath *smoothedPath = [UIBezierPath bezierPath];
    CGPoint startPoint = [self pointOnCircleWithCenter:center radius:radius angleInDegrees:-90];
    
    [smoothedPath moveToPoint:startPoint];
    
    CGFloat delta = 360.0f / sampleCount;
    CGFloat angleInDegrees = -90;
    for (NSInteger i = 1; i < sampleCount; i++) {
        angleInDegrees += delta;
        CGPoint point = [self pointOnCircleWithCenter:center radius:radius angleInDegrees:angleInDegrees];
        [smoothedPath addLineToPoint:point];
    }
    
    [smoothedPath addLineToPoint:startPoint];
    
    return smoothedPath;
}


- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(UIColor *)color
{
    UIBezierPath *smoothedPath = [self createCirclePathWithCenter:center radius:radius sampleCount:72];
    
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.frame = CGRectMake(center.x-radius, center.y-radius, radius*2, radius*2);
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.strokeColor = color.CGColor;
    slice.lineWidth = lineWidth;
    slice.lineCap = kCALineJoinBevel;
    slice.lineJoin = kCALineJoinBevel;
    slice.path = smoothedPath.CGPath;
    
    return slice;
}



#pragma mark -
#pragma mark Class methods

+ (void)showIndicatorWithStatus:(NSString*)status
{
    [[self sharedView] showIndicatorWithStatus:status];
}

+ (void)showProgress:(CGFloat)progress status:(NSString*)status
{
    // TODO:
}

+ (void)showSuccessWithStatus:(NSString *)status
{
    [self showImage:[[self sharedView] hudSuccessImage] status:status];
}

+ (void)showErrorWithStatus:(NSString *)status
{
    [self showImage:[[self sharedView] hudErrorImage] status:status];
}

+ (void)showImage:(UIImage *)image status:(NSString *)status
{
    [[self sharedView] showImage:image status:status];
}

+ (void)dismiss
{
    [self dismissAfterDelay:0.f];
}

+ (void)dismissAfterDelay:(NSTimeInterval)delay
{
    [[self sharedView] dismissAfterDelay:delay];
}



#pragma mark -
#pragma mark Instance methods

- (void)showHudWithType:(MMProgressHUDType)type status:(NSString *)status
{
    if (!self.overlayView.superview) {
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                [window addSubview:self.overlayView];
                break;
            }
        }
    }
    
    if (!self.superview) {
        [self.overlayView addSubview:self];
    }
    
    self.statusLabel.text = status;
    self.activityCount++;
    
    self.overlayView.userInteractionEnabled = YES;
    self.accessibilityLabel = status;
    self.isAccessibilityElement = YES;
    
    self.overlayView.hidden = NO;
    [self positionHUD:nil];
    
    if (self.alpha != 1) {
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
        MMProgressHUD *__weak weakSelf=self;
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             weakSelf.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                             weakSelf.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                             UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, status);
                         }];
        
        [self setNeedsDisplay];
    }

}

- (void)showIndicatorWithStatus:(NSString *)status
{
    self.imageView.hidden = YES;
    [self cancelRingLayerAnimation];
    [self.indicatorView startAnimating];
    
    [self showHudWithType:MMProgressHUDIndicator status:status];
}


- (void)showImage:(UIImage *)image status:(NSString *)status
{
    [self cancelRingLayerAnimation];
    
    if (![self.class isVisible]) {
        [self showHudWithType:MMProgressHUDSuccess status:status];
    }
    
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.statusLabel.text = status;
    [self positionHUD:nil];
    
    [self.indicatorView stopAnimating];

    self.accessibilityLabel = status;
    self.isAccessibilityElement = YES;
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, status);
}


- (void)positionHUD:(NSNotification*)notification
{
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    
    CGFloat posY = (orientationFrame.size.height / 2) - 60.f;
    CGFloat posX = orientationFrame.size.width / 2;
    
    CGPoint newCenter = CGPointMake(posX, posY);
    
    self.hudView.center= newCenter;
}


- (void)dismissAfterDelay:(CGFloat)delay
{
    self.activityCount = 0;
    MMProgressHUD *__weak weakSelf = self;
    [UIView animateWithDuration:0.1f
                          delay:delay
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         weakSelf.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8, 0.8);
                         weakSelf.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if(weakSelf.alpha == 0) {
                             [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
                             [weakSelf cancelRingLayerAnimation];
                             [_hudView removeFromSuperview];
                             _hudView = nil;
                             
                             [_overlayView removeFromSuperview];
                             _overlayView = nil;
                             
                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);

                         }
                     }];
}

@end
