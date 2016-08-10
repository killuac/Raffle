//
//  UITableViewCell+Base.m
//  LuckyDraw
//
//  Created by Killua Liu on 1/22/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "UITableViewCell+Base.h"

@implementation UITableViewCell (Base)

+ (void)load
{
    KLSwizzleMethod([self class], @selector(initWithStyle:reuseIdentifier:), @selector(swizzle_initWithStyle:reuseIdentifier:), NO);
}

- (instancetype)swizzle_initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCell *cell = [self swizzle_initWithStyle:style reuseIdentifier:reuseIdentifier];
    cell.textLabel.font = [UIFont titleFont];
    cell.textLabel.textColor = [UIColor titleColor];
    cell.textLabel.backgroundColor = cell.backgroundColor;
    cell.textLabel.clipsToBounds = YES;
    
    cell.detailTextLabel.font = [UIFont titleFont];
    cell.detailTextLabel.textColor = [UIColor subtitleColor];
    cell.detailTextLabel.backgroundColor = cell.backgroundColor;
    cell.detailTextLabel.clipsToBounds = YES;
    
    return cell;
}

- (void)didMoveToSuperview
{
    [self.contentView layoutIfNeeded];  // For round corner image
}

@end
