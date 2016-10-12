//
//  LatestNewsViewController.m
//  Feedeater
//
//  Created by Edwin Boyko on 13/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "LatestNewsViewController.h"

@interface LatestNewsViewController (){
    StoryDetailsTableViewController *storyVC;
    FeedBookmarksViewController *feedBookmarksVC;
    NSString *keyName; // Address for the feed in the Defaults
    int newStoriesAmount; // Amount of new stories since last visit
    NSURL *finalURL;
    NSURLSession *session;
}

@end

@implementation LatestNewsViewController

    NSInteger numberOfNews = 60; // Max amount of stories shown
    NSInteger hudHideDelay = 10; // Delay before hud will disappear in seconds

- (void)viewDidLoad {
    [super viewDidLoad];
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self.refreshControl = [[UIRefreshControl alloc]init];
    
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    
    self.dataManager = [DataManager sharedInstance];
    
    [self setUpProgressHUD]; // Give default settings to Progress HUD
    
    self.definesPresentationContext = true;
    
    self.searchResults = [[NSMutableArray alloc]init];
    
    [self setUpSearchController];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.searchController loadViewIfNeeded];
    
    NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&userip=%@&num=%li&q=%@",[self getIPAddress], (long)numberOfNews, [self.selectedFeed valueForKey:@"url"]];
    finalURL = [NSURL URLWithString:urlString];
    [self getNewsFromURL:finalURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Downloading Data

- (void)setUpProgressHUD {
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:true];
    
    [self.hud.backgroundView setStyle:MBProgressHUDBackgroundStyleBlur];
    self.hud.label.text = @"Loading";
    self.hud.removeFromSuperViewOnHide = true;
    self.hud.center = self.view.center;
    self.hud.completionBlock = ^{
        if(self.newsArray.count == 0){
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was a problem with loading data." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.navigationController popToRootViewControllerAnimated:true];
            }];
            [errorAlert addAction:okay];
            [self.navigationController presentViewController:errorAlert animated:true completion:nil];
        }
    };
    [self.hud hideAnimated:true afterDelay:hudHideDelay];
}

-(void)showInternetAlert{
    UIAlertController *internetAlert = [UIAlertController alertControllerWithTitle:@"Error with Loading" message:@"Please check your internet connection." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self.navigationController popToRootViewControllerAnimated:true];
    }];
    [internetAlert addAction:okay];
    [self.navigationController presentViewController:internetAlert animated:YES completion:nil];
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

-(void)checkForNewStories{
    newStoriesAmount = 0;
    NSString *title;
    NSString *key = [NSString stringWithFormat:@"%@_lastTitle", keyName]; // Create key for defaults
    
    if([[self.dataManager standardUserDefaults] objectForKey:key]){ // If there is object under such key
        for(id story in self.newsArray){ // Go through news titles
            title = [story objectForKey:@"title"];
            if(![title isEqualToString:[[self.dataManager standardUserDefaults] objectForKey:key]]){
                // Check if there are new stories on top of the old ones
                newStoriesAmount++; // Increment amount value if different title
            }
            else {
                break; // Exit if faced same title
            }
        }
        if(newStoriesAmount > 0) {
            self.title = [NSString stringWithFormat:@"%@ (%i New)",[self.selectedFeed valueForKey:@"name"], newStoriesAmount];
            // Indicate how many new stories since last visit
        }
    }
    
    [[self.dataManager standardUserDefaults] setObject:[[self.newsArray firstObject]objectForKey:@"title"] forKey:key]; // Save first title to defaults to check on new stories next time
}

-(void)pullToRefresh{
    [self setUpProgressHUD];
    [self getNewsFromURL:finalURL];
}

-(void)getNewsFromURL:(NSURL*)url{
    [self.tableView reloadData];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error){
            [self.hud hideAnimated:true];
        }
        else {
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if([[jsonDict objectForKey:@"responseStatus"]integerValue] == 400){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hud hideAnimated:true];
                });
            }
            else {
                
                NSMutableArray *tempArr = [[[jsonDict objectForKey:@"responseData"]objectForKey:@"feed"] objectForKey:@"entries"];
                
                keyName = [[[jsonDict objectForKey:@"responseData"]objectForKey:@"feed"]objectForKey:@"title"];
                
                self.newsArray = tempArr;
                
                self.visibleNews = self.newsArray;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hud hideAnimated:true];
                    [self checkForNewStories];
                    [self.tableView reloadData];
                    [self.refreshControl endRefreshing];
                });
            }
        }
    }]resume];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.visibleNews.count;
}

- (StoryCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"StoryCell";
    StoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[StoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.titleLabel.text = [[self.visibleNews objectAtIndex:indexPath.row]objectForKey:@"title"];
    
    float fontSize = [[self.dataManager standardUserDefaults]floatForKey:@"font_size"];
    [cell.titleLabel setFont:[cell.titleLabel.font fontWithSize:fontSize]];
    
    cell.openButton.tag = indexPath.row;
    [cell.openButton addTarget:self action:@selector(openInBrowser:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.textLabel.numberOfLines = 2;
    if(!cell.shown){
        if(indexPath.row < newStoriesAmount){
            cell.titleLabel.text = [NSString stringWithFormat:@"NEW! %@", cell.titleLabel.text];
            UIColor *golden = [UIColor colorWithRed:1.00 green:0.84 blue:0.00 alpha:1.0];
            cell.layer.backgroundColor = golden.CGColor;
            
            [UIView animateWithDuration:0.9 animations:^{
                cell.layer.backgroundColor = [UIColor clearColor].CGColor;
            } completion:nil];
        }
        cell.shown = true;
    }
    
    return cell;
}

-(void)openInBrowser:(UIButton*)button{
    NSString *urlString = [[self.visibleNews objectAtIndex:button.tag] valueForKey:@"link"];
    NSURL *url = [NSURL URLWithString:urlString];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    storyVC.selectedStory = [self.visibleNews objectAtIndex:indexPath.row];
    storyVC.currentFeed = self.selectedFeed;

    [self.searchController setActive:false];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Search COntroller

- (void)setUpSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    
    [self.searchController.searchBar sizeToFit];
    [self.searchController.searchBar setPlaceholder:@"Search for News"];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = searchController.searchBar.text;
    
    if (![searchString isEqualToString:@""]) {
        [self.searchResults removeAllObjects];
        
        for(id story in self.newsArray){
            
            NSString *storyTitle = [story objectForKey:@"title"];
            BOOL matchesFound = [storyTitle localizedCaseInsensitiveContainsString:searchString];
            
            if(matchesFound){
                [self.searchResults addObject:story];
            }
        }
        self.visibleNews = self.searchResults;
    }
    else {
        self.visibleNews = self.newsArray;
    }
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"toStory"]){
        storyVC = [segue destinationViewController];
    }
    if([[segue identifier] isEqualToString:@"toFeedsBookmarks"]){
        feedBookmarksVC = [segue destinationViewController]; // Find Feed Bookmarks VC
        feedBookmarksVC.currentFeed = self.selectedFeed; // Transfer selected feed to Feed Bookmarks VC
    }
}


- (IBAction)toHomeScreen:(id)sender { // Swipe right to go to the homescreen
    [self.navigationController popToRootViewControllerAnimated:true];
}

@end
