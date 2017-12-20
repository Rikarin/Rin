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


// comparison == != is !is in ??
AstExpression parseComparisonExpression(ref TokenRange trange) {
    return trange.parseComparisonExpression(trange.parsePrefixExpression());
}

AstExpression parseComparisonExpression(ref TokenRange trange, AstExpression lhs) {
    lhs = trange.parseShiftExpression(lhs);
    Location loc = lhs.location;

    void processToken(BinaryOp op) {
        trange.popFront();

        auto rhs = trange.parseShiftExpression();

        loc.spanTo(rhs.location);
        lhs = new AstBinaryExpression(loc, op, lhs, rhs);
    }

    switch (trange.front.type) with (TokenType) {
        case EqualEqual:               processToken(BinaryOp.Equal);                 break;
        case BangEqual:                processToken(BinaryOp.NotEqual);              break;
        case More:                     processToken(BinaryOp.Greater);               break;
        case MoreEqual:                processToken(BinaryOp.GreaterEqual);          break;
        case Less:                     processToken(BinaryOp.Less);                  break;
        case LessEqual:                processToken(BinaryOp.LessEqual);             break;
        case BangLessMoreEqual:        processToken(BinaryOp.Unordered);             break;
        case BangLessMore:             processToken(BinaryOp.UnorderedEqual);        break;
        case LessMore:                 processToken(BinaryOp.LessGreater);           break;
        case LessMoreEqual:            processToken(BinaryOp.LessEqualGreater);      break;
        case BangMore:                 processToken(BinaryOp.UnorderedLessEqual);    break;
        case BangMoreEqual:            processToken(BinaryOp.UnorderedLess);         break;
        case BangLess:                 processToken(BinaryOp.UnorderedGreaterEqual); break;
        case BangLessEqual:            processToken(BinaryOp.UnorderedGreater);      break;
        case Is:                       processToken(BinaryOp.Identical);             break;
        case In:                       processToken(BinaryOp.In);                    break;
        case As:                       processToken(BinaryOp.As);                    break; // TODO: is this ok here?
        case QuestionMarkQuestionMark: processToken(BinaryOp.NullCoalescing);        break;

        case Bang:
            trange.popFront();

            switch (trange.front.type) {
                case Is: processToken(BinaryOp.NotIdentical); break;
                case In: processToken(BinaryOp.NotIn);        break;
                default: assert(false, "Error pyco");
            }
            break;
        default:
    }

    return lhs;
}


// <<, >>, >>>
AstExpression parseShiftExpression(ref TokenRange trange) {
    return trange.parseShiftExpression(trange.parsePrefixExpression());
}

AstExpression parseShiftExpression(ref TokenRange trange, AstExpression lhs) {
    lhs = trange.parseAddExpression(lhs);
    Location loc = lhs.location;

    while (true) {
        void processToken(BinaryOp op) {
            trange.popFront();
            auto rhs = trange.parseAddExpression();

            loc.spanTo(rhs.location);
            lhs = new AstBinaryExpression(loc, op, lhs, rhs);
        }

        switch (trange.front.type) with (BinaryOp) with (TokenType) {
            case LessLess:     processToken(LeftShift);   break;
            case MoreMore:     processToken(SRightShift); break;
            case MoreMoreMore: processToken(URightShift); break;
            default: return lhs;
        }
    }
}


// +, -, ~
AstExpression parseAddExpression(ref TokenRange trange) {
    return trange.parseAddExpression(trange.parsePrefixExpression());
}

AstExpression parseAddExpression(ref TokenRange trange, AstExpression lhs) {
    lhs = trange.parseMulExpression(lhs);
    Location loc = lhs.location;

    while (true) {
        void processToken(BinaryOp op) {
            trange.popFront();
            auto rhs = trange.parseMulExpression();

            loc.spanTo(rhs.location);
            lhs = new AstBinaryExpression(loc, op, lhs, rhs);
        }

        switch (trange.front.type) with (BinaryOp) with (TokenType) {
            case Plus:  processToken(Add);    break;
            case Minus: processToken(Sub);    break;
            case Tilde: processToken(Concat); break;
            default: return lhs;
        }
    }
}


// *, /, %
AstExpression parseMulExpression(ref TokenRange trange) {
    return trange.parseMulExpression(trange.parsePrefixExpression());
}

AstExpression parseMulExpression(ref TokenRange trange, AstExpression lhs) {
    Location loc = lhs.location;

    while (true) {
        void processToken(BinaryOp op) {
            trange.popFront();
            auto rhs = trange.parsePrefixExpression();

            loc.spanTo(rhs.location);
            lhs = new AstBinaryExpression(loc, op, lhs, rhs);
        }

        switch (trange.front.type) with (BinaryOp) with (TokenType) {
            case Asterisk: processToken(Mul); break;
            case Slash:    processToken(Div); break;
            case Percent:  processToken(Rem); break;
            default: return lhs;
        }
    }
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


AstExpression parsePrimaryExpression(ref TokenRange trange) {
    Location loc = trange.front.location;

    switch (trange.front.type) with (TokenType) {
        case Identifier: assert(false, "TODO"); // TODO
        case Dot: assert(false); // TODO
        case Self: assert(false); // TODO
        case Super: assert(false); // TODO
        case True: assert(false); // TODO
        case False: assert(false); // TODO
        case Null: assert(false); // TODO
        case IntegerLiteral: assert(false); // TODO
        case StringLiteral: assert(false); // TODO
        case CharacterLiteral: assert(false); // TODO


        case OpenBracket: assert(false); // TODO
        case OpenBrace: assert(false); // TODO
        case Function: assert(false); // TODO
        case Delegate: assert(false); // TODO
        // __FILE__
        // __LINE__
        case Dollar: assert(false); // TODO
        case TypeId: assert(false); // TODO
        case NameOf: assert(false); // TODO
        case Is: assert(false); // TODO
        case Mixin: assert(false); // TODO
        case OpenParen: assert(false); // TODO

        default:
            // TODO
    }

    assert(false, "LOLO");
}


/*
 * Parse postfix expr. [ ... ], ++, --, .identifier, ?.identifier
 */
 AstExpression parsePostfixExpression(ParseMode mode)(ref TokenRange trange, AstExpression expr) {
    Location loc;

    while (true) {
        bool isConditional;

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

            case QuestionMarkOpenBracket:
                isConditional = true;
                goto case;

            case OpenBracket:
                trange.popFront();

                if (trange.front.type == CloseBracket) {
                    assert(false, "TODO"); // TODO
                }

                auto args = trange.parseArguments();
                switch (trange.front.type) {
                    case CloseBracket:
                        loc.spanTo(trange.front.location);
                        expr = new AstIndexExpression(loc, expr, args, isConditional);
                        break;

                    case DotDot:
                        trange.popFront();
                        auto end = trange.parseArguments();

                        loc.spanTo(trange.front.location);
                        expr = new AstSliceExpression(loc, expr, args, end, isConditional);
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

    assert(false);
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