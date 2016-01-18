//
//  MultiPictureLayoutView.m
//  demo
//
//  Created by ios_zhu on 16/1/15.
//  Copyright © 2016年 ios_zhu. All rights reserved.
//

#import "MultiPictureLayoutView.h"
#import "UIImageView+WebCache.h"

#define SPLITLINE_WIDTH   1
#define IMAGE_URL   @"imageUrl"
#define IMAGE_WIDTH   @"image_width"
#define IMAGE_HEIGHT   @"image_height"
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]


@interface MultiPictureLayoutView ()
{
    BOOL _isInited;
    NSMutableArray *_imageViewArray;
    UIButton *_signButton;
}
@end


@implementation MultiPictureLayoutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        _imageViewArray = [NSMutableArray array];
        [self creatImageViews];
        [self createSignButton];
        _isInited = YES;
    }
    
    return self;
}

- (void)creatImageViews
{
    for (NSInteger index = 0; index < 9; index++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        [_imageViewArray addObject:imageView];
    }
}


- (void)setPictures:(NSArray *)pictures
{
    NSInteger count = pictures.count;
    
    if (count == 0) {
        [self free];
        
        return;
    }
    
    count = MIN(count, 9);
    _pictures = [pictures subarrayWithRange:NSMakeRange(0, count)];
    _isInited = NO;
    
    [self setNeedsLayout];
}

- (void)free
{
    _isInited = NO;
    _pictures = nil;
    
    //    NSInteger count = _pictures.count;
    //    for (NSInteger index = 0; index < count; index++) {
    //        UIImageView *imageView = _imageViewArray[index];
    //        imageView.image = nil;
    //        [imageView sd_cancelCurrentImageLoad];
    //        [imageView removeFromSuperview];
    //    }
    
    for (UIImageView *imageView in _imageViewArray) {
        imageView.image = nil;
        [imageView sd_cancelCurrentImageLoad];
        [imageView removeFromSuperview];
    }
    
        [_signButton removeFromSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    if (_isInited || (width == 0)) {
        return;
    }
    
    _isInited = YES;
    //  以下代码为计算 imageView 的布局
    NSInteger count = _pictures.count;
    NSArray *imagesFrameArray = [self layoutSubviewsCustoms:count withItemWidth:width];
    
    for (NSInteger index = 0; index < count; index++) {
        NSDictionary *imageDict = _pictures[index];
        UIImageView *imageView = _imageViewArray[index];
        
        imageView.frame = [imagesFrameArray[index] CGRectValue];
        
        //  在使用过程中，取图片地址的方式按照实际需求做改动
        NSString *imageUrl = [imageDict objectForKey:IMAGE_URL];
        if (imageUrl.length > 0) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        }
        
        [self addSubview:imageView];
    }
    
    NSString *title;
    if (count == 1) {
        //  宽、长
        NSDictionary *imageDict = _pictures[0];
        NSNumber *imageWidth = [imageDict objectForKey:IMAGE_WIDTH];
        NSNumber *imageHeight = [imageDict objectForKey:IMAGE_HEIGHT];
        
        if (imageWidth == 0 || imageHeight == 0) {
            return ;
        }
        
        CGFloat scale = imageHeight.floatValue / imageWidth.floatValue;
        
        if (scale < 0.5) {
            scale = 0.5;
            title = @"宽图";
        }
        else if (scale > 1.5) {
            scale = 1.5;
            title = @"长图";
        }
    }
    else if (count > 1){
        // 多图
        title = @"多图";
    }
    
    if (title.length != 0) {
        _signButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 64, CGRectGetHeight(self.frame) - 23, 64, 23);
        [_signButton setTitle:title forState:UIControlStateNormal];
        [self addSubview:_signButton];
    }
}


#pragma mark - 计算 frame，返回装有 frame 的数组

