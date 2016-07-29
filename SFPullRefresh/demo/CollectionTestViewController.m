//
//  TopLoadViewController.m
//  SFPullRefreshDemo
//
//  Created by shaohua.chen on 10/16/14.
//  Copyright (c) 2014 shaohua.chen. All rights reserved.
//

#import "CollectionTestViewController.h"
#import "UIScrollView+SFPullRefresh.h"

@interface CollectionTestViewController ()

@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSMutableArray *items;

@property (strong, nonatomic) UILabel *hintsLabel;

@end


@implementation CollectionTestViewController

- (UILabel *)hintsLabel {
    if (!_hintsLabel) {
        _hintsLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        _hintsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _hintsLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _items = [NSMutableArray array];
    _page = 0;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    self.collectionView.alwaysBounceVertical = YES;    
    
    CollectionTestViewController *wkself = self;

    [self.collectionView sf_addRefreshHandler:^{
        wkself.page = 0;
        [wkself loadStrings];
    }];
    
    [self.collectionView sf_addLoadMoreHandler:^{
        [wkself loadStrings];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView sf_refreshAnimated:NO];
}

- (void)loadStrings
{
    [self requestDataAtPage:self.page success:^(NSArray *strings) {
        if ([self.collectionView sf_isRefreshing]) {
            [self.items removeAllObjects];
        }
        for (NSString *str in strings) {
            [self.items insertObject:str atIndex:0];
        }
        if (strings.count<10) {
            [self.collectionView sf_reachEndWithText:@"加载完毕"];
        }
        _page++;
        if (self.items.count<=0) {
            _hintsLabel.text = @"数据为空";
            [self.collectionView sf_showHintsView:self.hintsLabel];
        }

        [self.collectionView sf_finishLoading];

    } failure:^(NSString *msg) {
        [self.items removeAllObjects];
        [self.collectionView sf_finishLoading];
        self.hintsLabel.text = msg;
        [self.collectionView sf_showHintsView:self.hintsLabel];
    }];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%li", (long)indexPath.row%10]]];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    cell.backgroundView = imgView;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat w = ([UIScreen mainScreen].bounds.size.width-30)/2;
    return CGSizeMake(w, w);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    CollectionTestViewController *collectionVC = [[CollectionTestViewController alloc] initWithCollectionViewLayout:layout];
    collectionVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:collectionVC animated:YES];
}

- (void)requestDataAtPage:(NSInteger)page success:(void(^)(NSArray *))success failure:(void(^)(NSString *))failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        NSMutableArray *arr = [NSMutableArray array];
        if (page<5) {
            for (NSInteger i=0; i<10; i++) {
                [arr addObject:[NSString stringWithFormat:@"%li", i%10]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success(arr);
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(@"服务器错误！");
                }
            });
        }
        
    });
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
