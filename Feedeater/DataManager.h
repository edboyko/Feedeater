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

@property (strong,nonatomic, readonly) NSUserDefaults *standardUserDefaults;

@property (strong, nonatomic, readonly) NSManagedObjectContext *context;

+(DataManager*)sharedInstance;
@property (NS_NONATOMIC_IOSONLY, getter=getBookmarks, readonly, copy) NSArray *bookmarks;

-(NSFetchRequest*)fetchRequestWithEntity:(NSString*)entityName;

-(void)saveFeed:(NSString*)name url:(NSString*)url;
-(void)deleteObject:(NSManagedObject*)object;
-(void)saveBookmark:(NSString*)name url:(NSString*)url feed:(NSManagedObject*)feed;
-(void)editFeed:(NSManagedObject*)feed name:(NSString*)name andURL:(NSString*)urlString;
- (void)saveContext;

@end
