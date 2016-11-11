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

@property (readonly, strong, nonatomic) NSMutableArray *pageData;
@end

@implementation ModelController


- (instancetype)init {
    self = [super init];
    if (self) {
        
        NSArray *results= [self loadCoreData];
        if(results.count > 0){
            [_pageData addObject:results];
        }
        else{
            NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext];
            
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext];
            
            Person *person = [[Person alloc]initWithEntity: entityDescription insertIntoManagedObjectContext:managedObjectContext];
            
            person.name = @"";
            person.timestamp = [self getDateString];
            person.interaction = @"";
            person.cardImage = nil;
            
            _pageData = [[NSMutableArray alloc] init];
            
            [_pageData addObject:person];
        }
    }
    return self;
}

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    dataViewController.dataObject = self.pageData[index];
    
    return dataViewController;
}


- (NSUInteger)indexOfViewController:(DataViewController *)viewController {
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.dataObject];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    DataViewController *dataViewControllerInstance = (DataViewController *)viewController;
    
    if([dataViewControllerInstance.nameTextField.text isEqual: @""]){
        return nil;
    }
    
    NSData *uiImageData = UIImagePNGRepresentation(dataViewControllerInstance.cardImageView.image);
    
    [self SaveCoreData:dataViewControllerInstance.nameTextField.text Date:dataViewControllerInstance.timestampTextField.text Interaction:dataViewControllerInstance.interactionTextView.text CardImage:uiImageData];
    
    index++;
    if (index == [self.pageData count]) {
        
        NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext];
        
        Person *person = [[Person alloc]initWithEntity: entityDescription insertIntoManagedObjectContext:managedObjectContext];
        
        person.name = @"";
        person.timestamp = [self getDateString];
        person.interaction = @"";
        person.cardImage = nil;
        
        _pageData = [[NSMutableArray alloc] init];
        
        [_pageData addObject:person];
        
        //return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

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
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(error){
        NSLog(@"Fetch request Failed! %@", [error localizedDescription]);
    }
    
    return results;
}

// Save data from the DataView
- (void)SaveCoreData: (NSString*)name Date:(NSString*)date Interaction:(NSString*)interaction CardImage:(NSData*) cardImage{
    
    NSManagedObjectContext *managedObjectContext = [[DataManager sharedManager] managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext];
    
    Person *person = [[Person alloc]initWithEntity: entityDescription insertIntoManagedObjectContext:managedObjectContext];
    
    [person setValue:name forKeyPath:@"name"];
    [person setValue:date forKeyPath:@"timestamp"];
    [person setValue:interaction forKeyPath:@"interaction"];
    [person setValue:cardImage forKeyPath:@"cardImage"];
    
    NSError *error = nil;
    if(![managedObjectContext save:&error]){
        NSLog(@"Save Failed! %@", [error localizedDescription]);
    }else{
        NSLog(@"Person %@ Saved!", name);
    }
}


@end
