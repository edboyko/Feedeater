//
//  FeedCell.h
//  Feedeater
//
//  Created by Edwin Boyko on 15/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *editFeedButton;


-(void)configureWithObjectFromArray:(NSArray*)array atIndex:(NSInteger)index;
@end
