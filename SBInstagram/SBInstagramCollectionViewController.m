//
//  SBInstagramCollectionViewController.m
//  instagram
//
//  Created by Santiago Bustamante on 8/31/13.
//  Copyright (c) 2013 Pineapple Inc. All rights reserved.
//

#import "SBInstagramCollectionViewController.h"
#import "SBInstagramController.h"
#import "SBInstagramMediaEntity.h"

@interface SBInstagramCollectionViewController()

@property (nonatomic, strong) NSMutableArray *mediaArray;
@property (nonatomic, strong) SBInstagramController *instagramController;
@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, assign) BOOL hideFooter;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation SBInstagramCollectionViewController

- (id) initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    if ((self = [super initWithCollectionViewLayout:layout])) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicator startAnimating];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = @"Instagram";
    self.downloading = YES;
    self.mediaArray = [NSMutableArray arrayWithCapacity:0];
    [self.collectionView registerClass:[SBInstagramCell class] forCellWithReuseIdentifier:@"SBInstagramCell"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    

    
    
    
    self.instagramController = [SBInstagramController instagramControllerWithMainViewController:self];
    [self downloadNext];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void) downloadNext{
    self.downloading = YES;
    if ([self.mediaArray count] == 0) {
        [self.instagramController mediaUserWithUserId:INSTAGRAM_USER_ID andBlock:^(NSArray *mediaArray, NSError *error) {
            [self.mediaArray addObjectsFromArray:mediaArray];
            [self.collectionView reloadData];
            self.downloading = NO;
        }];
    }else{
        [self.instagramController mediaUserWithPagingWntity:[self.mediaArray objectAtIndex:(self.mediaArray.count-1)] andBlock:^(NSArray *mediaArray, NSError *error) {
            
            NSUInteger a = [self.mediaArray count];
            [self.mediaArray addObjectsFromArray:mediaArray];
            
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
            [mediaArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSUInteger b = a+idx;
                NSIndexPath *path = [NSIndexPath indexPathForItem:b inSection:0];
                [arr addObject:path];
            }];
            
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:arr];
            } completion:nil];
            
            self.downloading = NO;
            
            if (mediaArray.count == 0) {
                [self.activityIndicator stopAnimating];
                self.activityIndicator.hidden = YES;
                self.hideFooter = YES;
                [self.collectionView reloadData];
            }
            
        }];
    }    
    
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.mediaArray count];
}



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SBInstagramCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SBInstagramCell" forIndexPath:indexPath];

    if ([self.mediaArray count]>0) {
        SBInstagramMediaPagingEntity *entity = [self.mediaArray objectAtIndex:indexPath.row];
        cell.indexPath = indexPath;
        [cell setEntity:entity andIndexPath:indexPath];
    }

    if (indexPath.row == [self.mediaArray count]-1 && !self.downloading) {
        [self downloadNext];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (self.hideFooter) {
        return CGSizeZero;
    }
    return CGSizeMake(CGRectGetWidth(self.view.frame),40);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind != UICollectionElementKindSectionFooter || self.hideFooter){
        return nil;
    }
    
    UICollectionReusableView *foot = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
    
    CGPoint center = self.activityIndicator.center;
    center.x = foot.center.x;
    center.y = 20;
    self.activityIndicator.center = center;
    
    [foot addSubview:self.activityIndicator];
    
    return foot;
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (SB_IS_IPAD) {
        return CGSizeMake(200, 200);
    }
    return CGSizeMake(100, 100);

}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10* (SB_IS_IPAD?2:1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10 * (SB_IS_IPAD?2:1);
}


@end