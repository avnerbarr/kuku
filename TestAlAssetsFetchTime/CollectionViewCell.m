//
//  CollectionViewCell.m
//  TestAlAssetsFetchTime
//
//  Created by Avner Barr on 11/20/13.
//  Copyright (c) 2013 Avner Barr. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.contentView.frame.size.width, 200)];
        self.label.numberOfLines = 0;
        self.label.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.contentView addSubview:self.label];
    }
    return self;
}

-(void)prepareForReuse
{
    self.imageView.image = nil;
}

@end
