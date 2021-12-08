import Foundation
import AsyncBlock

// Create a series of operations which are run with a delay and
// no locking mechanism so that threads are not blocked. There
// is also a max of 3 for concurrent operations which will be
// observable due to the delay. When each operation finishes
// another can be started. It acts like back pressure by
// restricting the number of active operations.

let queue = OperationQueue()
queue.maxConcurrentOperationCount = 3

func delay(competionHandler: @escaping () -> Void) {
    let sec = Double.random(in: 0.75..<1.5)
    DispatchQueue.global().asyncAfter(deadline: .now() + sec) {
        competionHandler()
    }
}

func createOperation(number: Int) -> AsyncBlockOperation {
    AsyncBlockOperation { done in
        print("Start (\(number))")
        delay {
            done()
            print("End (\(number))")
        }
    }
}

for number in (1...10) {
    queue.addOperation(createOperation(number: number))
}
for number in (11...20) {
    queue.addOperation(createOperation(number: number))
}

queue.waitUntilAllOperationsAreFinished()
print("All done")
