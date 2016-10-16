//
//  SingletonClass.m
//  Feedeater
//
//  Created by Edwin Boyko on 12/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "DataManager.h"
@interface DataManager()

@property (strong, nonatomic, readonly) NSManagedObjectContext *context;

@end

@implementation DataManager



+(DataManager*)sharedInstance{
    static DataManager *dataManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dataManager = [[DataManager alloc]init];
    });
    
    return dataManager;
}

-(id)init{
    self = [super init];
    if(self){
        [self reloadArray];
    }
    return self;
}

-(NSManagedObjectContext*)context{
    
    return [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer]viewContext];
}

#pragma mark - Get Data

-(void)reloadArray{
    NSManagedObjectContext *context = [self context];
    NSEntityDescription *feedEntity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *error;
    [request setEntity:feedEntity];
    self.feedsArray = [context executeFetchRequest:request error:&error];
}

-(NSArray*)getBookmarks{
    NSManagedObjectContext *context = self.context;
    NSEntityDescription *bookmarkEntity = [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *error;
    [request setEntity:bookmarkEntity];
    return [context executeFetchRequest:request error:&error];
}

#pragma mark - Save Data

-(BOOL)saveFeed:(NSString*)name url:(NSString*)url{
    NSManagedObjectContext *context = self.context;
    NSManagedObject *newFeed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:context];
    
    [newFeed setValue:name forKey:@"name"];
    [newFeed setValue:url forKey:@"url"];
    
    NSError *error = nil;
    
    if (![newFeed.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        return false;
    }
    else {
        return true;
    }
}

-(BOOL)saveBookmark:(NSString*)name url:(NSString*)url feed:(NSManagedObject*)feed{
    
    NSManagedObjectContext *context = self.context;
    
    NSManagedObject *newBookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:context];
    
    [newBookmark setValue:name forKey:@"name"];
    [newBookmark setValue:url forKey:@"url"];
    [newBookmark setValue:feed forKey:@"feed"];
    
    NSError *error = nil;
    
    if (![newBookmark.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        return false;
    }
    else {
        return true;
    }
}

#pragma mark - Delete Data

-(BOOL)deleteObject:(id)object{
    NSManagedObject *objectToDelete = object;
    NSManagedObjectContext *context = [self context];
    [context deleteObject:objectToDelete];
    
    NSError *deleteError = nil;
    
    if (![objectToDelete.managedObjectContext save:&deleteError]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
        return false;
    }
    else {
        return true;
    }
}

#pragma mark - User Defaults

-(NSUserDefaults*)standardUserDefaults{
    return [NSUserDefaults standardUserDefaults];
}

@end
