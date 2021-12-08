# Async Block

Running a lot of asynchronous operations concurrently can lead to [Thread Explosion] and often result in a crash. It is best to limit the number of active operations so that a concurrent queue does not cause extra threads to be created when other threads are waiting. Using an [OperationQueue] with [maxConcurrentOperationCount] will limit the number of operations. Apple's [BlockOperation] does not run asynchronously while this implementation does and has [isAsynchronous] set to true. 

## Operation Queues

Apple has included [OperationQueue] since iOS 2.0 when the SDK first became available to developers. It predates [Dispatch] which was included with iOS 4.0 as Grand Central Dispatch. It added many more features for concurrency to replace classic thread programming techniques with the goal of adaption code written for the platform so that at runtime queues could handle work across the multiple cores that Apple started to increase in count over the next few years from 2 cores to many more. There are still many advantages of using an [Operation] with an [OperationQueue]. A key advantage is setting [maxConcurrentOperationCount] to limit the number of concurrent tasks. With Dispatch either work is run with serial behavior, one at a time, or concurrent with no limit.

An `Operation` can have dependencies which are other operations. A series of operations could be set up however is necessary to support the work being done and run it on an `OperationQueue` with the max value set.

## Combine

Apple introduced [Combine] with iOS 13.0 and all of the other Apple platforms. It supports Publishers and Subscribers which can control the amount of work being done dynamically with a technique known as [back pressure]. Instead of having a fixed limit the `Demand` can change as processing is running.

## State Transitions

Running async operations will require managing state transitions. Operations have 4 states: ready, executing, finished and cancelled. Changes to state are reported with [KVO] which is a very efficient mechanism. [Asynchronous Versus Synchronous Operations] covers how those state transitions are handled.

> If you execute operations manually, though, you might want to define your operation objects as asynchronous. Defining an asynchronous operation requires more work, because you have to monitor the ongoing state of your task and report changes in that state using KVO notifications. But defining asynchronous operations is useful in cases where you want to ensure that a manually executed operation does not block the calling thread.

In this code the KVO changes are handled with the `transition(to:)` function while a closure can be provided which will be given a `done` closure. Once the async work is done that closure should be used. It will trigger the state transition to `.finished` so the [OperationQueue] knows that operation is done and can can start another operation. Besides limiting the number of concurrent operations, this mechanism also allows operations to be added to the queue at any time.

Every state transition involves 2 states which are represented by computed properties. When an operation starts both `isReady` and `isExecuting` change. Later when the `done()` closure is called `isExecuting` and `isFinished` change and so the `transition(to:)` function calls `willChangeValue` and `didChangeValue` for the `newState` and `state`. The OperationQueue can observe these changes and react immediately as KVO is very efficient.

## Start and Main Functions

For an async operation only the `start` function is overridden while `main` is not as the documentation states it should be. The async work will be started in the `start` function and when it completed the state will transition to finished.

## Cancellation

Just like the [cancel function] on [DispatchWorkItem], calling the `cancel` function on the operation will not stop an operation once it has started. It will prevent a queued operation from starting if it was cancelled before it started.

> Cancellation causes future attempts to execute the work item to return immediately. Cancellation does not affect the execution of a work item that has already begun.

[Thread Explosion]: https://developer.apple.com/videos/play/wwdc2015/718/?time=1509
[KVO]: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html
[OperationQueue]: https://developer.apple.com/documentation/foundation/operationqueue
[Dispatch]: https://developer.apple.com/documentation/dispatch
[Operation]: https://developer.apple.com/documentation/foundation/operation
[BlockOperation]: https://developer.apple.com/documentation/foundation/blockoperation
[maxConcurrentOperationCount]: https://developer.apple.com/documentation/foundation/operationqueue/1414982-maxconcurrentoperationcount
[isAsynchronous]: https://developer.apple.com/documentation/foundation/operation/1408275-isasynchronous
[Asynchronous Versus Synchronous Operations]: https://developer.apple.com/documentation/foundation/operation#1661231
[cancel function]: https://developer.apple.com/documentation/dispatch/dispatchworkitem/1780910-cancel
[DispatchWorkItem]: https://developer.apple.com/documentation/dispatch/dispatchworkitem
[Combine]: https://developer.apple.com/documentation/combine
[back pressure]: https://developer.apple.com/documentation/combine/processing-published-elements-with-subscribers
