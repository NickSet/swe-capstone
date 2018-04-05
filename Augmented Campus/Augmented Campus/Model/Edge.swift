public struct Edge<T>: Equatable where T: Hashable {

    public let from: Node<T>
    public var to: Node<T>
    public let weight: Double?
    public let stairs: Bool

}

extension Edge: CustomStringConvertible {
    
    public var description: String {
        guard let unwrappedWeight = weight else {
            return "\(from.description) -> \(to.description)"
        }
        return "\(from.description) -(\(unwrappedWeight))-> \(to.description)"
    }
    
}

extension Edge: Hashable {
    
    public var hashValue: Int {
        var string = "\(from.description)\(to.description)\(stairs)"
        if weight != nil {
            string.append("\(weight!)")
        }
        return string.hashValue
    }
}

public func == <T>(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
    guard lhs.from == rhs.from else {
        return false
    }
    
    guard lhs.to == rhs.to else {
        return false
    }
    
    guard lhs.weight == rhs.weight else {
        return false
    }
    
    return true
}
