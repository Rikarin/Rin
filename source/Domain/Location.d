module Domain.Location;

import Domain.Context;


struct Location {
  package Position start;
  package Position stop;

  this(Position start, Position stop) {
    this.start = start;
    this.stop = stop;
  }

  uint length() const {
    return stop.offset - start.offset;
  }

  // TODO
}

struct Position {
  import std.bitmanip;
  mixin(bitfields!(
    uint, "m_offset", uint.sizeof * 8 - 1,
    bool, "m_mixin", 1
  ));

  package uint offset() const {
    return m_offset;
  }

  package uint raw() const {
    return *(cast(uint *)&this);
  }

  package bool isFile() const {
    return !m_mixin;
  }

  package bool isMixin() const {
    return m_mixin;
  }

  Position getWithOffset(uint offset) const {
    return Position(raw + offset);
  }

  auto getFullPosition(Context c) const {
    return 0; // TODO
  }
}