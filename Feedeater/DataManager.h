//
//  SingletonClass.h
//  Feedeater
//
//  Created by Edwin Boyko on 12/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface DataManager : NSObject

@property (strong,nonatomic) NSUserDefaults *standardUserDefaults;

@property (strong, nonatomic) NSManagedObjectContext *context;

+(DataManager*)sharedInstance;
-(NSArray*)getBookmarks;
-(NSFetchRequest*)fetchRequestWithEntity:(NSString*)entityName;

-(void)saveFeed:(NSString*)name url:(NSString*)url;
-(void)deleteObject:(NSManagedObject*)object;
-(void)saveBookmark:(NSString*)name url:(NSString*)url feed:(NSManagedObject*)feed;

- (void)saveContext;

@end
