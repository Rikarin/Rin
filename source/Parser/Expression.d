module Parser.Expression;
@safe:

import Tokens;
import Lexer;
import Parser.Utils;
import Domain.Location;
import Ast.Expression;
import Ast.Type;

enum ParseMode {
    Greedy
}

void test(ref TokenRange trange) {
    trange.parseExpression();
}


AstExpression parseExpression(ParseMode mode = ParseMode.Greedy)(ref TokenRange trange) {
    auto lhs = trange.parsePrefixExpression();

    return trange.parseBinaryExpression!(
        TokenType.Comma,
        BinaryOp.Comma,
        parseAssignExpression
        )(lhs);
}

private AstExpression parseBinaryExpression(
    TokenType type,
    BinaryOp op,
    alias parseNext
)(ref TokenRange trange, AstExpression lhs) {
    lhs = parseNext(trange, lhs);
    Location loc = trange.front.location;

    while (trange.front.type == type) {
        trange.popFront();

        auto rhs = trange.parsePrefixExpression();
        rhs = parseNext(trange, rhs);

        loc.spanTo(rhs.location);
        lhs = new AstBinaryExpression(loc, op, lhs, rhs);
    }
    
    return lhs;
}


AstExpression parseAssignExpression(ref TokenRange trange) {
    return trange.parseAssignExpression(trange.parsePrefixExpression());    
}

AstExpression parseAssignExpression(ref TokenRange trange, AstExpression lhs) {
    lhs = trange.parseTernaryExpression(lhs);
    Location loc = lhs.location;

    void processToken(BinaryOp op) {
        trange.popFront();

        auto rhs = trange.parsePrefixExpression();
        rhs = trange.parseAssignExpression(rhs);

        loc.spanTo(rhs.location);
        lhs = new AstBinaryExpression(loc, op, lhs, rhs);
    }

    switch (trange.front.type) with (BinaryOp) with (TokenType) {
        case Equal:             processToken(Assign);            break;
        case PlusEqual:         processToken(AddAssign);         break;
        case MinusEqual:        processToken(SubAssign);         break;
        case AsteriskEqual:     processToken(MulAssign);         break;
        case SlashEqual:        processToken(DivAssign);         break;
        case PercentEqual:      processToken(RemAssign);         break;
        case AmpersandEqual:    processToken(AndAssign);         break;
        case PipeEqual:         processToken(OrAssign);          break;
        case CaretEqual:        processToken(XorAssign);         break;
        case TildeEqual:        processToken(ConcatAssign);      break;
        case LessLessEqual:     processToken(LeftShiftAssign);   break;
        case MoreMoreEqual:     processToken(SRightShiftAssign); break;
        case MoreMoreMoreEqual: processToken(URightShiftAssign); break;
        case CaretCaretEqual:   processToken(PowAssign);         break;
        default:
    }

    return lhs;
}


// condition ? true : false
AstExpression parseTernaryExpression(ref TokenRange trange) {
    return trange.parseTernaryExpression(trange.parsePrefixExpression());
}

AstExpression parseTernaryExpression(ref TokenRange trange, AstExpression condition) {
    condition = trange.parseLogicalOrExpression(condition);

    if (trange.front.type == TokenType.QuestionMark) {
        Location loc = condition.location;
        trange.popFront();

        auto ifTrue = trange.parseExpression();
        trange.match(TokenType.Colon);
        auto ifFalse = trange.parseTernaryExpression();

        loc.spanTo(ifFalse.location);
        // TOOD: ret; ternary
    }

    return condition;
}


// ||
AstExpression parseLogicalOrExpression(ref TokenRange trange) {
    return trange.parseLogicalOrExpression();
}

AstExpression parseLogicalOrExpression(ref TokenRange trange, AstExpression lhs) {
    return trange.parseBinaryExpression!(
        TokenType.PipePipe,
        BinaryOp.LogicalOr,
        parseLogicalAndExpression
    )(lhs);
}


// &&
AstExpression parseLogicalAndExpression(ref TokenRange trange) {
    return trange.parseLogicalAndExpression();
}

