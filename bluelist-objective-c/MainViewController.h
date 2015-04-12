//
//  MainViewController.h
//  SpaceAlerts
//
//  Created by abdullah on 4/11/15.
//  Copyright (c) 2015 XtremethinkersCode. All rights reserved.
//





#import <UIKit/UIKit.h>
#import "KMXMLParser.h"

@interface MainViewController : UITableViewController <KMXMLParserDelegate>

@property (strong, nonatomic) NSMutableArray *parseResults;

@end
