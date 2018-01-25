public struct Edge<T>: Equatable where T: Equatable, T: Hashable {

    public let from: Vertex<T>
    public let to: Vertex<T>
    public let weight: Double
    public let stairs: Bool

}