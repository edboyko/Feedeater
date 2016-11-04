//
//  StoryCell.m
//  Feedeater
//
//  Created by Edwin Boyko on 22/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import "StoryCell.h"

@implementation StoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureFromArray:(NSArray*)array
              atIndexPath:(NSIndexPath*)indexPath
             withFontSize:(CGFloat)fontSize
               newStories:(NSInteger)amount
{
    
    self.titleLabel.text = [[array objectAtIndex:indexPath.row]objectForKey:@"title"];
    
    [self.titleLabel setFont:[self.titleLabel.font fontWithSize:fontSize]];
    
    self.openButton.tag = indexPath.row;
    
    self.textLabel.numberOfLines = 2;
    if(!self.shown){
        if(indexPath.row < amount){
            self.titleLabel.text = [NSString stringWithFormat:@"NEW! %@", self.titleLabel.text];
            UIColor *golden = [UIColor colorWithRed:1.00 green:0.84 blue:0.00 alpha:1.0];
            self.layer.backgroundColor = golden.CGColor;
            
            [UIView animateWithDuration:0.9 animations:^{
                self.layer.backgroundColor = [UIColor clearColor].CGColor;
            } completion:nil];
        }
        self.shown = true;
    }
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
