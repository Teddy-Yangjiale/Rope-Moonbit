// Whitebox tests: internal node invariants

///|
test "metrics_of_str basic" {
  let m = metrics_of_str("hello\nworld")
  assert_eq(m.chars, 11)
  assert_eq(m.lines, 1)
}

///|
test "metrics_add" {
  let a = { bytes: 5, chars: 5, lines: 1 }
  let b = { bytes: 3, chars: 3, lines: 0 }
  let c = metrics_add(a, b)
  assert_eq(c.chars, 8)
  assert_eq(c.lines, 1)
}

///|
test "node_from_str small" {
  let node = node_from_str("hello")
  match node {
    Leaf(s) => assert_eq(s, "hello")
    Internal(_) => abort("expected Leaf")
  }
}

///|
test "node_collect roundtrip" {
  let s = "hello world"
  let node = node_from_str(s)
  assert_eq(node_collect(node), s)
}

///|
test "node_insert at start" {
  let node = node_from_str("world")
  let new_node = node_insert(node, 0, "hello ")
  assert_eq(node_collect(new_node), "hello world")
}

///|
test "node_insert at end" {
  let node = node_from_str("hello")
  let new_node = node_insert(node, 5, " world")
  assert_eq(node_collect(new_node), "hello world")
}

///|
test "node_remove middle" {
  let node = node_from_str("hello world")
  let new_node = node_remove(node, 5, 11)
  assert_eq(node_collect(new_node), "hello")
}

///|
test "node_char_at" {
  let node = node_from_str("hello")
  assert_eq(node_char_at(node, 0), 'h')
  assert_eq(node_char_at(node, 4), 'o')
}

///|
test "node_line_to_char" {
  let node = node_from_str("line1\nline2\nline3")
  assert_eq(node_line_to_char(node, 0), 0)
  assert_eq(node_line_to_char(node, 1), 6)
  assert_eq(node_line_to_char(node, 2), 12)
}
