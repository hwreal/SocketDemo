//
//  main.m
//  ClientApp
//
//  Created by 黄威 on 2020/4/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "fishhook.h"

#import "SocketC.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


int my_connect(int fd, const struct sockaddr * serv_addr, socklen_t serv_addr_size);
int my_connect(int fd, const struct sockaddr * serv_addr, socklen_t serv_addr_size){
    printf("\nhook connect!!!!\n");
    printf("ori fd: %d\n",fd);
    struct sockaddr_in *serv_addr_in = (struct sockaddr_in *)serv_addr;
    short portH =  ntohs(serv_addr_in->sin_port);
    printf("ori portH:%d\n",portH);
    char *ipStr = inet_ntoa(serv_addr_in->sin_addr);
    printf("ori ipStrH: %s\n",ipStr);
    
    
    // 首先用原来fd连接 SOCKS服务器
    struct sockaddr_in socks_serv_addr;
    bzero((char *) &socks_serv_addr, sizeof(socks_serv_addr));
    socks_serv_addr.sin_family = AF_INET;
    socks_serv_addr.sin_addr.s_addr = inet_addr("192.168.7.174");//inet_ntoa
    socks_serv_addr.sin_port = htons(8023);
    
    int connectResult = orig_connect(fd,(struct sockaddr *)&socks_serv_addr,sizeof(socks_serv_addr));
    if (connectResult == -1) {
        printf("ERROR connecting");
        return connectResult;
    }
    sleep(0.2);
    
    // 鉴权
    unsigned char buf_1[3];
    buf_1[0] = 5;
    buf_1[1] = 1;
    buf_1[2] = 0;
    write(fd, buf_1, 3);
    sleep(0.2);
    
    // socks服务器连接目标地址
    unsigned char buf_2[10] = { 5, 1, 0, 1 /*AT_IPV4*/, 192,168,7,173, 0,80 };
    buf_2[4] = serv_addr->sa_data[2];
    buf_2[5] = serv_addr->sa_data[3];
    buf_2[6] = serv_addr->sa_data[4];
    buf_2[7] = serv_addr->sa_data[5];
    
    buf_2[8] = serv_addr->sa_data[0];
    buf_2[9] = serv_addr->sa_data[1];
    
    write(fd, buf_2, 10);
    sleep(0.2);
    
    return 0;
}

int main(int argc, char * argv[]) {
    
    rebind_symbols((struct rebinding[1]){{"connect", my_connect, (void*)&orig_connect}},1);
    
    // hook connect
    
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