- (NSArray *)layoutSubviewsCustoms:(NSInteger )count withItemWidth:(CGFloat)width
{
    if (count == 0) {
        return nil;
    }
    
    CGFloat originY = 0;
    NSMutableArray *array = [NSMutableArray array];
    
    switch (count) {
        case 1:{
            originY = [self layoutOneSpecialStyleView:array withItemWidth:width];
            break;
        }
            
        case 2: {
            originY = [self layoutTwoStyleView:array withOriginY:0 withItemWidth:width];
            break;
        }
            
        case 3: {
            originY = [self layoutNoEqualStyleView:array withOriginY:0 withItemWidth:width];
            break;
        }
            
        case 4: {
            originY = [self layoutOneStyleView:array withOriginY:0 withItemWidth:width];
            originY = [self layoutThreeEqualStyleView:array withOriginY:originY + SPLITLINE_WIDTH withItemWidth:width];
            break;
            
        }
            
        case 5: {
            originY = [self layoutTwoStyleView:array withOriginY:0 withItemWidth:width];
            originY = [self layoutThreeEqualStyleView:array withOriginY:originY + SPLITLINE_WIDTH withItemWidth:width];
            break;
        }
            
        case 6: {
            originY = [self layoutNoEqualStyleView:array withOriginY:0 withItemWidth:width];
            originY = [self layoutThreeEqualStyleView:array  withOriginY:originY + SPLITLINE_WIDTH withItemWidth:width];
            break;
        }
            
        case 7: {
            originY = [self layoutOneStyleView:array withOriginY:0 withItemWidth:width];
            originY = [self layoutThreeEqualStyleView:array withOriginY:originY + SPLITLINE_WIDTH withItemWidth:width];
            originY = [self layoutThreeEqualStyleView:array withOriginY: originY + SPLITLINE_WIDTH withItemWidth:width];
            break;
        }
            
        case 8: {
            originY = [self layoutTwoStyleView:array withOriginY:0 withItemWidth:width];
            originY = [self layoutThreeEqualStyleView:array withOriginY:originY + SPLITLINE_WIDTH withItemWidth:width];
            originY = [self layoutThreeEqualStyleView:array withOriginY: originY + SPLITLINE_WIDTH withItemWidth:width];
            break;
        }
            
        case 9: {
            originY = [self layoutNoEqualStyleView:array withOriginY:0 withItemWidth:width];
            originY = [self layoutThreeEqualStyleView:array withOriginY:originY + SPLITLINE_WIDTH withItemWidth:width];
            originY = [self layoutThreeEqualStyleView:array withOriginY:originY + SPLITLINE_WIDTH withItemWidth:width];
            break;
        }
            
        default: {
            break;
        }
    }
    
    NSArray *imageFrameArray = [NSArray arrayWithArray:array];
    
    return imageFrameArray;
}

- (CGFloat)layoutOneSpecialStyleView:(NSMutableArray *)array withItemWidth:(CGFloat)width
{
    NSNumber *imageWidth = [_pictures[0] objectForKey:@"image_width"];
    NSNumber *imageHeight = [_pictures[0] objectForKey:@"image_height"];
    
    CGFloat scaleHeight = [MultiPictureLayoutView calculateImageHeightFromBaseWidth:width withImageWidth:imageWidth.floatValue withImageHeight:imageHeight.floatValue];
    
    CGRect frame = CGRectMake(0, 0, width, scaleHeight);
    [array addObject:[NSValue valueWithCGRect:frame]];
    
    return scaleHeight;
}

- (CGFloat)layoutOneStyleView:(NSMutableArray *)array withOriginY:(CGFloat)originY withItemWidth:(CGFloat)width
{
    CGFloat baseWidth = width;
    CGFloat threeWidth = (baseWidth - SPLITLINE_WIDTH * 2) / 3.0;
    CGFloat threeBigWidth = baseWidth - threeWidth - SPLITLINE_WIDTH;
    
    CGRect frame = CGRectMake(0, originY, baseWidth, threeBigWidth);
    [array addObject:[NSValue valueWithCGRect:frame]];
    
    return originY + threeBigWidth;
}

- (CGFloat)layoutTwoStyleView:(NSMutableArray *)array withOriginY:(CGFloat)originY withItemWidth:(CGFloat)width
{
    CGFloat baseWidth = width;
    CGFloat twoWidth = (baseWidth - SPLITLINE_WIDTH) * 0.5;
    CGRect frame = CGRectMake(0, originY, twoWidth, twoWidth);
    CGRect SecondFrame = CGRectMake(twoWidth + SPLITLINE_WIDTH, originY, twoWidth, twoWidth);
    
    [array addObject:[NSValue valueWithCGRect:frame]];
    [array addObject:[NSValue valueWithCGRect:SecondFrame]];
    
    return originY + twoWidth;
}

- (CGFloat)layoutThreeEqualStyleView:(NSMutableArray *)array withOriginY:(CGFloat)originY withItemWidth:(CGFloat)width
{
    CGFloat baseWidth = width;
    CGFloat threeWidth = (baseWidth - SPLITLINE_WIDTH*2) / 3.0;
    
    CGRect frame = CGRectMake(0, originY, threeWidth, threeWidth);
    CGRect secondframe = CGRectMake(threeWidth + SPLITLINE_WIDTH, originY, threeWidth, threeWidth);
    CGRect threeFrame = CGRectMake((threeWidth + SPLITLINE_WIDTH) * 2, originY, threeWidth, threeWidth);
    
    [array addObject:[NSValue valueWithCGRect:frame]];
    [array addObject:[NSValue valueWithCGRect:secondframe]];
    [array addObject:[NSValue valueWithCGRect:threeFrame]];
    
    return originY + threeWidth;
}

