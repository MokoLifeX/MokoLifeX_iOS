//
//  MKLFXConnectShowView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/20.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXConnectShowView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

static NSString *const titleMsg = @"Connect to device's hotspot";
static NSString *const step1Msg = @"1.Go to your device Settings > Wi-Fi";
static NSString *const step2Msg = @"2.Connect to the Wi-Fi as below";
static NSString *const step3Msg = @"3.Back to the App and continue";

static NSTimeInterval const animationDuration = .3f;

@interface MKLFXConnectShowCenterView : UIView

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, strong)UILabel *msgLabel1;

@property (nonatomic, strong)UILabel *msgLabel2;

@property (nonatomic, strong)UIImageView *centerIcon;

@property (nonatomic, strong)UILabel *msgLabel3;

@property (nonatomic, strong)UIView *lineView1;

@property (nonatomic, strong)UIView *lineView2;

@property (nonatomic, strong)UIButton *cancelButton;

@property (nonatomic, strong)UIButton *confirmButton;

@end

@implementation MKLFXConnectShowCenterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.msgLabel1];
        [self addSubview:self.msgLabel2];
        [self addSubview:self.centerIcon];
        [self addSubview:self.msgLabel3];
        [self addSubview:self.lineView1];
        [self addSubview:self.lineView2];
        [self addSubview:self.cancelButton];
        [self addSubview:self.confirmButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize titleSize = [NSString sizeWithText:self.titleLabel.text
                                      andFont:self.titleLabel.font
                                   andMaxSize:CGSizeMake(self.frame.size.width - 2 * 10.f, MAXFLOAT)];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10.f);
        make.top.mas_equalTo(20.f);
        make.height.mas_equalTo(titleSize.height);
    }];
    CGSize msgLabelSize1 = [NSString sizeWithText:self.msgLabel1.text
                                          andFont:self.msgLabel1.font
                                       andMaxSize:CGSizeMake(self.frame.size.width - 2 * 10.f, MAXFLOAT)];
    [self.msgLabel1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10.f);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(30.f);
        make.height.mas_equalTo(msgLabelSize1.height);
    }];
    CGSize msgLabelSize2 = [NSString sizeWithText:self.msgLabel2.text
                                          andFont:self.msgLabel2.font
                                       andMaxSize:CGSizeMake(self.frame.size.width - 2 * 10.f, MAXFLOAT)];
    [self.msgLabel2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10.f);
        make.top.mas_equalTo(self.msgLabel1.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(msgLabelSize2.height);
    }];
    [self.centerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(179.f);
        make.top.mas_equalTo(self.msgLabel2.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(122.f);
    }];
    CGSize msgLabelSize3 = [NSString sizeWithText:self.msgLabel3.text
                                          andFont:self.msgLabel3.font
                                       andMaxSize:CGSizeMake(self.frame.size.width - 2 * 10.f, MAXFLOAT)];
    [self.msgLabel3 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.right.mas_equalTo(-10.f);
        make.top.mas_equalTo(self.centerIcon.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(msgLabelSize3.height);
    }];
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(self.lineView2.mas_left);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(45.f);
    }];
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lineView2.mas_right);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(45.f);
    }];
    [self.lineView2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(CUTTING_LINE_HEIGHT);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(45.f);
    }];
    [self.lineView1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.cancelButton.mas_top);
        make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
    }];
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = DEFAULT_TEXT_COLOR;
        _titleLabel.font = MKFont(16.f);
        _titleLabel.text = titleMsg;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)msgLabel1 {
    if (!_msgLabel1) {
        _msgLabel1 = [[UILabel alloc] init];
        _msgLabel1.textAlignment = NSTextAlignmentLeft;
        _msgLabel1.font = MKFont(14.f);
        _msgLabel1.textColor = RGBCOLOR(143, 143, 143);
        _msgLabel1.text = step1Msg;
        _msgLabel1.numberOfLines = 0;
    }
    return _msgLabel1;
}

- (UILabel *)msgLabel2 {
    if (!_msgLabel2) {
        _msgLabel2 = [[UILabel alloc] init];
        _msgLabel2.textAlignment = NSTextAlignmentLeft;
        _msgLabel2.font = MKFont(14.f);
        _msgLabel2.textColor = RGBCOLOR(143, 143, 143);
        _msgLabel2.text = step2Msg;
        _msgLabel2.numberOfLines = 0;
    }
    return _msgLabel2;
}

- (UIImageView *)centerIcon {
    if (!_centerIcon) {
        _centerIcon = [[UIImageView alloc] init];
        _centerIcon.image = LOADICON(@"MokoLifeX", @"MKLFXConnectShowView", @"lfx_AlertWifiSettingsIcon.png");
    }
    return _centerIcon;
}

- (UILabel *)msgLabel3 {
    if (!_msgLabel3) {
        _msgLabel3 = [[UILabel alloc] init];
        _msgLabel3.textAlignment = NSTextAlignmentLeft;
        _msgLabel3.font = MKFont(14.f);
        _msgLabel3.textColor = RGBCOLOR(143, 143, 143);
        _msgLabel3.text = step3Msg;
        _msgLabel3.numberOfLines = 0;
    }
    return _msgLabel3;
}

- (UIView *)lineView1 {
    if (!_lineView1) {
        _lineView1 = [[UIView alloc] init];
        _lineView1.backgroundColor = CUTTING_LINE_COLOR;
    }
    return _lineView1;
}

- (UIView *)lineView2 {
    if (!_lineView2) {
        _lineView2 = [[UIView alloc] init];
        _lineView2.backgroundColor = CUTTING_LINE_COLOR;
    }
    return _lineView2;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:NAVBAR_COLOR_MACROS forState:UIControlStateNormal];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:NAVBAR_COLOR_MACROS forState:UIControlStateNormal];
    }
    return _confirmButton;
}

@end

@interface MKLFXConnectShowView ()

@property (nonatomic, strong)MKLFXConnectShowCenterView *alertView;

@property (nonatomic, copy)void (^confirmBlock)(void);

@end

@implementation MKLFXConnectShowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = kAppWindow.bounds;
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        [self addSubview:self.alertView];
        [self addTapAction];
    }
    return self;
}

#pragma mark - event method
- (void)cancelButtonPressed {
    [self dismiss];
}

- (void)confirmButtonPressed {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
    [self dismiss];
}

#pragma mark - public method
- (void)showWithConfirmBlock:(void (^)(void))confirmBlock {
    self.confirmBlock = confirmBlock;
    [kAppWindow addSubview:self];
    [UIView animateWithDuration:animationDuration animations:^{
        self.alertView.transform = CGAffineTransformMakeTranslation(-(kViewWidth - 55.f), 0);
    }];
}

- (void)dismiss {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark - Private method
- (void)addTapAction {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(dismiss)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - getter
- (MKLFXConnectShowCenterView *)alertView {
    if (!_alertView) {
        _alertView = [[MKLFXConnectShowCenterView alloc] initWithFrame:CGRectMake(kViewWidth, defaultTopInset + 50.f, (kViewWidth - 2 * 55.f), 350.f)];
        _alertView.backgroundColor = COLOR_WHITE_MACROS;
        [_alertView.cancelButton addTarget:self
                                    action:@selector(cancelButtonPressed)
                          forControlEvents:UIControlEventTouchUpInside];
        [_alertView.confirmButton addTarget:self
                                     action:@selector(confirmButtonPressed)
                           forControlEvents:UIControlEventTouchUpInside];
        
        _alertView.layer.masksToBounds = YES;
        _alertView.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _alertView.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _alertView.layer.cornerRadius = 6.f;
    }
    return _alertView;
}

@end
