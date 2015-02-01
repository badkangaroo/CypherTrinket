//
//  ViewController.h
//  EncodeThing
//
//  Created by alex okita on 2014.19.8.
//  Copyright (c) 2014 alex okita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *MainView;
@property (strong, nonatomic) IBOutlet UITextField *InputTextField;
@property (strong, nonatomic) IBOutlet UITextView *HintView;
@property (strong, nonatomic) IBOutlet UISwitch *ClassicScrambleSwitch;
- (IBAction)ValueStep:(UIStepper *)sender;

@property (strong, nonatomic) NSMutableArray *WordLetters;
@property (strong, nonatomic) NSMutableArray *CodeLetters;
@property (strong, nonatomic) IBOutlet UILabel *ASCIIValueOutput;
@property (strong, nonatomic) IBOutlet UIView *KeyView;
- (IBAction)ScrambleType:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *Password;
- (IBAction)ClearButton:(UIButton *)sender;

@end

