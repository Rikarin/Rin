module Ast.Type;

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

}