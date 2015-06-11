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
@property (nonatomic, strong) NSMutableArray *notificationsQueue;
- (void)playSound:(NSString *)soundName;
- (void)updateNotifications;
@end

@implementation ChimeAppDelegate

#pragma mark -
#pragma mark Application lifecycle
+ (void)initialize {
  NSDictionary *dict = @{
      @"enabled": @YES,
      @"frequency": @1,
      @"fromTime": @9,
      @"tillTime": @21}
  ;
  [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
  
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
  self.notificationsQueue = [[NSMutableArray alloc] initWithCapacity:12];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(defaultsChanged:)
                                               name:NSUserDefaultsDidChangeNotification
                                             object:nil];
  [self updateNotifications];
  self.window.rootViewController = self.viewController;
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
  CFURLRef soundFileURLRef  = CFBundleCopyResourceURL(
       mainBundle,
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
  AudioServicesDisposeSystemSoundID ((unsigned int)[number integerValue]);
}
- (BOOL)hour:(NSUInteger)anHour isBetween:(NSUInteger)fromTime and:(NSUInteger)tillTime {
  return tillTime > fromTime ? tillTime >= anHour && anHour >= fromTime  // 22 >= h >= 9
  : anHour <= tillTime || anHour >= fromTime; // h <= 1 || h >= 9
}

- (void)scheduleOneNotification {
  if ([self.notificationsQueue count]) {
    UILocalNotification *notif = (self.notificationsQueue)[0];
    NSDate *fireDate = [notif fireDate];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    // Shift weekend appts forward if needed
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL weekends = YES; //[defaults boolForKey:@"days"];
    if (!weekends) {
      NSUInteger day = [[gregorian components:NSWeekdayCalendarUnit fromDate:[notif fireDate]] weekday];
      if (day == 1 || day == 7) {
        NSLog(@"        Shifting day off weekend %@", fireDate);
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:day == 7 ? 2 : 1];
        fireDate = [gregorian dateByAddingComponents:components toDate:fireDate options:0];        
      }
    }
    
    BOOL earlierThanNow = [fireDate compare:[NSDate dateWithTimeIntervalSinceNow:5.0]] == NSOrderedAscending;
    if (earlierThanNow) {
      NSLog(@"        Shifting past appt forward %@", fireDate);
      NSDateComponents *components = [[NSDateComponents alloc] init];
      [components setDay:1];
      fireDate = [gregorian dateByAddingComponents:components toDate:fireDate options:0];
    }


    NSLog(@"Scheduling %@ %.0f", fireDate, [fireDate timeIntervalSinceNow]/60/60);
    [notif setFireDate:fireDate];
    
    
    UIApplication* app = [UIApplication sharedApplication];
    [app scheduleLocalNotification:notif];
    [self.notificationsQueue removeObject:notif];
  }
}

- (void)scheduleAllNotifications {
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(scheduleOneNotificationAndLoop)
                                             object:nil];
  if ([self.notificationsQueue count]) {
    while ([self.notificationsQueue count]) {
      [self scheduleOneNotification];
    }
    NSLog(@"All alerts scheduled");
  }
}

- (void)scheduleOneNotificationAndLoop {
  [self.viewController setSpinnerVisible:YES];
  [self scheduleOneNotification];
  
  if ([self.notificationsQueue count]) {
    [self performSelector:@selector(scheduleOneNotificationAndLoop)
               withObject:nil
               afterDelay:0];
  } else {
    NSLog(@"All alerts scheduled");
    [self.viewController setSpinnerVisible:NO];
  }
}

- (void)updateNotifications {
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(scheduleOneNotificationAndLoop)
                                             object:nil];
  [self.notificationsQueue removeAllObjects];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  
  BOOL enabled = [defaults boolForKey:@"enabled"];
  NSUInteger frequency = [defaults integerForKey:@"frequency"];
  BOOL weekends = YES; //[defaults boolForKey:@"days"];
  NSUInteger fromTime = ([defaults integerForKey:@"fromTime"]) % 24;
  NSUInteger tillTime = ([defaults integerForKey:@"tillTime"]) % 24;
  NSUInteger themeIndex = [defaults integerForKey:@"theme"];
  NSArray *themes = @[@"beep", @"roman", @"chord", @"speech", @"speecha", @"retro"];
  NSString *theme = themes[themeIndex];
  
  NSDictionary *formatDict = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Themes"][theme];
  
  NSString *soundNameFormat = formatDict[@"format"];
  NSString *soundNameFormat30 = formatDict[@"format-30"];
  NSString *soundNameFormat15 = formatDict[@"format-15"];
  NSString *soundNameFormat45 = formatDict[@"format-45"];
  
  if (!soundNameFormat30) soundNameFormat30 = soundNameFormat;
  if (!soundNameFormat15) soundNameFormat15 = soundNameFormat30;
  if (!soundNameFormat45) soundNameFormat45 = soundNameFormat30;
  
  NSArray *formats = @[soundNameFormat, soundNameFormat15, soundNameFormat30, soundNameFormat45];
  
  
  if (enabled) {
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit fromDate:now];
    NSUInteger thisHour = [dateComponents hour];
    [dateComponents setHour:thisHour];
    [dateComponents setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *baseFireDate = [gregorian dateFromComponents:dateComponents];
    
    NSLog(@"Scheduling chimes from %lu to %lu with %@", (unsigned long)fromTime, (unsigned long)tillTime, theme);
    NSDateComponents *hourComponents = [[NSDateComponents alloc] init];
    
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
          
          UILocalNotification *alarm = [[UILocalNotification alloc] init];
          [hourComponents setHour:i];
          [hourComponents setMinute:j * 15];
          alarm.fireDate = [gregorian dateByAddingComponents:hourComponents toDate:baseFireDate options:0];
          
          if (beforeHour) alarm.fireDate = [alarm.fireDate dateByAddingTimeInterval:-2 * 60];          
          
          alarm.timeZone = [NSTimeZone defaultTimeZone];
          alarm.repeatInterval = weekends ? kCFCalendarUnitDay : kCFCalendarUnitWeekday;
          
          NSUInteger hourName = (thisHour + i) % 12;
          if (hourName == 0) hourName = 12;
          alarm.soundName = [NSString stringWithFormat:formats[j], theme, hourName];
          if (alarm) [self.notificationsQueue addObject:alarm];
          
          NSLog(@"firing %2lu %@ - %@", (unsigned long)anHour, alarm.fireDate, alarm.soundName);
          
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
  
  NSArray *notifications = self.notificationsQueue;
  if (![notifications count]) notifications = [app scheduledLocalNotifications];
  if ([notifications count]) {
    UILocalNotification *notif = notifications[0];
    [self playSound:notif.soundName];
  }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  [self scheduleAllNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [self scheduleAllNotifications];
}

@end
