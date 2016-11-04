//
//  SingletonClass.m
//  Feedeater
//
//  Created by Edwin Boyko on 12/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "DataManager.h"

@interface DataManager()

@property (readonly, strong) NSPersistentContainer *persistentContainer;

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


-(NSManagedObjectContext*)context{
    return self.persistentContainer.viewContext;
}

/*
-(id)init{
    self = [super init];
    if(self){
        [self reloadArray];
    }
    return self;
}
*/
/*
-(NSManagedObjectContext*)context{
    return [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer]viewContext];
}
 */
#pragma mark - Get Data

-(NSFetchRequest*)fetchRequestWithEntity:(NSString *)entityName{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    fetchRequest.entity = entity;
    return fetchRequest;
}
/*
-(void)reloadArray{
    NSManagedObjectContext *context = [self context];
    NSEntityDescription *feedEntity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *error;
    [request setEntity:feedEntity];
    self.feedsArray = [context executeFetchRequest:request error:&error];
}
*/
-(NSArray*)getBookmarks{
    NSManagedObjectContext *context = self.context;
    NSEntityDescription *bookmarkEntity = [NSEntityDescription entityForName:@"Bookmark" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *error;
    request.entity = bookmarkEntity;
    return [context executeFetchRequest:request error:&error];
}
 
#pragma mark - Save Data

-(void)saveFeed:(NSString*)name url:(NSString*)url{
    NSManagedObjectContext *context = self.context;
    NSManagedObject *newFeed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:context];
    
    [newFeed setValue:name forKey:@"name"];
    [newFeed setValue:url forKey:@"url"];
    [newFeed setValue:[NSDate date] forKey:@"created"];
    
    NSError *error = nil;
    
    if (![newFeed.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

-(void)saveBookmark:(NSString*)name url:(NSString*)url feed:(NSManagedObject*)feed{
    
    NSManagedObjectContext *context = self.context;
    
    NSManagedObject *newBookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:context];
    
    [newBookmark setValue:name forKey:@"name"];
    [newBookmark setValue:url forKey:@"url"];
    [newBookmark setValue:feed forKey:@"feed"];
    
    NSError *error = nil;
    
    if (![newBookmark.managedObjectContext save:&error]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

#pragma mark - Delete Data

-(void)deleteObject:(NSManagedObject*)object{
    [self.context deleteObject:object];
    NSError *deleteError = nil;
    if(![object.managedObjectContext save:&deleteError]){
        NSLog(@"Unable to save managed object context.");
        NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
    }
}

#pragma mark - User Defaults

-(NSUserDefaults*)standardUserDefaults{
    return [NSUserDefaults standardUserDefaults];
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Feedeater"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if (context.hasChanges && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
