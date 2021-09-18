//
//  MKLFXCColorSettingPickView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCColorSettingPickView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKCustomUIAdopter.h"

@interface MKLFXCColorSettingPickViewModel : NSObject

@property (nonatomic, assign)NSInteger colorType;

@property (nonatomic, copy)NSString *colorMsg;

@end

@implementation MKLFXCColorSettingPickViewModel
@end

@interface MKLFXCColorSettingPickView ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIPickerView *pickerView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, assign)NSInteger currentColorType;

@end

@implementation MKLFXCColorSettingPickView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGB(0xf2f2f2);
        [self addSubview:self.msgLabel];
        [self addSubview:self.pickerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(15.f);
        make.bottom.mas_equalTo(-15.f);
    }];
}

#pragma mark - 代理方法

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44.f;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.dataList.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view{
    UILabel *titleLabel = (UILabel *)view;
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = DEFAULT_TEXT_COLOR;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = MKFont(14.f);
    }
    MKLFXCColorSettingPickViewModel *model = self.dataList[row];
    if(model.colorType == self.currentColorType){
        /*选中后的row的字体颜色*/
        /*重写- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0) __TVOS_PROHIBITED; 方法加载 attributedText*/
        
        titleLabel.attributedText
        = [self pickerView:pickerView attributedTitleForRow:row forComponent:component];
        
    }else{
        
        titleLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    }
    return titleLabel;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    MKLFXCColorSettingPickViewModel *model = self.dataList[row];
    return model.colorMsg;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    MKLFXCColorSettingPickViewModel *model = self.dataList[row];
    return [MKCustomUIAdopter attributedString:@[model.colorMsg]
                                         fonts:@[MKFont(14.f)]
                                        colors:@[UIColorFromRGB(0x2F84D0)]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    MKLFXCColorSettingPickViewModel *model = self.dataList[row];
    self.currentColorType = model.colorType;
    [self.pickerView reloadAllComponents];
    if ([self.delegate respondsToSelector:@selector(lfxc_colorSettingPickViewTypeChanged:)]) {
        [self.delegate lfxc_colorSettingPickViewTypeChanged:model.colorType];
    }
}

#pragma mark - public
- (void)updateColorType:(NSInteger)colorType {
    [self loadPickViewDatas];
    [self.pickerView reloadAllComponents];
    self.currentColorType = colorType;
    NSInteger selectedRow = 0;
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKLFXCColorSettingPickViewModel *model = self.dataList[i];
        if (model.colorType == colorType) {
            selectedRow = i;
            break;
        }
    }
    [self.pickerView selectRow:selectedRow inComponent:0 animated:YES];
}

#pragma mark - private method
- (void)loadPickViewDatas {
    MKLFXCColorSettingPickViewModel *transitionDirectlyModel = [[MKLFXCColorSettingPickViewModel alloc] init];
    transitionDirectlyModel.colorMsg = @"Active power indicator with color direct transition";
    transitionDirectlyModel.colorType = 0;
    [self.dataList addObject:transitionDirectlyModel];
    
    MKLFXCColorSettingPickViewModel *transitionSmoothlyModel = [[MKLFXCColorSettingPickViewModel alloc] init];
    transitionSmoothlyModel.colorMsg = @"Active power indicator with color smooth transition";
    transitionSmoothlyModel.colorType = 1;
    [self.dataList addObject:transitionSmoothlyModel];
    
    MKLFXCColorSettingPickViewModel *whiteModel = [[MKLFXCColorSettingPickViewModel alloc] init];
    whiteModel.colorMsg = @"White";
    whiteModel.colorType = 2;
    [self.dataList addObject:whiteModel];
    
    MKLFXCColorSettingPickViewModel *redModel = [[MKLFXCColorSettingPickViewModel alloc] init];
    redModel.colorMsg = @"Red";
    redModel.colorType = 3;
    [self.dataList addObject:redModel];
    
    MKLFXCColorSettingPickViewModel *greenModel = [[MKLFXCColorSettingPickViewModel alloc] init];
    greenModel.colorMsg = @"Green";
    greenModel.colorType = 4;
    [self.dataList addObject:greenModel];
    
    MKLFXCColorSettingPickViewModel *blueModel = [[MKLFXCColorSettingPickViewModel alloc] init];
    blueModel.colorMsg = @"Blue";
    blueModel.colorType = 5;
    [self.dataList addObject:blueModel];
    
    MKLFXCColorSettingPickViewModel *orangeModel = [[MKLFXCColorSettingPickViewModel alloc] init];
    orangeModel.colorMsg = @"Yellow";
    orangeModel.colorType = 6;
    [self.dataList addObject:orangeModel];
    
    MKLFXCColorSettingPickViewModel *cyanModel = [[MKLFXCColorSettingPickViewModel alloc] init];
    cyanModel.colorMsg = @"Cyan";
    cyanModel.colorType = 7;
    [self.dataList addObject:cyanModel];
    
    MKLFXCColorSettingPickViewModel *purpleModel = [[MKLFXCColorSettingPickViewModel alloc] init];
    purpleModel.colorMsg = @"Purple";
    purpleModel.colorType = 8;
    [self.dataList addObject:purpleModel];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(14.f);
        _msgLabel.text = @"Select power indicator color when device is ON";
    }
    return _msgLabel;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        
        _pickerView.layer.masksToBounds = YES;
        _pickerView.layer.borderColor = UIColorFromRGB(0x2F84D0).CGColor;
        _pickerView.layer.borderWidth = 0.5f;
        _pickerView.layer.cornerRadius = 4.f;
    }
    return _pickerView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}


@end
