//
//  SingletonClass.h
//  Feedeater
//
//  Created by Edwin Boyko on 12/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface DataManager : NSObject

//@property (strong,nonatomic) NSArray *feedsArray;
@property (strong,nonatomic) NSUserDefaults *standardUserDefaults;

@property (strong, nonatomic) NSManagedObjectContext *context;

+(DataManager*)sharedInstance;
//-(void)reloadArray;
-(NSArray*)getBookmarks;
-(NSFetchRequest*)fetchRequestWithEntity:(NSString*)entityName;

-(void)saveFeed:(NSString*)name url:(NSString*)url;
//-(BOOL)deleteObject:(id)object;
-(void)deleteObject:(NSManagedObject*)object;
-(void)saveBookmark:(NSString*)name url:(NSString*)url feed:(NSManagedObject*)feed;

@end
