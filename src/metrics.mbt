// Metric computation helpers

///|
pub fn metrics_empty() -> Metrics {
  { bytes: 0, chars: 0, lines: 0 }
}

// Returns UTF-16 code units per code point (1 for BMP, 2 for astral plane U+10000+).

///|
pub fn char_utf16_len(c : Char) -> Int {
  if c.to_int() >= 0x10000 {
    2
  } else {
    1
  }
}

// Returns the number of UTF-8 bytes needed to encode a Unicode code point.

///|
pub fn char_utf8_len(c : Char) -> Int {
  let code = c.to_int()
  if code < 0x80 {
    1
  } else if code < 0x800 {
    2
  } else if code < 0x10000 {
    3
  } else {
    4
  }
}

///|
pub fn metrics_of_str(s : String) -> Metrics {
  let mut chars = 0
  let mut bytes = 0
  let mut lines = 0
  for c in s {
    chars = chars + 1
    bytes = bytes + char_utf8_len(c)
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
