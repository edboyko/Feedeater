//
//  AboutViewController.m
//  Feedeater
//
//  Created by Edwin Boyko on 06/09/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 2;
    }
    else if(section == 1){
        return 8;
    }
    else if(section == 2){
        return 1;
    }
    else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Title"forIndexPath:indexPath];
    if(indexPath.section == 0){
        
        if(indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"Title" forIndexPath:indexPath];
            cell.textLabel.text = @"Feedeater";
        }
        else if(indexPath.row == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:@"Description" forIndexPath:indexPath];
            cell.textLabel.text = @"Feedeater allows you to track feeds from your favourite web sites and makes it easier to follow the news and not miss out anything interesting.\nJust find a proper RSS URL and add new feed using it. It is simple!";
        }
    }
    else if(indexPath.section == 1){
        
        if(indexPath.row == 0 || indexPath.row == 5){
            cell = [tableView dequeueReusableCellWithIdentifier:@"Title" forIndexPath:indexPath];
            if(indexPath.row == 0){
                cell.textLabel.text = @"What you can do?";
            }
            else if(indexPath.row == 5){
                cell.textLabel.text = @"How can you help?";
            }
        }
        else if(indexPath.row > 0 && indexPath.row != 5){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Faq Item"];
            if(indexPath.row == 1){
                cell.textLabel.text = @"- Add your feeds.";
            }
            if(indexPath.row == 2){
                cell.textLabel.text = @"- Create bookmarks.";
            }
            if(indexPath.row == 3){
                cell.textLabel.text = @"- Share stories on social media.";
            }
            if(indexPath.row == 4){
                cell.textLabel.text = @"- Send stories to your friends via SMS.";
            }
            else if(indexPath.row == 6){
                cell.textLabel.text = @"- Report a bug.";
            }
            else if(indexPath.row == 7){
                cell.textLabel.text = @"- Become a tester.";
            }
        }
    }
    else if(indexPath.section == 2){
        if(indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"Copyright"];
            cell.textLabel.text = @"Author: Edvin Boiko © 2016";
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"Description";
    }
    else if(section == 1){
        return @"FAQ";
    }
    else if(section == 2){
        return @"Copyright";
    }
    else {
        return @"";
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
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

@end
