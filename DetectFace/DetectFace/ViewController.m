//
//  ViewController.m
//  DetectFace
//
//  Created by 筒井 啓太 on 12/02/24.
//  Copyright (c) 2012 東京工業大学. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Resize.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)takePictureButtonClick:(id)sender {
  NSLog(@"写真撮影ボタンがクリックされました！");
  picker_ = [[UIImagePickerController alloc] init];
  picker_.delegate = self;
  picker_.sourceType = UIImagePickerControllerSourceTypeCamera;
  [self presentModalViewController:picker_ animated:YES];
}

#pragma mark -
#pragma mark UIImagePickerController delegate method

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
  NSLog(@"写真を取得しました！");
  
  UIImage *resizedImage =
      [image getResizedImageWithWidth:pictureImageView_.frame.size.width
                                height:pictureImageView_.frame.size.height];
  [pictureImageView_ setImage:resizedImage];
  pictureImageView_.layer.sublayers = nil;
  [picker_ dismissModalViewControllerAnimated:YES];
  
  NSData *data = UIImageJPEGRepresentation(resizedImage, 0.2);
  
  NSURL *url = [NSURL URLWithString:@"http://detectface.com/api/detect?f=2"];
  NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
  [req setHTTPMethod:@"POST"];
  [req setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
  [req setValue:[NSString stringWithFormat:@"%d", [data length]]
        forHTTPHeaderField:@"Content-Length"];
  [req setHTTPBody:data];
  
  conn_ = [[NSURLConnection alloc] initWithRequest:req delegate:self];
  if (conn_) {
    NSLog(@"NSURLConnection create success");
    response_ = [NSMutableString string];
    indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator_.frame = CGRectMake(135.0, 215.0f, 50.0f, 50.0f);
    [self.view addSubview:indicator_];
    [indicator_ startAnimating];
  } else {
    NSLog(@"conn is nil");
  }
}

#pragma mark -
#pragma mark NSUIConnection delegate method

- (void)connection:(NSURLConnection *)connection
    didReceiveResponse:(NSURLResponse *)response {
  NSLog(@"didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  NSLog(@"didReceiveData");
  NSString *string = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];
  [response_ appendString:string];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSLog(@"connectionDidFinishLoading");
  NSLog(@"%@", response_);
  NSData *data = [response_ dataUsingEncoding:NSUTF8StringEncoding];
  parser_ = [[NSXMLParser alloc] initWithData:data];
  [parser_ setDelegate:self];
  [parser_ parse];
}

#pragma mark -
#pragma mark NSXMLParser delegate method

- (void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"right-eye"]
      || [elementName isEqualToString:@"left-eye"]
      || [elementName isEqualToString:@"point"]) {
    float x, y;
    x = [(NSString *)[attributeDict objectForKey:@"x"] floatValue];
    y = [(NSString *)[attributeDict objectForKey:@"y"] floatValue];
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(x, y, 2.0f, 2.0f);
    if ([elementName isEqualToString:@"right-eye"]
        || [elementName isEqualToString:@"left-eye"]) {
      layer.backgroundColor = [UIColor redColor].CGColor;
    } else {
      NSString *identity = (NSString *)[attributeDict objectForKey:@"id"];
      if ([identity hasPrefix:@"F"]) {
        layer.backgroundColor = [UIColor yellowColor].CGColor;
      } else if ([identity hasPrefix:@"EL"]) {
        layer.backgroundColor = [UIColor whiteColor].CGColor;
      } else if ([identity hasPrefix:@"BR"]) {
        layer.backgroundColor = [UIColor blackColor].CGColor;
      } else if ([identity hasPrefix:@"M"]) {
        layer.backgroundColor = [UIColor purpleColor].CGColor;
      } else if ([identity hasPrefix:@"N"]) {
        layer.backgroundColor = [UIColor orangeColor].CGColor;
      }
    }
    [pictureImageView_.layer addSublayer:layer];
  }
}

- (void)parser:(NSXMLParser *)parser
    didEndElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName {
  if ([elementName isEqualToString:@"faces"]) {
    [indicator_ stopAnimating];
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
  
}

@end
