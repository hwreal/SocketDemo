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

extern int (* orig_connect)(int fd, const struct sockaddr *, socklen_t);

int createAndConnetSocket2(const char * addrIP, int port);
int createAndConnetSocket(const char * addrIP, int port);

int sendMsg(int sockfd, const void *msg);
char * recvMsg(int sockfd);
int closeSocket(int sockfd);



#endif /* SocketC_h */
