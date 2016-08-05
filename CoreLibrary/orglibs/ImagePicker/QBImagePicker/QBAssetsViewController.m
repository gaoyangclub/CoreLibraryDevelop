//
//  QBAssetsViewController.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBAssetsViewController.h"
#import <Photos/Photos.h>

// Views
#import "QBImagePickerController.h"
#import "QBAssetCell.h"
#import "QBVideoIndicatorView.h"

static CGSize CGSizeScale(CGSize size, CGFloat scale) {
    return CGSizeMake(size.width * scale, size.height * scale);
}

@interface QBImagePickerController (Private)

@property (nonatomic, strong) NSBundle *assetBundle;

@end

@implementation NSIndexSet (Convenience)

- (NSArray *)qb_indexPathsFromIndexesWithSection:(NSUInteger)section
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}

@end

@implementation UICollectionView (Convenience)

- (NSArray *)qb_indexPathsForElementsInRect:(CGRect)rect
{
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

@end

@interface QBAssetsViewController () <PHPhotoLibraryChangeObserver, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

//@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) NSObject *fetchResult;

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) CGRect previousPreheatRect;

@property (nonatomic, assign) BOOL disableScrollToBottom;
@property (nonatomic, strong) NSIndexPath *lastSelectedItemIndexPath;

@end

@implementation QBAssetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpToolbarItems];
    [self resetCachedAssets];
    
    // Register observer
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure navigation item
//    self.navigationItem.title = self.assetCollection.localizedTitle;
    if ([self.data isKindOfClass:[PHAssetCollection class]]) {
        // Thumbnail
        PHAssetCollection* assetCollection = (PHAssetCollection*)self.data;
        if (assetCollection.localizedTitle != nil) {
            self.navigationItem.title = assetCollection.localizedTitle;
        }else{
            NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
            //指定输出的格式   这里格式必须是和上面定义字符串的格式相同，否则输出空
            [formatter setDateFormat:@"yyyy-MM-dd"];
            self.navigationItem.title = [formatter stringFromDate:assetCollection.startDate];
        }
    }else if([self.data isKindOfClass:[NSMutableArray class]]){
        self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"albums.cell.all", @"QBImagePicker", self.imagePickerController.assetBundle, nil);
    }
    
    self.navigationItem.prompt = self.imagePickerController.prompt;
    
    // Configure collection view
    self.collectionView.allowsMultipleSelection = self.imagePickerController.allowsMultipleSelection;
    
    // Show/hide 'Done' button
    if (self.imagePickerController.allowsMultipleSelection) {
        [self.navigationItem setRightBarButtonItem:self.doneButton animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
    
    [self updateDoneButtonState];
    [self updateSelectionInfo];
    [self.collectionView reloadData];
    
    // Scroll to bottom
    if (self.isMovingToParentViewController && !self.disableScrollToBottom) {
        PHFetchResult* result;
        NSIndexPath *indexPath;
        if ([self.fetchResult isKindOfClass:[PHFetchResult class]]) {
            result = (PHFetchResult*)self.fetchResult;
            if (result.count <= 0) {
                return;
            }
            indexPath = [NSIndexPath indexPathForItem:(result.count - 1) inSection:0];
        }else if([self.fetchResult isKindOfClass:[NSMutableArray class]]){
            NSMutableArray* fetchArr = (NSMutableArray*)self.fetchResult;
            if (fetchArr.count <= 0) {
                return;
            }
            NSInteger lastSection = fetchArr.count - 1;//最后一节
            result = fetchArr[lastSection];//最后一节的数据
            indexPath = [NSIndexPath indexPathForItem:(result.count - 1) inSection:lastSection];
        }
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.disableScrollToBottom = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.disableScrollToBottom = NO;
    
    [self updateCachedAssets];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Save indexPath for the last item
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    
    // Update layout
    [self.collectionViewLayout invalidateLayout];
    
    // Restore scroll position
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }];
}

- (void)dealloc
{
    // Deregister observer
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}


#pragma mark - Accessors

- (void)setData:(NSObject *)data{
    _data = data;
    
    [self updateFetchRequest];
    [self.collectionView reloadData];
}

//- (void)setAssetCollection:(PHAssetCollection *)assetCollection
//{
//    _assetCollection = assetCollection;
//    
//    [self updateFetchRequest];
//    [self.collectionView reloadData];
//}

-(PHFetchResult*)getFetchResultByIndexPath:(NSIndexPath *)indexPath{
    PHFetchResult* result;
    if ([self.fetchResult isKindOfClass:[PHFetchResult class]]) {
        result = (PHFetchResult*)self.fetchResult;
    }else if([self.fetchResult isKindOfClass:[NSMutableArray class]]){
        NSMutableArray* fetchArr = (NSMutableArray*)self.fetchResult;
        result = fetchArr[indexPath.section];
    }
    return result;
}

