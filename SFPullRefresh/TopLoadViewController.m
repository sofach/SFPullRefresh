//
//  TopLoadViewController.m
//  SFPullRefreshDemo
//
//  Created by shaohua.chen on 10/16/14.
//  Copyright (c) 2014 shaohua.chen. All rights reserved.
//

#import "TopLoadViewController.h"
#import "UIScrollView+SFPullRefresh.h"
#import "SFLoadMoreControl.h"
#import "IMVLoadMoreControl.h"

@interface TopLoadViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *items;
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) UITableView *table;

@end


@implementation TopLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.items = [NSMutableArray array];
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    
    [self.view addSubview:_table];
    _page = 0;

    [_table sf_addLoadMoreHandler:^{
        [self loadStrings];
    } customLoadMoreControl:nil position:SFPullRefreshPositionTop];
    
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
        if ([self.table sf_isRefreshing]) {
            [self.items removeAllObjects];
        }
        for (NSString *str in strings) {
            [self.items insertObject:str atIndex:0];
        }
//        [self.items addObjectsFromArray:strings];
        
        if (strings.count<10) {
            
            [self.table sf_reachEnd];
        }
        if (self.items.count<=0) {
            
        }
        _page++;
        [self.table reloadData];
        [self.table sf_finishLoading];
    } failure:^(NSString *msg) {
        [self.items removeAllObjects];
        [self.table reloadData];
        [self.table sf_finishLoading];
    }];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = [_items objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.table sf_loadMoreAnimated:YES];
}



- (void)requestDataAtPage:(NSInteger)page success:(void(^)(NSArray *))success failure:(void(^)(NSString *))failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.5);
        NSMutableArray *arr = [NSMutableArray array];
        if (page<3) {
            for (NSInteger i=0; i<10; i++) {
                [arr addObject:[NSString stringWithFormat:@"this is row%i", i+page*10]];
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
