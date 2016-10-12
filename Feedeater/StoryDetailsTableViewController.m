//
//  StoryDetailsTableViewController.m
//  Feedeater
//
//  Created by Edwin Boyko on 02/09/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "StoryDetailsTableViewController.h"

@interface StoryDetailsTableViewController (){
    FBSDKLikeControl *likeButton;
}

@end

@implementation StoryDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataManager = [DataManager sharedInstance];
    
    self.tableView.scrollEnabled = false;
    
    likeButton = [[FBSDKLikeControl alloc] init];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    likeButton.objectID = [self.selectedStory valueForKey:@"link"]; // Set up "Like" Button
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if(indexPath.row == 0){ // Story Title
        cell.textLabel.text = [self.selectedStory valueForKey:@"title"];
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightSemibold];
    }
    else if(indexPath.row == 1){ // Story Description
        if([[self.selectedStory valueForKey:@"contentSnippet"]isEqualToString:@""]){
            cell.textLabel.text = @"No Description";
            UIFontDescriptor * fontD = [cell.textLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = [UIFont fontWithDescriptor:fontD size:16.0f];
        }
        else {
            cell.textLabel.text = [self.selectedStory valueForKey:@"contentSnippet"];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.textAlignment = NSTextAlignmentJustified;
        }
    }
    else if(indexPath.row > 1){
        [cell.textLabel setFont:[UIFont systemFontOfSize:17.0f weight:UIFontWeightBold]];
        cell.textLabel.textColor = [UIColor colorWithRed:0.04 green:0.46 blue:0.87 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if(indexPath.row == 2){
            cell.textLabel.textColor = [UIColor colorWithRed:0.33 green:0.76 blue:0.46 alpha:1.0];
            [cell.textLabel setFont:[UIFont systemFontOfSize:19.0f weight:UIFontWeightBold]];
            cell.textLabel.text = @"Open with Browser";
        }
        else if(indexPath.row == 3){
            cell.textLabel.text = @"Save to Bookmarks";
                
            for(NSManagedObject *bookmark in [self.dataManager getBookmarks]){
                if([[bookmark valueForKey:@"name"]isEqualToString:[self.selectedStory valueForKey:@"title"]]){
                    [self disableCell:cell newText:@"In Bookmarks"];
                }
            }
        }
        else if(indexPath.row == 4){
            cell.textLabel.text = @"Share";
        }
        else if(indexPath.row == 5){
            cell.textLabel.text = @"Send via SMS";
        }
        else if(indexPath.row == 6){
            likeButton.center = CGPointMake(self.view.center.x, cell.contentView.center.y);
            [cell.contentView addSubview:likeButton];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 2){ // Open with Browser Button
        NSURL *url = [NSURL URLWithString:[self.selectedStory valueForKey:@"link"]];
        if (![[UIApplication sharedApplication] openURL:url]) {
            NSLog(@"%@%@",@"Failed to open url:",[url description]);
        }
    }
    else if(indexPath.row == 3){ // Add to Bookmarks Button
        if([self.dataManager saveBookmark:[self.selectedStory valueForKey:@"title"]
                                      url:[self.selectedStory valueForKey:@"link"]
                                     feed:self.currentFeed])
        {
            
            [self showMessage:@"Bookmark Added!" fromView:[tableView cellForRowAtIndexPath:indexPath]];
            
            NSArray *rowIndexArray = [[NSArray alloc]initWithObjects:indexPath, nil];
            [self.tableView reloadRowsAtIndexPaths:rowIndexArray withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    if(indexPath.row == 4){ // Share Button
        NSArray *postContent;
        NSURL *storyURL = [NSURL URLWithString:[self.selectedStory valueForKey:@"link"]];
        postContent = @[storyURL];
        UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:postContent applicationActivities:nil];
        [self presentViewController:avc animated:true completion:nil];
    }
    if(indexPath.row == 5){ // Send via SMS Button
        [self openAddressBook:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

-(void)disableCell:(UITableViewCell*)cell newText:(NSString*)string{ // Make Cell non-interactible
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = false;
    cell.textLabel.text = string;
    cell.textLabel.textColor = [UIColor lightGrayColor];
    [cell.textLabel setFont:[UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [likeButton setHidden:true]; // Hide "Like" Button before transition
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        likeButton.center = CGPointMake(self.view.center.x, likeButton.center.y); // Change "Like" Button position after transition
        [likeButton setHidden:false]; // Show Button
    }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Send via SMS

-(void)showMessage:(NSString*)message fromView:(UIView*)view{
    AXPopoverView *popoverView = [AXPopoverView new];
    popoverView.title = message;
    
    popoverView.translucent = true;
    popoverView.preferredArrowDirection = AXPopoverArrowDirectionTop;
    popoverView.translucentStyle = AXPopoverTranslucentLight;
    [popoverView showFromView:view animated:true duration:2.0];
}

-(NSString*)getNumberFromContact:(CNContact*)contact{ // Get number of selected contact
    
    NSArray <CNLabeledValue<CNPhoneNumber *> *> *phoneNumbers = contact.phoneNumbers;
    CNLabeledValue<CNPhoneNumber *> *firstPhone = [phoneNumbers firstObject];
    CNPhoneNumber *number = firstPhone.value;
    return number.stringValue;
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    
    self.number = [self getNumberFromContact:contact];
    
    NSString *storyTitle = [self.selectedStory valueForKey:@"title"];
    NSString *storyLink = [self.selectedStory valueForKey:@"link"];
    
    NSString *message = [NSString stringWithFormat:@"%@, %@", storyTitle, storyLink]; // Compose message
    
    [self performSelectorInBackground:@selector(sendSMS:) withObject:message]; // Open SMS dialogue with precomposed message after quiting contact picker
}

-(void)sendSMS:(NSString*)message{ // Open SMS dialogue
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = message;
        controller.recipients = [NSArray arrayWithObjects:self.number, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:true completion:nil];
        
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            NSLog(@"Sending failed");
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)openAddressBook:(UIViewController*)vc{ // Shows Contact list
    
    self.addressBook = [[CNContactPickerViewController alloc]init];
    self.addressBook.delegate = self;
    [vc presentViewController:self.addressBook animated:true completion:nil];
}

@end
