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

@property (strong,nonatomic) NSArray *feedsArray;
@property (strong,nonatomic) NSUserDefaults *standardUserDefaults;

@property (strong, nonatomic) NSFetchedResultsController *frc;

+(DataManager*)sharedInstance;
-(void)reloadArray;
-(NSArray*)getBookmarks;

-(BOOL)saveFeed:(NSString*)name url:(NSString*)url;
-(BOOL)deleteObject:(id)object;
-(BOOL)saveBookmark:(NSString*)name url:(NSString*)url feed:(NSManagedObject*)feed;

@end