- (PHCachingImageManager *)imageManager
{
    if (_imageManager == nil) {
        _imageManager = [PHCachingImageManager new];
    }
    
    return _imageManager;
}

- (BOOL)isAutoDeselectEnabled
{
    return (self.imagePickerController.maximumNumberOfSelection == 1
            && self.imagePickerController.maximumNumberOfSelection >= self.imagePickerController.minimumNumberOfSelection);
}


#pragma mark - Actions

- (IBAction)done:(id)sender
{
    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didFinishPickingAssets:)]) {
        [self.imagePickerController.delegate qb_imagePickerController:self.imagePickerController
                                               didFinishPickingAssets:self.imagePickerController.selectedAssets.array];
    }
}


#pragma mark - Toolbar

- (void)setUpToolbarItems
{
    // Space
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    // Info label
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    UIBarButtonItem *infoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    infoButtonItem.enabled = NO;
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    
    self.toolbarItems = @[leftSpace, infoButtonItem, rightSpace];
}

- (void)updateSelectionInfo
{
    NSMutableOrderedSet *selectedAssets = self.imagePickerController.selectedAssets;
    
    if (selectedAssets.count > 0) {
        NSBundle *bundle = self.imagePickerController.assetBundle;
        NSString *format;
        if (selectedAssets.count > 1) {
            format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.items-selected", @"QBImagePicker", bundle, nil);
        } else {
            format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.item-selected", @"QBImagePicker", bundle, nil);
        }
        
        NSString *title = [NSString stringWithFormat:format, selectedAssets.count];
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:title];
    } else {
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:@""];
    }
}


#pragma mark - Fetching Assets

- (void)updateFetchRequest
{
    if (self.data) {
        PHFetchOptions *options = [PHFetchOptions new];
        
        switch (self.imagePickerController.mediaType) {
            case QBImagePickerMediaTypeImage:
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                break;
                
            case QBImagePickerMediaTypeVideo:
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
                break;
                
            default:
                break;
        }
        
        NSInteger lastSection = 0;
        NSInteger assetIndex = 0;
        PHAsset *asset = [self.imagePickerController.selectedAssets firstObject];
        if ([self.data isKindOfClass:[PHAssetCollection class]]) {
            // Thumbnail
            PHAssetCollection* assetCollection = (PHAssetCollection*)self.data;
            PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            assetIndex = [result indexOfObject:asset];
            self.fetchResult = result;
        }else if([self.data isKindOfClass:[NSMutableArray class]]){
            NSMutableArray* fetchArr = [NSMutableArray array];
            NSMutableArray* arr = (NSMutableArray*)self.data;
            for (PHAssetCollection* assetCollection in arr) {
                [fetchArr addObject:[PHAsset fetchAssetsInAssetCollection:assetCollection options:options]];
            }
            lastSection = arr.count - 1;
            PHFetchResult * result = fetchArr[lastSection];
            assetIndex = [result indexOfObject:asset];
            self.fetchResult = fetchArr;
        }
        if ([self isAutoDeselectEnabled] && self.imagePickerController.selectedAssets.count > 0) {
            // Get index of previous selected asset
//            NSInteger assetIndex = [self.fetchResult indexOfObject:asset];
            self.lastSelectedItemIndexPath = [NSIndexPath indexPathForItem:assetIndex inSection:lastSection];
        }
    } else {
        self.fetchResult = nil;
    }
}


#pragma mark - Checking for Selection Limit

- (BOOL)isMinimumSelectionLimitFulfilled
{
   return (self.imagePickerController.minimumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
}

- (BOOL)isMaximumSelectionLimitReached
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.imagePickerController.minimumNumberOfSelection);
   
    if (minimumNumberOfSelection <= self.imagePickerController.maximumNumberOfSelection) {
        return (self.imagePickerController.maximumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
    }
   
    return NO;
}

- (void)updateDoneButtonState
{
    self.doneButton.enabled = [self isMinimumSelectionLimitFulfilled];
}


