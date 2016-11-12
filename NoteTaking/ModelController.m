//
//  ModelController.m
//  NoteTaking
//
//  Created by Rui on 2016-11-10.
//  Copyright © 2016 Rui. All rights reserved.
//

#import "ModelController.h"
#import "DataViewController.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


@interface ModelController ()

@property (readonly, strong, nonatomic) NSMutableArray *timestampPageData;
@property (readonly, strong, nonatomic) NSMutableArray *personPageData;
@end

@implementation ModelController


- (instancetype)init {
    self = [super init];
    if (self) {
        
        _timestampPageData = [[NSMutableArray alloc] init];
        _personPageData = [[NSMutableArray alloc] init];

        NSArray *arrayResult= [self loadCoreData];
        
        //If has Core Data, Then Read it out, Set to The Page Data Array
        if(arrayResult.count > 0){
            NSLog(@"count = %lu", (unsigned long)arrayResult.count);
            //Set Core Data To Array
            for(Person *person in arrayResult){
                [_personPageData addObject:person];
                [_pageData addObject:person.timestamp];
            }
        }
        //If hasn't Core Data, Create a new Page Data
        else{
            NSString *date = [self getDateString];
            [_timestampPageData addObject:date];
        }
    }
    return self;
}


//Forward flip page
- (DataViewController *)forwardviewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Return the data view controller for the given index.
    if (([self.timestampPageData count] == 0) || (index >= [self.timestampPageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    dataViewController.dataObject = self.pageData[index];
    
    //Set person detail view base on page index
    if (([self.personPageData count] != 0) && (index < [self.personPageData count])) {
        dataViewController.personObject = self.personPageData[index];
    }
    
    //Set Page Number to dataViewController
    dataViewController.totalCount = self.pageData.count;
    dataViewController.currentCount = index + 1;
    
    return dataViewController;
}

//Backward filp page
- (DataViewController *)backwardviewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Return the data view controller for the given index.
    if (([self.timestampPageData count] == 0) || (index >= [self.timestampPageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    
    //Set person detail view base on page index
    dataViewController.dataObject = self.pageData[index];
    dataViewController.personObject = self.personPageData[index];
    
    //Set Page Number to dataViewController
    dataViewController.totalCount = self.pageData.count;
    dataViewController.currentCount = index + 1;
    
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(DataViewController *)viewController {
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    
    return [self.pageData indexOfObject: viewController.dataObject];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self backwardviewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    if (index == [self.timestampPageData count]) {
        
        DataViewController *dataViewControllerInstance = (DataViewController *)viewController;
        
        //If Name is empty, return nil
        if([dataViewControllerInstance.nameTextField.text isEqual: @""]){
            return nil;
        }
        
        //Only Save Data When it is last page
        if( index != [self.personPageData count]){
            NSData *uiImageData = UIImagePNGRepresentation(dataViewControllerInstance.cardImageView.image);
            
            [self SaveCoreData:dataViewControllerInstance.nameTextField.text Date:dataViewControllerInstance.timestampTextField.text Interaction:dataViewControllerInstance.interactionTextView.text CardImage:uiImageData];
            
            //set dataviewcontroller personObject
            dataViewControllerInstance.personObject = self.personPageData[index-1];
        }
        
        //Add a new page
        NSString *date = self.getDateString;
        [_timestampPageData addObject:date];
        
    }
    
    return [self forwardviewControllerAtIndex:index storyboard:viewController.storyboard];
}

//Convert Data to String With Format
-(NSString *)getDateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:now];
    return dateString;
}

// Load data from the local database if it's avaliable
- (NSArray*)loadCoreData {
    
    // 1. Get a pointer to the database
    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext];
    
    // 2. fetch data from core data
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    //Sort by timestamp
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    
    // Fetch Core Data
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(error){
        NSLog(@"Fetch request Failed! %@", [error localizedDescription]);
    }
    
    return results;
}

// Save data from the DataView
- (void)SaveCoreData: (NSString*)name Date:(NSString*)date Interaction:(NSString*)interaction CardImage:(NSData*) cardImage{
    
    // 1. Get a pointer to the database
    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext];
    
    // 2. Get Entity Descripton
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext];
    
    // 3. Initial a new person
    Person *person = [[Person alloc]initWithEntity: entityDescription insertIntoManagedObjectContext:managedObjectContext];
    
    // Set Data
    [person setValue:name forKeyPath:@"name"];
    [person setValue:date forKeyPath:@"timestamp"];
    [person setValue:interaction forKeyPath:@"interaction"];
    [person setValue:cardImage forKeyPath:@"cardImage"];
    
    // Add to Page Data
    [_personPageData addObject:person];
    
    NSError *error = nil;
    
    // Save Data to Core Data
    if(![managedObjectContext save:&error]){
        NSLog(@"Save Failed! %@", [error localizedDescription]);
    }else{
        NSLog(@"Person %@ Saved!", name);
    }
}


@end
