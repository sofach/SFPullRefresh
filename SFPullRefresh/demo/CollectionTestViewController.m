//
//  TopLoadViewController.m
//  SFPullRefreshDemo
//
//  Created by shaohua.chen on 10/16/14.
//  Copyright (c) 2014 shaohua.chen. All rights reserved.
//

#import "CollectionTestViewController.h"
#import "UIScrollView+SFPullRefresh.h"

@interface CollectionTestViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) UICollectionView *collectionView;
@end


@implementation CollectionTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _items = [NSMutableArray array];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
//    _collectionView.alwaysBounceVertical = YES;
//    [self.view addSubview:_collectionView];
    
    //以下调用必须在 [self.view addSubview:self.collectionView];之前
    CollectionTestViewController *wkself = self;
    [self.collectionView sf_addRefreshHandler:^{
        [wkself loadStrings];
    }];
    [self.collectionView sf_addLoadMoreHandler:^{
        [wkself loadStrings];
    }];
    [self.view addSubview:self.collectionView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)loadStrings
{
    [self requestDataAtPage:self.collectionView.sf_page success:^(NSArray *strings) {
        if ([self.collectionView sf_isRefreshing]) {
            [self.items removeAllObjects];
        }
        for (NSString *str in strings) {
            [self.items insertObject:str atIndex:0];
        }
        [self.collectionView sf_finishLoading];
        if (strings.count<10) {
            [self.collectionView sf_reachEndWithText:@"加载完毕"];
        }
        if (self.items.count<=0) {
            [self.collectionView sf_showHints:@"数据为空"];
        }
    } failure:^(NSString *msg) {
        [self.items removeAllObjects];
        [self.collectionView sf_finishLoading];
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


- (void)requestDataAtPage:(NSInteger)page success:(void(^)(NSArray *))success failure:(void(^)(NSString *))failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.5);
        NSMutableArray *arr = [NSMutableArray array];
        if (page<3) {
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
                if (success) {
                    success(nil);
                }
                //                if (failure) {
                //                    failure(@"服务器错误！");
                //                }
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
