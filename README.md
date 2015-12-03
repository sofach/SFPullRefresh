## SFPullRefresh (support ios5+)

SFPullRefresh provides a very simple way to implement pull refresh and load more, supports customizing refresh or loadmore control with your own view.

![image](http://github.com/sofach/SFPullRefresh/raw/master/demo.gif)

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
  __weak YourViewController *wkself = self; //you must use wkself to break the retain cycle
  [self.table sf_addRefreshHandler:^{
      wkself.page = 0;
      [wkself loadStrings];
  }];
    
  [self.table sf_addLoadMoreHandler:^{
      [wkself loadStrings];
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
}
```
#### Customization
You can customize refresh or load more control with your own view.

```objective-c

    CustomRefreshControl *customRefreshControl = [[CustomRefreshControl alloc] initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width, 60)];
    
    __weak YourViewController *wkself = self; //you must use wkself to break the retain cycle
    [self.table sf_addRefreshHandler:^{
        wkself.page = 0;
        [wkself loadStrings];
    } customRefreshControl:customRefreshControl];

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
