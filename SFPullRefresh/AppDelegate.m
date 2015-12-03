//
//  AppDelegate.m
//  SFPullRefreshDemo
//
//  Created by shaohua.chen on 10/16/14.
//  Copyright (c) 2014 shaohua.chen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "CollectionTestViewController.h"
#import "TableTestViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    TableTestViewController *tableVC = [[TableTestViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *tableNavi = [[UINavigationController alloc] initWithRootViewController:tableVC];
    UITabBarItem *tableBarItem = [[UITabBarItem alloc] init];
    tableBarItem.title = @"table";
    tableNavi.tabBarItem = tableBarItem;
//    tableNavi.navigationBar.translucent = NO;
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

    CollectionTestViewController *collectionVC = [[CollectionTestViewController alloc] initWithCollectionViewLayout:layout];
    UINavigationController *collectionNavi = [[UINavigationController alloc] initWithRootViewController:collectionVC];
    UITabBarItem *collectionBarItem = [[UITabBarItem alloc] init];
    collectionBarItem.title = @"collection";
    collectionNavi.tabBarItem = collectionBarItem;
    
    UITabBarController *tabController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    tabController.viewControllers = @[collectionNavi,tableNavi];
//    tabController.tabBar.translucent = NO;
    self.window.rootViewController = tabController;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

@end
