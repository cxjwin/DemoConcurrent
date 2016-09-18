//
//  main.m
//  Demo_Pthread
//
//  Created by cxjwin on 3/29/15.
//  Copyright (c) 2015 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

struct threadInfo {
    uint32_t *inputValues;
    size_t count;
};

struct threadResult {
    uint32_t min;
    uint32_t max;
};

void *findMinAndMax(void *arg) {
    NSLog(@"%@", [NSThread currentThread]);
    struct threadInfo const * const info = (struct threadInfo *) arg;
    
    uint32_t min = UINT32_MAX;
    uint32_t max = 0;
    for (size_t i = 0; i < info->count; ++i) {
        uint32_t v = info->inputValues[i];
        min = MIN(min, v);
        max = MAX(max, v);
    }
    
    free(arg);
    
    struct threadResult * const result = (struct threadResult *) malloc(sizeof(*result));
    result->min = min;
    result->max = max;
    
    return result;
}

int main(int argc, const char * argv[]) {
    size_t const count = 1000000;
    uint32_t inputValues[count];
    
    // 使用随机数字填充 inputValues
    for (size_t i = 0; i < count; ++i) {
        inputValues[i] = arc4random();
    }
    
    // 开始4个寻找最小值和最大值的线程
    size_t const threadCount = 4;
    pthread_t tid[threadCount];
    for (size_t i = 0; i < threadCount; ++i) {
        struct threadInfo * const info = (struct threadInfo *) malloc(sizeof(*info));
        size_t offset = (count / threadCount) * i;
        info->inputValues = inputValues + offset;
        info->count = MIN(count - offset, count / threadCount);
        int err = pthread_create(tid + i, NULL, &findMinAndMax, info);
        NSCAssert(err == 0, @"pthread_create() failed: %d", err);
    }
    
    // 等待线程退出
    struct threadResult * results[threadCount];
    for (size_t i = 0; i < threadCount; ++i) {
        int err = pthread_join(tid[i], (void **) &(results[i]));
        NSCAssert(err == 0, @"pthread_join() failed: %d", err);
    }
    
    // 因为四个线程分别有各自的最大最小值, 所以需要在比较一次
    // 寻找 min 和 max
    uint32_t min = UINT32_MAX;
    uint32_t max = 0;
    for (size_t i = 0; i < threadCount; ++i) {
        min = MIN(min, results[i]->min);
        max = MAX(max, results[i]->max);
        free(results[i]);
        results[i] = NULL;
    }
    
    fprintf(stdout, "min = %u \n", min);
    fprintf(stdout, "max = %u \n", max);
    
    return 0;
}

