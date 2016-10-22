//
//  AddFeedViewController.h
//  Feedeater
//
//  Created by Edwin Boyko on 12/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFeedViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *addManuallyButton;

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
