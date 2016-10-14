//
//  FeedListViewController.m
//  Feedeater
//
//  Created by Edwin Boyko on 13/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "FeedListViewController.h"

@interface FeedListViewController (){
    LatestNewsViewController *latestNewsVC;
    EditFeedViewController *editFeedVC;
    NSUserDefaults *standarduserDefaults;
}

@end

@implementation FeedListViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
    
    self.title = @"Feeds";
    self.dataManager = [DataManager sharedInstance];
}

-(void)update{
    NSLog(@"update!");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    
    [self.dataManager reloadArray];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataManager.feedsArray.count;
}


- (FeedCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CellFeed";
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell == nil){
        cell = [[FeedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [cell configureWithObjectFromArray:self.dataManager.feedsArray atIndex:indexPath.row];
    
    [cell.editFeedButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside]; // Add action to Edit Button
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.newsVC.selectedFeed = [[self.dataManager feedsArray]objectAtIndex:indexPath.row]; // Save Feed you want to edit to News View Controller
    self.newsVC.title = [self.newsVC.selectedFeed valueForKey:@"name"]; // Change News View Controller's title to selected feed Name
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
        if([self.dataManager deleteObject:[self.dataManager.feedsArray objectAtIndex:indexPath.row]]){
            
            [self.dataManager reloadArray];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
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
    // Get the new view controller using [segue destinationViewController].
    if([segue.identifier isEqual: @"toNews"]){
        // Find News View Controller
        self.newsVC = [segue destinationViewController];
    }
    else if([segue.identifier isEqual: @"toEditFeed"]){
        // Find Edit Feed View Controller
        editFeedVC = [segue destinationViewController];
    }
}


-(void)edit:(UIButton*)sender
{
    // Save Feed you want to edit to Edit Feed View Controller
    editFeedVC.selectedFeed = [[self.dataManager feedsArray]objectAtIndex:sender.tag];
}

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

- (IBAction)showOptions:(UIBarButtonItem *)sender {
    
    UIAlertController *options= [UIAlertController alertControllerWithTitle:@"Options" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* openBookmarks = [UIAlertAction actionWithTitle:@"All Bookmarks" style:UIAlertActionStyleDefault
    handler:^(UIAlertAction *action)
    {
        // Open Bookmarks
        [self performSegueWithIdentifier:@"bookMarks" sender:nil];
    }];
    
    UIAlertAction* openSettings = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault
    handler:^(UIAlertAction *action)
    {
        // Open Settings
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    UIAlertAction* about = [UIAlertAction actionWithTitle:@"About" style:UIAlertActionStyleDefault
    handler:^(UIAlertAction *action)
    {
        // Open About screen
        [self performSegueWithIdentifier:@"toInfo" sender:nil];
    }];
    
    UIAlertAction* close = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    
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
    [options addAction:openBookmarks];
    [options addAction:openSettings];
    [options addAction:about];
    [options addAction:close];
    
    [self presentViewController:options animated:YES completion:nil];
}

-(void)toBookmarks:(id)sender{
    [self performSegueWithIdentifier:@"bookMarks" sender:sender];
}

@end
