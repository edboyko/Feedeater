//
//  FeedBookmarksViewController.m
//  Feedeater
//
//  Created by Edwin Boyko on 19/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "FeedBookmarksViewController.h"
#import "LatestNewsViewController.h"

@interface FeedBookmarksViewController ()

@property (strong, nonatomic) NSArray *bookmarksArray;

@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation FeedBookmarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataManager = [DataManager sharedInstance];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    [self updateTitle];
}

-(void)updateTitle{ // Updates title to show amount of Bookmarks
    self.title = [NSString stringWithFormat:@"Bookmarks (%lu)", [[[self.currentFeed valueForKey:@"bookmarks"]allObjects]count]];
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
    return [[[self.currentFeed valueForKey:@"bookmarks"]allObjects]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"BookmarkCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[[[self.currentFeed valueForKey:@"bookmarks"]allObjects] objectAtIndex:indexPath.row]valueForKey:@"name"];
    
    float fontSize = [[self.dataManager standardUserDefaults]floatForKey:@"font_size"];
    [cell.textLabel setFont:[cell.textLabel.font fontWithSize:fontSize]];
    [cell.textLabel setNumberOfLines:2];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{ // Open bookmark in browser
    NSURL *url = [NSURL URLWithString:[[[[self.currentFeed valueForKey:@"bookmarks"]allObjects] objectAtIndex:indexPath.row ] valueForKey:@"url"]];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *currentBookmarksArray = [[self.currentFeed valueForKey:@"bookmarks"]allObjects];
        [self.dataManager deleteObject:[currentBookmarksArray objectAtIndex:indexPath.row]];
        
        [self.dataManager reloadArray];
        [self updateTitle];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        /*
        if([self.dataManager deleteObject:[currentBookmarksArray objectAtIndex:indexPath.row]]){
            [self.dataManager reloadArray];
            [self updateTitle];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        */
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
