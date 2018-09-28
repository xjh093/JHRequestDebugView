//
//  JHRequestHistoryView.m
//  JHKit
//
//  Created by HaoCold on 2018/9/28.
//  Copyright © 2018年 HaoCold. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2018 xjh093
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#define kTitleBackgroundColor [UIColor colorWithRed:0 green:199/255.0 blue:140/255.0 alpha:1]

#import "JHRequestHistoryView.h"

@interface JHRequestHistoryView()<UITableViewDelegate,UITableViewDataSource>
@property (strong,  nonatomic) UITableView *tableView;
@end

@implementation JHRequestHistoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self jhSetupViews];
    }
    return self;
}

- (void)jhSetupViews
{
    [self addSubview:self.tableView];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"history_resueID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.numberOfLines = 0;
    }
    NSDictionary *dic = _dataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"[%@].%@",@(indexPath.row),dic[@"url"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_clickBlock) {
        if (indexPath.row < _dataArray.count) {
            _clickBlock(_dataArray[indexPath.row]);
        }
    }
}


#pragma mark - public
- (void)reloadData{
    [_tableView reloadData];
}

#pragma mark - setter & getter

- (UITableView *)tableView{
    if (!_tableView) {
        
        [self addSubview:[[UIView alloc] init]];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:0];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.layer.cornerRadius = 5;
        tableView.clipsToBounds = YES;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = [[UIView alloc] init];
        tableView.showsVerticalScrollIndicator = NO;
        //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView = tableView;
        
        tableView.tableHeaderView = ({
            UILabel *title = [[UILabel alloc] init];
            title.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 40);
            title.text = @"JHRequestHistory";
            title.textColor = [UIColor whiteColor];
            title.font = [UIFont boldSystemFontOfSize:18];
            title.textAlignment = NSTextAlignmentCenter;
            title.backgroundColor = kTitleBackgroundColor;
            title;
        });
    }
    return _tableView;
}


@end
