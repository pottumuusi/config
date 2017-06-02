#include <jni.h>
#include <stdio.h>
#include "HelloExample.h"

JNIEXPORT void JNICALL Java_HelloExample_helloPrint(JNIEnv *env, jobject obj) {
    printf("Hello, world!\n");
    return;
}
