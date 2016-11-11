//
//  ModelController.h
//  NoteTaking
//
//  Created by Rui on 2016-11-10.
//  Copyright © 2016 Rui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person+CoreDataProperties.h"
#import "DataManager.h"


@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)forwardviewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (DataViewController *)backwardviewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end

