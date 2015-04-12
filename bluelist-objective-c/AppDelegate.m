//
//  AppDelegate.m
//  SpaceAlerts
//
//  Created by abdullah on 4/11/15.
//  Copyright (c) 2015 XtremethinkersCode. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <facebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <IMFCore/IMFCore.h>
#import <IMFPush/IMFPush.h>
#import <IMFFacebookAuthenticationHandler.h>
#import <IMFGoogleAuthenticationHandler.h>
#import <IMFData/IMFData.h>

@interface AppDelegate ()
@property IMFLogger *logger;
@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    //Create an instance of our MainViewController and initialize it
    MainViewController *vc = [[MainViewController alloc] initWithStyle:UITableViewStylePlain];
    /*Create a navigation controller so we can manage display of multiple controllers
     and initialize it with our 'vc' as its' rootviewcontroller */
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.window makeKeyAndVisible];
    //Set the windows rootviewcontroller as our navigation controller
    [self.window setRootViewController:navController];
    //Registering for remote Notifications must be done after User is Authenticated, this is done from PushViewController by calling function registerForPushNotification(application:UIApplication)
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Consider if these calls should be in applicationDidEnterBackground and/or other application lifecycle event.
    // Perhaps [IMFLogger send]; should only happen when the end-user presses a button to do so, for example.
    // CAUTION: the URL receiving the uploaded log and analytics payload is auth-protected, so these calls
    // should only be made after authentication, otherwise your end-user will receive a random auth prompt!
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push notification functions

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [self.logger logWarnWithMessages:@"didFailToRegisterForRemoteNotificationsWithError %@",error.description];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.logger logInfoWithMessages:@"didRegisterForRemoteNotificationsWithDeviceToken %@",deviceToken.description];
    IMFPushClient *push = [IMFPushClient sharedInstance];
    [self.logger logInfoWithMessages:@"Registering with backend"];
    [push registerDeviceToken:deviceToken completionHandler:^(IMFResponse *response, NSError *error) {
        if(error){
            [self.logger logErrorWithMessages:@"Error during device registration %@",error.description];
            return;
        }
        [self.logger logInfoWithMessages:@"Response during device registration json: %@",response.responseJson.description];
        NSLog(@"Succesfully Registered Device %@",deviceToken.description);
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self.logger logInfoWithMessages:@"didReceiveRemoteNotification fetchCompletionHandler userInfo: %@",userInfo.description];
    NSNumber *contentAvailable = userInfo[@"aps"][@"content-available"];
    if(contentAvailable != nil){
        [self.logger logInfoWithMessages:@"Received a silent or mixed push.."];
        [self.logger logInfoWithMessages:@"contentAvailable: %@",contentAvailable];
        //Perform background task
        if( [contentAvailable intValue] == 1){
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    } else{
        [self.logger logInfoWithMessages:@"Received a default notification."];
        completionHandler(UIBackgroundFetchResultNoData);
    }
    //record the event for push monitoring
    [[IMFPushClient sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    [self.logger logInfoWithMessages:@"actionable notification received"];
    completionHandler();
}

#pragma mark - Helper functions for debugging purposes

-(OSStatus) deleteAllKeysForSecClass:(CFTypeRef) secClass {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:(__bridge id) secClass forKey:(__bridge id) kSecClass];
    OSStatus result = SecItemDelete((__bridge  CFDictionaryRef) dict);
    return result;
}
- (void) clearKeychain {
    [self deleteAllKeysForSecClass:kSecClassIdentity];
    [self deleteAllKeysForSecClass:kSecClassGenericPassword];
    [self deleteAllKeysForSecClass:kSecClassInternetPassword];
    [self deleteAllKeysForSecClass:kSecClassCertificate];
    [self deleteAllKeysForSecClass:kSecClassKey];
}

@end
