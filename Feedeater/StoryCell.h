//
//  StoryCell.h
//  Feedeater
//
//  Created by Edwin Boyko on 22/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *openButton;
@property BOOL shown;

@end
