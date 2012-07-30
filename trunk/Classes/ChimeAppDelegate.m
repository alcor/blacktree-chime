//
//  ChimeAppDelegate.m
//  Chime
//
//  Created by Nicholas Jitkoff on 1/2/11.
//  Copyright 2011 Blacktree Inc. All rights reserved.
//

#import "ChimeAppDelegate.h"
#import "ChimeViewController.h"
#import <AudioToolbox/AudioToolbox.h>


@interface ChimeAppDelegate ()
- (void)playSound:(NSString *)soundName;
- (void)updateNotifications;
@end

@implementation ChimeAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle
+ (void)initialize {
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithBool:YES], @"enabled",
                        [NSNumber numberWithInteger:1], @"frequency",
                        [NSNumber numberWithInteger:9], @"fromTime",
                        //[NSNumber numberWithInteger:1], @"days",
                        [NSNumber numberWithInteger:21], @"tillTime",
                        nil];
  [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
  
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
  notificationsQueue = [[NSMutableArray alloc] initWithCapacity:12];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
  [self updateNotifications];
  [self.window addSubview:viewController.view];
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)defaultsChanged:(NSNotification *)notif {
  [self updateNotifications];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  NSLog(@"Playing local notification");
  [self playSound:notification.soundName];
}


- (void)playSound:(NSString *)soundName {
  CFBundleRef mainBundle = CFBundleGetMainBundle();
  
  CFURLRef soundFileURLRef  = CFBundleCopyResourceURL (mainBundle,
                                                       (CFStringRef)[soundName stringByDeletingPathExtension],
                                                       (CFStringRef)[soundName pathExtension],
                                                       NULL);
  if (soundFileURLRef) {
    SystemSoundID soundFileObject;
    AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObject);
    AudioServicesPlaySystemSound (soundFileObject);
    
    [self performSelector:@selector(disposeSound:)
               withObject:[NSNumber numberWithInteger:soundFileObject]
               afterDelay:5];
    
    CFRelease(soundFileURLRef); 
  }
}
- (void)disposeSound:(NSNumber *)number {
  AudioServicesDisposeSystemSoundID ([number integerValue]);
}
- (BOOL)hour:(NSUInteger)anHour isBetween:(NSUInteger)fromTime and:(NSUInteger)tillTime {
  return tillTime > fromTime ? tillTime >= anHour && anHour >= fromTime  // 22 >= h >= 9
  : anHour <= tillTime || anHour >= fromTime; // h <= 1 || h >= 9
}

- (void)scheduleOneNotification {
  if ([notificationsQueue count]) {
    UILocalNotification *notif = [notificationsQueue objectAtIndex:0];
    NSDate *fireDate = [notif fireDate];
    
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];

    // Shift weekend appts forward if needed
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL weekends = YES; //[defaults boolForKey:@"days"];
    if (!weekends) {
      NSUInteger day = [[gregorian components:NSWeekdayCalendarUnit fromDate:[notif fireDate]] weekday];
      if (day == 1 || day == 7) {
        NSLog(@"        Shifting day off weekend %@", fireDate);
        NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
        [components setDay:day == 7 ? 2 : 1];
        fireDate = [gregorian dateByAddingComponents:components toDate:fireDate options:0];        
      }
    }
    
    BOOL earlierThanNow = [fireDate compare:[NSDate dateWithTimeIntervalSinceNow:5.0]] == NSOrderedAscending;
    if (earlierThanNow) {
      NSLog(@"        Shifting past appt forward %@", fireDate);
      NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
      [components setDay:1];
      fireDate = [gregorian dateByAddingComponents:components toDate:fireDate options:0];
    }


    NSLog(@"Scheduling %@ %.0f", fireDate, [fireDate timeIntervalSinceNow]/60/60);
    [notif setFireDate:fireDate];
    
    
    UIApplication* app = [UIApplication sharedApplication];
    [app scheduleLocalNotification:notif];
    [notificationsQueue removeObject:notif]; 
  }
}

- (void)scheduleAllNotifications {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scheduleOneNotificationAndLoop) object:nil];
  if ([notificationsQueue count]) {
    while ([notificationsQueue count]) {
      [self scheduleOneNotification];
    }
    NSLog(@"All alerts scheduled");
  }
}

- (void)scheduleOneNotificationAndLoop {
  [viewController setSpinnerVisible:YES];
  [self scheduleOneNotification];
  
  if ([notificationsQueue count]) {
    [self performSelector:@selector(scheduleOneNotificationAndLoop) withObject:nil afterDelay:0.0]; 
  } else {
    NSLog(@"All alerts scheduled");
    [viewController setSpinnerVisible:NO];
    
  }
}

