#include <stdio.h>

void say_hello(void);

int main(void)
{

    say_hello();

    return 0;
}

void say_hello(void)
{
    char name[100];
    printf("Enter your name");
    scanf("%s", name);

    printf("hello %s\n", name);
}
