//
//  ChimeAppDelegate.h
//  Chime
//
//  Created by Nicholas Jitkoff on 1/2/11.
//  Copyright 2011 Blacktree Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChimeViewController;

@interface ChimeAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet ChimeViewController *viewController;

- (void)playTestSound;
@end

