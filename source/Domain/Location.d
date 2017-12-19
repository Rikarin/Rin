module Domain.Location;

import Domain.Context;


struct Location {
@safe: pure:
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

    void spanTo(Position p) {
        // TODO
    }

    void spanTo(Location l) {
        // TODO
    }
}

struct Position {
@safe: pure:
    import std.bitmanip;
    mixin(bitfields!(
        uint, "_offset", uint.sizeof * 8 - 1,
        bool, "_mixin", 1
    ));

    package uint offset() const {
        return _offset;
    }

    package uint raw() const @trusted {
        return *(cast(uint *)&this);
    }

    package bool isFile() const {
        return !_mixin;
    }

    package bool isMixin() const {
        return _mixin;
    }

    Position getWithOffset(uint offset) const {
        return Position(raw + offset);
    }

    auto getFullPosition(Context c) const {
        return 0; // TODO
    }
}