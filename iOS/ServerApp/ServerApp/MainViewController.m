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

@property (weak, nonatomic) IBOutlet UIButton *listenButton;

@property (weak, nonatomic) IBOutlet UITextField *msgTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UILabel *recvMsgLabel;
@property(nonatomic, assign) int socketListen;
@property NSMutableArray* socketConnectArr;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务端";
    self.socketListen = bindAndListen();
    NSLog(@"*** viewDidLoad 服务端创建并监听socket:%d",self.socketListen);
    
    self.socketConnectArr = [[NSMutableArray alloc] initWithCapacity:10];
    [self.socketConnectArr removeAllObjects];
    
}

- (IBAction)listen:(UIButton *)sender {
    [self monClientConnect];
}

/// 监听客户端连接
- (void)monClientConnect{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(globalQueue, ^{
        
        while (YES) {
            NSLog(@"*** 服务端开始等待客户端的连接 monClientConnect, 线程:%@",[NSThread currentThread]);
            int socketConnect = acceptSocket(self.socketListen);
            if (socketConnect == -1) {
                NSLog(@"监听出错");
                return;
            }
            
            NSLog(@"*** 服务端接受客户端连接,创建一个Socket: %d\n\n",socketConnect);
            NSNumber *sfd = [[NSNumber alloc] initWithInt:socketConnect];
            
            [self.socketConnectArr addObject:sfd];
            
            [self monClientMsg:socketConnect];
            
            //            if ([msgStr isEqualToString:@"recvError-1"]) {
            //                // 回到主线程
            //                dispatch_async(mainQueue, ^{
            //                    _statusLabel.text = @"收信息错误";
            //                });
            //                break;
            //            }
            //            // 回到主线程
            //            dispatch_async(mainQueue, ^{
            //                _statusLabel.text = @"收到客户端信息";
            //                _recvMsgLabel.text = msgStr;
            //            });
        }
    });
}


/// 监听客户端信息
- (void)monClientMsg: (int) socketConnect {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(globalQueue, ^{
        
        while (YES) {
            NSLog(@"*** 服务端开始监听客户端信息 socketConnect: %d",socketConnect);
            char *msg = recvMsg(socketConnect);
            NSLog(@"*** 收到客户端的信息 socketConnect: %d, %s\n\n",socketConnect,msg);
            NSString *msgStr = [[NSString alloc]initWithUTF8String:msg];
            if ([msgStr isEqualToString:@"recvError-1"]) {
                // 回到主线程
                dispatch_async(mainQueue, ^{
                    _statusLabel.text = [NSString stringWithFormat:@"收信息错误,断开连接:%d",socketConnect];
                });
                
                NSNumber *sfd = [[NSNumber alloc] initWithInt:socketConnect];
                [self.socketConnectArr removeObject:sfd];

                
                break;
            }
            // 回到主线程
            dispatch_async(mainQueue, ^{
                _statusLabel.text =  [NSString stringWithFormat:@"收到客户端信息,id: %d",socketConnect]; // @"收到客户端信息";
                _recvMsgLabel.text = [NSString stringWithFormat:@"id(%d): %@, ",socketConnect,msgStr];
            });
        }
    });
}

- (IBAction)sendMsg:(UIButton *)sender {
    NSString *msgStr = self.msgTextField.text;
    NSLog(@"向客户端发送信息:%@\n",msgStr);
    
    const void *msgCStr = (const void *)msgStr.UTF8String;
    
    for (NSNumber * socketID in self.socketConnectArr) {
        int sid = socketID.intValue;
        sendMsg(sid, msgCStr);
    }
}


- (IBAction)closeS:(UIButton *)sender {
    for (NSNumber * socketID in self.socketConnectArr) {
        int sid = socketID.intValue;
        closeSocket(sid);
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
