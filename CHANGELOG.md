# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-06-26

### Added

- `Rope::new()` — create empty rope
- `Rope::from_str(s)` — build rope from string
- `Rope::insert(char_idx, text)` — O(log n) insert
- `Rope::remove(start, end_)` — O(log n) remove
- `Rope::append(text)` — append to end
- `Rope::split(char_idx)` — split into two ropes at a char index
- `Rope::concat(other)` — concatenate two ropes
- `Rope::len_chars()`, `len_bytes()`, `len_lines()`, `is_empty()`
- `Rope::char_at(char_idx)` — O(log n) random access
- `Rope::line_to_char(line_idx)`, `char_to_line(char_idx)` — line/char conversions
- `Rope::char_to_byte(char_idx)`, `byte_to_char(byte_idx)` — UTF-8 byte offset support
- `Rope::slice(start, end_)`, `Rope::line(line_idx)` — zero-copy slice views
- `Rope::chunks()`, `chars()`, `lines()` — lazy iterators
- `Rope::op_equal(other)` — content equality
- `RopeBuilder` — efficient incremental construction

### Design

- B-tree structure with branching factor 4–8
- Leaf chunks up to 256 UTF-16 code units
- Metrics (bytes/chars/lines) cached at each internal node
- Persistent/immutable style: all edits return new rope values
- Real UTF-8 byte tracking in `Metrics.bytes` for LSP/DAP compatibility
