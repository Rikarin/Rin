module Domain.Name;

import Tokens;
import Domain.Context;


struct Name {
    private uint m_id;

    private this(uint id) {
        this.m_id = id;
    }

    bool isEmpty() const {
        return this == BuiltinName!"";
    }

    bool isReserved() const {
        return m_id < (Names.length - Prefill.length);
    }

    bool isDefined() const {
        return m_id != 0;
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
    private Name m_name;
    private const Context m_context;

    private this(Name name, const Context context) {
        m_name = name;
        m_context = context;
    }

    private ref nameManager() const {
        return m_context.nameManager;
    }

    alias m_name this;
    Name name() const {
        return m_name;
    }

    string toString() const {
        return nameManager.m_names[m_id];
    }

    immutable(char)* toStringz() const {
        auto s = toString();
        return s.ptr;
    }
}


struct NameManager {
    private string[] m_names;
    private uint[string] m_lookups;

    @disable this(this);

    package static get() {
        return NameManager(Names, Lookups);
    }

    auto getName(const(char)[] str) {
        if (auto id = str in m_lookups) {
            return Name(*id);
        }

        import std.string;
        auto s = str.toStringz()[0 .. str.length];

        scope (exit) assert(str.ptr !is s.ptr, s);

        auto id = m_lookups[s] = cast(uint)m_names.length;
        m_names ~= s;

        return Name(id);
    }

    void dump() {
        foreach (x; m_names) {
            import std.stdio;
            writeln(m_lookups[x], "\t=> ", x);
        }
    }
}


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

    foreach (k, v; operatorsMap()) {
        idents ~= k;
    }

    foreach (k, v; keywordsMap()) {
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
