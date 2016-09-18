//
//  main.m
//  Demo_Locks
//
//  Created by cxjwin on 4/1/15.
//  Copyright (c) 2015 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>
#import <pthread.h>

@import Darwin;

double JGTimeBlock (void (^block)(void)) {
  mach_timebase_info_data_t info;
  if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;

  uint64_t start = mach_absolute_time ();
  block ();
  uint64_t end = mach_absolute_time ();
  uint64_t elapsed = end - start;

  uint64_t nanos = elapsed * info.numer / info.denom;
  return (double)nanos / NSEC_PER_SEC;
}

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

    static const NSUInteger LOOPAGE = 1e6;
    static size_t const iterations = 10;

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    uint64_t deltaTime = dispatch_benchmark(iterations, ^{
      NSUInteger num = 0;
      for (NSUInteger i = 0; i < LOOPAGE; ++i) {
        ++num;
      }
    });
    dict[@"NoLock"] = @(deltaTime);

    deltaTime = dispatch_benchmark(iterations, ^{
      NSLock *lock = [[NSLock alloc] init];
      NSUInteger num = 0;
      for (NSUInteger i = 0; i < LOOPAGE; ++i) {
        [lock lock];
        ++num;
        [lock unlock];
      }
    });
    dict[@"NSLock"] = @(deltaTime);

    deltaTime = dispatch_benchmark(iterations, ^{
      NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
      NSUInteger num = 0;
      for (NSUInteger i = 0; i < LOOPAGE; ++i) {
        [lock lock];
        ++num;
        [lock unlock];
      }
    });
    dict[@"NSRecursiveLock"] = @(deltaTime);

    deltaTime = dispatch_benchmark(iterations, ^{
      NSCondition *lock = [[NSCondition alloc] init];
      NSUInteger num = 0;
      for (NSUInteger i = 0; i < LOOPAGE; ++i) {
        [lock lock];
        ++num;
        [lock unlock];
      }
    });
    dict[@"NSCondition"] = @(deltaTime);

    deltaTime = dispatch_benchmark(iterations, ^{
      NSConditionLock *lock = [[NSConditionLock alloc] init];
      NSUInteger num = 0;
      for (NSUInteger i = 0; i < LOOPAGE; ++i) {
        [lock lock];
        ++num;
        [lock unlock];
      }
    });
    dict[@"NSConditionLock"] = @(deltaTime);

    deltaTime = dispatch_benchmark(iterations, ^{
      pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
      NSUInteger num = 0;
      for (NSUInteger i = 0; i < LOOPAGE; ++i) {
        pthread_mutex_lock(&mutex);
        ++num;
        pthread_mutex_unlock(&mutex);
      }
    });
    dict[@"Mutex"] = @(deltaTime);

    __block pthread_rwlock_t rwlock;
    pthread_rwlock_init(&rwlock, NULL);
    deltaTime = dispatch_benchmark(iterations, ^{
      NSUInteger num = 0;
      NSUInteger i = 0;
      for (; i < LOOPAGE / 2; ++i) {
        pthread_rwlock_rdlock(&rwlock);
        ++num;
        pthread_rwlock_unlock(&rwlock);
      }
      for (; i < LOOPAGE; ++i) {
        pthread_rwlock_wrlock(&rwlock);
        ++num;
        pthread_rwlock_unlock(&rwlock);
      }
    });
    dict[@"RWLock"] = @(deltaTime);

    deltaTime = dispatch_benchmark(iterations, ^{
      OSSpinLock lock = OS_SPINLOCK_INIT;
      NSUInteger num = 0;
      for (NSUInteger i = 0; i < LOOPAGE; ++i) {
        OSSpinLockLock(&lock);
        ++num;
        OSSpinLockUnlock(&lock);
      }
    });
    dict[@"SpinLock"] = @(deltaTime);

    dispatch_semaphore_t dsema = dispatch_semaphore_create(1);
    deltaTime = dispatch_benchmark(iterations, ^{
      NSUInteger num = 0;
      for (NSUInteger i = 0; i < LOOPAGE; ++i) {
        dispatch_semaphore_wait(dsema, DISPATCH_TIME_FOREVER);
        ++num;
        dispatch_semaphore_signal(dsema);
      }
    });
    dict[@"Semaphore"] = @(deltaTime);

    deltaTime = dispatch_benchmark(iterations, ^{
      dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
      __block NSInteger num = 0;
      for (NSInteger i = 0; i < LOOPAGE; ++i) {
        dispatch_sync(queue, ^{
          ++num;
        });
      }
    });
    dict[@"GCD"] = @(deltaTime);

    deltaTime = dispatch_benchmark(iterations, ^{
      int64_t num = 0;
      for (NSUInteger i = 0; i < LOOPAGE; ++i) {
        OSAtomicIncrement64(&num);
      }
    });
    dict[@"Atomic"] = @(deltaTime);

    NSObject *dummy = [[NSObject alloc] init];
    deltaTime = dispatch_benchmark(iterations, ^{
      NSUInteger num = 0;
      for (NSUInteger i = 0; i < LOOPAGE; ++i) {
        @synchronized(dummy) {
          ++num;
        }
      }
    });
    dict[@"Synchronized"] = @(deltaTime);

    // 排序
    NSArray *array = [dict keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
      return [obj1 compare:obj2];
    }];

    // 输出
    [array enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
      NSLog(@"lock : %@, time : %@ ns, %f s", key, dict[key], [dict[key] longLongValue] * 1.0 / NSEC_PER_SEC);
    }];
  }
  return 0;
}
