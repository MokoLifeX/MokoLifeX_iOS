//
//  MKColorSettingPickView.m
//  MokoLifeX
//
//  Created by aa on 2020/6/16.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKColorSettingPickView.h"

static CGFloat const pickViewRowHeight = 44.f;

@interface MKColorPickerModel : NSObject

@property (nonatomic, assign)mk_ledColorType colorType;

@property (nonatomic, copy)NSString *colorMsg;

@end
@implementation MKColorPickerModel

@end

@interface MKColorSettingPickView ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIPickerView *pickerView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, assign)mk_ledColorType currentColorType;

@end

@implementation MKColorSettingPickView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
        make.width.mas_equalTo(260.f);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(15.f);
        make.bottom.mas_equalTo(-15.f);
    }];
}

#pragma mark - 代理方法

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return pickViewRowHeight;
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
    MKColorPickerModel *model = self.dataList[row];
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
    MKColorPickerModel *model = self.dataList[row];
    return model.colorMsg;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    MKColorPickerModel *model = self.dataList[row];
    NSAttributedString *attString = [MKAttributedString getAttributedString:@[model.colorMsg]
                                                                      fonts:@[MKFont(14.f)]
                                                                     colors:@[UIColorFromRGB(0x2F84D0)]];
    return attString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    MKColorPickerModel *model = self.dataList[row];
    self.currentColorType = model.colorType;
    [self.pickerView reloadAllComponents];
    if ([self.delegate respondsToSelector:@selector(colorSettingPickViewTypeChanged:)]) {
        [self.delegate colorSettingPickViewTypeChanged:model.colorType];
    }
}

#pragma mark - public
- (void)updateColorType:(mk_ledColorType)colorType {
    [self loadPickViewDatas];
    [self.pickerView reloadAllComponents];
    self.currentColorType = colorType;
    NSInteger selectedRow = 0;
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKColorPickerModel *model = self.dataList[i];
        if (model.colorType == colorType) {
            selectedRow = i;
            break;
        }
    }
    [self.pickerView selectRow:selectedRow inComponent:0 animated:YES];
}

#pragma mark - private method
- (void)loadPickViewDatas {
    MKColorPickerModel *transitionSmoothlyModel = [[MKColorPickerModel alloc] init];
    transitionSmoothlyModel.colorMsg = @"Color transition smoothly";
    transitionSmoothlyModel.colorType = mk_ledColorTransitionSmoothly;
    [self.dataList addObject:transitionSmoothlyModel];
    
    MKColorPickerModel *transitionDirectlyModel = [[MKColorPickerModel alloc] init];
    transitionDirectlyModel.colorMsg = @"Color transition directly";
    transitionDirectlyModel.colorType = mk_ledColorTransitionDirectly;
    [self.dataList addObject:transitionDirectlyModel];
    
    MKColorPickerModel *whiteModel = [[MKColorPickerModel alloc] init];
    whiteModel.colorMsg = @"White";
    whiteModel.colorType = mk_ledColorWhite;
    [self.dataList addObject:whiteModel];
    
    MKColorPickerModel *redModel = [[MKColorPickerModel alloc] init];
    redModel.colorMsg = @"Red";
    redModel.colorType = mk_ledColorRed;
    [self.dataList addObject:redModel];
    
    MKColorPickerModel *greenModel = [[MKColorPickerModel alloc] init];
    greenModel.colorMsg = @"Green";
    greenModel.colorType = mk_ledColorGreen;
    [self.dataList addObject:greenModel];
    
    MKColorPickerModel *blueModel = [[MKColorPickerModel alloc] init];
    blueModel.colorMsg = @"Blue";
    blueModel.colorType = mk_ledColorBlue;
    [self.dataList addObject:blueModel];
    
    MKColorPickerModel *orangeModel = [[MKColorPickerModel alloc] init];
    orangeModel.colorMsg = @"Orange";
    orangeModel.colorType = mk_ledColorOrange;
    [self.dataList addObject:orangeModel];
    
    MKColorPickerModel *cyanModel = [[MKColorPickerModel alloc] init];
    cyanModel.colorMsg = @"Cyan";
    cyanModel.colorType = mk_ledColorCyan;
    [self.dataList addObject:cyanModel];
    
    MKColorPickerModel *purpleModel = [[MKColorPickerModel alloc] init];
    purpleModel.colorMsg = @"Purple";
    purpleModel.colorType = mk_ledColorPurple;
    [self.dataList addObject:purpleModel];
    
    MKColorPickerModel *disableModel = [[MKColorPickerModel alloc] init];
    disableModel.colorMsg = @"LED disabled";
    disableModel.colorType = mk_ledColorDisable;
    [self.dataList addObject:disableModel];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(14.f);
        _msgLabel.text = @"Select LED color when device ON";
    }
    return _msgLabel;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        // 显示选中框,iOS10以后分割线默认的是透明的，并且默认是显示的，设置该属性没有意义了，
        _pickerView.showsSelectionIndicator = YES;
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
