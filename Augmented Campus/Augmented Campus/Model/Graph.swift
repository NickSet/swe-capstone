import Foundation

private class EdgeList<T> where T: Hashable {

  var node: Node<T>
  var edges: [Edge<T>]?

  init(node: Node<T>) {
    self.node = node
  }

  func addEdge(_ edge: Edge<T>) {
    edges?.append(edge)
  }

}

open class Graph<T>: AbstractGraph<T> where T: Hashable {

  fileprivate var adjacencyList: [EdgeList<T>] = []

  public required init() {
    super.init()
  }

  public required init(fromGraph graph: AbstractGraph<T>) {
    super.init(fromGraph: graph)
  }

  open override var nodes: [Node<T>] {
    var nodes = [Node<T>]()
    for edgeList in adjacencyList {
      nodes.append(edgeList.node)
    }
    return nodes
  }

  open override var edges: [Edge<T>] {
    var allEdges = Set<Edge<T>>()
    for edgeList in adjacencyList {
      guard let edges = edgeList.edges else {
        continue
      }

      for edge in edges {
        allEdges.insert(edge)
      }
    }
    return Array(allEdges)
  }

  open override func createNode(_ data: T) -> Node<T> {
    let matchingNodes = nodes.filter { node in
      return node.data == data
    }

    if matchingNodes.count > 0 {
      return matchingNodes.last!
    }

    let node = Node(data: data, index: adjacencyList.count)
    adjacencyList.append(EdgeList(node: node))
    return node
  }

  open override func addDirectedEdge(_ from: Node<T>, to: Node<T>, withWeight weight: Double?, stairs: Bool) {
    let edge = Edge(from: from, to: to, weight: weight, stairs: stairs)
    let edgeList = adjacencyList[from.index]
    if edgeList.edges != nil {
        edgeList.addEdge(edge)
    } else {
        edgeList.edges = [edge]
    }
  }

  open override func addUndirectedEdge(_ nodes: (Node<T>, Node<T>), withWeight weight: Double?, stairs: Bool) {
    addDirectedEdge(nodes.0, to: nodes.1, withWeight: weight, stairs: stairs)
    addDirectedEdge(nodes.1, to: nodes.0, withWeight: weight, stairs: stairs)
  }

  open override func weightFrom(_ sourceNode: Node<T>, to destinationNode: Node<T>) -> Double? {
    guard let edges = adjacencyList[sourceNode.index].edges else {
      return nil
    }

    for edge: Edge<T> in edges {
      if edge.to == destinationNode {
        return edge.weight
      }
    }

    return nil
  }

  open override func edgesFrom(_ sourceNode: Node<T>) -> [Edge<T>] {
    return adjacencyList[sourceNode.index].edges ?? []
  }

  open override var description: String {
    var rows = [String]()
    for edgeList in adjacencyList {

      guard let edges = edgeList.edges else {
        continue
      }

      var row = [String]()
      for edge in edges {
        var accessible = edge.stairs ? "A " : ""
        var value = "\(accessible)\(edge.to.data)"
        if edge.weight != nil {
          value = "(\(value): \(edge.weight!))"
        }
        row.append(value)
      }

      rows.append("\(edgeList.node.data) -> [\(row.joined(separator: ", "))]")
    }

    return rows.joined(separator: "\n")
  }
}
