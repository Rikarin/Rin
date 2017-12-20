module Ast.Type;

import Domain.Location;


enum AstTypeKind : ubyte {
    Builtin,
    Identifier,

    Pointer,
    Slice,
    Array,
    Map,
    Tuple,
    Bracket,
    Function,
    TypeOf
}


class AstType {
@safe:
    Location location() { assert(false, "TODO"); }
}