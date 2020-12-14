//
//  ViewController.m
//  myblog
//
//  Created by bytedance on 2020/6/3.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import <Masonry.h>

@interface ViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UILabel *headline;
@property (nonatomic, strong) UILabel *subhead;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollViewbg;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property(nonatomic,weak)NSTimer *timer;
@property(nonatomic,strong)NSDictionary *bigDic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //AF拉取网络数据
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"https://www.hupospace.com/wp-admin/includes/findtext.php" parameters:nil headers:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        self.bigDic = responseObject;
        [self.tableView reloadData];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
    }];
    [self initSubviews];
    [self initConstraints];
    //页数控制
    [self startTimer];
}

- (void)initSubviews {
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.headline];
    [self.view addSubview:self.subhead];
    [self.view addSubview:self.pageControl];
    [self.view addSubview:self.tableView];
}

- (void)initConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.width.mas_equalTo(414);
        make.height.mas_equalTo(270);
    }];
    [self.headline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.imageView.mas_centerX);
        make.centerY.equalTo(self.imageView.mas_centerY).offset(-20);
    }];
    [self.subhead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headline.mas_bottom);
        make.centerX.equalTo(self.imageView.mas_centerX);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(10);
        make.centerX.equalTo(self.imageView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(384, 200));
    }];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.scrollView.mas_bottom).offset(-20);
        make.centerX.equalTo(self.scrollView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView.mas_bottom).offset(20);
        make.centerX.equalTo(self.imageView.mas_centerX);
    }];
}

//下一页
- (void)nextPage{
    NSInteger page =self.pageControl.currentPage + 1;
    if(page == 5){
        page=0;
    }
    self.pageControl.currentPage = page;
    [self.scrollView setContentOffset:CGPointMake(page * self.scrollView.frame.size.width,0) animated:YES];
}

#pragma mark -Timer 定时器
-(void)startTimer{
    self.timer=[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark -UIcrollViewDelegate  页数控制代理

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page=(int)(scrollView.contentOffset.x/scrollView.frame.size.width+0.5);
    self.pageControl.currentPage = page;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [self stopTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self startTimer];
}
#pragma mark -UITableViewDataSource  表视图
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSArray *data = [_bigDic objectForKey:@"data"];
    return data.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

//告诉tableView每一行显示的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    UITableViewCell *cell =[[UITableViewCell alloc]initWithFrame:CGRectZero];
    NSArray *data = [_bigDic objectForKey:@"data"];
    NSDictionary *Dict = data[data.count - indexPath.section - 1];
    NSString *content = [Dict objectForKey:@"post_content"];
    cell.textLabel.text = content;
    cell.textLabel.numberOfLines = 0;  //可多行显示
    cell.textLabel.lineBreakMode=NSLineBreakByWordWrapping;//拆行
    return cell;
}

#pragma mark -代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (tableView.rowHeight)<100?tableView.rowHeight:100;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = YES;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 300;
    }
    return _tableView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.contentSize=CGSizeMake(5 * 384, 0);
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate=self;
        for(int i = 0; i < 5; i++){
            UIImageView *imageView=[[UIImageView alloc]init];
            NSString *name =[NSString stringWithFormat:@"pic%d",i+1];
            imageView.image=[UIImage imageNamed:name];
            imageView.frame=CGRectMake(i*384,0, 384, 200);
            [_scrollView addSubview:imageView];
        }
    }
    return _scrollView;
}

- (UILabel *)headline {
    if (!_headline) {
        _headline = [[UILabel alloc] init];
        _headline.textAlignment=NSTextAlignmentCenter;
        _headline.text=@"Kohakuの家";
        _headline.font=[UIFont systemFontOfSize:40];
        _headline.textColor=[UIColor whiteColor];
    }
    return _headline;
}

- (UILabel *)subhead {
    if (!_subhead) {
        _subhead = [[UILabel alloc] init];
        _subhead.textAlignment=NSTextAlignmentCenter;
        _subhead.text=@"换一个地方，换一种心情";
        _subhead.font=[UIFont systemFontOfSize:25];
        _subhead.textColor=[UIColor whiteColor];
    }
    return _subhead;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"背景"]];
        _imageView.frame=CGRectMake(0 , 0, 414, 270);
        _imageView.contentMode=UIViewContentModeScaleToFill;
        _imageView.clipsToBounds=YES;
    }
    return _imageView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        _pageControl.numberOfPages = 5;
        _pageControl.currentPage = 0;
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}
@end


