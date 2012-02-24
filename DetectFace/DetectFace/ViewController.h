//
//  ViewController.h
//  DetectFace
//
//  Created by 筒井 啓太 on 12/02/24.
//  Copyright (c) 2012 東京工業大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UINavigationControllerDelegate,
                                             UIImagePickerControllerDelegate,
                                             NSURLConnectionDelegate,
                                             NSXMLParserDelegate> {
 @private
  IBOutlet UIImageView *pictureImageView_;                                             
  IBOutlet UIButton *takePictureButton_;
  UIImagePickerController *picker_;
  NSURLConnection *conn_;
  NSMutableString *response_;
  NSXMLParser *parser_;
  UIActivityIndicatorView *indicator_;
}

- (IBAction)takePictureButtonClick:(id)sender;

@end
