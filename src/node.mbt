// B-tree node operations

// Build a node from a string, splitting into leaves as needed

///|
pub fn node_from_str(s : String) -> Node {
  if s.length() <= max_leaf_bytes {
    Leaf(s)
  } else {
    let children : Array[Node] = []
    let metrics_arr : Array[Metrics] = []
    let mut i = 0
    while i < s.length() {
      let end = if i + max_leaf_bytes < s.length() {
        i + max_leaf_bytes
      } else {
        s.length()
      }
      let chunk = s[i:end].to_owned()
      children.push(Leaf(chunk))
      metrics_arr.push(metrics_of_str(chunk))
      i = i + max_leaf_bytes
    }
    if children.length() <= max_children {
      Internal({ children, metrics: metrics_arr })
    } else {
      node_balance_children(children, metrics_arr)
    }
  }
}

///|
fn node_balance_children(
  children : Array[Node],
  metrics_arr : Array[Metrics],
) -> Node {
  if children.length() <= max_children {
    return Internal({ children, metrics: metrics_arr })
  }
  let parent_children : Array[Node] = []
  let parent_metrics : Array[Metrics] = []
  let mut i = 0
  while i < children.length() {
    let end = if i + max_children < children.length() {
      i + max_children
    } else {
      children.length()
    }
    let sub_children : Array[Node] = []
    let sub_metrics : Array[Metrics] = []
    for j = i; j < end; j = j + 1 {
      sub_children.push(children[j])
      sub_metrics.push(metrics_arr[j])
    }
    let mut m = metrics_empty()
    for k = 0; k < sub_metrics.length(); k = k + 1 {
      m = metrics_add(m, sub_metrics[k])
    }
    parent_children.push(
      Internal({ children: sub_children, metrics: sub_metrics }),
    )
    parent_metrics.push(m)
    i = i + max_children
  }
  node_balance_children(parent_children, parent_metrics)
}

// Collect all text from a node

///|
pub fn node_collect(node : Node) -> String {
  match node {
    Leaf(s) => s
    Internal(data) => {
      let mut result = ""
      for i = 0; i < data.children.length(); i = i + 1 {
        result = result + node_collect(data.children[i])
      }
      result
    }
  }
}

// Insert text at char_idx

///|
pub fn node_insert(node : Node, char_idx : Int, text : String) -> Node {
  match node {
    Leaf(s) => {
      let before = s[:char_idx].to_owned()
      let after = s[char_idx:].to_owned()
      node_from_str(before + text + after)
    }
    Internal(data) => {
      let mut offset = 0
      let mut target = data.children.length() - 1
      for i = 0; i < data.children.length(); i = i + 1 {
        let child_chars = data.metrics[i].chars
        if char_idx <= offset + child_chars {
          target = i
          break
        }
        offset = offset + child_chars
      }
      let new_child = node_insert(
        data.children[target],
        char_idx - offset,
        text,
      )
      let new_children = data.children.copy()
      let new_metrics = data.metrics.copy()
      new_children[target] = new_child
      new_metrics[target] = metrics_of_node(new_child)
      Internal({ children: new_children, metrics: new_metrics })
    }
  }
}

// Remove chars [start, end_) from node

///|
pub fn node_remove(node : Node, start : Int, end_ : Int) -> Node {
  match node {
    Leaf(s) => {
      let before = s[:start].to_owned()
      let after = s[end_:].to_owned()
      Leaf(before + after)
    }
    Internal(data) => {
      let new_children : Array[Node] = []
      let new_metrics : Array[Metrics] = []
      let mut offset = 0
      for i = 0; i < data.children.length(); i = i + 1 {
        let child_chars = data.metrics[i].chars
        let child_start = offset
        let child_end = offset + child_chars
        if end_ <= child_start || start >= child_end {
          new_children.push(data.children[i])
          new_metrics.push(data.metrics[i])
        } else {
          let local_start = if start > child_start {
            start - child_start
          } else {
            0
          }
          let local_end = if end_ < child_end {
            end_ - child_start
          } else {
            child_chars
          }
          let new_child = node_remove(data.children[i], local_start, local_end)
          let m = metrics_of_node(new_child)
          if m.chars > 0 {
            new_children.push(new_child)
            new_metrics.push(m)
          }
        }
        offset = child_end
      }
      if new_children.length() == 0 {
        Leaf("")
      } else if new_children.length() == 1 {
        new_children[0]
      } else {
        Internal({ children: new_children, metrics: new_metrics })
      }
    }
  }
}

// Get char at char_idx using string iteration

///|
pub fn node_char_at(node : Node, char_idx : Int) -> Char {
  match node {
    Leaf(s) => str_char_at(s, char_idx)
    Internal(data) => {
      let mut offset = 0
      for i = 0; i < data.children.length(); i = i + 1 {
        let child_chars = data.metrics[i].chars
        if char_idx < offset + child_chars {
          return node_char_at(data.children[i], char_idx - offset)
        }
        offset = offset + child_chars
      }
      abort("char_at: index out of bounds")
    }
  }
}

///|
fn str_char_at(s : String, idx : Int) -> Char {
  let mut i = 0
  for c in s {
    if i == idx {
      return c
    }
    i = i + 1
  }
  abort("str_char_at: index out of bounds")
}

// Convert line index to char index (start of that line)

///|
pub fn node_line_to_char(node : Node, line_idx : Int) -> Int {
  match node {
    Leaf(s) => str_line_to_char(s, line_idx)
    Internal(data) => {
      let mut offset_chars = 0
      let mut offset_lines = 0
      for i = 0; i < data.children.length(); i = i + 1 {
        let child_lines = data.metrics[i].lines
        if line_idx <= offset_lines + child_lines {
          return offset_chars +
            node_line_to_char(data.children[i], line_idx - offset_lines)
        }
        offset_chars = offset_chars + data.metrics[i].chars
        offset_lines = offset_lines + child_lines
      }
      offset_chars
    }
  }
}

///|
fn str_line_to_char(s : String, line_idx : Int) -> Int {
  if line_idx == 0 {
    return 0
  }
  let mut lines_seen = 0
  let mut pos = 0
  for c in s {
    if c == '\n' {
      lines_seen = lines_seen + 1
      if lines_seen == line_idx {
        return pos + 1
      }
    }
    pos = pos + 1
  }
  s.length()
}

// Convert char index to line number

///|
pub fn node_char_to_line(node : Node, char_idx : Int) -> Int {
  match node {
    Leaf(s) => str_char_to_line(s, char_idx)
    Internal(data) => {
      let mut offset_chars = 0
      let mut offset_lines = 0
      for i = 0; i < data.children.length(); i = i + 1 {
        let child_chars = data.metrics[i].chars
        if char_idx <= offset_chars + child_chars {
          return offset_lines +
            node_char_to_line(data.children[i], char_idx - offset_chars)
        }
        offset_chars = offset_chars + child_chars
        offset_lines = offset_lines + data.metrics[i].lines
      }
      offset_lines
    }
  }
}

///|
fn str_char_to_line(s : String, char_idx : Int) -> Int {
  let mut lines = 0
  let mut i = 0
  for c in s {
    if i >= char_idx {
      break
    }
    if c == '\n' {
      lines = lines + 1
    }
    i = i + 1
  }
  lines
}
