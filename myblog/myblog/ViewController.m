//
//  ViewController.m
//  myblog
//
//  Created by bytedance on 2020/6/3.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "AFNetworking.h"
#import "YYText.h"

@interface ViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIScrollView *scrollViewbg;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property(nonatomic,weak)NSTimer *timer;
@property(nonatomic,strong)NSDictionary *bigDic;
@property (nonatomic, strong) YYTextLayout *layout;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGRect tableRect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //AF拉取网络数据
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"https://www.hupospace.com/wp-admin/includes/findtext.php" parameters:nil headers:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        self.bigDic = responseObject;
        NSLog(@"JSON: %@", self->_bigDic);
        [self.tableView reloadData];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    //导航栏
    
    //顶部图片
    UIImageView *imageViewbg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"背景"]];
     imageViewbg.frame=CGRectMake(0,0,414, 270);
     imageViewbg.contentMode=UIViewContentModeScaleToFill;
     imageViewbg.clipsToBounds=YES;

    //大标题
    UILabel *label=[[UILabel alloc]init];
    label.frame=CGRectMake(55, 45, 300, 135);
    label.textAlignment=NSTextAlignmentCenter;
    label.text=@"Kohakuの家";
    label.font=[UIFont systemFontOfSize:40];
    label.textColor=[UIColor whiteColor];
    self.label=label;
    
    //小标题
    UILabel *label2=[[UILabel alloc]init];
     label2.frame=CGRectMake(55, 90, 300, 135);
     label2.textAlignment=NSTextAlignmentCenter;
     label2.text=@"换一个地方，换一种心情";
     label2.font=[UIFont systemFontOfSize:25];
     label2.textColor=[UIColor whiteColor];
    self.label2=label2;
    
    //轮循ScrollView
    UIScrollView *scrollView=[[UIScrollView alloc]init];
    scrollView.frame=CGRectMake(15, 285, 384, 200);
    self.scrollView = scrollView;
    for(int i=0;i<5;i++)
    {
        UIImageView *imageView=[[UIImageView alloc]init];
        NSString *name =[NSString stringWithFormat:@"pic%d",i+1];
        imageView.image=[UIImage imageNamed:name];
        imageView.frame=CGRectMake(i*384,0, 384, 200);
        [scrollView addSubview:imageView];
    }
    scrollView.contentSize=CGSizeMake(5*384, 0);
 //   [self.scrollViewbg addSubview:scrollView];
    scrollView.showsVerticalScrollIndicator = FALSE;
    scrollView.showsHorizontalScrollIndicator = FALSE;
    scrollView.pagingEnabled=YES;
    
    
    //页数控制
    UIPageControl *pageControl=[[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(155, 450, 100, 20);
    pageControl.numberOfPages=5;
    pageControl.currentPage = 0;
    self.pageControl.hidesForSinglePage=YES;
    [self.scrollViewbg addSubview:pageControl];
    self.pageControl = pageControl;
    scrollView.delegate=self;
    [self startTimer];
    
    UIView *view1=[[UIView alloc]init];
    self.view1=view1;
    view1.frame=CGRectMake(0, 0,414,500);
    [self.view1 addSubview:imageViewbg];
    [self.view1 addSubview:scrollView];
    [self.view1 addSubview:label];
    [self.view1 addSubview:label2];
    [self.view1 addSubview:pageControl];
    
    
    
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64,414,self.view.bounds.size.height) style:UITableViewStyleGrouped];
    self.tableView.dataSource=self;
    self.tableView.rowHeight=300;
    self.tableView.tableHeaderView=view1;

    [self.view addSubview:_tableView];
    [self.tableView reloadData];

    CGRect screen =[[UIScreen mainScreen]bounds];
    CGFloat navigationBarHeight=44;

    UINavigationBar *navigationBar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, screen.size.width, navigationBarHeight)];
    [self.view addSubview:navigationBar];
    UINavigationItem *navigationItem =[[UINavigationItem alloc]initWithTitle:@"琥珀博客"];
    navigationBar.items=@[navigationItem];
}

//下一页
- (void)nextPage
{
    NSInteger page =self.pageControl.currentPage + 1;
    if(page == 5)
    {
        page=0;
    }
    self.pageControl.currentPage=page;
    [self.scrollView setContentOffset:CGPointMake(page * self.scrollView.frame.size.width,0) animated:YES];
}
#pragma mark -Timer 定时器
-(void)startTimer
{
     self.timer=[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
     
}

-(void)stopTimer
{
    [self.timer invalidate];
    self.timer=nil;
}

#pragma mark -UIcrollViewDelegate  页数控制代理

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
        int page=(int)(scrollView.contentOffset.x/scrollView.frame.size.width+0.5);
        self.pageControl.currentPage = page;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self stopTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}
#pragma mark -UITableViewDataSource  表视图
//这些方法不需要主动调用
//告诉TableView有多少组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *data = [_bigDic objectForKey:@"data"];
    return data.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//告诉tableView每一行显示的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{

    UITableViewCell *cell =[[UITableViewCell alloc]initWithFrame:CGRectZero];
    NSArray *data = [_bigDic objectForKey:@"data"];
    NSDictionary *Dict = data[data.count-indexPath.section-1];
    NSString *content = [Dict objectForKey:@"post_content"];
    cell.textLabel.text=content;
    cell.textLabel.numberOfLines=0;  //可多行显示
    cell.textLabel.lineBreakMode=NSLineBreakByWordWrapping;//拆行
    return cell;
}

#pragma mark -代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"TEST ++你好");
    return (tableView.rowHeight)<100?tableView.rowHeight:100;
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
//{
//    CommentViewController * commentVc = [[CommentViewController alloc]init];
//    commentVc.topic = self.topics[indexPath.row];
//    [self.navigationController pushViewController:commentVc animated:YES];
//}

@end


