//
//  KLSegmentControl.m
//  Raffle
//
//  Created by Killua Liu on 7/17/16.
//  Copyright © 2016 Syzygy. All rights reserved.
//

#import "KLSegmentControl.h"

#define TITLE_LABEL_FONT        [UIFont subtitleFont]
#define SELECTION_MARK_MARGIN   UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? 8.0 : 5.0

#pragma mark - Class: KLSegmentCollectionViewCell
@interface KLSegmentCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@end

@implementation KLSegmentCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews
{
    _titleLabel = [UILabel newAutoLayoutView];
    _titleLabel.font = TITLE_LABEL_FONT;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel constraintsCenterInSuperview];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.titleLabel.textColor = highlighted ? [self.titleLabel.textColor darkerColor] : [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.userInteractionEnabled = !self.isSelected;
    self.titleLabel.textColor = selected ? [UIColor orangeColor] : [UIColor whiteColor];
}

@end


#pragma mark - Class: KLSegmentControl
@interface KLSegmentControl () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableDictionary *itemSizes;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *currentSelectionMark;

@property (nonatomic, assign) CGFloat itemInset;
@property (nonatomic, assign) CGFloat defaultItemInset;

@end

@implementation KLSegmentControl

#pragma mark - Lifecycle
+ (instancetype)segmentControlWithItems:(NSArray *)items
{
    return [[self alloc] initWithItems:items];
}

- (instancetype)initWithItems:(NSArray *)items
{
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.defaultItemInset = KLViewDefaultMargin;
        self.items = items;
        [self addSubviews];
        [self addObservers];
        [self relayoutCollectionView];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? CGSizeMake(self.width, 36) : CGSizeMake(self.width, 30);
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    _itemSizes = [NSMutableDictionary dictionary];
    [items enumerateObjectsUsingBlock:^(NSString *item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        self.itemSizes[indexPath] = [NSValue valueWithCGSize:[item sizeWithFont:TITLE_LABEL_FONT]];
    }];
}

- (void)addSubviews
{
    // Add collection view
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, self.defaultItemInset, 0, self.defaultItemInset);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.backgroundColor = [UIColor darkBackgroundColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self addSubview:_collectionView];
    [self.collectionView constraintsEqualWithSuperView];
    [self.collectionView registerClass:[KLSegmentCollectionViewCell class] forCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    // Add current selection mark
    _currentSelectionMark = [UIView newAutoLayoutView];
    _currentSelectionMark.backgroundColor = [UIColor blackColor];
    _currentSelectionMark.userInteractionEnabled = NO;
    _currentSelectionMark.layer.zPosition = -1;
    [self.collectionView addSubview:_currentSelectionMark];
}

- (void)relayoutCollectionView
{
    self.itemInset = self.isNeedResizeItem ? (SCREEN_WIDTH - [self totalItemWidth]) / (self.items.count + 1) / 2 : self.defaultItemInset;
    
    UICollectionViewFlowLayout *flowLayout = (id)self.collectionView.collectionViewLayout;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, self.itemInset, 0, self.itemInset);
    [flowLayout invalidateLayout];
}

- (BOOL)isNeedResizeItem
{
    CGFloat totalWidth = [self totalItemWidth];
    return (totalWidth + self.defaultItemInset * 2 * (self.items.count + 1)) <= SCREEN_WIDTH;
}

- (CGFloat)totalItemWidth
{
    __block CGFloat totalItemWidth = 0;
    [self.itemSizes enumerateKeysAndObjectsUsingBlock:^(id key, NSValue *value, BOOL * _Nonnull stop) {
        totalItemWidth += value.CGSizeValue.width;
    }];
    return totalItemWidth;
}

#pragma mark - Orientation observer
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public method
- (void)reloadData
{
    if (self.items.count == 0) return;
    
    [self relayoutCollectionView];
    
    NSIndexPath *indexPath = self.selectedIndexPath;
    [self.collectionView reloadData];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (NSIndexPath *)selectedIndexPath
{
    NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems].firstObject;
    if (indexPath.item == NSNotFound) {
        return [NSIndexPath indexPathForItem:0 inSection:0];
    }
    if (indexPath.item >= self.items.count) {
        return [NSIndexPath indexPathForItem:self.items.count-1 inSection:0];
    }
    return indexPath;
}

- (void)selectSegmentAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self animateSelectCellAtIndexPath:indexPath completion:^(BOOL finished) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }];
}

- (void)scrollWithOffsetRate:(CGFloat)offsetRate
{
    if (offsetRate == 0 || self.items.count == 1) return;
    NSIndexPath *indexPath = self.selectedIndexPath;
    if ((offsetRate < 0 && indexPath.item == 0) || (offsetRate > 0 && indexPath.item == self.items.count - 1)) return;
    
    KLSegmentCollectionViewCell *selCell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSUInteger item = offsetRate > 0 ? indexPath.item + 1 : indexPath.item - 1;     // Next or previous cell
    KLSegmentCollectionViewCell *npCell = (id)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
    CGFloat dx = ABS(npCell.centerX - selCell.centerX);
    CGFloat dw = npCell.width - selCell.width;
    
    CGRect frame = CGRectInset(selCell.frame, self.itemInset/3, 0);
    self.currentSelectionMark.centerX = selCell.centerX + dx * offsetRate;
    self.currentSelectionMark.width = frame.size.width + dw * ABS(offsetRate);
}

#pragma mark - Collection view delegate flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [self.itemSizes[indexPath] CGSizeValue].width;
    return CGSizeMake(width + self.itemInset * 2, self.height);
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KLSegmentCollectionViewCell *cell = (id)[collectionView dequeueReusableCellWithReuseIdentifier:CVC_REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.titleLabel.text = self.items[indexPath.item];
    return cell;
}

#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(KLSegmentCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.isSelected) {
        [self setCurrentSelectionMarkFrameByCell:cell];
    }
}

- (void)setCurrentSelectionMarkFrameByCell:(KLSegmentCollectionViewCell *)cell
{
    CGFloat dy = (cell.height - cell.titleLabel.intrinsicContentHeight - SELECTION_MARK_MARGIN) / 2;
    self.currentSelectionMark.frame = CGRectInset(cell.frame, self.itemInset/3, dy);
    self.currentSelectionMark.layer.cornerRadius = self.currentSelectionMark.height / 2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self animateSelectCellAtIndexPath:indexPath completion:^(BOOL finished) {
        [self.delegate segmentControl:self didSelectSegmentAtIndex:indexPath.item];
    }];
}

- (void)animateSelectCellAtIndexPath:(NSIndexPath *)indexPath completion:(KLBOOLBlockType)completion
{
    KLSegmentCollectionViewCell *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDefaultDuration:^{
        [self setCurrentSelectionMarkFrameByCell:cell];
    } completion:completion];
}

@end
