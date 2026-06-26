// B-tree rope: core type definitions

pub let max_children : Int = 8
pub let min_children : Int = 4
pub let max_leaf_bytes : Int = 256
pub let min_leaf_bytes : Int = 64

pub struct Metrics {
  bytes : Int
  chars : Int
  lines : Int
}

pub struct NodeData {
  children : Array[Node]
  metrics  : Array[Metrics]
}

pub enum Node {
  Leaf(String)
  Internal(NodeData)
}

pub struct Rope {
  root    : Node
  metrics : Metrics
}

pub struct RopeSlice {
  rope  : Rope
  start : Int
  end_  : Int
}
