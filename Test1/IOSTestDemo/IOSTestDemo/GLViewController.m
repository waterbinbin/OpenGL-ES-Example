//
//  GLViewController.m
//  IOSTestDemo
//
//  Created by 王福滨 on 17/3/25.
//  Copyright © 2017年 wangfubin. All rights reserved.
//

#import "GLViewController.h"
#import "ViewDemo2.h"

@interface GLViewController ()
@property (nonatomic, strong) ViewDemo2 *myView;
@end

@implementation GLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view = (ViewDemo2 *)self.view;
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
