//
//  FindMinMaxOperation.h
//  Demo_Operation
//
//  Created by cxjwin on 3/31/15.
//  Copyright (c) 2015 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FindMinMaxOperation : NSOperation

@property (nonatomic, assign) NSUInteger min;
@property (nonatomic, assign) NSUInteger max;

- (instancetype)initWithNumbers:(NSArray *)numbers;

@end
