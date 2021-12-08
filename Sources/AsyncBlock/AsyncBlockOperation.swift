import Foundation

enum AsyncBlockState: String {
    case ready = "isReady"
    case executing = "isExecuting"
    case finished  = "isFinished"
    case cancelled = "isCancelled"
}

public typealias AsyncBlockDoneClosure = () -> Void
public typealias AsyncBlockClosure = (@escaping AsyncBlockDoneClosure) -> Void

public class AsyncBlockOperation: Operation {
    let asyncBlock: AsyncBlockClosure

    var state: AsyncBlockState = .ready

    // handle KVO events before changing state
    func transition(to newState: AsyncBlockState) {
        guard state != newState else { return }

        willChangeValue(forKey: newState.rawValue)
        willChangeValue(forKey: state.rawValue)

        state = newState

        didChangeValue(forKey: state.rawValue)
        didChangeValue(forKey: newState.rawValue)
    }

    public override var isReady: Bool {
        state == .ready
    }

    public override var isExecuting: Bool {
        state == .executing
    }

    public override var isFinished: Bool {
        state == .finished
    }

    public override var isCancelled: Bool {
        state == .cancelled
    }

    public init(asyncBlock: @escaping AsyncBlockClosure) {
        self.asyncBlock = asyncBlock
        super.init()
    }

    public override var isAsynchronous: Bool { true }

    public override func start() {
        guard !isCancelled else { return }

        transition(to: .executing)

        let done: AsyncBlockDoneClosure = { [weak self] in
            guard let self = self else { fatalError() }
            self.transition(to: .finished)
        }

        asyncBlock(done)
    }

    public override func cancel() {
        transition(to: .cancelled)
    }
}
