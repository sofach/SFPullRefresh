//
//  ViewController.m
//  SFPullRefreshDemo
//
//  Created by shaohua.chen on 10/16/14.
//  Copyright (c) 2014 shaohua.chen. All rights reserved.
//

#import "ViewController.h"
#import "CollectionTestViewController.h"
#import "TableTestViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSString *testString;

@property (strong, nonatomic) TableTestViewController *topRefreshVC;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _items = @[@"UITableView Test", @"UICollectionView Test(not support well)"];
    
    _table = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _table.dataSource = self;
    _table.delegate = self;
    _table.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_table];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 60;
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
    if (indexPath.row == 0) {
        TableTestViewController *topRefreshVC = [[TableTestViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:topRefreshVC animated:YES];
    }
    else if (indexPath.row == 1)
    {
        CollectionTestViewController *topLoadVC = [[CollectionTestViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:topLoadVC animated:YES];
    }
    else
    {
    }
}

@end
