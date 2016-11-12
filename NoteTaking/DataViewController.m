//
//  DataViewController.m
//  NoteTaking
//
//  Created by Rui on 2016-11-10.
//  Copyright © 2016 Rui. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUITextViewStyle];
    [self setUIImageViewStyle];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.timestampTextField.text = [self.dataObject description];
    
    [self showCount:self.currentCount TotalCount:self.totalCount];
    
    if ([self.personObject isKindOfClass:[Person class]]) {
        Person *classSpecifiedInstance = (Person *)self.personObject;
        if(classSpecifiedInstance != nil){
            //Person Name
            if(classSpecifiedInstance.name != nil){
                self.nameTextField.text = classSpecifiedInstance.name;
            }
            /*
            if(classSpecifiedInstance.timestamp != nil){
                        self.timestampTextField.text = classSpecifiedInstance.timestamp;
            }
             */
            if(classSpecifiedInstance.interaction != nil){
                self.interactionTextView.text = classSpecifiedInstance.interaction;
            }
            if(classSpecifiedInstance.cardImage != nil){
                UIImage *image = [UIImage imageWithData: classSpecifiedInstance.cardImage];
                self.cardImageView.image = image;
            }
        }
    }
    
}

-(void) setUITextViewStyle{
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    self.interactionTextView.layer.borderColor = borderColor.CGColor;
    self.interactionTextView.layer.borderWidth = 1.0;
    self.interactionTextView.layer.cornerRadius = 5.0;
}

-(void) setUIImageViewStyle{
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    self.cardImageView.layer.borderColor = borderColor.CGColor;
    self.cardImageView.layer.borderWidth = 1.0;
    self.cardImageView.layer.cornerRadius = 5.0;
}

-(void)showCount:(NSInteger)current TotalCount:(NSInteger)total{
    
    NSString *labCount;
    
    labCount = [NSString stringWithFormat:@"%li/%li", (long)current, (long)total];
    
    self.pageNumberLabel.text = labCount;
}

@end
