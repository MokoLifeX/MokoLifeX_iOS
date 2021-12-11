//
//  MKLFXSaveDeviceController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/27.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXSaveDeviceController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "UIView+MKAdd.h"

#import "MKCustomUIAdopter.h"
#import "MKTextField.h"
#import "MKHudManager.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXDeviceListDatabaseManager.h"

@interface MKLFXSaveDeviceController ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)MKTextField *textField;

@property (nonatomic, strong)UIButton *saveButton;

@end

@implementation MKLFXSaveDeviceController

- (void)dealloc {
    NSLog(@"MKLFXSaveDeviceController销毁");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //本页面禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    self.textField.text = SafeStr(self.deviceModel.deviceName);
}

#pragma mark - event method
- (void)saveButtonPressed {
    if (!ValidStr(self.textField.text) || self.textField.text.length > 20) {
        [self.view showCentralToast:@"Device name must be 1-20 Characters!"];
        return;
    }
    self.deviceModel.deviceName = SafeStr(self.textField.text);
    [[MKHudManager share] showHUDWithTitle:@"Save..." inView:self.view isPenetration:NO];
    [MKLFXDeviceListDatabaseManager insertDeviceList:@[self.deviceModel] sucBlock:^{
        [[MKHudManager share] hide];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_lfx_addNewDeviceSuccessNotification"
                                                            object:nil
                                                          userInfo:@{@"deviceModel":self.deviceModel}];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Add Device";
    self.leftButton.hidden = YES;
    [self.view addSubview:self.msgLabel];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(defaultTopInset + 20.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(defaultTopInset + 20.f);
        make.height.mas_equalTo(35.f);
    }];
    [self.view addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(-30.f);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 50.f);
        make.height.mas_equalTo(40.f);
    }];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = NAVBAR_COLOR_MACROS;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.text = @"Connection successful!";
    }
    return _msgLabel;
}

- (MKTextField *)textField {
    if (!_textField) {
        _textField = [[MKTextField alloc] initWithTextFieldType:mk_normal];
        @weakify(self);
        _textField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            
        };
        _textField.maxLength = 20;
        _textField.placeholder = @"1-20 Characters";
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = MKFont(14.f);
        
        _textField.backgroundColor = COLOR_WHITE_MACROS;
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _textField.layer.cornerRadius = 6.f;
    }
    return _textField;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [MKCustomUIAdopter customButtonWithTitle:@"Done"
                                                        target:self
                                                        action:@selector(saveButtonPressed)];
    }
    return _saveButton;
}

@end
