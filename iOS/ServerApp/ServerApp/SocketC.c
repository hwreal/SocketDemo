//
//  SocketC.c
//  ClientApp
//
//  Created by 黄威 on 2020/4/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#include "SocketC.h"


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


int bindAndListen(void){
    
    int socketListen = socket(AF_INET, SOCK_STREAM, 0);
    if (socketListen == -1)
    {
        printf("Failed creating socket\n");
        return -1;
    }
    
    // 地址
    struct sockaddr_in serv_addr;
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(SOCKET_PORT);
    
    
    int bindResult = bind(socketListen, (struct sockaddr *) &serv_addr, sizeof(serv_addr));
    if (bindResult == -1)
    {
        printf("Failed binding\n");
        return -1;
    }
    else
    {
        printf("Successful binding\n");
    }
    
    
    int listenResult = listen(socketListen,5);
    if (listenResult == -1)
    {
        printf("Failed listen\n");
        return -1;
    }
    else
    {
        printf("Successful listen\n");
    }
    
    return socketListen;
}

int acceptSocket(int socketListen){
    struct sockaddr_in cli_addr;
    socklen_t clilen;
    char buffer[TRANSFER_SIZE];
    bzero(buffer, sizeof(buffer));
    
    int socketConnect = accept(socketListen, (struct sockaddr *) &cli_addr, &clilen);
    //printf("收到请求客户端连接请求,创建socket 连接, socketConnect:%d \n",socketConnect);
    return socketConnect;
}


int sendMsg(int sockfd, const void *msg){
    ssize_t sRet = send(sockfd, msg, strlen(msg), 0);
    return (int)sRet;
}

char msgBuffer[2048];
char * recvMsg(int sockfd){
    bzero(msgBuffer, sizeof(msgBuffer));
    ssize_t ret = recv(sockfd, msgBuffer, sizeof(msgBuffer), 0);
    printf("*** s  :%d\n",ret);
    if (ret == -1 || ret == 0) {
        printf("recv 函数报错(-1)\n");
        bzero(msgBuffer, sizeof(msgBuffer));
        strcpy(msgBuffer, "recvError-1");
        
    }
    return msgBuffer;
}

int closeSocket(int sockfd){
    return close(sockfd);
}