AstExpression parseLogicalAndExpression(ref TokenRange trange, AstExpression lhs) {
    return trange.parseBinaryExpression!(
        TokenType.AmpersandAmpersand,
        BinaryOp.LogicalAnd,
        parseLogicalBitwiseOrExpression
    )(lhs);
}


// |
AstExpression parseLogicalBitwiseOrExpression(ref TokenRange trange) {
    return trange.parseLogicalBitwiseOrExpression();
}

AstExpression parseLogicalBitwiseOrExpression(ref TokenRange trange, AstExpression lhs) {
    return trange.parseBinaryExpression!(
        TokenType.PipePipe,
        BinaryOp.LogicalOr,
        parseLogicalBitwiseXorExpression
    )(lhs);
}


// ^
AstExpression parseLogicalBitwiseXorExpression(ref TokenRange trange) {
    return trange.parseLogicalBitwiseXorExpression();
}

AstExpression parseLogicalBitwiseXorExpression(ref TokenRange trange, AstExpression lhs) {
    return trange.parseBinaryExpression!(
        TokenType.Caret,
        BinaryOp.Xor,
        parseLogicalBitwiseAndExpression
    )(lhs);
}


// &
AstExpression parseLogicalBitwiseAndExpression(ref TokenRange trange) {
    return trange.parseLogicalBitwiseAndExpression();
}

AstExpression parseLogicalBitwiseAndExpression(ref TokenRange trange, AstExpression lhs) {
    return trange.parseBinaryExpression!(
        TokenType.Ampersand,
        BinaryOp.And,
        parseLogicalAndExpression
    )(lhs);
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

            auto type = trange.parseType();
            trange.match(CloseParen);
            result = parsePrefixExpression(trange);

            loc.spanTo(result.location);
            result = new AstCastExpression(loc, type, result);
            break;

        default:
            result = parsePrimaryExpression(trange);
            result = parsePostfixExpression!mode(trange, result);
    }

    assert(result);
    return parsePowExpression(trange, result);
}


/*
 * Parse postfix expr. [ ... ], ++, --, .identifier, ?.identifier
 */
 AstExpression parsePostfixExpression(ParseMode mode)(ref TokenRange trange, AstExpression expr) {
    Location loc;

    while (true) {
        switch (trange.front.type) with (TokenType) {
            case PlusPlus:
                loc.spanTo(trange.front.location);
                trange.popFront();

                expr = new AstUnaryExpression(loc, UnaryOp.PostInc, expr);
                break;

            case MinusMinus:
                loc.spanTo(trange.front.location);
                trange.popFront();

                expr = new AstUnaryExpression(loc, UnaryOp.PostDec, expr);
                break;

            case OpenParen:
                auto args = trange.parseArguments!OpenParen();

                loc.spanTo(trange.previous);
                expr = new AstCallExpression(loc, expr, args);
                break;

            case OpenBracket:
                trange.popFront();

                if (trange.front.type == CloseBracket) {
                    assert(false, "TODO"); // TODO
                }

                auto args = trange.parseArguments();
                switch (trange.front.type) {
                    case CloseBracket:
                        loc.spanTo(trange.front.location);
                        expr = new AstIndexExpression(loc, expr, args);
                        break;

                    case DotDot:
                        trange.popFront();
                        auto end = trange.parseArguments();

                        loc.spanTo(trange.front.location);
                        expr = new AstSliceExpression(loc, expr, args, end);
                        break;

                    default:
                        assert(false, "WTF are you doing, man?");
                }
                break;

            static if (mode == ParseMode.Greedy) {
            case Dot:
            case QuestionMarkDot:
                trange.popFront();
                // TODO
                // parse...(trange, trange.front.type == Dot);
                break;
            }

            default:
                return expr;
        }
    }
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







// TODO: mockups
AstExpression[] parseArguments(TokenType open)(ref TokenRange trange) {
    return null;
}

AstExpression[] parseArguments(ref TokenRange trange) {
    return null;
}

AstType parseType(ref TokenRange trange) {
    return null;
}