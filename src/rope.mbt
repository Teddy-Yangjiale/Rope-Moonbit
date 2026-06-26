// Public Rope API

///|
pub fn Rope::new() -> Rope {
  { root: Leaf(""), metrics: metrics_empty() }
}

///|
pub fn Rope::from_str(s : String) -> Rope {
  if s.length() == 0 {
    Rope::new()
  } else {
    let root = node_from_str(s)
    let m = metrics_of_node(root)
    { root, metrics: m }
  }
}

///|
pub fn Rope::len_chars(self : Rope) -> Int {
  self.metrics.chars
}

///|
pub fn Rope::len_bytes(self : Rope) -> Int {
  self.metrics.bytes
}

///|
pub fn Rope::len_lines(self : Rope) -> Int {
  // number of lines = newlines + 1 (unless empty)
  if self.metrics.chars == 0 {
    0
  } else {
    self.metrics.lines + 1
  }
}

///|
pub fn Rope::is_empty(self : Rope) -> Bool {
  self.metrics.chars == 0
}

///|
pub fn Rope::to_string(self : Rope) -> String {
  node_collect(self.root)
}

///|
pub fn Rope::insert(self : Rope, char_idx : Int, text : String) -> Rope {
  if text.length() == 0 {
    return self
  }
  if char_idx < 0 || char_idx > self.metrics.chars {
    abort(
      "Rope::insert: char_idx \{char_idx} out of range [0, \{self.metrics.chars}]",
    )
  }
  let new_root = node_insert(self.root, char_idx, text)
  let m = metrics_of_node(new_root)
  { root: new_root, metrics: m }
}

///|
pub fn Rope::remove(self : Rope, start : Int, end_ : Int) -> Rope {
  if start >= end_ {
    return self
  }
  if start < 0 || end_ > self.metrics.chars {
    abort(
      "Rope::remove: range [\{start}, \{end_}) out of bounds [0, \{self.metrics.chars}]",
    )
  }
  let new_root = node_remove(self.root, start, end_)
  let m = metrics_of_node(new_root)
  { root: new_root, metrics: m }
}

///|
pub fn Rope::append(self : Rope, text : String) -> Rope {
  self.insert(self.metrics.chars, text)
}

///|
pub fn Rope::char_at(self : Rope, char_idx : Int) -> Char {
  if char_idx < 0 || char_idx >= self.metrics.chars {
    abort(
      "Rope::char_at: char_idx \{char_idx} out of range [0, \{self.metrics.chars})",
    )
  }
  node_char_at(self.root, char_idx)
}

///|
pub fn Rope::line_to_char(self : Rope, line_idx : Int) -> Int {
  let n = self.len_lines()
  if line_idx < 0 || line_idx >= n {
    abort("Rope::line_to_char: line_idx \{line_idx} out of range [0, \{n})")
  }
  node_line_to_char(self.root, line_idx)
}

///|
pub fn Rope::char_to_line(self : Rope, char_idx : Int) -> Int {
  node_char_to_line(self.root, char_idx)
}

///|
pub fn Rope::slice(self : Rope, start : Int, end_ : Int) -> RopeSlice {
  { rope: self, start, end_ }
}

///|
pub fn Rope::line(self : Rope, line_idx : Int) -> RopeSlice {
  let start = self.line_to_char(line_idx)
  let end_ = if line_idx + 1 < self.len_lines() {
    self.line_to_char(line_idx + 1)
  } else {
    self.metrics.chars
  }
  { rope: self, start, end_ }
}

///|
pub fn RopeBuilder::new() -> RopeBuilder {
  { chunks: [] }
}

///|
pub fn RopeBuilder::push(self : RopeBuilder, chunk : String) -> Unit {
  if chunk.length() > 0 {
    self.chunks.push(chunk)
  }
}

///|
pub fn RopeBuilder::build(self : RopeBuilder) -> Rope {
  // Join all chunks in a single pass to build the full string once,
  // then construct the B-tree from it.
  let mut content = ""
  for s in self.chunks {
    content = content + s
  }
  Rope::from_str(content)
}

///|
pub fn Rope::char_to_byte(self : Rope, char_idx : Int) -> Int {
  let mut bytes = 0
  let mut chars = 0
  for c in self.chars() {
    if chars == char_idx {
      break
    }
    bytes = bytes + char_utf8_len(c)
    chars = chars + 1
  }
  bytes
}

///|
pub fn Rope::byte_to_char(self : Rope, byte_idx : Int) -> Int {
  let mut bytes = 0
  let mut chars = 0
  for c in self.chars() {
    if bytes >= byte_idx {
      break
    }
    bytes = bytes + char_utf8_len(c)
    chars = chars + 1
  }
  chars
}

///|
pub fn Rope::split(self : Rope, char_idx : Int) -> (Rope, Rope) {
  let left = self.remove(char_idx, self.metrics.chars)
  let right = self.remove(0, char_idx)
  (left, right)
}

///|
pub fn Rope::concat(self : Rope, other : Rope) -> Rope {
  Rope::from_str(self.to_string() + other.to_string())
}

///|
pub fn Rope::op_equal(self : Rope, other : Rope) -> Bool {
  if self.metrics.chars != other.metrics.chars ||
    self.metrics.bytes != other.metrics.bytes {
    false
  } else {
    self.to_string() == other.to_string()
  }
}

///|
pub fn RopeSlice::to_string(self : RopeSlice) -> String {
  let full = self.rope.to_string()
  // self.start/end_ are char (code-point) indices; convert to UTF-16 offsets
  // before slicing because MoonBit s[i:j] operates on UTF-16 code units.
  let u_start = str_char_to_utf16(full, self.start)
  let u_end = str_char_to_utf16(full, self.end_)
  full[u_start:u_end].to_owned()
}

///|
pub fn RopeSlice::len_chars(self : RopeSlice) -> Int {
  self.end_ - self.start
}
