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
  IBOutlet UILabel *frequencyLabel;
  IBOutlet UILabel *fromLabel;
  IBOutlet UILabel *tillLabel;
  IBOutlet UILabel *themeLabel;
  IBOutlet UILabel *onOffLabel;
  IBOutlet UIImageView *bellImage;
  IBOutlet UIImageView *backgroundView;
  IBOutlet UIButton *fromUpButton;
  IBOutlet UIButton *fromDownButton;
  IBOutlet UIButton *tillUpButton;
  IBOutlet UIButton *tillDownButton;
  IBOutlet UIActivityIndicatorView *spinner;
  IBOutlet UIView *errorView;
  IBOutlet UIButton *settingsButton;


}
- (IBAction)toggleValueForSender:(id)sender;
- (void)setSpinnerVisible:(BOOL)visible;
- (IBAction)openSettings:(id)sender;
- (void)updateValues;
@end

