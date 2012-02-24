//
//  UIImage+Resize.h
//  DetectFace
//
//  Created by 筒井 啓太 on 12/02/25.
//  Copyright (c) 2012 東京工業大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage *)getResizedImageWithWidth:(CGFloat)width height:(CGFloat)height;

@end
