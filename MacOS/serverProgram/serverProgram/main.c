//
//  main.c
//  sever
//
//  Created by 黄威 on 15/1/27.
//  Copyright (c) 2015年 killerpoio. All rights reserved.
//


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>
#include <pthread.h>
#include <arpa/inet.h>


#define SOCKET_PORT 50001
#define TRANSFER_SIZE 2048

int main(int argc, char** argv)
{
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
        printf("Failed creating socket\n");
        return 0;
    }
    
    // 地址
    struct sockaddr_in serv_addr;
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(SOCKET_PORT);
    
    /** 绑定socket和地址
     函数原型:int bind(int socket, const struct sockaddr *address, socklen_t address_len);
     摘要 :在套接口中，一个套接字只是用户程序与内核交互信息的枢纽，它自身没有太多的信息，也没有网络协议地址和端口号等信息，在进行网络通信的时候，必须把一个套接字与一个地址相关联，这个过程就是地址绑定的过程。许多时候内核会我们自动绑定一个地址，然而有时用户可能需要自己来完成这个绑定的过程，以满足实际应用的需要，最典型的情况是一个服务器进程需要绑定一个众所周知的地址或端口以等待客户来连接。这个事由 bind的函数完成。  从bind函数功能我们很容易推测出这个函数的需要的参数与相应的返回值，如果此时大家已经对socket接口有点熟悉了： #include<sys/socket.h>  intbind( int sockfd, struct sockaddr* addr, socklen_t addrlen) 返回：0 ──成功， - 1 ──失败 参数sockfd  指定地址与哪个套接字绑定，这是一个由之前的socket函数调用返回的套接字。调用bind的函数之后，该套接字与一个相应的地址关联，发送到这个地址的数据可以通过这个套接字来读取与使用。 参数addr  指定地址。这是一个地址结构，并且是一个已经经过填写的有效的地址结构。调用bind之后这个地址与参数sockfd指定的套接字关联，从而实现上面所说的效果。 参数addrlen  正如大多数socket接口一样，内核不关心地址结构，当它复制或传递地址给驱动的时候，它依据这个值来确定需要复制多少数据。这已经成为socket接口中最常见的参数之一了。  bind函数并不是总是需要调用的，只有用户进程想与一个具体的地址或端口相关联的时候才需要调用这个函数。如果用户进程没有这个需要，那么程序可以依赖内核的自动的选址机制来完成自动地址选择，而不需要调用bind的函数，同时也避免不必要的复杂度。在一般情况下，对于服务器进程问题需要调用 bind函数，对于客户进程则不需要调用bind函数。
     
     @param socket 指定地址与哪个套接字绑定，这是一个由之前的socket函数调用返回的套接字;
     @param address 地址;
     @param address_len 地址长度;
     @return 0表示成功， -1表示失败;
     
     */
    int bindResult = bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr));
    if (bindResult == -1)
    {
        printf("Failed binding\n");
        return 0;
    }
    else
    {
        printf("Successful binding\n");
    }
    
    /** 监听
     函数原型:int listen(int socket, int backlog);
     头文件:#include<sys/socket.h>
     摘要:listen函数使用主动连接套接口变为被连接套接口，使得一个进程可以接受其它进程的请求，从而成为一个服务器进程。在TCP服务器编程中listen函数把进程变为一个服务器，并指定相应的套接字变为被动连接。当调用listen之后，服务器进程就可以调用accept来接受一个外来的请求。
     
     @param socket sockfd被listen函数作用的套接字，sockfd之前由socket函数返回。在被socket函数返回的套接字fd之时，它是一个主动连接的套接字，也就是此时系统假设用户会对这个套接字调用connect函数，期待它主动与其它进程连接，然后在服务器编程中，用户希望这个套接字可以接受外来的连接请求，也就是被动等待用户来连接。由于系统默认时认为一个套接字是主动连接的，所以需要通过某种方式来告诉系统，用户进程通过系统调用listen来完成这件事;
     @param backlog 这个参数涉及到一些网络的细节。在进程正理一个一个连接请求的时候，可能还存在其它的连接请求。因为TCP连接是一个过程，所以可能存在一种半连接的状态，有时由于同时尝试连接的用户过多，使得服务器进程无法快速地完成连接请求。如果这个情况出现了，服务器进程希望内核如何处理呢？内核会在自己的进程空间里维护一个队列以跟踪这些完成的连接但服务器进程还没有接手处理或正在进行的连接，这样的一个队列内核不可能让其任意大，所以必须有一个大小的上限。这个backlog告诉内核使用这个数值作为上限。毫无疑问，服务器进程不能随便指定一个数值，内核有一个许可的范围。这个范围是实现相关的。很难有某种统一，一般这个值会小30以内;
     @return 0表示成功, -1表示失败;
     */
    int listenResult = listen(sockfd,5);
    if (listenResult == -1)
    {
        printf("Failed listen\n");
        return 0;
    }
    else
    {
        printf("Successful listen\n");
    }
    
    struct sockaddr_in cli_addr;
    socklen_t clilen;
    char buffer[TRANSFER_SIZE];
    
    //    while (1) {
    //        printf("aaaaa\n");
    //
    //    }
    
    while (1)
    {
        
        printf("开始监听....\n");
        
        bzero(buffer, sizeof(buffer));
        /**
         函数原型:int accept(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len);
         头文件:#include <sys/socket.h>  #include <sys/types.h>
         摘要:服务程序调用accept函数从处于监听状态的流套接字s的客户连接请求队列中取出排在最前的一个客户请求，并且创建一个新的套接字来与客户套接字创建连接通道，如果连接成功，就返回新创建的套接字的描述符，以后与客户套接字交换数据的是新创建的套接字；如果失败就返回 INVALID_SOCKET。该函数的第一个参数指定处于监听状态的流套接字；操作系统利用第二个参数来返回所连接的客户进程的协议地址（由addr指针所指）；操作系统利用第三个参数来返回该地址（参数二）的大小。如果我们对客户协议地址不感兴趣，那么可以把addr和addrlen均置为空指针NULL;
         
         @param socket 监听的套接字描述符;
         @param address 指向结构体sockaddr的指针(包含客户套接字信息);
         @param address_len address参数指向的内存空间的长度;
         
         @return 成功返回新套接字描述符,失败返回错误信息如下:
         EAGAIN：套接字处于非阻塞状态，当前没有连接请求。
         EBADF：非法的文件描述符。
         ECONNABORTED：连接中断。
         EINTR：系统调用被信号中断。
         EINVAL：套接字没有处于监听状态，或非法的addrlen参数。
         EMFILE：达到进程打开文件描述符限制。
         ENFILE：达到打开文件数限制。
         ENOTSOCK：文件描述符为文件的文件描述符。
         EOPNOTSUPP：套接字类型不是SOCK_STREAM.
         */
        
        int newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, &clilen);
        printf("收到请求 newsockfd:%d \n",newsockfd);
        
        
        int f = 0;
        while (1) {
            recv(newsockfd, buffer, sizeof(buffer), 0);
            struct in_addr addr;
            addr.s_addr = cli_addr.sin_addr.s_addr;
            printf("收到信息:%s 来自:%s\n",buffer,inet_ntoa(addr));
            
            char *msg = "I am server";
            
            f ++;
            
            char str[255];
            sprintf(str, "%d", f); //将100转为16进制表示的字符串。


            
            send(newsockfd, str, sizeof(str), 0);
        
        }
        
        
    }
    
    return 0;
}