#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && self.view.window != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0) {
        // Compute the assets to start caching and to stop caching
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView qb_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        } removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView qb_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        CGSize itemSize = [(UICollectionViewFlowLayout *)self.collectionViewLayout itemSize];
        CGSize targetSize = CGSizeScale(itemSize, [[UIScreen mainScreen] scale]);
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:targetSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:targetSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect addedHandler:(void (^)(CGRect addedRect))addedHandler removedHandler:(void (^)(CGRect removedRect))removedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHFetchResult* result;
        if ([self.fetchResult isKindOfClass:[PHFetchResult class]]) {
            result = (PHFetchResult*)self.fetchResult;
        }else if([self.fetchResult isKindOfClass:[NSMutableArray class]]){
            NSMutableArray* fetchArr = (NSMutableArray*)self.fetchResult;
            result = fetchArr[indexPath.section];
        }
        if (indexPath.item < result.count) {
            PHAsset *asset = result[indexPath.item];
            [assets addObject:asset];
        }
    }
    return assets;
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.fetchResult isKindOfClass:[PHFetchResult class]]) {
            PHFetchResult* result = (PHFetchResult*)self.fetchResult;
            PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:result];
            if (collectionChanges) {
                // Get the new fetch result
                result = [collectionChanges fetchResultAfterChanges];
                self.fetchResult = result;
                
                if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                    // We need to reload all if the incremental diffs are not available
                    [self.collectionView reloadData];
                } else {
                    // If we have incremental diffs, tell the collection view to animate insertions and deletions
                    [self.collectionView performBatchUpdates:^{
                        NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                        if ([removedIndexes count]) {
                            [self.collectionView deleteItemsAtIndexPaths:[removedIndexes qb_indexPathsFromIndexesWithSection:0]];
                        }
                        
                        NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                        if ([insertedIndexes count]) {
                            [self.collectionView insertItemsAtIndexPaths:[insertedIndexes qb_indexPathsFromIndexesWithSection:0]];
                        }
                        
                        NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                        if ([changedIndexes count]) {
                            [self.collectionView reloadItemsAtIndexPaths:[changedIndexes qb_indexPathsFromIndexesWithSection:0]];
                        }
                    } completion:NULL];
                }
                
                [self resetCachedAssets];
            }
        }else if([self.fetchResult isKindOfClass:[NSMutableArray class]]){
            NSMutableArray* fetchArr = (NSMutableArray*)self.fetchResult;
            BOOL reload = NO;
            for (int i = 0;  i < fetchArr.count; i ++) {
                PHFetchResult* result = fetchArr[i];
                PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:result];
                if (collectionChanges) {
                    // Get the new fetch result
                    result = [collectionChanges fetchResultAfterChanges];
                    fetchArr[i] = result;//替换掉即可
                    
                    if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                        // We need to reload all if the incremental diffs are not available
                        reload = YES;
                    } else {
                        // If we have incremental diffs, tell the collection view to animate insertions and deletions
                        [self.collectionView performBatchUpdates:^{
                            NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                            if ([removedIndexes count]) {
                                [self.collectionView deleteItemsAtIndexPaths:[removedIndexes qb_indexPathsFromIndexesWithSection:i]];
                            }
                            
                            NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                            if ([insertedIndexes count]) {
                                [self.collectionView insertItemsAtIndexPaths:[insertedIndexes qb_indexPathsFromIndexesWithSection:i]];
                            }
                            
                            NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                            if ([changedIndexes count]) {
                                [self.collectionView reloadItemsAtIndexPaths:[changedIndexes qb_indexPathsFromIndexesWithSection:i]];
                            }
                        } completion:NULL];
                    }
                    
                    [self resetCachedAssets];
                }
            }
            
            if (reload) {
                [self.collectionView reloadData];
            }
            
        }
        
    });
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if([self.data isKindOfClass:[NSMutableArray class]]){
        NSMutableArray* arr = (NSMutableArray*)self.data;
        return arr.count;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.fetchResult isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult* result = (PHFetchResult*)self.fetchResult;
        return result.count;
    }else if([self.fetchResult isKindOfClass:[NSMutableArray class]]){
        NSMutableArray* fetchArr = (NSMutableArray*)self.fetchResult;
        PHFetchResult* result = fetchArr[section];
        return result.count;
    }
    return 0;//self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QBAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    cell.tag = indexPath.item;
    cell.showsOverlayViewWhenSelected = self.imagePickerController.allowsMultipleSelection;
    
    PHFetchResult* result;
    if ([self.fetchResult isKindOfClass:[PHFetchResult class]]) {
        result = (PHFetchResult*)self.fetchResult;
    }else if([self.fetchResult isKindOfClass:[NSMutableArray class]]){
        NSMutableArray* fetchArr = (NSMutableArray*)self.fetchResult;
        result = fetchArr[indexPath.section];
    }
    // Image
    PHAsset *asset = result[indexPath.item];
    
    CGSize itemSize = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize];
    CGSize targetSize = CGSizeScale(itemSize, [[UIScreen mainScreen] scale]);
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  if (cell.tag == indexPath.item) {
                                      cell.imageView.image = result;
                                  }
                              }];
    
    // Video indicator
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.videoIndicatorView.hidden = NO;
        
        NSInteger minutes = (NSInteger)(asset.duration / 60.0);
        NSInteger seconds = (NSInteger)ceil(asset.duration - 60.0 * (double)minutes);
        cell.videoIndicatorView.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
        
        if (asset.mediaSubtypes & PHAssetMediaSubtypeVideoHighFrameRate) {
            cell.videoIndicatorView.videoIcon.hidden = YES;
            cell.videoIndicatorView.slomoIcon.hidden = NO;
        }
        else {
            cell.videoIndicatorView.videoIcon.hidden = NO;
            cell.videoIndicatorView.slomoIcon.hidden = YES;
        }
    } else {
        cell.videoIndicatorView.hidden = YES;
    }
    
    // Selection state
    if ([self.imagePickerController.selectedAssets containsObject:asset]) {
        [cell setSelected:YES];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    return cell;
}

