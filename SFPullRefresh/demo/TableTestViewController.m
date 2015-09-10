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

@interface TableTestViewController ()

@property (strong, nonatomic) NSMutableArray *items;

@property (strong, nonatomic) TestTableCell *heightCell;
@end

@implementation TableTestViewController

static NSString *cellId = @"cellId";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _items = [NSMutableArray array];

    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"TestTableCell" bundle:nil] forCellReuseIdentifier:cellId];
    
//    _table.estimatedRowHeight = 60;
    
//    CustomRefreshControl *customRefreshControl = [[CustomRefreshControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
//    
//    [_table sf_addRefreshHandler:^{
//        self.page = 0;
//        [self loadStrings];
//    } position:SFPullRefreshPositionTop customRefreshControl:customRefreshControl];
    
    __weak TableTestViewController *wkself = self; //you must use wkself to break the retain cycle
    [self.tableView sf_addRefreshHandler:^{
        [wkself loadStrings];
    }];
    
    [self.tableView sf_addLoadMoreHandler:^{
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
    [self requestDataAtPage:self.tableView.sf_page success:^(NSArray *strings) {
        if (self.tableView.sf_isRefreshing) {
            [self.items removeAllObjects];
        }
        for (NSString *str in strings) {
//            [self.items insertObject:str atIndex:0]; //如果顶部加载，数据从头插入体验更好
            [self.items addObject:str];
        }
        
        if (strings.count<10) {
            [self.tableView sf_reachEndWithText:@"加载完毕"];
        }
        [self.tableView sf_finishLoading];
        if (self.items.count<=0) {
            [self.tableView sf_showHints:@"没有数据"];
        }
    } failure:^(NSString *msg) {
        [self.items removeAllObjects];
        [self.tableView sf_finishLoading];
        //可以使用自定义的提示界面
//        UIView *hintsView = [[UIView alloc] initWithFrame:self.tableView.bounds];
//        hintsView.backgroundColor = [UIColor greenColor];
//        [self.tableView sf_showHintsView:hintsView];
        [self.tableView sf_showHints:msg];
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
    TestTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    [cell setString:[_items objectAtIndex:indexPath.row]];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height<74?74:size.height+1;
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
    if (indexPath.row == 0) {
        [self.tableView sf_refreshAnimated:YES];
    } else {
        [self.tableView sf_loadMoreAnimated:YES];
    }
    
//    [self.tableView sf_loadMoreAnimated:YES];
}

- (void)requestDataAtPage:(NSInteger)page success:(void(^)(NSArray *))success failure:(void(^)(NSString *))failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.5);
        NSMutableArray *arr = [NSMutableArray array];
        if (page<3) {
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
