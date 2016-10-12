//
//  StoryDetailsTableViewController.h
//  Feedeater
//
//  Created by Edwin Boyko on 02/09/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <AXPopoverView.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <MessageUI/MessageUI.h>
#import "DataManager.h"

@interface StoryDetailsTableViewController : UITableViewController <CNContactViewControllerDelegate, CNContactPickerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>
@property(strong, nonatomic) CNContactPickerViewController *addressBook;
@property(strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSObject *selectedStory;

@property (strong, nonatomic) DataManager *dataManager;

@property (strong, nonatomic) NSManagedObject *currentFeed;
@end
