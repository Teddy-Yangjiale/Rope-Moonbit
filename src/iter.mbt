// Iterators: chunks, chars, lines
// Uses Array collection to avoid low-level Iter::new API

pub fn Rope::chunks(self : Rope) -> Iter[String] {
  let buf : Array[String] = []
  collect_chunks(self.root, buf)
  buf.iter()
}

fn collect_chunks(node : Node, buf : Array[String]) -> Unit {
  match node {
    Leaf(s) => buf.push(s)
    Internal(data) => {
      for i = 0; i < data.children.length(); i = i + 1 {
        collect_chunks(data.children[i], buf)
      }
    }
  }
}

pub fn Rope::chars(self : Rope) -> Iter[Char] {
  let buf : Array[Char] = []
  collect_chars(self.root, buf)
  buf.iter()
}

fn collect_chars(node : Node, buf : Array[Char]) -> Unit {
  match node {
    Leaf(s) => {
      for c in s {
        buf.push(c)
      }
    }
    Internal(data) => {
      for i = 0; i < data.children.length(); i = i + 1 {
        collect_chars(data.children[i], buf)
      }
    }
  }
}

pub fn Rope::lines(self : Rope) -> Iter[RopeSlice] {
  let buf : Array[RopeSlice] = []
  let n = self.len_lines()
  for i = 0; i < n; i = i + 1 {
    buf.push(self.line(i))
  }
  buf.iter()
}
