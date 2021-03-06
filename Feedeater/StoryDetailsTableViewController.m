//
//  StoryDetailsTableViewController.m
//  Feedeater
//
//  Created by Edwin Boyko on 02/09/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "StoryDetailsTableViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <AXPopoverView.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <MessageUI/MessageUI.h>

@interface StoryDetailsTableViewController ()<CNContactViewControllerDelegate, CNContactPickerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate> {
    FBSDKLikeControl *likeButton;
}

@property (strong, nonatomic) CNContactPickerViewController *addressBook;
@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) DataManager *dataManager;
@property (strong, nonatomic) AXPopoverView *popover;

@end

@implementation StoryDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataManager = [DataManager sharedInstance];
    
    likeButton = [[FBSDKLikeControl alloc] init];
    
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
    [super viewWillAppear:YES];
    likeButton.objectID = (self.selectedStory)[@"link"]; // Set up "Like" Button
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.popover removeFromSuperview];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 2;
    }
    else if(section == 1){
        return 4;
    }
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if(indexPath.section == 0){
        
        cell.textLabel.textColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1.0];
        
        if(indexPath.row == 0){ // Story Title
            cell.textLabel.text = (self.selectedStory)[@"title"];
            cell.textLabel.numberOfLines = 3;
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightSemibold];
        }
        else if(indexPath.row == 1){ // Story Description
            if([(self.selectedStory)[@"contentSnippet"]isEqualToString:@""]){
                cell.textLabel.text = @"No Description";
                UIFontDescriptor * fontD = [cell.textLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.textLabel.font = [UIFont fontWithDescriptor:fontD size:16.0f];
            }
            else {
                cell.textLabel.text = (self.selectedStory)[@"contentSnippet"];
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.textAlignment = NSTextAlignmentJustified;
            }
        }
    }
    else if(indexPath.section == 1){
        
        (cell.textLabel).font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightBold];
        cell.textLabel.textColor = [UIColor colorWithRed:0.98 green:0.37 blue:0.38 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if(indexPath.row == 0){
            cell.textLabel.textColor = [UIColor colorWithRed:0.33 green:0.76 blue:0.46 alpha:1.0];
            (cell.textLabel).font = [UIFont systemFontOfSize:19.0f weight:UIFontWeightBold];
            cell.textLabel.text = @"Open with Browser";
        }
        else if(indexPath.row == 1){
            cell.textLabel.text = @"Save to Bookmarks";
            
            for(NSManagedObject *bookmark in [self.dataManager getBookmarks]){
                if([[bookmark valueForKey:@"name"]isEqualToString:(self.selectedStory)[@"title"]]){
                    [self disableCell:cell newText:@"In Bookmarks"];
                }
            }
        }
        else if(indexPath.row == 2){
            cell.textLabel.text = @"Share";
        }
        else if(indexPath.row == 3){
            cell.textLabel.text = @"Send via SMS";
        }
    }
    else if(indexPath.section == 2){
        
        likeButton.center = CGPointMake(self.view.center.x, cell.contentView.center.y);
        [cell.contentView addSubview:likeButton];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        if(indexPath.row == 0){ // Open with Browser
            NSURL *url = [NSURL URLWithString:(self.selectedStory)[@"link"]];
            if (![[UIApplication sharedApplication] openURL:url]) {
                NSLog(@"%@%@",@"Failed to open url:",url.description);
            }
        }
        else if(indexPath.row == 1){ // Add to Bookmarks
            [self.dataManager saveBookmark:(self.selectedStory)[@"title"]
                                       url:(self.selectedStory)[@"link"]
                                      feed:self.currentFeed];
            [self showMessage:@"Bookmark Added!" fromView:[tableView cellForRowAtIndexPath:indexPath]];
            
            NSArray *rowIndexArray = @[indexPath];
            [self.tableView reloadRowsAtIndexPaths:rowIndexArray withRowAnimation:UITableViewRowAnimationFade];
        }
        if(indexPath.row == 2){ // Share on Social Media
            NSArray *postContent;
            NSURL *storyURL = [NSURL URLWithString:(self.selectedStory)[@"link"]];
            postContent = @[storyURL];
            UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:postContent applicationActivities:nil];
            [self presentViewController:avc animated:true completion:nil];
        }
        if(indexPath.row == 3){ // Send via SMS
            [self openAddressBook:self];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    }
}

-(void)disableCell:(UITableViewCell*)cell newText:(NSString*)string{ // Make Cell non-interactible
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = false;
    cell.textLabel.text = string;
    cell.textLabel.textColor = [UIColor lightGrayColor];
    (cell.textLabel).font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [likeButton setHidden:YES]; // Hide "Like" Button before transition
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        likeButton.center = CGPointMake(self.view.center.x, likeButton.center.y); // Change "Like" Button position after transition
        [likeButton setHidden:NO]; // Show Button
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
    self.popover = [AXPopoverView new];
    self.popover.title = message;
    
    self.popover.translucent = true;
    self.popover.preferredArrowDirection = AXPopoverArrowDirectionTop;
    self.popover.translucentStyle = AXPopoverTranslucentLight;
    [self.popover showFromView:view animated:true duration:2.0];
}

-(NSString*)getNumberFromContact:(CNContact*)contact{ // Get number of selected contact
    
    NSArray <CNLabeledValue<CNPhoneNumber *> *> *phoneNumbers = contact.phoneNumbers;
    CNLabeledValue<CNPhoneNumber *> *firstPhone = phoneNumbers.firstObject;
    CNPhoneNumber *number = firstPhone.value;
    return number.stringValue;
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    
    self.number = [self getNumberFromContact:contact];
    
    NSString *storyTitle = (self.selectedStory)[@"title"];
    NSString *storyLink = (self.selectedStory)[@"link"];
    
    NSString *message = [NSString stringWithFormat:@"%@, %@", storyTitle, storyLink]; // Compose message
    
    [self performSelectorInBackground:@selector(sendSMS:) withObject:message]; // Open SMS dialogue with precomposed message after quiting contact picker
}

-(void)sendSMS:(NSString*)message{ // Open SMS dialogue
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = message;
        controller.recipients = @[self.number];
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
