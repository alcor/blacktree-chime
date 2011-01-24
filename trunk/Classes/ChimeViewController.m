//
//  ChimeViewController.m
//  Chime
//
//  Created by Nicholas Jitkoff on 1/2/11.
//  Copyright 2011 Blacktree Inc. All rights reserved.
//

#import "ChimeViewController.h"
#import "ChimeAppDelegate.h"
@interface ChimeViewController ()
- (void)updateValues;
@end

@implementation ChimeViewController
- (void)toggleValueForSender:(id)sender {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *options = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Options"];
  
  BOOL decrease = NO;
  NSString *key = nil;
  if (sender == onOffButton) {
    BOOL enabled = [defaults boolForKey:@"enabled"];
    [defaults setBool:!enabled forKey:@"enabled"];
    [self updateValues];
  } else {
    if (sender == frequencyButton) {
      key = @"frequency";
    } else if (sender == fromButton || sender == fromUpButton || sender == fromDownButton) {
      key = @"fromTime";
      if (sender == fromDownButton) decrease = YES;
      [fromUpButton setAlpha:0.33];
      [fromDownButton setAlpha:0.33];
      [UIView beginAnimations:@"" context:NULL];
      [UIView setAnimationDuration:1.0];
      [fromUpButton setAlpha: 0.1];  
      [fromDownButton setAlpha: 0.1];  
      [UIView commitAnimations];
      
    } else if (sender == tillButton || sender == tillUpButton || sender == tillDownButton) {
      key = @"tillTime";
      if (sender == tillDownButton) decrease = YES;
      
      [tillUpButton setAlpha:0.33];
      [tillDownButton setAlpha:0.33];
      [UIView beginAnimations:@"" context:NULL];
      [UIView setAnimationDuration:1.0];
      [tillUpButton setAlpha: 0.1];  
      [tillDownButton setAlpha: 0.1];  
      [UIView commitAnimations];
    } else if (sender == themeButton) {
      key = @"theme";
    } else if (sender == daysButton) {
      key = @"days";
    } 
    
    NSInteger count = [[options valueForKey:key] count];
    NSInteger value = [defaults integerForKey:key] + (decrease ? -1 : 1);
    value = (value + count) % count;
    [defaults setInteger:value forKey:key];
    
    
    if (sender == themeButton) {
      [(ChimeAppDelegate *)[[UIApplication sharedApplication] delegate] playTestSound]; 
    }
  }
  [self updateValues];  
  [defaults synchronize];
}
- (void)setSpinnerVisible:(BOOL)visible {
  if (visible) {
    [spinner startAnimating]; 
  } else {
    [spinner stopAnimating]; 
  }
}
- (void)updateValues {

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSDictionary *options = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Options"];
  
  
  NSInteger frequencyValue = [defaults integerForKey:@"frequency"];
  [frequencyButton setTitle: [[options valueForKey:@"frequency"] objectAtIndex:frequencyValue]
                   forState:UIControlStateNormal];
  
  NSInteger fromValue = [defaults integerForKey:@"fromTime"];
  [fromButton setTitle: [[options valueForKey:@"fromTime"] objectAtIndex:fromValue]
              forState:UIControlStateNormal];
  
  NSInteger tillValue = [defaults integerForKey:@"tillTime"];
  [tillButton setTitle: [[options valueForKey:@"tillTime"] objectAtIndex:tillValue]
             forState:UIControlStateNormal];

  NSInteger daysValue = [defaults integerForKey:@"days"];
  [daysButton setTitle: [[options valueForKey:@"days"] objectAtIndex:daysValue]
             forState:UIControlStateNormal];
  
  NSInteger themeValue = [defaults integerForKey:@"theme"];
  [themeButton setTitle: [[options valueForKey:@"theme"] objectAtIndex:themeValue]
             forState:UIControlStateNormal];
  
  NSInteger enabled = [defaults boolForKey:@"enabled"];
  
  [UIView beginAnimations:@"" context:NULL];
  [UIView setAnimationDuration:0.05];
  [onLabel setAlpha:enabled ? 1.0: 0.33];
  [offLabel setAlpha:enabled ? 0.33: 1.0];
  [bellImage setAlpha:enabled ? 1.0: 0.0];
  [UIView commitAnimations];

  [UIView beginAnimations:@"" context:NULL];
  [UIView setAnimationDuration:0.5];
  [frequencyButton setAlpha: enabled ? 1.0 : 0.33];
  [UIView commitAnimations];

  
  [UIView beginAnimations:@"" context:NULL];
  [UIView setAnimationDuration:0.4];
  [fromButton setAlpha: enabled ? 1.0 : 0.33];
//  [fromUpButton setAlpha:  0.33];
//  [fromDownButton setAlpha: 0.33];  
  [UIView commitAnimations];

  [UIView beginAnimations:@"" context:NULL];
  [UIView setAnimationDuration:0.3];
  [tillButton setAlpha: enabled ? 1.0 : 0.33];
//  [tillUpButton setAlpha:  0.33];
//  [tillDownButton setAlpha: 0.33];  
  [UIView commitAnimations];
  
  [UIView beginAnimations:@"" context:NULL];
  [UIView setAnimationDuration:0.2];
  [daysButton setAlpha: enabled ? 1.0 : 0.33];  
  [UIView commitAnimations];
  
  [UIView beginAnimations:@"" context:NULL];
  [UIView setAnimationDuration:0.1];
  [themeButton setAlpha: enabled ? 1.0 : 0.33];  
  [UIView commitAnimations];
  
}

- (void)log:(NSString *)string {
  
}
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [self updateValues];
  [super viewDidLoad];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
