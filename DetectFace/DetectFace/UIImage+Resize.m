//
//  UIImage+Resize.m
//  DetectFace
//
//  Created by 筒井 啓太 on 12/02/25.
//  Copyright (c) 2012 東京工業大学. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)getResizedImageWithWidth:(CGFloat)width height:(CGFloat)height {
  UIGraphicsBeginImageContext(CGSizeMake(width, height));
  [self drawInRect:CGRectMake(0.0f, 0.0f, width, height)];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

@end
