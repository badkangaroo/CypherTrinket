//
//  ViewController.m
//  EncodeThing
//
//  Created by alex okita on 2014.19.8.
//  Copyright (c) 2014 alex okita. All rights reserved.
//
#import "ViewController.h"
#import <UIKit/UIKit.h>

@implementation ViewController
NSString *keyLetters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.";
NSArray *outputLetters;
NSMutableArray *codeBlocks;
NSMutableArray *letterBlocks;
int stepValue;

//build a pretty user interface.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set the sizes of the different UI parts here.
    CGRect r = self.KeyView.bounds;
    int width = r.size.width;
    int height = r.size.height;
    int size = height/19;
    int top = 5;
    outputLetters = [self MakeASCIIArray];
    
    //build label grid
    //37 / 2 = 18.5 so we'll make two columns, one with 19 and the other with 18
    NSArray *inLetters = [self GetNSArrayFromString:keyLetters];
    NSArray *outputChars = [self MakeASCIIArray];
    
    for(int i = 0; i < [inLetters count]; i++)
    {
        UILabel *label = [[UILabel alloc] init];
        
        //make a letter
        int ls = (i < 19) ? 10 : (width/2);
        int ts = (i < 19) ? top + (i * size) :  top + ((i-19) * (size));
        
        //left top width height
        label.frame =CGRectMake(ls, ts, size, size);
        label.font=[UIFont boldSystemFontOfSize:15.0];
        label.textAlignment = NSTextAlignmentRight;
        NSString *s = inLetters[i];
        label.text = s;
        [self.WordLetters addObject:label];
        [self.KeyView addSubview: label];
    }
    
    //build the boxes for the key encoding
    int tag = 0;
    for(int column = 0; column < 4; column++)
    {
        for (int row = 0; row < [inLetters count]; row++)
        {
            int ls = (row < 19) ? 10 : (width/2);
            ls += 10 + size + (size * column);
            int ts = (row < 19) ? top + (row * size) :  top + ((row-19) * (size));
            NSString *s = [NSString stringWithFormat:@"%@", [outputChars objectAtIndex:row]];
            CGRect frame = CGRectMake(ls,ts,size,size);
            UIButton *b = [self makeAButton:s withFrame:frame];
            b.tag = ++tag;
            [self.KeyView addSubview:b];
            [self.CodeLetters addObject:b];
        }
    }
}

-(UIButton*) makeAButton:(NSString*)title withFrame:(CGRect)rect
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:rect];
    button.titleLabel.font = [UIFont systemFontOfSize: 12];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor magentaColor] forState:UIControlStateReserved];
    [button setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(letterPressed:)
     forControlEvents:UIControlEventAllTouchEvents];
    
    return button;
}

-(void) viewDidLayoutSubviews
{
    
}

-(IBAction)letterPressed:(UIButton*)sender
{
    UITextField *label = [self Password];
    NSString *previousText = label.text;
    label.text = [NSString stringWithFormat:@"%@%@", previousText, sender.currentTitle];
    NSLog(@"pressed: %@", sender.currentTitle);
    [sender setBackgroundColor:[UIColor greenColor]];
}

- (IBAction)EncodingInput:(UITextField *)sender
{
    NSString *s = sender.text;
    NSMutableArray *chars = [[NSMutableArray alloc] initWithCapacity:[s length]];
    
    for (int i=0; i < [s length]; i++)
    {
        NSString *ichar  = [NSString stringWithFormat:@"%C", [s characterAtIndex:i]];
        [chars addObject:ichar];
    }
    
    self.HintView.text = s;
    
    //get a number based on the passkey
    [self BuildKey: [self GetASCIIValue:s]];
}

-( unsigned long ) GetASCIIValue: ( NSString * ) input
{
    unsigned long val = 0;
    for (int i=0; i < [input length]; i++)
    {
        int asciiCode = [input characterAtIndex:i];
        val += asciiCode ^ i;
    }
    self.ASCIIValueOutput.text = [NSString stringWithFormat:@"%lu", val];
    return val;
}
         
-( NSArray * ) GetNSArrayFromString:(NSString*) string
{
    NSMutableArray *str = [NSMutableArray array];
    for (int i = 0; i < [string length]; i++)
    {
        NSString *s  = [NSString stringWithFormat:@"%C", [string characterAtIndex:i]];
        [str addObject:s];
    }
    NSArray *a = [str copy];
    return a;
}

//adds all printable glyphs to a char array
//printable ascii starts at 33 and ends at 126
//32 is (space) 94 characters possible for output
-( NSArray * ) MakeASCIIArray
{
    NSMutableArray *chars = [NSMutableArray array];
    for(int i = 33, index = 0; i < 127; ++i , ++index)
    {
        NSString *c = [NSString stringWithFormat:@"%c", i];
        NSString *s = [NSString stringWithFormat:@"%@", c];
        [chars addObject :s];
    }
    NSArray *c = [chars copy];
    return c;
}

-(NSString*) getCharForPassKey:(NSString *)passKey forColumn:(int)col forRow:(int)row
{
    //get a number based on the passkey
    //this is a value based on adding the ASCII numbers for each
    //character in the string together
    unsigned long keyIndex = [self GetASCIIValue:passKey];
    
    //unscrambled ascii table of usable characters
    //these are used to make a password may add options
    //for various versions of this
    NSArray *outputChars = [self MakeASCIIArray];
    
    unsigned long r = (keyIndex * row);
    unsigned long o = (r * col);
    unsigned long outPutIndex = (o % [outputChars count]);
    
    NSString *s = [NSString stringWithFormat:@"%@",[outputChars objectAtIndex:outPutIndex]];
    
    return s;
}