- (void)updateNotifications {
  
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scheduleOneNotificationAndLoop) object:nil];
  [notificationsQueue removeAllObjects];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  
  BOOL enabled = [defaults boolForKey:@"enabled"];
  NSUInteger frequency = [defaults integerForKey:@"frequency"];
  BOOL weekends = YES; //[defaults boolForKey:@"days"];
  NSUInteger fromTime = ([defaults integerForKey:@"fromTime"]) % 24;
  NSUInteger tillTime = ([defaults integerForKey:@"tillTime"]) % 24;
  NSUInteger themeIndex = [defaults integerForKey:@"theme"];
  NSArray *themes = [NSArray arrayWithObjects:@"beep", @"roman", @"chord", @"speech", @"speecha", @"retro", nil];
  NSString *theme = [themes objectAtIndex:themeIndex];
  
  NSDictionary *formatDict = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Themes"] objectForKey:theme];
  
  NSString *soundNameFormat = [formatDict objectForKey:@"format"];
  NSString *soundNameFormat30 = [formatDict objectForKey:@"format-30"];
  NSString *soundNameFormat15 = [formatDict objectForKey:@"format-15"];
  NSString *soundNameFormat45 = [formatDict objectForKey:@"format-45"];
  
  if (!soundNameFormat30) soundNameFormat30 = soundNameFormat;
  if (!soundNameFormat15) soundNameFormat15 = soundNameFormat30;
  if (!soundNameFormat45) soundNameFormat45 = soundNameFormat30;
  
  NSArray *formats = [NSArray arrayWithObjects:soundNameFormat, soundNameFormat15, soundNameFormat30, soundNameFormat45, nil];
  
  
  if (enabled) {
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit fromDate:now];
    NSUInteger thisHour = [dateComponents hour];
    [dateComponents setHour:thisHour];
    [dateComponents setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *baseFireDate = [gregorian dateFromComponents:dateComponents];
    
    NSLog(@"Scheduling chimes from %d to %d with %@", fromTime, tillTime, theme);
    NSDateComponents *hourComponents = [[[NSDateComponents alloc] init] autorelease];
    
    BOOL halfHours = frequency >= 2;
    BOOL quarterHours = frequency >= 3;
    BOOL beforeHour = frequency == 0;
    
    for (int i = 0; i < 24; i++) {
      NSUInteger anHour = (thisHour + i) % 24;
      BOOL isValid = [self hour:anHour isBetween:fromTime and:tillTime];
      BOOL halvesAreValid = [self hour:(anHour + 1) % 24 isBetween:fromTime and:tillTime];
      if (isValid) {
        
        for (int j = 0; j < (frequency && halvesAreValid ? 4 : 1); j++) {
          
          if (j == 2 && !halfHours) {
            continue;
          } 
          
          if (((j % 2) == 1) && !quarterHours) {
            continue;
          }
          
          UILocalNotification *alarm = [[[UILocalNotification alloc] init] autorelease];
          [hourComponents setHour:i];
          [hourComponents setMinute:j * 15];
          alarm.fireDate = [gregorian dateByAddingComponents:hourComponents toDate:baseFireDate options:0];
          
          if (beforeHour) alarm.fireDate = [alarm.fireDate dateByAddingTimeInterval:-2 * 60];          
          
          alarm.timeZone = [NSTimeZone defaultTimeZone];
          alarm.repeatInterval = weekends ? kCFCalendarUnitDay : kCFCalendarUnitWeekday;
          
          NSUInteger hourName = (thisHour + i) % 12;
          if (hourName == 0) hourName = 12;
          alarm.soundName = [NSString stringWithFormat:[formats objectAtIndex:j], theme, hourName];
          if (alarm) [notificationsQueue addObject:alarm];
          
          NSLog(@"firing %2d %@ - %@", anHour, alarm.fireDate, alarm.soundName);
          
        }
      } else {
        //NSLog(@"skping %d", anHour);
      }
    }
  }
  UIApplication* app = [UIApplication sharedApplication];
  NSArray*    oldNotifications = [app scheduledLocalNotifications];
  
  if ([oldNotifications count] > 0)
    [app cancelAllLocalNotifications];
  
  [self performSelector:@selector(scheduleOneNotificationAndLoop) withObject:nil afterDelay:5.0]; 
}

- (void)playTestSound {
  UIApplication* app = [UIApplication sharedApplication];
  
  NSArray *notifications = notificationsQueue;
  if (![notifications count]) notifications = [app scheduledLocalNotifications];
  if ([notifications count]) {
    UILocalNotification *notif = [notifications objectAtIndex:0];
    [self playSound:notif.soundName];
  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  [self scheduleAllNotifications];
  
  
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
   */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  /*
   Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
   */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}


- (void)applicationWillTerminate:(UIApplication *)application {
  [self scheduleAllNotifications];
  /*
   Called when the application is about to terminate.
   See also applicationDidEnterBackground:.
   */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
  /*
   Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
   */
}


- (void)dealloc {
  [viewController release];
  [window release];
  [super dealloc];
}


@end
