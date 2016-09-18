//
//  main.m
//  Demo_GCD
//
//  Created by cxjwin on 3/31/15.
//  Copyright (c) 2015 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSInteger const count = 1000000;
        NSUInteger inputValues[count];
        
        for (NSInteger i = 0; i < count; ++i) {
            inputValues[i] = arc4random();
        }
        
        NSInteger const threadCount = 4;
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        __block NSUInteger *minNums = malloc(sizeof(NSUInteger) * threadCount);
        __block NSUInteger *maxNums = malloc(sizeof(NSUInteger) * threadCount);

        NSUInteger *pInput = &inputValues[0];
        for (NSUInteger i = 0; i < threadCount; ++i) {
            dispatch_group_async(group, queue, ^{
                NSLog(@"%@", [NSThread currentThread]);

                NSInteger offset = (count / threadCount) * i;
                NSUInteger *values = pInput + offset;
                NSInteger valuesCount = MIN(count - offset, count / threadCount);
                
                NSUInteger min = NSUIntegerMax;
                NSUInteger max = 0;
                for (NSInteger j = 0; j < valuesCount; ++j) {
                    NSUInteger v = values[j];
                    min = MIN(min, v);
                    max = MAX(max, v);
                }
                minNums[i] = min;
                maxNums[i] = max;
            });
        }
        
        dispatch_group_notify(group, queue, ^{
            NSUInteger min = NSUIntegerMax;
            NSUInteger max = 0;
            for (NSUInteger i = 0; i < threadCount; ++i) {
                NSLog(@"min num[%lu] = %lu", (unsigned long)i, (unsigned long)minNums[i]);
                NSLog(@"max num[%lu] = %lu", (unsigned long)i, (unsigned long)maxNums[i]);
                min = MIN(min, minNums[i]);
                max = MAX(max, maxNums[i]);
            }
            NSLog(@"min : %lu", (unsigned long)min);
            NSLog(@"max : %lu", (unsigned long)max);
            
            free(minNums);
            free(maxNums);
        });
        
        // 为了暂缓释放group 和 queue
        sleep(1);
    }
    return 0;
}
