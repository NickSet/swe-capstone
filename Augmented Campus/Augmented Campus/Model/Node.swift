import Foundation

public class Node<T> where T: Hashable {
    
    public var data: T
    public let index: Int
    
    init(data: T, index: Int) {
        self.data = data
        self.index = index
    }
}

extension Node: Equatable {
    public static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
        guard lhs.data == rhs.data else {
            return false
        }
        return true
    }
}

extension Node: Hashable {
    public var hashValue: Int {
        return "\(data)\(index)".hashValue
    }
}
