//
//  FeedListViewController.m
//  Feedeater
//
//  Created by Edwin Boyko on 13/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "FeedListViewController.h"
#import "LatestNewsViewController.h"
#import "EditFeedViewController.h"
#import "DataManager.h"
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FeedListViewController () <NSFetchedResultsControllerDelegate>{
    LatestNewsViewController *newsVC;
    EditFeedViewController *editFeedVC;
}

@property (strong, nonatomic) DataManager *dataManager;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (assign, nonatomic) BOOL editing;

@end

@implementation FeedListViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Saved Feeds";
    self.dataManager = [DataManager sharedInstance];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
    [self.dataManager saveContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.fetchedResultsController).sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController).sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CellFeed";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    if(self.editing){
        cell.backgroundColor = [UIColor colorWithRed:0.98 green:0.37 blue:0.38 alpha:1.0];
    }
    else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    NSManagedObject *feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [feed valueForKey:@"name"];
    NSDate *date = [feed valueForKey:@"created"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"HH:mm dd/MM/YYYY";
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Added: %@", [dateFormatter stringFromDate:date]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

#pragma mark Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!_editing){
        [self performSegueWithIdentifier:@"toNews" sender:[tableView cellForRowAtIndexPath:indexPath]];
        newsVC.selectedFeed = [self.fetchedResultsController objectAtIndexPath:indexPath]; // Save Feed you want to edit to News View Controller
        
        newsVC.title = [newsVC.selectedFeed valueForKey:@"name"]; // Change News View Controller's title to selected feed Name
    }
    else {
        [self performSegueWithIdentifier:@"toEditFeed" sender:[tableView cellForRowAtIndexPath:indexPath]];
        editFeedVC.selectedFeed = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        
        [self.navigationController presentViewController:[self deleteFeedAlert:indexPath] animated:YES completion:nil];
    }
}

-(UIAlertController*)deleteFeedAlert:(NSIndexPath*)indexPath{
    UIAlertController *deleteFeedAlert = [UIAlertController alertControllerWithTitle:@"Delete" message:@"Are you sure you want to delete this feed?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.dataManager deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }];
    UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:nil];
    [deleteFeedAlert addAction:backAction];
    [deleteFeedAlert addAction:deleteAction];
    
    return deleteFeedAlert;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqual: @"toNews"]){
        // Find News View Controller
        newsVC = segue.destinationViewController;
    }
    else if([segue.identifier isEqual: @"toEditFeed"]){
        // Find Edit Feed View Controller
        editFeedVC = segue.destinationViewController;
    }
}
#pragma mark - Add Feed Alert

/*
- (BOOL)validateUrl:(NSString *)candidate { // Checks if URL is in correct format
    NSString *urlRegEx = @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&amp;=]*)?";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}


- (IBAction)addAlert:(id)sender { // Shows "Add Feed" alert view
    NSString *alertMessage = @"Please fill all fields.\nPlease provide correct URL address.";
    UIAlertController *newFeedAlert = [UIAlertController alertControllerWithTitle:@"Add New Feed" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    // Add textfields for Name and URL address
    [newFeedAlert addTextFieldWithConfigurationHandler:nil];
    [newFeedAlert addTextFieldWithConfigurationHandler:nil];
    // Save textfields to variables
    UITextField *nameField = [[newFeedAlert textFields]firstObject];
    UITextField *urlField = [[newFeedAlert textFields]lastObject];
    
    nameField.placeholder = @"Name";
    urlField.placeholder = @"URL";
    
    UIAlertAction *addFeed = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if(![nameField.text isEqualToString:@""] && ![urlField.text isEqualToString:@""]){
            if([self validateUrl:urlField.text]){ // If all fields were filled correctly, add new feed
                
                if([self.dataManager saveFeed:nameField.text url:urlField.text]){
                    [self.dataManager reloadArray];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                }
                else {
                    NSLog(@"Unable to save feed.");
                }
            }
            else { // Inform user that they failed to provide correct URL
                UIAlertController *newFeedAlert = [UIAlertController alertControllerWithTitle:@"Wrong URL" message:@"Please provide correct URL address." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okay = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [newFeedAlert addAction:okay];
                [self presentViewController:newFeedAlert animated:true completion:nil];
            }
        }
        else { // Inform user that they failed to fill all fields
            UIAlertController *newFeedAlert = [UIAlertController alertControllerWithTitle:@"Please Fill All Fields" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [newFeedAlert addAction:okay];
            [self presentViewController:newFeedAlert animated:true completion:nil];

        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [newFeedAlert addAction:addFeed];
    [newFeedAlert addAction:cancel];
    
    [self presentViewController:newFeedAlert animated:true completion:nil];
}
*/

/*
- (void)loginWithFacebook { // Performs facebook login or logout
    if([FBSDKAccessToken currentAccessToken] == nil){
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        [login logInWithPublishPermissions: @[@"publish_actions"] fromViewController:self
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         {
             if (error) {
                 NSLog(@"Process error");
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
             } else {
                 NSLog(@"Logged in");
                 [FBSDKAccessToken setCurrentAccessToken:result.token];
             }
         }];
    }
    else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
    }
}
*/

#pragma mark - Options

- (IBAction)showOptions:(UIBarButtonItem *)sender {
    
    UIAlertController *options= [UIAlertController alertControllerWithTitle:@"Options" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* editingMode = [UIAlertAction actionWithTitle:@"Editing Mode"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
    {
        NSLog(@"Enable Editing Mode!");
        _editing = !_editing;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }];
    UIAlertAction* openBookmarks = [UIAlertAction actionWithTitle:@"All Bookmarks"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
    {
        // Open Bookmarks
        [self performSegueWithIdentifier:@"bookMarks" sender:nil];
    }];
    
    UIAlertAction* openSettings = [UIAlertAction actionWithTitle:@"Settings"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
    {
        // Open Settings
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    UIAlertAction* about = [UIAlertAction actionWithTitle:@"About"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action)
    {
        // Open About screen
        [self performSegueWithIdentifier:@"toInfo" sender:nil];
    }];
    
    UIAlertAction* close = [UIAlertAction actionWithTitle:@"Close"
                                                    style:UIAlertActionStyleCancel
                                                  handler:nil];
    
    // Login with facebook. No need for it at the moment
    /*
    NSString *fbloginTitle;
    
    // Change name of "Facebook Login" item based on login status
    if([FBSDKAccessToken currentAccessToken] == nil){
        fbloginTitle = @"Login with Facebook";
    }
    else {
        fbloginTitle = @"Logout";
    }
    
    UIAlertAction* loginToFacebook = [UIAlertAction actionWithTitle:fbloginTitle style:UIAlertActionStyleDefault
    handler:^(UIAlertAction * action)
    {
    // Login with Facebook
    [self loginWithFacebook];
    }];
    */
    
    //[options addAction:loginToFacebook];
    [options addAction:editingMode];
    [options addAction:openBookmarks];
    [options addAction:openSettings];
    [options addAction:about];
    [options addAction:close];
    
    [self presentViewController:options animated:YES completion:nil];
}

#pragma mark - Fetched Results Controller

- (NSFetchedResultsController*)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [self.dataManager fetchRequestWithEntity:@"Feed"];
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20;
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:self.dataManager.context
                                                             sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    }
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
