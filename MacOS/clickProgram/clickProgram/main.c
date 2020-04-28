//
//  main.c
//  send
//
//  Created by 黄威 on 15/1/27.
//  Copyright (c) 2015年 killerpoio. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <pthread.h>
#include <arpa/inet.h>


#define SOCKET_PORT 50001
#define TRANSFER_SIZE 2048


int main(int argc, char** argv)
{
    ///
    
    /** 创建一个socket
     函数原型:int socket(int family, int type, int protocol)
     摘要:
     
     @param family AF_INET 是IPv4协议,AF_INET6是IPv6协议;
     @param type SOCK_STREAM是字节流套接字(TCP/IP),SOCK_DGRAM是数据包套接字(UDP), SOCK_RAW是原始套接字;
     @param protocol IPPROTO_TCP是TCP传输协议, IPPROTO_UDP是UDP传输协议,0表示缺省;
     @return 若成功则为非负描述符，若出错则为-1
     */
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd == -1)
    {
        printf("ERROR opening socket");
        return 0;
    }
    
    
    printf("请输入对方IP:");
    char addrIP[4*3 + 3];
    scanf("%s",addrIP);
    
    // 地址
    struct sockaddr_in serv_addr;
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr(addrIP);//inet_ntoa
    serv_addr.sin_port = htons(SOCKET_PORT);
    
    /** 连接
     函数原型:int connect(int socket, const struct sockaddr *address, socklen_t address_len);
     头文件:#include <sys/types.h> #include <sys/socket.h>
     摘要:connect()用来将参数sockfd 的socket 连至参数serv_addr 指定的网络地址. 结构sockaddr请参考bind(). 参数addrlen 为sockaddr 的结构长度.
     　　返回值：成功则返回0, 失败返回-1, 错误原因存于errno 中.
     
     @param socket
     @param address
     @param address_len
     @return 成功则返回0, 失败返回-1, 错误原因存于errno 中
     */
    int connectResult = connect(sockfd,(struct sockaddr *)&serv_addr,sizeof(serv_addr));
    if (connectResult == -1) {
        printf("ERROR connecting");
        return 0;
    }
    
    while (1) {
        printf("请输入要发送的消息:");
        
        char ss[100];
        scanf("%s",ss);
        
        char *message = "hello";
        ssize_t sRet = send(sockfd, ss, sizeof(ss), 0);
        printf("消息发送成功:  大小%d\n",sRet);
    }
    
    close(sockfd);
    return 0;
}
