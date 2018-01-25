import Foundation

public struct Node<T>: Equatable where T: Hashable {

  public var data: T
  public let index: Int

}

extension Node: CustomStringConvertible {

  public var description: String {
    return "\(index): \(data)"
  }

}

extension Node: Hashable {

  public var hashValue: Int {
    return "\(data)\(index)".hashValue
  }

}

public func ==<T>(lhs: Node<T>, rhs: Node<T>) -> Bool {
  guard lhs.index == rhs.index else {
    return false
  }

  guard lhs.data == rhs.data else {
    return false
  }

  return true
}