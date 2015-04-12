//
//  WebViewController.m
//  SpaceAlerts
//
//  Created by abdullah on 4/11/15.
//  Copyright (c) 2015 XtremethinkersCode. All rights reserved.
//


#import "WebViewController.h"
#import "AppDelegate.h"
#import <CloudantToolkit/CloudantToolkit.h>
#import <CDTDatastore/CloudantSync.h>
#import <IMFData/IMFData.h>
#import <IMFCore/IMFCore.h>

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize url = _url, webView = _webView;

- (id)initWithURL:(NSString *)postURL title:(NSString *)postTitle
{
    self = [super init];
    if (self) {
        _url = postURL;
        self.title = postTitle;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.url = [self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  
    NSURL *newURL = [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
    // Do any additional setup after loading the view.
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:newURL]];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
