//
//  main.m
//  Demo_RWLock
//
//  Created by cxjwin on 2016/9/15.
//  Copyright © 2016年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

int main(int argc, const char * argv[]) {
  @autoreleasepool {
      // insert code here...
    __block pthread_rwlock_t rwlock;
    pthread_rwlock_init(&rwlock, NULL);

    __block size_t index = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_apply(1000, queue, ^(size_t idx) {
//      if (idx % 4 == 0) {
//        // write
//        pthread_rwlock_wrlock(&rwlock);
//        index = idx;
//        NSLog(@"W : %@, %ld", [NSThread currentThread], index);
//        pthread_rwlock_unlock(&rwlock);
//      } else {
//        // read
//        pthread_rwlock_rdlock(&rwlock);
//        NSLog(@"R : %@, %ld", [NSThread currentThread], index);
//        pthread_rwlock_unlock(&rwlock);
//      }
//    });

    for (NSInteger i = 0; i < 1000; ++i) {
      dispatch_async(queue, ^{
        if (i % 4 == 0) {
          // write
          pthread_rwlock_wrlock(&rwlock);
          index = i;
          NSLog(@"W : %@, %ld", [NSThread currentThread], index);
          pthread_rwlock_unlock(&rwlock);
        } else {
          // read
          pthread_rwlock_rdlock(&rwlock);
          NSLog(@"R : %@, %ld", [NSThread currentThread], index);
          pthread_rwlock_unlock(&rwlock);
        }
      });
    }

    sleep(1);
  }
    return 0;
}
