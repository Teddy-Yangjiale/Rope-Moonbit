// Blackbox tests: public Rope API

///|
test "new rope is empty" {
  let r = Rope::new()
  assert_eq(r.is_empty(), true)
  assert_eq(r.len_chars(), 0)
  assert_eq(r.len_lines(), 0)
}

///|
test "from_str basic" {
  let r = Rope::from_str("hello")
  assert_eq(r.len_chars(), 5)
  assert_eq(r.is_empty(), false)
  assert_eq(r.to_string(), "hello")
}

///|
test "insert at beginning" {
  let r = Rope::from_str("world")
  let r2 = r.insert(0, "hello ")
  assert_eq(r2.to_string(), "hello world")
  assert_eq(r2.len_chars(), 11)
}

///|
test "insert at end" {
  let r = Rope::from_str("hello")
  let r2 = r.append(" world")
  assert_eq(r2.to_string(), "hello world")
}

///|
test "insert in middle" {
  let r = Rope::from_str("helloworld")
  let r2 = r.insert(5, " ")
  assert_eq(r2.to_string(), "hello world")
}

///|
test "remove from middle" {
  let r = Rope::from_str("hello world")
  let r2 = r.remove(5, 11)
  assert_eq(r2.to_string(), "hello")
  assert_eq(r2.len_chars(), 5)
}

///|
test "remove all" {
  let r = Rope::from_str("hello")
  let r2 = r.remove(0, 5)
  assert_eq(r2.is_empty(), true)
  assert_eq(r2.to_string(), "")
}

///|
test "char_at" {
  let r = Rope::from_str("hello")
  assert_eq(r.char_at(0), 'h')
  assert_eq(r.char_at(4), 'o')
}

///|
test "len_lines single line" {
  let r = Rope::from_str("hello")
  assert_eq(r.len_lines(), 1)
}

///|
test "len_lines multiline" {
  let r = Rope::from_str("line1\nline2\nline3")
  assert_eq(r.len_lines(), 3)
}

///|
test "line_to_char" {
  let r = Rope::from_str("line1\nline2\nline3")
  assert_eq(r.line_to_char(0), 0)
  assert_eq(r.line_to_char(1), 6)
  assert_eq(r.line_to_char(2), 12)
}

///|
test "char_to_line" {
  let r = Rope::from_str("line1\nline2\nline3")
  assert_eq(r.char_to_line(0), 0)
  assert_eq(r.char_to_line(6), 1)
  assert_eq(r.char_to_line(12), 2)
}

///|
test "slice to_string" {
  let r = Rope::from_str("hello world")
  let s = r.slice(6, 11)
  assert_eq(s.to_string(), "world")
}

///|
test "line accessor" {
  let r = Rope::from_str("line1\nline2\nline3")
  assert_eq(r.line(0).to_string(), "line1\n")
  assert_eq(r.line(1).to_string(), "line2\n")
  assert_eq(r.line(2).to_string(), "line3")
}

///|
test "chunks iterator collects all text" {
  let r = Rope::from_str("hello world")
  let mut result = ""
  r.chunks().each(fn(chunk) { result = result + chunk })
  assert_eq(result, "hello world")
}

///|
test "chars iterator count" {
  let r = Rope::from_str("hello")
  let mut count = 0
  r.chars().each(fn(_c) { count = count + 1 })
  assert_eq(count, 5)
}

///|
test "large text split into leaves" {
  let big = String::make(512, 'a')
  let r = Rope::from_str(big)
  assert_eq(r.len_chars(), 512)
  assert_eq(r.to_string(), big)
}

///|
test "insert into large text" {
  let big = String::make(300, 'a')
  let r = Rope::from_str(big)
  let r2 = r.insert(150, "X")
  assert_eq(r2.len_chars(), 301)
  assert_eq(r2.char_at(150), 'X')
}

// --- Edge case tests ---

///|
test "empty rope operations" {
  let r = Rope::new()
  assert_eq(r.len_chars(), 0)
  assert_eq(r.len_bytes(), 0)
  assert_eq(r.len_lines(), 0)
  assert_eq(r.is_empty(), true)
  let r2 = r.insert(0, "")
  assert_eq(r2.is_empty(), true)
  let r3 = r.append("")
  assert_eq(r3.is_empty(), true)
}