- (CGFloat)layoutNoEqualStyleView:(NSMutableArray *)array withOriginY:(CGFloat)originY withItemWidth:(CGFloat)width
{
    CGFloat baseWidth = width;
    CGFloat threeWidth = (baseWidth - SPLITLINE_WIDTH * 2) / 3.0;
    CGFloat threeBigWidth = baseWidth - threeWidth - SPLITLINE_WIDTH;
    
    CGRect frame = CGRectMake(0, originY, threeBigWidth, threeBigWidth);
    CGRect secondeFrame = CGRectMake(threeBigWidth + SPLITLINE_WIDTH, originY, threeWidth, threeWidth);
    CGRect threeFrame = CGRectMake(threeBigWidth + SPLITLINE_WIDTH, threeWidth + SPLITLINE_WIDTH + originY, threeWidth, threeWidth);
    
    [array addObject:[NSValue valueWithCGRect:frame]];
    [array addObject:[NSValue valueWithCGRect:secondeFrame]];
    [array addObject:[NSValue valueWithCGRect:threeFrame]];
    
    return threeBigWidth;
}


+ (CGFloat)heightFromImageArray:(NSArray *)pictures withWidth:(CGFloat)width
{
    CGFloat baseWidth;
    if (width != 0) {
        baseWidth = width;
    }
    else {
        return 0;
    }
    
    NSInteger number = pictures.count;
    CGFloat twoWidth = (baseWidth - SPLITLINE_WIDTH) * 0.5;
    CGFloat threeWidth = (baseWidth - SPLITLINE_WIDTH * 2) / 3.0;
    CGFloat threeBigWidth = baseWidth - threeWidth - SPLITLINE_WIDTH;
    
    CGFloat height;
    switch (number) {
        case 1: {
            //  取出数组中图片的宽高度
            NSNumber *imageWidth = [pictures[0] objectForKey:@"image_width"];
            NSNumber *imageHeight = [pictures[0] objectForKey:@"image_height"];
            height = [MultiPictureLayoutView calculateImageHeightFromBaseWidth:width withImageWidth:imageWidth.floatValue withImageHeight:imageHeight.floatValue];
            break;
        }
            
        case 2: {
            height = twoWidth;
            break;
        }
            
        case 3: {
            height = threeBigWidth;
            break;
        }
            
        case 4: {
            height = threeBigWidth + threeWidth + SPLITLINE_WIDTH;
            break;
        }
            
        case 5: {
            height = twoWidth + threeWidth + SPLITLINE_WIDTH;
            break;
        }
            
        case 6: {
            height = threeBigWidth + threeWidth + SPLITLINE_WIDTH;
            break;
        }
            
        case 7: {
            height = threeBigWidth + threeWidth * 2 + SPLITLINE_WIDTH * 2;
            break;
        }
            
        case 8: {
            height = twoWidth + threeWidth * 2 + SPLITLINE_WIDTH * 2;
            break;
        }
            
        case 9: {
            height = threeBigWidth + threeWidth * 2 + SPLITLINE_WIDTH * 2;
            break;
        }
            
        default: {
            height = 0;
        }
    }
    
    return height;
}

+ (CGFloat)calculateImageHeightFromBaseWidth:(CGFloat)baseWidth withImageWidth:(CGFloat)imageWidth withImageHeight:(CGFloat)imageHeight
{
    if (imageWidth == 0 || imageHeight == 0) {
        return 0;
    }
    
    CGFloat scale = imageHeight / imageWidth;
    
    if (scale < 0.5) {
        scale = 0.5;
    }
    else if (scale > 1.5) {
        scale = 1.5;
    }
    
    CGFloat scaleHeight = baseWidth * scale;
    
    return scaleHeight;
}

- (void)createSignButton
{
    _signButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_signButton setTitleColor:RGBA(0xFF, 0xFF, 0xFF, 1.0) forState:UIControlStateNormal];
    [_signButton setTitleColor:RGBA(0xFF, 0xFF, 0xFF, 0.5) forState:UIControlStateHighlighted];
    _signButton.titleLabel.font = [UIFont systemFontOfSize:12];
    _signButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_signButton setBackgroundImage:[[UIImage imageNamed:@"image_scale_type_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    _signButton.userInteractionEnabled = NO;
}

@end
