//
//  RunningVC.m
//  LoveSports
//
//  Created by zorro on 15-1-21.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

// 测试。。。
#import "RunningVC.h"
#import "FSLineChart.h"
#import "UIColor+FSPalette.h"
#import "ShowWareView.h"
#import "CalendarHomeView.h"
#import "LandscapeVC.h"

@interface RunningVC ()

@property (nonatomic, strong) FSLineChart *lineChart;
@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UISegmentedControl *segement;
@property (nonatomic, assign) NSInteger segIndex;

@property (nonatomic, strong) CalendarHomeView *calenderView;
@property (nonatomic, strong) UIButton *lastButton;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger percent;

@end

@implementation RunningVC

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.contents = (id)[UIImage imageNamed:@"background@2x.jpg"].CGImage;
    
    [self loadCalendarButton];
    [self loadSegmentedControl];
    [self loadLandscapeButton];
    //  [self loadDateLabel];
    [self loadShareButton];
    [self loadLineChart];
    [self loadChartStyleButtons];
}

- (void)loadCalendarButton
{
    UIButton *calendarButton = [UIButton simpleWithRect:CGRectMake(15, 70, 45, 35)
                                              withImage:@"日历.png"
                                        withSelectImage:@"日历.png"];
    
    [calendarButton addTarget:self action:@selector(clickCalendarButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:calendarButton];
}

- (void)clickCalendarButton
{
    if (!_calenderView)
    {
        _calenderView = [[CalendarHomeView alloc] initWithFrame:CGRectMake(2, self.view.height * 0.15, self.view.width - 4.0, self.view.height * 0.8)];
    }
    
    [_calenderView setLoveSportsToDay:365 ToDateforString:nil];
    DEF_WEAKSELF_(RunningVC);
    _calenderView.calendarblock = ^(CalendarDayModel *model) {
        NSLog(@"\n---------------------------");
        NSLog(@"1星期 %@",[model getWeek]);
        NSLog(@"2字符串 %@",[model toString]);
        NSLog(@"3节日  %@",model.holiday);
        if (model.holiday)
        {
        }
        else
        {
        }
    };
    
    [_calenderView popupWithtype:PopupViewOption_colorLump touchOutsideHidden:YES succeedBlock:^(UIView *_view) {
    } dismissBlock:^(UIView *_view) {
    }];
}

- (void)loadSegmentedControl
{
    _segement = [[UISegmentedControl alloc] initWithItems:@[@"日", @"周", @"月"]];
    _segement.frame = CGRectMake((self.view.width - 200) / 2, 30, 200, 40);
    
    _segement.backgroundColor = [UIColor clearColor];
    _segement.tintColor = [UIColor clearColor];
    //[_segement setBackgroundImage:[UIImage image:@"日@2x.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segement setImage:[UIImage image:@"日选中@2x.png"] forSegmentAtIndex:0];
    [_segement setImage:[UIImage image:@"周@2x.png"] forSegmentAtIndex:1];
    [_segement setImage:[UIImage image:@"月@2x.png"] forSegmentAtIndex:2];
    [_segement addTarget:self action:@selector(clickSegementControl:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segement];
    _segIndex = 0;
}

- (void)clickSegementControl:(UISegmentedControl *)seg
{
    NSArray *images = @[@"日@2x.png", @"周@2x.png", @"月@2x.png"];
    NSArray *selectImages = @[@"日选中@2x.png", @"周选中@2x.png", @"月选中@2x.png"];

    [_segement setImage:[UIImage image:images[_segIndex]]
      forSegmentAtIndex:_segIndex];
    [_segement setImage:[UIImage image:selectImages[_segement.selectedSegmentIndex]]
      forSegmentAtIndex:_segement.selectedSegmentIndex];
    _segIndex = _segement.selectedSegmentIndex;
}

- (void)loadLandscapeButton
{
    UIButton *landscapeButton = [UIButton simpleWithRect:CGRectMake(self.view.width - 60, 70, 45, 35)
                                              withImage:@"竖屏@2x.png"
                                        withSelectImage:@"竖屏@2x.png"];
    
    [landscapeButton addTarget:self action:@selector(landscapeViewData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:landscapeButton];
}

- (void)landscapeViewData
{
    LandscapeVC *vc = [[LandscapeVC alloc] init];
    
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)loadDateLabel
{
    _weekLabel = [UILabel customLabelWithRect:CGRectMake(0, 25, self.view.width, 30)
                                    withColor:[UIColor clearColor]
                                withAlignment:NSTextAlignmentCenter
                                 withFontSize:20
                                     withText:@"星期一"
                                withTextColor:[UIColor whiteColor]];
    [self.view addSubview:_weekLabel];
    
    _dateLabel = [UILabel customLabelWithRect:CGRectMake(0, 50, self.view.width, 30)
                                    withColor:[UIColor clearColor]
                                withAlignment:NSTextAlignmentCenter
                                 withFontSize:20
                                     withText:@"2015/2/2"
                                withTextColor:[UIColor whiteColor]];
    [self.view addSubview:_dateLabel];
}

-(void)loadLineChart
{
    // Generating some dummy data
    NSMutableArray *chartData = [NSMutableArray arrayWithCapacity:0];
    for(int i = 0; i < 7; i++)
    {
        chartData[i] = [NSNumber numberWithFloat: (arc4random() % 10 + 1) * 0.1];
    }
    
    NSArray *days = @[@"10/10", @"10/11", @"10/12", @"10/13", @"10/14", @"10/15", @"10/16"];
    
    CGRect rect = CGRectMake((self.view.width - self.view.width * 0.9) / 2, 120, self.view.width * 0.9, 200);
    _lineChart = [[FSLineChart alloc] initWithFrame:rect];
    _lineChart.verticalGridStep = 6;
    _lineChart.horizontalGridStep = (int)days.count; // 151,187,205,0.2
    _lineChart.color = [UIColor colorWithRed:151.0f/255.0f green:187.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
    _lineChart.fillColor = [_lineChart.color colorWithAlphaComponent:0.3];
    _lineChart.labelForIndex = ^(NSUInteger item) {
        return days[item];
    };
    _lineChart.labelForValue = ^(CGFloat value) {
         return [NSString stringWithFormat:@""];
    };
    [_lineChart setChartData:chartData];
    
    [self.view addSubview:_lineChart];
}

- (void)loadChartStyleButtons
{
    CGFloat offsetX = ((self.view.width - 60) - 90 * 3) / 2;
    NSArray *images = @[@"足迹@2x.png", @"能量@2x.png", @"路程@2x.png"];
    NSArray *selectImages = @[@"足迹-选中@2x.png", @"能量选中@2x.png", @"路程选中@2x.png"];
    
    for (int i = 0; i < images.count; i++)
    {
        UIButton *button = [UIButton simpleWithRect:CGRectMake(30 + (90 + offsetX) * i , 340, 90, 89)
                                                   withImage:images[i]
                                             withSelectImage:selectImages[i]];
        
        button.tag = 2000 + i;
        [button addTarget:self action:@selector(clcikChartStyleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        if (i == 0)
        {
            button.selected = YES;
            _lastButton = button;
        }
    }
}

- (void)clcikChartStyleButton:(UIButton *)button
{
    _lastButton.selected = NO;
    button.selected = YES;
    _lastButton = button;
    
    if (button.tag == 2000)
    {
        
    }
    else if (button.tag == 2001)
    {
    }
    else if (button.tag == 2002)
    {
        
    }
}

- (void)loadShareButton
{
    UIButton *calendarButton = [UIButton simpleWithRect:CGRectMake(self.view.width - 45, self.view.height - 99, 90/2.0, 70/2.0)
                                              withImage:@"分享@2x.png"
                                        withSelectImage:@"分享@2x.png"];
    
    [self.view addSubview:calendarButton];
}

#pragma mark --- 重写父类方法 ---
- (void)leftSwipe
{
    NSLog(@"..左扫..");
    NSMutableArray *chartData = [NSMutableArray arrayWithCapacity:7];
    for(int i = 0; i < 7; i++)
    {
        chartData[i] = [NSNumber numberWithFloat: (arc4random() % 10 + 1) * 0.1];
    }
    
    if (_lineChart)
    {
        [_lineChart setChartData:chartData];
    }
}

- (void)rightSwipe
{
    NSLog(@"..右扫..");
    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:7];
    for(int i = 0;i < 7;i ++)
    {
        chartData[i] = [NSNumber numberWithFloat: (arc4random() % 10 + 1) * 0.1];
    }
    
    if (_lineChart)
    {
        [_lineChart setChartData:chartData];
    }
}

@end
