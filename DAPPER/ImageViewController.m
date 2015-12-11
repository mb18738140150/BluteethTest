//
//  ImageViewController.m
//  DAPPER
//
//  Created by 仙林 on 15/12/3.
//  Copyright © 2015年 Vbenz. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.frame = CGRectMake(100, 100, 100, 30);
    self.button.backgroundColor = [UIColor cyanColor];
    [_button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100,200, 200, 200)];
//    self.imageView.backgroundColor = [UIColor redColor];
    _imageView.image = _image;
    [self.view addSubview:_imageView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    

}

- (void)backAction:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
