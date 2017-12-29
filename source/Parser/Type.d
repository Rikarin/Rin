module Parser.Type;
@safe:

import Lexer;
import Tokens;
import Ast.Type;

import Parser.Utils;


AstType parseType(ParseMode mode = ParseMode.Greedy)(ref TokenRange trange) {
    trange.popFront();
    //parse type + monad
    return null;
}