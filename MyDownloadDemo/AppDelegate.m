//
//  AppDelegate.m
//  MyDownloadDemo
//
//  Created by jimbo on 2017/3/24.
//  Copyright © 2017年 naver. All rights reserved.
//

#import "AppDelegate.h"
#import "MyDownWindowController.h"


@interface AppDelegate ()
{
    MyDownWindowController *_downWC;
}
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    
    _downWC = [[MyDownWindowController alloc] init];
    self.window = _downWC.window;

    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
