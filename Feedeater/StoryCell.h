//
//  StoryCell.h
//  Feedeater
//
//  Created by Edwin Boyko on 22/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *openButton;
@property (assign, nonatomic) BOOL shown;

-(void)configureFromArray:(NSArray*)array
              atIndexPath:(NSIndexPath*)indexPath
             withFontSize:(CGFloat)fontSize
               newStories:(NSInteger)amount;
@end
