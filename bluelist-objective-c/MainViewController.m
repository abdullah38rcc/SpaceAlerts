//
//  MainViewController.m
//  SpaceAlerts
//
//  Created by abdullah on 4/11/15.
//  Copyright (c) 2015 XtremethinkersCode. All rights reserved.
//


#import "MainViewController.h"
#import "WebViewController.h"

#import <CloudantToolkit/CloudantToolkit.h>
#import <CDTDatastore/CloudantSync.h>
#import <IMFData/IMFData.h>
#import <IMFCore/IMFCore.h>


@interface MainViewController ()

@end

@implementation NSString (mycategory)

- (NSString *)stringByStrippingHTML 
{
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s; 
}

@end

@implementation MainViewController
@synthesize parseResults = _parseResults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadFeed)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    //Sets the navigation bar title
    self.title = @"News";
    //Set table row height so it can fit title & 2 lines of summary
    self.tableView.rowHeight = 90;
    
    //Parse feed
    KMXMLParser *parser = [[KMXMLParser alloc] initWithURL:@"http://spacealert.ipos.com.tr/news/mobile/feeds" delegate:self];
    _parseResults = [parser posts];

    [self stripHTMLFromSummary];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)stripHTMLFromSummary {
    int i = 0;
    int count = self.parseResults.count;
    //cycles through each 'summary' element stripping HTML
    while (i < count) {
        NSString *tempString = [[self.parseResults objectAtIndex:i] objectForKey:@"summary"];
        NSString *strippedString = [tempString stringByStrippingHTML];
        NSMutableDictionary *dict = [self.parseResults objectAtIndex:i];
        [dict setObject:strippedString forKey:@"summary"];
        [self.parseResults replaceObjectAtIndex:i withObject:dict];
        i++;
    }
}

- (void)reloadFeed {
    KMXMLParser *parser = [[KMXMLParser alloc] initWithURL:@"http://spacealert.ipos.com.tr/news/mobile/feeds" delegate:self];
    _parseResults = [parser posts];

    [self stripHTMLFromSummary];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.parseResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    //Check if cell is nil. If it is create a new instance of it
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
      [cell setBackgroundColor:[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1]];
    
    }
    // Configure titleLabel
    cell.textLabel.text = [[self.parseResults objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.textColor = [UIColor redColor];
    
    //Configure detailTitleLabel
     cell.detailTextLabel.text = [[self.parseResults objectAtIndex:indexPath.row] objectForKey:@"summary"];
     cell.detailTextLabel.textColor = [UIColor blueColor];
     cell.detailTextLabel.numberOfLines = 4;
    
    //Set accessoryType
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
   
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url = [[self.parseResults objectAtIndex:indexPath.row] objectForKey:@"link"];
    NSString *title = [[self.parseResults objectAtIndex:indexPath.row] objectForKey:@"title"];

    
    WebViewController *vc = [[WebViewController alloc] initWithURL:url title:title];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - KMXMLParser Delegate

- (void)parserDidFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not parse feed. Check your network connection." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)parserCompletedSuccessfully {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)parserDidBegin {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

@end
