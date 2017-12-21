module Domain.Location;

import Domain.Context;


struct Location {
@safe: pure:
    package Position start;
    package Position stop;

    this(Position start, Position stop) {
        this.start = start;
        this.stop  = stop;
    }

    uint length() const {
        return stop.offset - start.offset;
    }

    bool isFile() const {
        return start.isFile();
    }

    bool isMixin() const {
        return start.isMixin();
    }

    void spanTo(Position p) {
        stop = p;
    }

    void spanTo(Location l) {
        spanTo(l.stop);
    }

    auto getFullLocation(Context c) const {
        assert(false); // TODO
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

    Position getWithOffset(uint offset) const out(result) {
        assert(result.isMixin == isMixin, "Position overflow");
    } body {
        return Position(raw + offset);
    }

    auto getFullPosition(Context c) const {
        assert(false); // TODO
    }
}