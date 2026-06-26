// Blackbox tests: public Rope API

test "new rope is empty" {
  let r = Rope::new()
  assert_eq(r.is_empty(), true)
  assert_eq(r.len_chars(), 0)
  assert_eq(r.len_lines(), 0)
}

test "from_str basic" {
  let r = Rope::from_str("hello")
  assert_eq(r.len_chars(), 5)
  assert_eq(r.is_empty(), false)
  assert_eq(r.to_string(), "hello")
}

test "insert at beginning" {
  let r = Rope::from_str("world")
  let r2 = r.insert(0, "hello ")
  assert_eq(r2.to_string(), "hello world")
  assert_eq(r2.len_chars(), 11)
}

test "insert at end" {
  let r = Rope::from_str("hello")
  let r2 = r.append(" world")
  assert_eq(r2.to_string(), "hello world")
}

test "insert in middle" {
  let r = Rope::from_str("helloworld")
  let r2 = r.insert(5, " ")
  assert_eq(r2.to_string(), "hello world")
}

test "remove from middle" {
  let r = Rope::from_str("hello world")
  let r2 = r.remove(5, 11)
  assert_eq(r2.to_string(), "hello")
  assert_eq(r2.len_chars(), 5)
}

test "remove all" {
  let r = Rope::from_str("hello")
  let r2 = r.remove(0, 5)
  assert_eq(r2.is_empty(), true)
  assert_eq(r2.to_string(), "")
}

test "char_at" {
  let r = Rope::from_str("hello")
  assert_eq(r.char_at(0), 'h')
  assert_eq(r.char_at(4), 'o')
}

test "len_lines single line" {
  let r = Rope::from_str("hello")
  assert_eq(r.len_lines(), 1)
}

test "len_lines multiline" {
  let r = Rope::from_str("line1\nline2\nline3")
  assert_eq(r.len_lines(), 3)
}

test "line_to_char" {
  let r = Rope::from_str("line1\nline2\nline3")
  assert_eq(r.line_to_char(0), 0)
  assert_eq(r.line_to_char(1), 6)
  assert_eq(r.line_to_char(2), 12)
}

test "char_to_line" {
  let r = Rope::from_str("line1\nline2\nline3")
  assert_eq(r.char_to_line(0), 0)
  assert_eq(r.char_to_line(6), 1)
  assert_eq(r.char_to_line(12), 2)
}

test "slice to_string" {
  let r = Rope::from_str("hello world")
  let s = r.slice(6, 11)
  assert_eq(s.to_string(), "world")
}

test "line accessor" {
  let r = Rope::from_str("line1\nline2\nline3")
  assert_eq(r.line(0).to_string(), "line1\n")
  assert_eq(r.line(1).to_string(), "line2\n")
  assert_eq(r.line(2).to_string(), "line3")
}

test "chunks iterator collects all text" {
  let r = Rope::from_str("hello world")
  let mut result = ""
  r.chunks().each(fn(chunk) { result = result + chunk })
  assert_eq(result, "hello world")
}

test "chars iterator count" {
  let r = Rope::from_str("hello")
  let mut count = 0
  r.chars().each(fn(_c) { count = count + 1 })
  assert_eq(count, 5)
}

test "large text split into leaves" {
  let big = String::make(512, 'a')
  let r = Rope::from_str(big)
  assert_eq(r.len_chars(), 512)
  assert_eq(r.to_string(), big)
}

test "insert into large text" {
  let big = String::make(300, 'a')
  let r = Rope::from_str(big)
  let r2 = r.insert(150, "X")
  assert_eq(r2.len_chars(), 301)
  assert_eq(r2.char_at(150), 'X')
}
