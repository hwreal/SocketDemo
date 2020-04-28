//
//  MainViewController.m
//  ClientApp
//
//  Created by 黄威 on 2020/4/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "MainViewController.h"
#include "SocketC.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@property (weak, nonatomic) IBOutlet UITextField *msgTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UILabel *recvMsgLabel;
@property(nonatomic, assign) int socketId1;
@property(nonatomic, assign) int socketId2;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"客户端";
    
}

- (IBAction)connect:(UIButton *)sender {

    self.statusLabel.text = @"开始连接服务器";
    [self connectServer];
}

/**
 * 连接服务器
 */
- (void)connectServer {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    NSString *ipStr = self.ipTextField.text;

    dispatch_async(globalQueue, ^{
        NSLog(@"1--- 连接服务器 connectServer: %@",[NSThread currentThread]);
        
        const char *ipCStr = ipStr.UTF8String;
        self.socketId1 = connet(ipCStr);
        
        dispatch_async(mainQueue, ^{
            
            if (self.socketId1 == -1) {
                printf("链接失败");
                self.statusLabel.text = @"链接服务器失败";

            }else{
                printf("链接成功,socketID:%d\n",self.socketId1);
                self.statusLabel.text = @"链接服务器成功";
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [self monServerMsg];
                });
                //[self monServerMsg];
                
            }
            printf("\n");
            
        });
        
    });
}



/**
 * 监听服务端的信息
 */
- (void)monServerMsg {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(globalQueue, ^{
     
        
        while (YES) {
            NSLog(@"2---开始监听服务器 monServerMsg%@",[NSThread currentThread]);
                 printf("\n");
            char *msg = recvMsg(self.socketId1);
            printf("收到服务器的信息:%s\n\n",msg);
            NSString *msgStr = [[NSString alloc]initWithUTF8String:msg];
            if ([msgStr isEqualToString:@"recvError-1"]) {
                // 回到主线程
                dispatch_async(mainQueue, ^{
                    _statusLabel.text = @"收信息错误";
                });
                break;
            }
            // 回到主线程
            dispatch_async(mainQueue, ^{
                _statusLabel.text = @"收到服务端信息";
                _recvMsgLabel.text = msgStr;
            });
        }
    });
}

- (IBAction)sendMsg:(UIButton *)sender {
    NSURLSessionStreamTask *st = nil;
    
    NSString *msgStr = self.msgTextField.text;
    NSLog(@"向服务端发送信息:%@\n",msgStr);

    const void *msgCStr = (const void *)msgStr.UTF8String;
    sendMsg(self.socketId1, msgCStr);
    self.msgTextField.text = nil;
    
}

- (IBAction)closeS:(UIButton *)sender {
    closeSocket(self.socketId1);
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
