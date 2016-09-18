//
//  main.m
//  Demo_Operation
//
//  Created by cxjwin on 3/31/15.
//  Copyright (c) 2015 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FindMinMaxOperation.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSUInteger const count = 1000000;
        
        NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:count];
        // 使用随机数字填充 inputValues
        for (NSUInteger i = 0; i < count; ++i) {
            numbers[i] = @(arc4random());
        }
        
        NSMutableArray *ops = [NSMutableArray array];
        NSUInteger numberCount = numbers.count;
        NSUInteger threadCount = 4;
        for (NSUInteger i = 0; i < threadCount; i++) {
            NSUInteger offset = (count / threadCount) * i;
            NSUInteger count = MIN(numberCount - offset, numberCount / threadCount);
            NSRange range = NSMakeRange(offset, count);
            NSArray *subset = [numbers subarrayWithRange:range];
            FindMinMaxOperation *op = [[FindMinMaxOperation alloc] initWithNumbers:subset];
            [ops addObject:op];
        }
        
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue addOperations:ops waitUntilFinished:YES];
        
        NSUInteger min = NSUIntegerMax;
        NSUInteger max = 0;
        for (NSUInteger i = 0; i < threadCount; ++i) {
            min = MIN(min, [ops[i] min]);
            max = MAX(max, [ops[i] max]);
        }
        
        NSLog(@"min : %lu", (unsigned long)min);
        NSLog(@"max : %lu", (unsigned long)max);
    }
    return 0;
}
