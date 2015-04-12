//
//  WebViewController.h
//  SpaceAlerts
//
//  Created by abdullah on 4/11/15.
//  Copyright (c) 2015 XtremethinkersCode. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIWebView *webView;

- (id)initWithURL:(NSString *)postURL title:(NSString *)postTitle;

@end
