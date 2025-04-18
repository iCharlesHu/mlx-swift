// Copyright © 2024 Apple Inc.

import Foundation

extension MLXRandom {
    /// Global random state.
    ///
    /// Note: although this type is thread-safe, the MLXArrays that it returns are not -- do not
    /// evaluate these values or expressions that depend on them across multiple threads
    /// simultaneously.
    public class RandomState: Updatable, Evaluatable, @unchecked (Sendable) {
        private var state: MLXArray
        private let lock = NSLock()

        init() {
            let now = mach_approximate_time()
            state = MLXRandom.key(now)
        }

        public func innerState() -> [MLXArray] {
            lock.withLock {
                [state]
            }
        }

        public func next() -> MLXArray {
            lock.withLock {
                let (a, b) = MLXRandom.split(key: state)
                self.state = a
                return b
            }
        }

        public func seed(_ seed: UInt64) {
            lock.withLock {
                state = MLXRandom.key(seed)
            }
        }
    }

    /// Global random state.
    ///
    /// This can be used with `compile(state: [MLXRandom.globalState, ...], ...)`
    ///
    /// ### See Also
    /// - ``seed(_:)``
    public static let globalState = RandomState()

}  // MLXRandom