-(NSInteger)getCountOfAsetsWidthMediaType:(PHAssetMediaType)mediaType{
    if ([self.fetchResult isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult* result = (PHFetchResult*)self.fetchResult;
        return [result countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    }else if([self.fetchResult isKindOfClass:[NSMutableArray class]]){
        NSMutableArray* fetchArr = (NSMutableArray*)self.fetchResult;
        NSInteger totalCount = 0;
        for (PHFetchResult* result in fetchArr) {
            totalCount += [result countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        }
        return totalCount;
    }
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:@"FooterView"
                                                                                         forIndexPath:indexPath];
        
        
        if([self.data isKindOfClass:[NSMutableArray class]]){
            NSMutableArray* arr = (NSMutableArray*)self.data;
            if (indexPath.section != arr.count - 1) {//不是最后一个隐藏
                return nil;//不需要
            }
        }
        // Number of assets
        UILabel *label = (UILabel *)[footerView viewWithTag:1];
        
        NSBundle *bundle = self.imagePickerController.assetBundle;
        NSUInteger numberOfPhotos = [self getCountOfAsetsWidthMediaType:PHAssetMediaTypeImage];
//        [self.fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        NSUInteger numberOfVideos = [self getCountOfAsetsWidthMediaType:PHAssetMediaTypeVideo];
//        [self.fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
        
        switch (self.imagePickerController.mediaType) {
            case QBImagePickerMediaTypeAny:
            {
                NSString *format;
                if (numberOfPhotos == 1) {
                    if (numberOfVideos == 1) {
                        format = NSLocalizedStringFromTableInBundle(@"assets.footer.photo-and-video", @"QBImagePicker", bundle, nil);
                    } else {
                        format = NSLocalizedStringFromTableInBundle(@"assets.footer.photo-and-videos", @"QBImagePicker", bundle, nil);
                    }
                } else if (numberOfVideos == 1) {
                    format = NSLocalizedStringFromTableInBundle(@"assets.footer.photos-and-video", @"QBImagePicker", bundle, nil);
                } else {
                    format = NSLocalizedStringFromTableInBundle(@"assets.footer.photos-and-videos", @"QBImagePicker", bundle, nil);
                }
                
                label.text = [NSString stringWithFormat:format, numberOfPhotos, numberOfVideos];
            }
                break;
                
            case QBImagePickerMediaTypeImage:
            {
                NSString *key = (numberOfPhotos == 1) ? @"assets.footer.photo" : @"assets.footer.photos";
                NSString *format = NSLocalizedStringFromTableInBundle(key, @"QBImagePicker", bundle, nil);
                
                label.text = [NSString stringWithFormat:format, numberOfPhotos];
            }
                break;
                
            case QBImagePickerMediaTypeVideo:
            {
                NSString *key = (numberOfVideos == 1) ? @"assets.footer.video" : @"assets.footer.videos";
                NSString *format = NSLocalizedStringFromTableInBundle(key, @"QBImagePicker", bundle, nil);
                
                label.text = [NSString stringWithFormat:format, numberOfVideos];
            }
                break;
        }
        
        return footerView;
    }else if(kind == UICollectionElementKindSectionHeader){
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                  withReuseIdentifier:@"HeaderView"
                                                                                         forIndexPath:indexPath];
        
        PHAssetCollection* assetCollection = nil;
        if ([self.data isKindOfClass:[PHAssetCollection class]]) {
            assetCollection = (PHAssetCollection*)self.data;
        }else if([self.data isKindOfClass:[NSMutableArray class]]){
            NSMutableArray* arr = (NSMutableArray*)self.data;
            assetCollection = arr[indexPath.section];
        }
//        if (assetCollection.startDate == nil) {
//            return nil;//不需要
//        }
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        //指定输出的格式   这里格式必须是和上面定义字符串的格式相同，否则输出空
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        UILabel *label = (UILabel *)[headerView viewWithTag:1];
        
        label.text = [formatter stringFromDate:assetCollection.startDate];
        return headerView;
    }
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    if ([self.data isKindOfClass:[PHAssetCollection class]]) {
        // Thumbnail
        PHAssetCollection* assetCollection = (PHAssetCollection*)self.data;
        if (assetCollection.startDate == nil) {//不需要显示section header
            CGSize size = {0, 8};
            return size;
        }
    }
    CGSize size = {[UIScreen mainScreen].bounds.size.width, 40};
    return size;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if([self.data isKindOfClass:[NSMutableArray class]]){
        NSMutableArray* arr = (NSMutableArray*)self.data;
        if (section != arr.count - 1) {//不是最后一个隐藏
            CGSize size = {0, 0};
            return size;
        }
    }
    CGSize size = {[UIScreen mainScreen].bounds.size.width, 40};
    return size;
}


