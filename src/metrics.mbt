// Metric computation helpers

///|
pub fn metrics_empty() -> Metrics {
  { bytes: 0, chars: 0, lines: 0 }
}

///|
pub fn metrics_of_str(s : String) -> Metrics {
  let chars = s.length()
  let bytes = s.length()
  let mut lines = 0
  for c in s {
    if c == '\n' {
      lines = lines + 1
    }
  }
  { bytes, chars, lines }
}

///|
pub fn metrics_add(a : Metrics, b : Metrics) -> Metrics {
  {
    bytes: a.bytes + b.bytes,
    chars: a.chars + b.chars,
    lines: a.lines + b.lines,
  }
}

///|
pub fn metrics_of_node(node : Node) -> Metrics {
  match node {
    Leaf(s) => metrics_of_str(s)
    Internal(data) => {
      let mut m = metrics_empty()
      for i = 0; i < data.metrics.length(); i = i + 1 {
        m = metrics_add(m, data.metrics[i])
      }
      m
    }
  }
}
