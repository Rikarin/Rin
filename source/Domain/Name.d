module Domain.Name;

import Tokens;
import Domain.Context;


struct Name {
@safe: pure:
    private uint _id;

    private this(uint id) {
        this._id = id;
    }

    bool isEmpty() const {
        return this == BuiltinName!"";
    }

    bool isReserved() const {
        return _id < (Names.length - Prefill.length);
    }

    bool isDefined() const {
        return _id != 0;
    }

    auto getFullName(const Context c) const {
        return FullName(this, c);
    }

    string toString(const Context c) const {
        return getFullName(c).toString();
    }

    immutable(char)* toStringz(const Context c) const {
        return getFullName(c).toStringz();
    }
}


struct FullName {
@safe: pure:
    private Name _name;
    private const Context _context;

    private this(Name name, const Context context) {
        _name = name;
        _context = context;
    }

    private ref nameManager() const {
        return _context.nameManager;
    }

    alias _name this;
    Name name() const {
        return _name;
    }

    string toString() const {
        return nameManager._names[_id];
    }

    immutable(char)* toStringz() const {
        auto s = toString();
        return &s[0];
    }
}


struct NameManager {
@safe:
    private string[] _names;
    private uint[string] _lookups;

    @disable this(this);

    package static get() {
        return NameManager(Names, Lookups);
    }

    auto getName(const(char)[] str) @trusted {
        if (auto id = str in _lookups) {
            return Name(*id);
        }

        import std.string;
        auto s = str.toStringz()[0 .. str.length];

        scope (exit) assert(str.ptr !is s.ptr, s);

        auto id = _lookups[s] = cast(uint)_names.length;
        _names ~= s;

        return Name(id);
    }

    void dump() {
        foreach (x; _names) {
            import std.stdio;
            writeln(_lookups[x], "\t=> ", x);
        }
    }
}

@safe: pure:
template BuiltinName(string name) {
    private enum id = Lookups.get(name, uint.max);
    static assert(id < uint.max, name ~ " is not a buildin name!");

    enum BuiltinName = Name(id);
}
 
private enum Reserved = ["__ctor", "__postblit", "__vtbl"];

private enum Prefill = [
    // Linkages
    "C", "D", "C++", "Rin",
    // Version
    "Windows", "Linux", "Posix", "x86_64", "x86",
    // Generated
    // TODO
    // Scope
    "exit", "success", "failure",
    // Main
    "main",
    // Defined in object
    "object", "size_t", "ptrdiff_t", "string",
    "Object",
    "Type", "MemberInfo", // TODO

    // TODO
    // Runtime
    "__internal_assert_fail",
    "__internal_await",
    // TODO
    // Generated Symbols
    // TODO
    // TODO
];

private auto getNames() {
    auto idents = [""];

    foreach (k, v; operatorsMap) {
        idents ~= k;
    }

    foreach (k, v; keywordsMap) {
        idents ~= k;
    }

    return idents ~ Reserved ~ Prefill;
}

private enum Names = getNames();
static assert(Names[0] == "");

private auto getLookups() {
    uint[string] lookups;

    foreach (uint i, x; Names) {
        lookups[x] = i;
    }

    return lookups;
}

private enum Lookups = getLookups();