#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:shouldSelectAsset:)]) {
        PHFetchResult* result = [self getFetchResultByIndexPath:indexPath];
        PHAsset *asset = result[indexPath.item];
        
        return [self.imagePickerController.delegate qb_imagePickerController:self.imagePickerController shouldSelectAsset:asset];
    }
    
    if ([self isAutoDeselectEnabled]) {
        return YES;
    }
    
    return ![self isMaximumSelectionLimitReached];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QBImagePickerController *imagePickerController = self.imagePickerController;
    NSMutableOrderedSet *selectedAssets = imagePickerController.selectedAssets;
    
    PHFetchResult* result = [self getFetchResultByIndexPath:indexPath];
    PHAsset *asset = result[indexPath.item];
    
    if (imagePickerController.allowsMultipleSelection) {
        if ([self isAutoDeselectEnabled] && selectedAssets.count > 0) {
            // Remove previous selected asset from set
            [selectedAssets removeObjectAtIndex:0];
            
            // Deselect previous selected asset
            if (self.lastSelectedItemIndexPath) {
                [collectionView deselectItemAtIndexPath:self.lastSelectedItemIndexPath animated:NO];
            }
        }
        
        // Add asset to set
        [selectedAssets addObject:asset];
        
        self.lastSelectedItemIndexPath = indexPath;
        
        [self updateDoneButtonState];
        
        if (imagePickerController.showsNumberOfSelectedAssets) {
            [self updateSelectionInfo];
            
            if (selectedAssets.count == 1) {
                // Show toolbar
                [self.navigationController setToolbarHidden:NO animated:YES];
            }
        }
    } else {
        if ([imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didFinishPickingAssets:)]) {
            [imagePickerController.delegate qb_imagePickerController:imagePickerController didFinishPickingAssets:@[asset]];
        }
    }
    
    if ([imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didSelectAsset:)]) {
        [imagePickerController.delegate qb_imagePickerController:imagePickerController didSelectAsset:asset];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.imagePickerController.allowsMultipleSelection) {
        return;
    }
    
    QBImagePickerController *imagePickerController = self.imagePickerController;
    NSMutableOrderedSet *selectedAssets = imagePickerController.selectedAssets;
    
    PHFetchResult* result = [self getFetchResultByIndexPath:indexPath];
    PHAsset *asset = result[indexPath.item];
    
    // Remove asset from set
    [selectedAssets removeObject:asset];
    
    self.lastSelectedItemIndexPath = nil;
    
    [self updateDoneButtonState];
    
    if (imagePickerController.showsNumberOfSelectedAssets) {
        [self updateSelectionInfo];
        
        if (selectedAssets.count == 0) {
            // Hide toolbar
            [self.navigationController setToolbarHidden:YES animated:YES];
        }
    }
    
    if ([imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didDeselectAsset:)]) {
        [imagePickerController.delegate qb_imagePickerController:imagePickerController didDeselectAsset:asset];
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfColumns;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        numberOfColumns = self.imagePickerController.numberOfColumnsInPortrait;
    } else {
        numberOfColumns = self.imagePickerController.numberOfColumnsInLandscape;
    }
    
    CGFloat width = (CGRectGetWidth(self.view.frame) - 2.0 * (numberOfColumns - 1)) / numberOfColumns;
    
    return CGSizeMake(width, width);
}

@end
