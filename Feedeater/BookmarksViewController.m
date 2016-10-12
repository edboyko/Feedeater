//
//  BookmarksViewController.m
//  Feedeater
//
//  Created by Edwin Boyko on 16/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "BookmarksViewController.h"

@interface BookmarksViewController (){
    NSMutableArray *feedArray;
}

@end

@implementation BookmarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    feedArray = [[NSMutableArray alloc]init];
    self.dataManager = [DataManager sharedInstance];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    [self.dataManager reloadArray];
    
    [self findNonEmpty]; // Only show feeds that have bookmarks in them
    
}

-(void)findNonEmpty{
    [feedArray removeAllObjects]; // Make sure array always clean
    for(NSManagedObject *feed in self.dataManager.feedsArray){
        if([[[feed valueForKey:@"bookmarks"]allObjects]count] > 0){ // Find only feeds that have bookmarks in them
            [feedArray addObject:feed]; // Add non empty feed to temporary array
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return feedArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[feedArray objectAtIndex:section]valueForKey:@"bookmarks"]count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSManagedObject *feed = [feedArray objectAtIndex:section];
    
    return [NSString stringWithFormat:@"%@ (%lu)",[feed valueForKey:@"name"], [[[feed valueForKey:@"bookmarks"]allObjects]count]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"BookmarkCell";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[[[[feedArray objectAtIndex:indexPath.section]valueForKey:@"bookmarks"]allObjects] objectAtIndex:indexPath.row]valueForKey:@"name"];
    float fontSize = [[self.dataManager standardUserDefaults]floatForKey:@"font_size"];
    [cell.textLabel setFont:[cell.textLabel.font fontWithSize:fontSize]];
    cell.textLabel.numberOfLines = 2;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSURL *url = [NSURL URLWithString:[[[[[feedArray objectAtIndex:indexPath.section]valueForKey:@"bookmarks"]allObjects] objectAtIndex:indexPath.row]valueForKey:@"url"]];
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
        // Delete the row from the data source
        NSArray *currentBookmarksArray = [[[feedArray objectAtIndex:indexPath.section]valueForKey:@"bookmarks"]allObjects];
        if([self.dataManager deleteObject:[currentBookmarksArray objectAtIndex:indexPath.row]]){
            
            NSIndexSet *currentSection = [NSIndexSet indexSetWithIndex:indexPath.section];
            
            [self.dataManager reloadArray];
            
            if([[[[feedArray objectAtIndex:indexPath.section]valueForKey:@"bookmarks"]allObjects]count] < 1){ // Check if last bookmark was deleted
                [self findNonEmpty]; // Reload array to get rid of empty feeds
                [tableView deleteSections:currentSection withRowAnimation:UITableViewRowAnimationFade]; // Delete empty section
                [tableView reloadSectionIndexTitles];
            }
            else {
                [self.tableView reloadSections:currentSection withRowAnimation:UITableViewRowAnimationFade]; // Reload section if still bookmarks left
            }
        }
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
