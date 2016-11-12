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
    
    //Set Style
    [self setUITextViewStyle];
    [self setUIImageViewStyle];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set timestamp
    self.timestampTextField.text = [self.dataObject description];
    
    [self showCount:self.currentCount TotalCount:self.totalCount];
    
    if ([self.personObject isKindOfClass:[Person class]]) {
        
        //Casting id to Person
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
            //Interation Notes
            if(classSpecifiedInstance.interaction != nil){
                self.interactionTextView.text = classSpecifiedInstance.interaction;
            }
            //Card Image
            if(classSpecifiedInstance.cardImage != nil){
                
                //Casting NSdata to Image
                UIImage *image = [UIImage imageWithData: classSpecifiedInstance.cardImage];
                //Set Image
                self.cardImageView.image = image;
            }
        }
    }
    
}

//Set UITextView Border
-(void) setUITextViewStyle{
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    self.interactionTextView.layer.borderColor = borderColor.CGColor;
    self.interactionTextView.layer.borderWidth = 1.0;
    self.interactionTextView.layer.cornerRadius = 5.0;
}

//Set UIImageView Border
-(void) setUIImageViewStyle{
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    self.cardImageView.layer.borderColor = borderColor.CGColor;
    self.cardImageView.layer.borderWidth = 1.0;
    self.cardImageView.layer.cornerRadius = 5.0;
}

//Show Page Number
-(void)showCount:(NSInteger)current TotalCount:(NSInteger)total{
    
    NSString *labCount;
    
    labCount = [NSString stringWithFormat:@"%li/%li", (long)current, (long)total];
    
    self.pageNumberLabel.text = labCount;
}

//Take Photo Button Pushed
- (IBAction)takePhotoButton:(UIButton *)sender {
    //Define an image picker
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
#if TARGET_IPHONE_SIMULATOR
    //use Photo Library
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
#elif TARGET_OS_IPHONE
    //use camera
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
#endif
    
    //present picker
    [self presentViewController:picker animated:YES completion:NULL];
}

// Select Operation
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    self.cardImageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

// Cancel Operation
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
