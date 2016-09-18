//
//  FindMinMaxThread.h
//  Demo_NSThread
//
//  Created by cxjwin on 3/29/15.
//  Copyright (c) 2015 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FindMinMaxThread : NSThread

@property (nonatomic, assign) NSUInteger min;
@property (nonatomic, assign) NSUInteger max;

- (instancetype)initWithNumbers:(NSArray *)numbers;

@end
