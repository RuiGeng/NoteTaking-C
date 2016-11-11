//
//  DataViewController.h
//  NoteTaking
//
//  Created by Rui on 2016-11-10.
//  Copyright © 2016 Rui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person+CoreDataProperties.h"

@interface DataViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *timestampTextField;

@property (weak, nonatomic) IBOutlet UITextView *interactionTextField;

@property (strong, nonatomic) id dataObject;

@property (weak, nonatomic) IBOutlet UITextView *interactionTextView;

@property (weak, nonatomic) IBOutlet UIImageView *cardImageView;

@end

