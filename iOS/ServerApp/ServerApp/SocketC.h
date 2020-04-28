//
//  SocketC.h
//  ClientApp
//
//  Created by 黄威 on 2020/4/2.
//  Copyright © 2020 tencent. All rights reserved.
//

#ifndef SocketC_h
#define SocketC_h

#include <stdio.h>

int bindAndListen(void);
int acceptSocket(int socketListen);
int connet(const char * addrIP);
int sendMsg(int sockfd, const void *msg);
char * recvMsg(int sockfd);
int closeSocket(int sockfd);



#endif /* SocketC_h */
