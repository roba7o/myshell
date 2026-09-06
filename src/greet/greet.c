#include <stdio.h>
#include "greet.h"

char name[100];

void say_hello(void)
{
    printf("Enter your name");
    scanf("%s", name);

    printf("hello %s\n", name);
}
