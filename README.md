SFPullRefresh provides a very simple way to implement pull refresh and load more, and supports setting the position and customizing refresh or loadmore control with your own view.


### Installation with CocoaPods

```ruby

pod 'SFPullRefresh'

```


### Usage
#### Basic 
Add pull refresh handler and load more handler to your tableView or collectionView, and when you get data, you should call [self.table sf_finishLoading] to end loading animation, if there is no more data, you should call [self.table sf_reachEndWithText:@"reach end message"].

```objective-c
- (void)viewDidLoad
{
  ...

  [self.table sf_addRefreshHandler:^{
      self.page = 0;
      [self loadStrings];
  }];
    
  [self.table sf_addLoadMoreHandler:^{
      [self loadStrings];
  }];
  
  ...
}

- (void)loadStrings
{
    [self requestDataAtPage:self.page success:^(NSArray *strings) {
        if (self.table.sf_isRefreshing) {
            [self.items removeAllObjects];
        }
        [self.items addObjectsFromArray:strings];
        self.page++;
        if (strings.count<10) {
            [self.table sf_reachEndWithText:@"加载完毕"];
        }
        [self.table sf_finishLoading];

    } failure:^(NSString *msg) {
        [self.items removeAllObjects];
        [self.table sf_finishLoading];
    }];
```
#### Customization
You can set the position, and if you want use your own refresh animation, you can customize refresh or load more control with your own view.

```objective-c

    CustomRefreshControl *customRefreshControl = [[CustomRefreshControl alloc] initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width, 60)];
    
    [self.table sf_addRefreshHandler:^{
        self.page = 0;
        [self loadStrings];
    } customRefreshControl:customRefreshControl position:SFPullRefreshPositionBottom];

```
The custom view must conforms to protocol SFRefreshControlDelegate or SFLoadMoreControlDelegate.
```objective-c
@protocol SFRefreshControlDelegate <NSObject>
- (void)willRefreshWithProgress:(CGFloat)progress;
- (void)beginRefreshing;
- (void)endRefreshing;

@optional
- (void)setTintColor:(UIColor *)tintColor;
@end

@protocol SFLoadMoreControlDelegate <NSObject>
- (void)beginLoading;
- (void)endLoading;
- (void)reachEndWithText:(NSString *)text;

@optional
- (void)setTintColor:(UIColor *)tintColor;
@end
```
Enjoy it!
