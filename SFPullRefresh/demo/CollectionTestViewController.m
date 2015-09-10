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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _items = [NSMutableArray array];
    _page = 0;
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 10.0;
    layout.minimumLineSpacing = 10.0;
    _collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_collectionView];
    
    [self.collectionView sf_addRefreshHandler:^{
        _page = 0;
        [self loadStrings];
    }];
    [self.collectionView sf_addLoadMoreHandler:^{
        [self loadStrings];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)loadStrings
{
    [self requestDataAtPage:_page success:^(NSArray *strings) {
        if ([self.collectionView sf_isRefreshing]) {
            [self.items removeAllObjects];
        }
        for (NSString *str in strings) {
            [self.items insertObject:str atIndex:0];
        }
        _page++;
        if (strings.count<20) {
            [self.collectionView sf_reachEndWithText:@"加载完毕"];
        }
        if (self.items.count<=0) {
            
        }
        [self.collectionView sf_finishLoading];
    } failure:^(NSString *msg) {
        [self.items removeAllObjects];
        [self.collectionView sf_finishLoading];
    }];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%li", (long)indexPath.row%10]]];
        return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%li", (long)indexPath.row%10]];
    CGSize imgSize = img.size;
    
    return CGSizeMake(170, 170*imgSize.height/imgSize.width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    
//    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
//    _collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
//    [_collectionView setDataSource:self];
//    [_collectionView setDelegate:self];
//    
//    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
//    [_collectionView setBackgroundColor:[UIColor redColor]];
//    
//    [self.view addSubview:_collectionView];
//    
//    
//    // Do any additional setup after loading the view, typically from a nib.
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return 15;
//}
//
//// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
//    
//    cell.backgroundColor=[UIColor greenColor];
//    return cell;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(50, 50);
//}


- (void)requestDataAtPage:(NSInteger)page success:(void(^)(NSArray *))success failure:(void(^)(NSString *))failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.5);
        NSMutableArray *arr = [NSMutableArray array];
        if (page<3) {
            for (NSInteger i=0; i<20; i++) {
                [arr addObject:[NSString stringWithFormat:@"this is row%li", i+page*10]];
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
                    success(arr);
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
