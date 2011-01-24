//
//  ChimeViewController.h
//  Chime
//
//  Created by Nicholas Jitkoff on 1/2/11.
//  Copyright 2011 Blacktree Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChimeViewController : UIViewController {
  IBOutlet UITextView *textView;
  IBOutlet UIButton *frequencyButton;
  IBOutlet UIButton *fromButton;
  IBOutlet UIButton *tillButton;
  IBOutlet UIButton *themeButton;
  IBOutlet UIButton *onOffButton;
  IBOutlet UIButton *daysButton;
  IBOutlet UILabel *onLabel;
  IBOutlet UILabel *offLabel;
  IBOutlet UIImageView *bellImage;
  IBOutlet UIButton *fromUpButton;
  IBOutlet UIButton *fromDownButton;
  IBOutlet UIButton *tillUpButton;
  IBOutlet UIButton *tillDownButton;
  IBOutlet UIActivityIndicatorView *spinner;
}
- (IBAction)toggleValueForSender:(id)sender;
- (void)log:(NSString *)string;
- (void)setSpinnerVisible:(BOOL)visible;
@end

