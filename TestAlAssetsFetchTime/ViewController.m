//
//  ViewController.m
//  TestAlAssetsFetchTime
//
//  Created by Avner Barr on 11/20/13.
//  Copyright (c) 2013 Avner Barr. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CollectionViewCell.h"

typedef void(^timedBlock)();

double timeIt(timedBlock block)
{
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    block();
    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - start;
    return duration;
}

static NSString* cellReuseIdentifier = @"cell";
@interface ViewController () <UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collectionview;
@property (nonatomic,strong) ALAssetsLibrary *library;
@property (nonatomic,strong) NSMutableArray *assets;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    self.collectionview = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    
    [self.collectionview registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifier];

    
    [self.view addSubview:self.collectionview];
    
    [flowLayout setItemSize:self.collectionview.frame.size];
    
    [self loadAssets:^{
        self.collectionview.dataSource = self;
        [self.assets sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ALAsset *a1 = (ALAsset *)obj1;
            ALAsset *a2 = (ALAsset *)obj2;
            ALAssetRepresentation *r1 = [a1 defaultRepresentation];
            ALAssetRepresentation *r2 = [a2 defaultRepresentation];
            CGSize s1 =            [r1 dimensions];
            CGSize s2 = [r2 dimensions];
            CGFloat d1 = s1.width * s1.height;
            CGFloat d2 = s2.width * s2.height;
            return d1 < d2;
        }];
        [self.collectionview reloadData];
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Private

-(void)loadAssets:(void(^)())block
{
    self.assets = [NSMutableArray new];
    self.library = [[ALAssetsLibrary alloc] init];
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil)
        {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result)
                {

                    [self.assets addObject:result];
                }
            }];
        }
        if (group == nil)
        {
            block();
        }
    } failureBlock:nil];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __block CollectionViewCell *cell;
    double duration = timeIt(^{
    cell = (CollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    });
    
    NSString *str = [NSString stringWithFormat:@"dequeue time = %f",duration];

    __block ALAsset *asset;


        asset = [self.assets objectAtIndex:indexPath.row];

    
    __block    ALAssetRepresentation *representation;
    duration = timeIt(^{
        representation = [asset defaultRepresentation];
    });
    
    str = [NSString stringWithFormat:@"%@\nDefault representation fetch time = %f",str,duration];

    __block CGImageRef imageRef;
    
    duration = timeIt(^{
        imageRef = [representation fullResolutionImage];
    });
    
    str = [NSString stringWithFormat:@"%@\nFetch full resolution image time = %f",str,duration];
    
    
    
    __block UIImage *image;
    
    duration = timeIt(^{
        image = [UIImage imageWithCGImage:imageRef scale:representation.scale orientation:(UIImageOrientation)representation.orientation];
    });
    
    str = [NSString stringWithFormat:@"%@\nCreate UIImage time = %f",str,duration];
    
    str = [NSString stringWithFormat:@"%@\nImage Size is %@",str,NSStringFromCGSize(image.size)];
    str = [NSString stringWithFormat:@"%@\nArea is %f.0 px",str,image.size.width * image.size.height];
    cell.imageView.image = image;
    cell.label.text = str;
    return cell;
}

@end
