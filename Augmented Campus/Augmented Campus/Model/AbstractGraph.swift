open class AbstractGraph<T>: CustomStringConvertible where T: Hashable {

  public required init() {}

  public required init(fromGraph graph: AbstractGraph<T>) {
    for edge in graph.edges {
      let from = createNode(edge.from.data)
      let to = createNode(edge.to.data)
      let stairs = edge.stairs
      addDirectedEdge(from, to: to, withWeight: edge.weight, stairs: stairs)
    }
  }

  open var description: String {
    fatalError("abstract property accessed")
  }

  open var nodes: [Node<T>] {
    fatalError("abstract property accessed")
  }

  open var edges: [Edge<T>] {
    fatalError("abstract property accessed")
  }

  // Adds a new vertex to the matrix.
  // Performance: possibly O(n^2) because of the resizing of the matrix.
  open func createNode(_ data: T) -> Node<T> {
    fatalError("abstract function called")
  }

  open func addDirectedEdge(_ from: Node<T>, to: Node<T>, withWeight weight: Double?, stairs: Bool = false) {
    fatalError("abstract function called")
  }

  open func addUndirectedEdge(_ vertices: (Node<T>, Node<T>), withWeight weight: Double?, stairs: Bool = false) {
    fatalError("abstract function called")
  }

  open func weightFrom(_ sourceVertex: Node<T>, to destinationVertex: Node<T>) -> Double? {
    fatalError("abstract function called")
  }

  open func edgesFrom(_ sourceVertex: Node<T>) -> [Edge<T>] {
    fatalError("abstract function called")
  }
}
