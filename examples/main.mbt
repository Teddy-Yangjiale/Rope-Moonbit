///|
fn main {
  // Create a rope from a string
  let r = @src.Rope::from_str("Hello, World!\nThis is a rope.\nThird line.")

  println("=== Rope Demo ===")
  println("Total chars: \{r.len_chars()}")
  println("Total lines: \{r.len_lines()}")

  // Insert text
  let r2 = r.insert(7, "Beautiful ")
  println("\nAfter insert:")
  println(r2.to_string())

  // Remove text
  let r3 = r2.remove(7, 17)
  println("\nAfter remove:")
  println(r3.to_string())

  // Iterate lines
  println("\nLines:")
  let mut i = 0
  r.lines().each(fn(line) {
    println("  [\{i}] \{line.to_string()}")
    i = i + 1
  })

  // Index conversions
  println("\nLine 1 starts at char: \{r.line_to_char(1)}")
  println("Char 14 is on line: \{r.char_to_line(14)}")
}
