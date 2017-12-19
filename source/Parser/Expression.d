module Parser.Expression;
@safe:

import Tokens;
import Lexer;
import Parser.Utils;
import Ast.Expression;
import Domain.Location;

enum ParseMode {
    Greedy
}


AstExpression parsePrimaryExpression(ref TokenRange trange) {
    auto loc = trange.front.location;


    assert(false, "LOLO");
}


private AstExpression parsePrefixExpression(ParseMode mode = ParseMode.Greedy)(ref TokenRange trange) {
    AstExpression result;

    void processToken(UnaryOp op) {
        Location loc = trange.front.location;
        trange.popFront();

        result = trange.parsePrefixExpression();
        loc.spanTo(result.location);

        result = new AstUnaryExpression(loc, op, result);
    }

    switch (trange.front.type) with(TokenType) {
        case Ampersand:  processToken(UnaryOp.AddressOf);   break;
        case Await:      processToken(UnaryOp.Await);       break;
        case Asterisk:   processToken(UnaryOp.Dereference); break;
        case PlusPlus:   processToken(UnaryOp.PreInc);      break;
        case MinusMinus: processToken(UnaryOp.PreDec);      break;
        case Plus:       processToken(UnaryOp.Plus);        break;
        case Minus:      processToken(UnaryOp.Minus);       break;
        case Tilde:      processToken(UnaryOp.Complement);  break;
        case Bang:       processToken(UnaryOp.Not);         break;

        case OpenParen: // cast expression
            Location loc = trange.front.location;

            // TODO: parse type
            trange.match(CloseParen);
            result = parsePrefixExpression(trange);

            loc.spanTo(result.location);
            result = new AstCastExpression(loc, result);
            break;

        default:
            result = parsePrimaryExpression(trange);
            // TODO
    }

    assert(result);
    return parsePowExpression(trange, result);
}


/*
 * Parse ^^
 */
private AstExpression parsePowExpression(ref TokenRange trange, AstExpression expr) {
    Location loc = trange.front.location;

    while (trange.front.type == TokenType.CaretCaret) {
        trange.popFront();
        auto power = parsePrefixExpression(trange);
        loc.spanTo(power.location);

        expr = new AstBinaryExpression(loc, BinaryOp.Pow, expr, power);
    }

    return expr;
}