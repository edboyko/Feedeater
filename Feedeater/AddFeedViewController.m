//
//  AddFeedViewController.m
//  Feedeater
//
//  Created by Edwin Boyko on 12/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "AddFeedViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DataManager.h"

@interface AddFeedViewController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
    
    NSURL *searchURL;
    NSURLSession *session;
}

@property (strong, nonatomic) DataManager *dataManager;

@property (strong, nonatomic) NSArray *resultsArray;

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation AddFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [self.addManuallyButton addTarget:self action:@selector(addAlert) forControlEvents:UIControlEventTouchUpInside];
    self.dataManager = [DataManager sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.resultsArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"Result Cell";
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    cell.textLabel.text = (self.resultsArray)[indexPath.row][@"url"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selectedFeedURL = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [self presentViewController:[self addAlertWithName:@"" andURL:selectedFeedURL] animated:YES completion:nil];
}

#pragma mark - Adding Feed

-(void)addAlert{
    [self.navigationController presentViewController:[self addAlertWithName:@"" andURL:@""] animated:YES completion:nil];
}

-(NSString*) removeSpacesFromSearchString:(NSString*)string{
    NSString *newString = string;
    if([newString containsString:@" "]){
        newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return newString;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(![textField.text isEqualToString:@""]){
        
        [self setUpProgressHUD];
        [self.tableView addSubview:self.hud]; // Add "Loading" indicator
        NSString *result = self.searchField.text;
        result = [self removeSpacesFromSearchString:result];
        NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/feed/find?v=1.0&q=%@",result];
        searchURL = [NSURL URLWithString:urlString];
        [self getDataFromURL:searchURL];
        [textField resignFirstResponder];
    }
    return NO;
}


- (BOOL)validateUrl:(NSString *)candidate { // Checks if URL is correct
    NSString *urlRegEx = @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&amp;=]*)?";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (UIAlertController*)errorAlertWithTitle:(NSString*)title
                               andMessage:(NSString*)message
                                     name:(NSString*)name
                                      url:(NSString*)url {
    UIAlertController *newFeedAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
        UIAlertController *addFeedAlert = [self addAlertWithName:name andURL:url];
        [self.navigationController presentViewController:addFeedAlert animated:YES completion:nil];
    }];
    [newFeedAlert addAction:okay];
    return newFeedAlert;
}

- (UIAlertController*)addAlertWithName:(NSString*)name andURL:(NSString*)urlText { // Shows "Add Feed" alert view
    NSString *alertMessage = @"Please fill all fields.\nPlease provide correct URL address.";
    UIAlertController *newFeedAlert = [UIAlertController alertControllerWithTitle:@"Add New Feed" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    // Add textfields for Name and URL address
    [newFeedAlert addTextFieldWithConfigurationHandler:nil];
    [newFeedAlert addTextFieldWithConfigurationHandler:nil];
    // Save textfields to variables
    UITextField *nameField = newFeedAlert.textFields.firstObject;
    UITextField *urlField = newFeedAlert.textFields.lastObject;
    
    nameField.placeholder = @"Name";
    urlField.placeholder = @"URL";
    nameField.text = name;
    urlField.text = urlText;
    
    UIAlertAction *addFeed = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if(![nameField.text isEqualToString:@""] && ![urlField.text isEqualToString:@""]){
            if([self validateUrl:urlField.text]){ // If all fields were filled correctly, add new feed
                
                [self.dataManager saveFeed:nameField.text url:urlField.text];
                [self.navigationController popToRootViewControllerAnimated:true];
            }
            else { // Inform user that they failed to provide correct URL
                [self.navigationController presentViewController:[self errorAlertWithTitle:@"Wrong URL"
                                                           andMessage:@"Please provide correct url address."
                                                                 name:newFeedAlert.textFields.firstObject.text
                                                                  url:newFeedAlert.textFields.lastObject.text] animated:YES completion:nil];
            }
        }
        else { // Inform user that they failed to fill all fields
            [self.navigationController presentViewController:[self errorAlertWithTitle:@"Please Fill All Fields"
                                                       andMessage:nil
                                                             name:newFeedAlert.textFields.firstObject.text
                                                              url:newFeedAlert.textFields.lastObject.text] animated:YES completion:nil];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [newFeedAlert addAction:addFeed];
    [newFeedAlert addAction:cancel];
    
    return newFeedAlert;
}

#pragma mark - Finding Feeds

- (void)setUpProgressHUD {
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:true];
    self.hud.label.text = @"Loading";
    self.hud.removeFromSuperViewOnHide = true;
    self.hud.center = CGPointMake(self.view.center.x, 200);
}

-(UIAlertController*)errorAlertWithMessage:(NSString*)message{
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleCancel handler:nil];
    [errorAlert addAction:okay];
    return errorAlert;
}

-(void)getDataFromURL:(NSURL*)url{
    [[session dataTaskWithURL:url
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:YES];
                NSString *alertMessage = @"There was a problem with loading data.";
                [self.navigationController presentViewController:[self errorAlertWithMessage:alertMessage]
                                                        animated:YES
                                                      completion:nil];
            });
        }
        else {
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSDictionary *jsonDict;
            if(data){
                jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            }
            else {
                NSLog(@"No Data!");
                [self.navigationController popToRootViewControllerAnimated:YES];
                return;
            }
            if([jsonDict[@"responseStatus"]integerValue] == 400){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hud hideAnimated:true];
                });
            }
            else {
                
                self.resultsArray = jsonDict[@"responseData"][@"entries"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hud hideAnimated:true];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
                });
            }
        }
    }]resume];
    
}

@end
