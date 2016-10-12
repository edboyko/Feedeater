//
//  FeedCell.m
//  Feedeater
//
//  Created by Edwin Boyko on 15/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "FeedCell.h"

@implementation FeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithObjectFromArray:(NSArray*)array atIndex:(NSInteger)index {
    self.titleLabel.text = [[array objectAtIndex:index]valueForKey:@"name"];
    self.editFeedButton.tag = index; // Give Edit Button a tag
}

@end
