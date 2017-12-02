module Parser.Expression;
@safe:

import Tokens;
import Lexer;
import Ast.Expression;
import Domain.Location;


AstExpression parsePrimaryExpression(ref TokenRange trange) {
    auto loc = trange.front.location;


    assert(false, "LOLO");
}
