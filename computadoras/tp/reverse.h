#ifndef REVERSE_H
#define REVERSE_H

#include <stdio.h>
#include "sys_mmap/mymalloc.h"

extern const char* errores[];

int reverse(int infd, int outfd);

char* lineaLeer(int fd,int* length);

#endif
