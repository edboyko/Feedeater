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
    cell.textLabel.text = [[self.resultsArray objectAtIndex:indexPath.row]objectForKey:@"url"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selectedFeedURL = [[[tableView cellForRowAtIndexPath:indexPath]textLabel]text];
    [self addAlert:selectedFeedURL];
}

#pragma mark - Adding Feed

-(void)addAlert{
    [self addAlert:@""];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(![textField.text isEqualToString:@""]){
        [self setUpProgressHUD];
        [self.tableView addSubview:self.hud]; // Add "Loading" indicator
        NSString *space = @"%20";
        NSString *urlString = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/feed/find?v=1.0&q=rss%@feed%@%@",space,space,self.searchField.text];
        searchURL = [NSURL URLWithString:urlString];
        [self getDataFromURL:searchURL];
        return true;
    }
    else {
        return false;
    }
}


- (BOOL)validateUrl:(NSString *)candidate { // Checks if URL is correct
    NSString *urlRegEx = @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&amp;=]*)?";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (void)addAlert:(NSString* )urlText { // Shows "Add Feed" alert view
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
    urlField.text = urlText;
    
    UIAlertAction *addFeed = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if(![nameField.text isEqualToString:@""] && ![urlField.text isEqualToString:@""]){
            if([self validateUrl:urlField.text]){ // If all fields were filled correctly, add new feed
                
                if([self.dataManager saveFeed:nameField.text url:urlField.text]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:true];
                    });
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

#pragma mark - Finding Feeds

- (void)setUpProgressHUD {
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:true];
    self.hud.label.text = @"Loading";
    self.hud.removeFromSuperViewOnHide = true;
    self.hud.center = CGPointMake(self.view.center.x, 200);
}

-(UIAlertController*)errorAlert{
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error with Loading" message:@"There was a problem with loading data." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self.navigationController popToRootViewControllerAnimated:true];
    }];
    [errorAlert addAction:okay];
    return errorAlert;
}

-(void)getDataFromURL:(NSURL*)url{
    [[session dataTaskWithURL:url
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hideAnimated:true];
                [self.navigationController presentViewController:[self errorAlert] animated:YES completion:nil];
            });
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
                
                self.resultsArray = [[jsonDict objectForKey:@"responseData"]objectForKey:@"entries"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hud hideAnimated:true];
                    [self.tableView reloadData];
                });
            }
        }
    }]resume];
    
}

@end