-(NSMutableArray*) getInputLettersArray
{
    NSMutableArray *letterArray = [NSMutableArray array];
    unsigned long iletters = [keyLetters length];
    [keyLetters enumerateSubstringsInRange:NSMakeRange(0, iletters)
                                     options:(NSStringEnumerationByComposedCharacterSequences)
                                  usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
    {[letterArray addObject:substring];}];
    return letterArray;
}

-(void) BuildKey : ( unsigned long ) ASCIIValue
{
    //key can be any number of characters.
    
    //set number of rings to make
    int columns = 4;
    
    NSMutableArray *letterArray = [NSMutableArray array];
    unsigned long iletters = [keyLetters length];
    [keyLetters enumerateSubstringsInRange:NSMakeRange(0, iletters) options:(NSStringEnumerationByComposedCharacterSequences)
    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {[letterArray addObject:substring];}];
    
    //unscrambled ascii table of usable characters
    NSArray *outputChars = [self MakeASCIIArray];
    
    //should be 37, we'll not want to change this (A-Z 0-9 . )
    unsigned long rows = [keyLetters length];
    int t = 1;
    unsigned long rollingVal = 0;
    unsigned long val = ASCIIValue;
    for(int column = 1; column <= columns; column++)
    {
        for(int row = 1; row <= rows; row++)
        {
            unsigned long div = (val / 94) + t + column + row;
            rollingVal += div ^ val + t;
            unsigned long outPutIndex = (rollingVal + t + column + row) % [outputChars count];
            NSString *s = [NSString stringWithFormat:@"%@",[outputChars objectAtIndex:outPutIndex]];
            UIButton *button = (UIButton*)[self.MainView viewWithTag:t++];
            [button setTitle:s forState:UIControlStateNormal];
        }
    }
}

- (IBAction)ValueStep:(UIStepper *)sender
{
    [self BuildKey:sender.value];
    self.ASCIIValueOutput.text = [NSString stringWithFormat:@"%f",sender.value];
}

- (IBAction)ScrambleType:(id)sender
{

}

- (IBAction)ClearButton:(UIButton *)sender
{
    [self Password].text = @"";
    
    for(UIButton* button in self.CodeLetters)
    {
        [button setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
/*
 ASCII Table:
 0) byte: 33 - !
 1) byte: 34 - "
 2) byte: 35 - #
 3) byte: 36 - $
 4) byte: 37 - %
 5) byte: 38 - &
 6) byte: 39 - ' //apostrophe
 7) byte: 40 - (
 8) byte: 41 - )
 9) byte: 42 - *
 10) byte: 43 - +
 11) byte: 44 - , //comma
 12) byte: 45 - - //dash
 13) byte: 46 - . //period
 14) byte: 47 - /
 15) byte: 48 - 0
 16) byte: 49 - 1
 17) byte: 50 - 2
 18) byte: 51 - 3
 19) byte: 52 - 4
 20) byte: 53 - 5
 21) byte: 54 - 6
 22) byte: 55 - 7
 23) byte: 56 - 8
 24) byte: 57 - 9
 25) byte: 58 - :
 26) byte: 59 - ;
 27) byte: 60 - <
 28) byte: 61 - =
 29) byte: 62 - >
 30) byte: 63 - ?
 31) byte: 64 - @
 32) byte: 65 - A
 33) byte: 66 - B
 34) byte: 67 - C
 35) byte: 68 - D
 36) byte: 69 - E
 37) byte: 70 - F
 38) byte: 71 - G
 39) byte: 72 - H
 40) byte: 73 - I
 41) byte: 74 - J
 42) byte: 75 - K
 43) byte: 76 - L
 44) byte: 77 - M
 45) byte: 78 - N
 46) byte: 79 - O
 47) byte: 80 - P
 48) byte: 81 - Q
 49) byte: 82 - R
 50) byte: 83 - S
 51) byte: 84 - T
 52) byte: 85 - U
 53) byte: 86 - V
 54) byte: 87 - W
 55) byte: 88 - X
 56) byte: 89 - Y
 57) byte: 90 - Z
 58) byte: 91 - [
 59) byte: 92 - \
 60) byte: 93 - ]
 61) byte: 94 - ^
 62) byte: 95 - _ //underscore
 63) byte: 96 - ` //back tick
 64) byte: 97 - a
 65) byte: 98 - b
 66) byte: 99 - c
 67) byte: 100 - d
 68) byte: 101 - e
 69) byte: 102 - f
 70) byte: 103 - g
 71) byte: 104 - h
 72) byte: 105 - i
 73) byte: 106 - j
 74) byte: 107 - k
 75) byte: 108 - l
 76) byte: 109 - m
 77) byte: 110 - n
 78) byte: 111 - o
 79) byte: 112 - p
 80) byte: 113 - q
 81) byte: 114 - r
 82) byte: 115 - s
 83) byte: 116 - t
 84) byte: 117 - u
 85) byte: 118 - v
 86) byte: 119 - w
 87) byte: 120 - x
 88) byte: 121 - y
 89) byte: 122 - z
 90) byte: 123 - {
 91) byte: 124 - | //bar
 92) byte: 125 - }
 93) byte: 126 - ~
 */