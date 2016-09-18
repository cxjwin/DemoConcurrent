//
//  FindMinMaxThread.m
//  Demo_NSThread
//
//  Created by cxjwin on 3/29/15.
//  Copyright (c) 2015 cxjwin. All rights reserved.
//

#import "FindMinMaxThread.h"

@implementation FindMinMaxThread {
    NSArray *_numbers;
}

- (instancetype)initWithNumbers:(NSArray *)numbers {
    self = [super init];
    if (self) {
        _numbers = [numbers copy];
    }
    return self;
}

- (void)main {
    NSLog(@"%@", [NSThread currentThread]);
    
    __block NSUInteger min = NSUIntegerMax;
    __block NSUInteger max = 0;
    
    // 进行相关数据的处理
    [_numbers enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger idx, BOOL *stop) {
        NSUInteger number = num.unsignedIntegerValue;
        min = MIN(min, number);
        max = MAX(max, number);
    }];
    
    self.min = min;
    self.max = max;
}

@end
