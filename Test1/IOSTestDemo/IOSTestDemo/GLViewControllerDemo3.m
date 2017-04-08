//
//  GLViewControllerDemo3.m
//  IOSTestDemo
//
//  Created by 王福滨 on 17/3/25.
//  Copyright © 2017年 wangfubin. All rights reserved.
//

#import "GLViewControllerDemo3.h"
#import "ViewDemo3.h"

@interface GLViewControllerDemo3 ()
@property(nonatomic, strong) ViewDemo3 *myView;;
@end

@implementation GLViewControllerDemo3

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myView = (ViewDemo3 *)self.view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