///|
test "boundary inserts at zero and end" {
  let r = Rope::from_str("bc")
  let r2 = r.insert(0, "a")
  assert_eq(r2.to_string(), "abc")
  let r3 = r2.insert(3, "d")
  assert_eq(r3.to_string(), "abcd")
}

///|
test "remove noop when start equals end" {
  let r = Rope::from_str("hello")
  let r2 = r.remove(2, 2)
  assert_eq(r2.to_string(), "hello")
}

///|
test "unicode multibyte chars in rope" {
  let r = Rope::from_str("你好世界")
  assert_eq(r.len_chars(), 4)
  assert_eq(r.len_bytes(), 12)
  assert_eq(r.char_at(0), '你')
  assert_eq(r.char_at(3), '界')
  assert_eq(r.to_string(), "你好世界")
}

///|
test "insert unicode into ascii rope" {
  let r = Rope::from_str("hello world")
  let r2 = r.insert(5, "，")
  assert_eq(r2.len_chars(), 12)
  assert_eq(r2.char_at(5), '，')
}

// --- Stress tests ---

///|
test "stress: large text roundtrip" {
  let big = String::make(10000, 'x')
  let r = Rope::from_str(big)
  assert_eq(r.len_chars(), 10000)
  assert_eq(r.to_string(), big)
}

///|
test "stress: many sequential inserts" {
  let mut r = Rope::new()
  for i = 0; i < 100; i = i + 1 {
    r = r.append("ab")
  }
  assert_eq(r.len_chars(), 200)
  assert_eq(r.char_at(0), 'a')
  assert_eq(r.char_at(1), 'b')
  assert_eq(r.char_at(198), 'a')
  assert_eq(r.char_at(199), 'b')
}

///|
test "stress: large multiline text" {
  let line = "hello world\n"
  let mut content = ""
  for _i = 0; _i < 100; _i = _i + 1 {
    content = content + line
  }
  let r = Rope::from_str(content)
  // 100 trailing newlines → 101 lines (last line is empty)
  assert_eq(r.len_lines(), 101)
  assert_eq(r.len_chars(), 1200)
}

// --- Roundtrip tests ---

///|
test "roundtrip: insert then remove equals original" {
  let original = "hello world"
  let r = Rope::from_str(original)
  let r2 = r.insert(5, " beautiful")
  let r3 = r2.remove(5, 15)
  assert_eq(r3.to_string(), original)
}

///|
test "roundtrip: split then concat equals original" {
  let original = "hello world"
  let r = Rope::from_str(original)
  let (left, right) = r.split(5)
  let rejoined = left.concat(right)
  assert_eq(rejoined.to_string(), original)
}

///|
test "roundtrip: RopeBuilder equals from_str" {
  let text = "line1\nline2\nline3\n"
  let r1 = Rope::from_str(text)
  let builder = RopeBuilder::new()
  builder.push("line1\n")
  builder.push("line2\n")
  builder.push("line3\n")
  let r2 = builder.build()
  assert_eq(r1.op_equal(r2), true)
}

///|
test "equality: same content different structure" {
  let r1 = Rope::from_str("hello world")
  let r2 = Rope::from_str("hello").insert(5, " world")
  assert_eq(r1.op_equal(r2), true)
}

///|
test "equality: different content" {
  let r1 = Rope::from_str("hello")
  let r2 = Rope::from_str("world")
  assert_eq(r1.op_equal(r2), false)
}

///|
test "byte index conversions ascii" {
  let r = Rope::from_str("hello")
  assert_eq(r.char_to_byte(0), 0)
  assert_eq(r.char_to_byte(5), 5)
  assert_eq(r.byte_to_char(0), 0)
  assert_eq(r.byte_to_char(5), 5)
}

///|
test "byte index conversions unicode" {
  let r = Rope::from_str("你好")
  assert_eq(r.len_bytes(), 6)
  assert_eq(r.char_to_byte(1), 3)
  assert_eq(r.byte_to_char(3), 1)
}

///|
test "split at boundary" {
  let r = Rope::from_str("hello world")
  let (left, right) = r.split(0)
  assert_eq(left.to_string(), "")
  assert_eq(right.to_string(), "hello world")
  let (left2, right2) = r.split(11)
  assert_eq(left2.to_string(), "hello world")
  assert_eq(right2.to_string(), "")
}
