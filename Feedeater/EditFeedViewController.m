//
//  EditFeedViewController.m
//  Feedeater
//
//  Created by Edwin Boyko on 15/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "EditFeedViewController.h"

@interface EditFeedViewController ()

@property (strong, nonatomic) NSString *feedName;
@property (strong, nonatomic) NSString *feedURL;
@property (strong, nonatomic) DataManager *dataManager;
@end

@implementation EditFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataManager = [DataManager sharedInstance];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    
    self.title = [NSString stringWithFormat:@"Edit %@", [self.selectedFeed valueForKey:@"name"]];
    
    // Fill text fields
    self.nameField.text = [self.selectedFeed valueForKey:@"name"];
    self.urlField.text = [self.selectedFeed valueForKey:@"url"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL) validateUrl: (NSString *) candidate { // Checks if URL is correct
    NSString *urlRegEx =
    @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&amp;=]*)?";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

-(BOOL)fieldsNotEmpty{
    return (![self.nameField.text isEqualToString:@""] && ![self.urlField.text isEqualToString:@""]);
}

- (IBAction)confirmChanges:(UIButton *)sender {
    
    if([self fieldsNotEmpty]) {
        if([self validateUrl:self.urlField.text]){
            // If everything correct - edit Feed
            [self.dataManager editFeed:self.selectedFeed
                                  name:self.nameField.text
                                andURL:self.urlField.text];
            
            [self.navigationController popToRootViewControllerAnimated:true];
        }
        else { // Tell user that URL they provided is not correct
            UIAlertController *urlAlert = [UIAlertController alertControllerWithTitle:@"Wrong URL" message:@"Please provide correct URL address." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [urlAlert addAction:okay];
            [self.navigationController presentViewController:urlAlert animated:YES completion:nil];
        }
    }
    else { // Let user know that they have to fill all fields
        UIAlertController *urlAlert = [UIAlertController alertControllerWithTitle:@"Please Fill All Fields" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [urlAlert addAction:okay];
        [self.navigationController presentViewController:urlAlert animated:YES completion:nil];
    }
}
-(UIAlertController*)deleteFeedAlert{
    UIAlertController *deleteFeedAlert = [UIAlertController alertControllerWithTitle:@"Delete" message:@"Are you sure you want to delete this feed?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.dataManager deleteObject:self.selectedFeed];
        [self.navigationController popToRootViewControllerAnimated:true];
        
    }];
    UIAlertAction *backAction = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:nil];
    [deleteFeedAlert addAction:backAction];
    [deleteFeedAlert addAction:deleteAction];
    
    return deleteFeedAlert;
}

- (IBAction)deleteFeed:(UIButton *)sender {
    
    [self.navigationController presentViewController:[self deleteFeedAlert] animated:YES completion:nil];
}
@end
