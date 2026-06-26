# Rope-MoonBit

A B-tree rope data structure library for MoonBit, designed for efficient text editing operations.

A **rope** is a tree-based data structure that represents text as a sequence of small strings, enabling O(log n) insertions and deletions even for very large documents. This makes ropes ideal for text editors, language servers, and any application that performs frequent edits on large texts.

## Features

- O(log n) insert and remove at arbitrary positions
- O(n) construction from a string or via `RopeBuilder`
- Correct Unicode support: char indices and UTF-8 byte offsets
- Line/char index conversions for editor protocol (LSP/DAP) compatibility
- Lazy iterators for chunks, chars, and lines
- Slice views without copying
- Targets: wasm-gc, native, js

## Installation

Add to your `moon.mod`:

```json
{
  "deps": {
    "Teddy-Yangjiale/rope": "0.1.0"
  }
}
```

Then run:

```sh
moon update
moon install
```

## Quick Start

```moonbit
fn main {
  // Create a rope from a string
  let r = Rope::from_str("Hello, world!")
  println(r.len_chars())   // 13
  println(r.len_bytes())   // 13 (UTF-8 bytes)
  println(r.len_lines())   // 1

  // Efficient insert and remove
  let r2 = r.insert(7, "beautiful ")
  println(r2.to_string())  // "Hello, beautiful world!"

  let r3 = r2.remove(7, 17)
  println(r3.to_string())  // "Hello, world!"

  // Split and concat
  let (left, right) = r.split(7)
  println(left.to_string())   // "Hello, "
  println(right.to_string())  // "world!"
  let rejoined = left.concat(right)
  println(rejoined.to_string())  // "Hello, world!"
}
```

## API Reference

### Construction

| Function | Description |
|---|---|
| `Rope::new() -> Rope` | Create an empty rope |
| `Rope::from_str(s: String) -> Rope` | Build a rope from a string |
| `RopeBuilder::new() -> RopeBuilder` | Create a builder for incremental construction |
| `RopeBuilder::push(self, chunk: String) -> Unit` | Append a chunk |
| `RopeBuilder::build(self) -> Rope` | Finalize and build the rope |

### Queries

| Function | Description |
|---|---|
| `Rope::len_chars(self) -> Int` | Number of Unicode code points |
| `Rope::len_bytes(self) -> Int` | Number of UTF-8 bytes |
| `Rope::len_lines(self) -> Int` | Number of lines (newlines + 1) |
| `Rope::is_empty(self) -> Bool` | Whether the rope is empty |

### Editing

| Function | Description |
|---|---|
| `Rope::insert(self, char_idx: Int, text: String) -> Rope` | Insert text at char index |
| `Rope::remove(self, start: Int, end_: Int) -> Rope` | Remove chars `[start, end_)` |
| `Rope::append(self, text: String) -> Rope` | Append text to the end |
| `Rope::split(self, char_idx: Int) -> (Rope, Rope)` | Split into two ropes |
| `Rope::concat(self, other: Rope) -> Rope` | Concatenate two ropes |

### Index Conversion

| Function | Description |
|---|---|
| `Rope::char_at(self, char_idx: Int) -> Char` | Character at index |
| `Rope::line_to_char(self, line_idx: Int) -> Int` | First char index of a line |
| `Rope::char_to_line(self, char_idx: Int) -> Int` | Line number of a char |
| `Rope::char_to_byte(self, char_idx: Int) -> Int` | UTF-8 byte offset of a char |
| `Rope::byte_to_char(self, byte_idx: Int) -> Int` | Char index at a UTF-8 byte offset |

### Slices

| Function | Description |
|---|---|
| `Rope::slice(self, start: Int, end_: Int) -> RopeSlice` | View of `[start, end_)` |
| `Rope::line(self, line_idx: Int) -> RopeSlice` | View of a single line |
| `RopeSlice::to_string(self) -> String` | Materialize slice to string |
| `RopeSlice::len_chars(self) -> Int` | Length of slice in chars |

### Iterators

| Function | Description |
|---|---|
| `Rope::chunks(self) -> Iter[String]` | Iterate over leaf string chunks |
| `Rope::chars(self) -> Iter[Char]` | Iterate over all characters |
| `Rope::lines(self) -> Iter[RopeSlice]` | Iterate over lines as slices |

### Equality

| Function | Description |
|---|---|
| `Rope::op_equal(self, other: Rope) -> Bool` | Content equality |

## RopeBuilder Example

Use `RopeBuilder` when constructing a rope from many pieces — it builds the B-tree once at `build()` time, avoiding repeated tree reconstruction:

```moonbit
fn load_file_lines(lines: Array[String]) -> Rope {
  let builder = RopeBuilder::new()
  for line in lines {
    builder.push(line)
    builder.push("\n")
  }
  builder.build()
}
```

## Unicode Example

Char indices are Unicode code points, not bytes:

```moonbit
fn unicode_demo {
  let r = Rope::from_str("你好世界")
  println(r.len_chars())   // 4 (code points)
  println(r.len_bytes())   // 12 (UTF-8 bytes)
  println(r.char_at(0))    // '你'
  println(r.char_to_byte(1))  // 3 (second char starts at byte 3)
}
```

## Running the Example

```sh
git clone https://github.com/Teddy-Yangjiale/Rope-Moonbit
cd Rope-Moonbit
moon run examples
```

## Running Tests

```sh
moon test
```

## Design

The rope is a B-tree where:
- **Leaves** hold UTF-16 string chunks (up to 256 code units each)
- **Internal nodes** hold up to 8 children with pre-computed metrics (bytes, chars, newlines)
- All operations produce new nodes via **structural sharing** (persistent/immutable style)

This design gives O(log n) worst-case for insert/remove and O(n) for construction.

## License

Apache-2.0. See [LICENSE](LICENSE).
