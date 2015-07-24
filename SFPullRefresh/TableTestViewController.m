//
//  TopRefreshViewController.m
//  SFPullRefreshDemo
//
//  Created by shaohua.chen on 10/16/14.
//  Copyright (c) 2014 shaohua.chen. All rights reserved.
//
#import <objc/runtime.h>

#import "TableTestViewController.h"
#import "UIScrollView+SFPullRefresh.h"
#import "CustomRefreshControl.h"
#import "TestTableCell.h"

@interface TableTestViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *items;
@property (assign, nonatomic) NSInteger page;

@property (strong, nonatomic) UITableView *table;

@property (strong, nonatomic) TestTableCell *heightCell;
@end

@implementation TableTestViewController

static NSString *cellId = @"cellId";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _items = [NSMutableArray array];
    _page = 0;
    _table = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    _table.tableFooterView = [[UIView alloc] init];
    [_table registerNib:[UINib nibWithNibName:@"TestTableCell" bundle:nil] forCellReuseIdentifier:cellId];
//    _table.estimatedRowHeight = 60;
    [self.view addSubview:_table];
    
//    CustomRefreshControl *customRefreshControl = [[CustomRefreshControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
//    
//    [_table sf_addRefreshHandler:^{
//        self.page = 0;
//        [self loadStrings];
//    } customRefreshControl:customRefreshControl position:SFPullRefreshPositionTop];
    
    __weak TableTestViewController *wkself = self; //you must use wkself to break the retain cycle
    [_table sf_addRefreshHandler:^{
        wkself.page = 0;
        [wkself loadStrings];
    }];
    
    [_table sf_addLoadMoreHandler:^{
        [wkself loadStrings];
    }];
}

- (void)testBlock:(void(^)(void))block
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)dealloc
{
    NSLog(@"TableTestViewController dealloced");
}

- (void)loadStrings
{
    [self requestDataAtPage:_page success:^(NSArray *strings) {
        if (self.table.sf_isRefreshing) {
            [self.items removeAllObjects];
        }
        for (NSString *str in strings) {
//            [self.items insertObject:str atIndex:0]; //如果顶部加载，数据从头插入体验更好
            [self.items addObject:str];
        }
        
        _page++;
        if (strings.count<10) {
            [self.table sf_reachEndWithText:@"加载完毕"];
        }
        [self.table sf_finishLoading];

    } failure:^(NSString *msg) {
        [self.items removeAllObjects];
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
    if (!_heightCell) {
        _heightCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    [_heightCell setString:[_items objectAtIndex:indexPath.row]];
    CGSize size = [_heightCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    [cell setString:[_items objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self.table sf_refreshAnimated:YES];
    [self.table sf_loadMoreAnimated:YES];
}

- (void)requestDataAtPage:(NSInteger)page success:(void(^)(NSArray *))success failure:(void(^)(NSString *))failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.5);
        NSMutableArray *arr = [NSMutableArray array];
        if (page<4) {
            for (int i=0; i<10; i++) {
                NSMutableString *string = [NSMutableString string];
                int count = rand()%20+1;
                for (int j=0; j<count; j++) {
                    [string appendFormat:@"this is row%ld", i+page*10];
                }
                [arr addObject:string];
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
