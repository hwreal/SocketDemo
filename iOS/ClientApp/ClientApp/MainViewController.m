//
//  MainViewController.m
//  ClientApp
//
//  Created by 黄威 on 2020/4/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "MainViewController.h"
#include "SocketC.h"
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>



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
        NSLog(@"1--- 客户端连接服务器 connectServer: %@",[NSThread currentThread]);
        
        const char *ipCStr = ipStr.UTF8String;
        self.socketId1 = createAndConnetSocket(ipCStr, 50001);
        
        dispatch_async(mainQueue, ^{
            
            if (self.socketId1 == -1) {
                printf("链接失败");
                self.statusLabel.text = @"链接服务器失败";
                
            }else{
                printf("链接成功,socketID:%d\n",self.socketId1);
                self.statusLabel.text = @"链接服务器成功";
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
                closeSocket(self.socketId1);
                break;
            }
            // 回到主线程
            dispatch_async(mainQueue, ^{
                _statusLabel.text = @"收到服务端信息";
                if (msgStr.length > 3) {
                    _recvMsgLabel.text = msgStr;
                    
                }
            });
        }
    });
}

- (IBAction)sendMsg:(UIButton *)sender {
    
    /*
     NSURLSessionStreamTask *st = nil;
     
     NSString *msgStr = self.msgTextField.text;
     NSLog(@"向服务端发送信息:%@\n",msgStr);
     
     const void *msgCStr = (const void *)msgStr.UTF8String;
     sendMsg(self.socketId1, msgCStr);
     self.msgTextField.text = nil;
     */
    
    // 向HTTP服务器发送GET请求
    char buffer[200];
    bzero(buffer, sizeof(buffer));
    sprintf(buffer,"GET / HTTP/1.0\r\nHost: 192.168.7.173\r\nAccept: */*\r\nConnection: keep-alive\r\n\r\n");
    //printf("%s",buffer);
    //    self.msgTextField.text
    sendMsg(self.socketId1, buffer);
    printf("\n开始发送消息 fd:%d",self.socketId1);
    
    
    
    //sendMsg(4, buffer);
    
    
}


- (IBAction)sessionHTTP:(UIButton *)sender {
    
    [self getIPAddr];
    //    [self getHostByName];
    
    return;
    
    NSString *url1 = @"http://192.168.7.173?a=aaa";
    NSString *url2 = @"http://www.jandan.net";
    NSString *url3 = @"http://www.haha.net";
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:[NSURL URLWithString:url3] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"sessionHTTP error:%@",error);
        }else{
            NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"sessionHTTP resStr:%@",resStr);
        }
    }];
    [dataTask resume];
    
}

- (void)getHostByName{
    
//    gethostname(<#char *#>, <#size_t#>)
//
//    gethostbyname2(<#const char *#>, <#int#>)
    
    struct hostent * phost = gethostbyname("www.163.com");
    
    if (NULL == phost)
    {
        printf("error");
        
    }
    
    int i = 0;
    char str[32] = {0};
    
    printf("---Offical name:\n\t%s\n", phost->h_name);
    
    printf("---Alias name:\n");
    for (i = 0;  phost->h_aliases[i]; i++)
    {
        printf("\t%s\n", phost->h_aliases[i]);
    }
    
    printf("---Address list:\n");
    for (i = 0; phost->h_addr_list[i]; i++)
    {
        printf("\t%s\n", inet_ntop(phost->h_addrtype,  phost->h_addr_list[i], str, sizeof(str)-1));
    }
}

- (void)getIPAddr{
    struct addrinfo hints, *res, *res0;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family   = PF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;
    hints.ai_protocol = IPPROTO_UDP;
    
    int gai_error = getaddrinfo("www.job.com", NULL, &hints, &res0);
    
    if (gai_error)
    {
        printf("获取失败");
        
    }
    else
    {
        for(res = res0; res; res = res->ai_next)
        {
            if (res->ai_family == AF_INET)
            {
                // Found IPv4 address
                // Wrap the native address structure and add to list
                
                //[addresses addObject:[NSData dataWithBytes:res->ai_addr length:res->ai_addrlen]];
                
                struct sockaddr_in *serv_addr_in = (struct sockaddr_in *)res->ai_addr;
                short portH =  ntohs(serv_addr_in->sin_port);
                char *ipStr = inet_ntoa(serv_addr_in->sin_addr);
                printf("返回结果: %s:(%d)\n",ipStr,portH);
                
            }
            else if (res->ai_family == AF_INET6)
            {
                
                // Fixes connection issues with IPv6, it is the same solution for udp socket.
                // https://github.com/robbiehanson/CocoaAsyncSocket/issues/429#issuecomment-222477158
                struct sockaddr_in6 *sockaddr = (struct sockaddr_in6 *)(void *)res->ai_addr;
                in_port_t *portPtr = &sockaddr->sin6_port;
                if ((portPtr != NULL) && (*portPtr == 0)) {
                    // *portPtr = htons(port);
                }
                
                // Found IPv6 address
                // Wrap the native address structure and add to list
                // [addresses addObject:[NSData dataWithBytes:res->ai_addr length:res->ai_addrlen]];
            }
        }
    }
    freeaddrinfo(res0);
}

- (IBAction)closeS:(UIButton *)sender {
    closeSocket(self.socketId1);
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
