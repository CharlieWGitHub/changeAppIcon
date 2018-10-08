//
//  ViewController.m
//  changeAppIcon
//
//  Created by 王成龙 on 2018/10/8.
//  Copyright © 2018年 CL. All rights reserved.
//

#import "ViewController.h"
#import <objc/message.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 59);
    [button setTitle:@"变" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:@selector(changeIcon:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self runtimeReplaceAlert];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)changeIcon:(id)sender{
    NSLog(@"变");
    if ([[UIApplication sharedApplication] supportsAlternateIcons]) {
        NSLog(@"这个APP 可以改icon");
    }else{
        NSLog(@"这个APP 不让你改icon");
    }
    NSString *iconName = [[UIApplication sharedApplication] alternateIconName];
    if (iconName) {
        [[UIApplication sharedApplication] setAlternateIconName:nil completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"设置icon失败%@",error);
            }
            NSLog(@"设置icon成功%@",iconName);
        }];
    } else {
        [[UIApplication sharedApplication]setAlternateIconName:@"androidIcon60" completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"设置icon失败%@",error);
            }
            NSLog(@"设置icon成功%@",iconName);
        }];
    }
    
}

// 利用runtime来替换展现弹出框的方法
- (void)runtimeReplaceAlert{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method presentM = class_getInstanceMethod(self.class, @selector(presentViewController:animated:completion:));
        Method presentSwizzlingM = class_getInstanceMethod(self.class, @selector(ox_presentViewController:animated:completion:));        // 交换方法实现
        method_exchangeImplementations(presentM, presentSwizzlingM);
        
    });
    
}

// 自己的替换展示弹出框的方法
- (void)ox_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    
    if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {        NSLog(@"title : %@",((UIAlertController *)viewControllerToPresent).title);
        NSLog(@"message : %@",((UIAlertController *)viewControllerToPresent).message);
        // 换图标时的提示框的title和message都是nil，由此可特殊处理
        UIAlertController *alertController = (UIAlertController*)viewControllerToPresent;
        if (alertController.title == nil && alertController.message == nil) { // 是换图标的提示
            return;
        } else {
            // 其他提示还是正常处理
            [self ox_presentViewController:viewControllerToPresent animated:flag completion:completion];
            return;
        }
    }
    [self ox_presentViewController:viewControllerToPresent animated:flag completion:completion];
    
}


@end
