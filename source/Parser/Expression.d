module Parser.Expression;
@safe:

import Tokens;
import Lexer;
import Domain.Name;
import Domain.Location;
import Domain.BuiltinType;

import Ast.Type;
import Ast.Expression;
import Ast.Identifiers;
import IR.Expression;

import Parser.Type;
import Parser.Utils;
import Parser.Identifiers;


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
        condition = new AstTernaryExpression(loc, condition, ifTrue, ifFalse);
    }

    return condition;
}


// ||
AstExpression parseLogicalOrExpression(ref TokenRange trange) {
    return trange.parseLogicalOrExpression(trange.parsePrefixExpression());
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
    return trange.parseLogicalAndExpression(trange.parsePrefixExpression());
}

AstExpression parseLogicalAndExpression(ref TokenRange trange, AstExpression lhs) {
    return trange.parseBinaryExpression!(
        TokenType.AmpersandAmpersand,
        BinaryOp.LogicalAnd,
        parseBitwiseOrExpression
    )(lhs);
}


// |
AstExpression parseBitwiseOrExpression(ref TokenRange trange) {
    return trange.parseBitwiseOrExpression(trange.parsePrefixExpression());
}

AstExpression parseBitwiseOrExpression(ref TokenRange trange, AstExpression lhs) {
    return trange.parseBinaryExpression!(
        TokenType.PipePipe,
        BinaryOp.LogicalOr,
        parseBitwiseXorExpression
    )(lhs);
}


// ^
AstExpression parseBitwiseXorExpression(ref TokenRange trange) {
    return trange.parseBitwiseXorExpression(trange.parsePrefixExpression());
}

AstExpression parseBitwiseXorExpression(ref TokenRange trange, AstExpression lhs) {
    return trange.parseBinaryExpression!(
        TokenType.Caret,
        BinaryOp.Xor,
        parseBitwiseAndExpression
    )(lhs);
}


// &
AstExpression parseBitwiseAndExpression(ref TokenRange trange) {
    return trange.parseBitwiseAndExpression(trange.parsePrefixExpression());
}

AstExpression parseBitwiseAndExpression(ref TokenRange trange, AstExpression lhs) {
    return trange.parseBinaryExpression!(
        TokenType.Ampersand,
        BinaryOp.And,
        parseComparisonExpression
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
        case Self:      trange.popFront(); return new SelfExpression(loc);
        case Super:     trange.popFront(); return new SuperExpression(loc);
        case Dollar:    trange.popFront(); return new DollarExpression(loc);
        case True:      trange.popFront(); return new BooleanLiteral(loc, true);
        case False:     trange.popFront(); return new BooleanLiteral(loc, false);
        case Null:      trange.popFront(); return new NullLiteral(loc);
        case SharpFile: trange.popFront(); return new FileLiteral(loc);
        case SharpLine: trange.popFront(); return new LineLiteral(loc);

        case Identifier:       return trange.parseIdentifierExpression(trange.parseIdentifier());
        case Dot:              return trange.parseIdentifierExpression(trange.parseDotIdentifier());
        case Is:               return trange.parseIsExpression();
        case Less:             return trange.parseHtmlTag();
        case IntegerLiteral:   return trange.parseIntegerLiteral();
        case StringLiteral:    return trange.parseStringLiteral();
        case CharacterLiteral: return trange.parseCharacterLiteral();

        case OpenBracket:
            AstExpression[] keys;
            AstExpression[] values;

            do {
                trange.popFront();
                auto value = trange.parseAssignExpression();

                if (trange.front.type == Colon) {
                    trange.popFront();
                    keys   ~= value;
                    values ~= trange.parseAssignExpression();
                } else {
                    values ~= value;
                }
            } while (trange.front.type == Comma);

            loc.spanTo(trange.previous);
            trange.match(CloseBracket);
            assert(false); // TODO: array expr

        case OpenParen: assert(false); // TODO: tuple expr + something else

        case TypeOf: 
            trange.popFront();
            trange.match(OpenParen);

            auto ident = trange.parseIdentifier();
            trange.match(CloseParen);

            loc.spanTo(trange.previous);
            return new AstTypeOfExpression(loc, ident);
            
        case NameOf: 
            trange.popFront();
            trange.match(OpenParen);

            auto ident = trange.parseIdentifier();
            trange.match(CloseParen);

            loc.spanTo(trange.previous);
            return new AstNameOfExpression(loc, ident);

        case Default:
            trange.popFront();
            trange.match(OpenParen);

            if (trange.front.type == Identifier) {
                trange.parseIdentifier(); // TODO
            } else {
                trange.parseType(); // TODO
            }
            
            loc.spanTo(trange.previous);
            assert(false); // TODO

        case TypeId: assert(false); // TODO
        case Mixin: assert(false); // TODO

        default:
            auto type = trange.parseType!(ParseMode.Reluctant)();

            switch (trange.front.type) {
                case Dot:
                    trange.popFront();
                    return trange.parseIdentifierExpression(trange.parseQualifiedIdentifier(loc, type));

                case OpenParen:
                    auto args = trange.parseArguments!OpenParen();
                    loc.spanTo(trange.previous);
                    return new AstTypeCallExpression(loc, type, args);

                default:
            }

            assert(false, "Reached unreachable code!");
    }
}


/*
 * Parse postfix expr. [ ... ], ++, --, !, .identifier, ?.identifier
 */
 AstExpression parsePostfixExpression(ParseMode mode)(ref TokenRange trange, AstExpression expr) {
    Location loc;

    while (true) {
        switch (trange.front.type) with (TokenType) {
            case PlusPlus:
                trange.popFront();

                loc.spanTo(trange.previous);
                expr = new AstUnaryExpression(loc, UnaryOp.PostInc, expr);
                break;

            case MinusMinus:
                trange.popFront();

                loc.spanTo(trange.previous);
                expr = new AstUnaryExpression(loc, UnaryOp.PostDec, expr);
                break;

            case OpenParen:
                auto args = trange.parseArguments!OpenParen();

                loc.spanTo(trange.previous);
                expr = new AstCallExpression(loc, expr, args);
                break;

            case Bang:
                trange.popFront();

                loc.spanTo(trange.previous);
                expr = new AstUnaryExpression(loc, UnaryOp.Unwrap, expr);
                break;

            case As:
                trange.popFront();

                bool isNullable;
                if (trange.front.type == QuestionMark) {
                    trange.popFront();
                    isNullable = true;
                }

                auto type = trange.parseType();
                loc.spanTo(type.location);

                expr = new AstAsExpression(loc, type, isNullable, expr);
                break;

            case OpenBracket, QuestionMarkOpenBracket:
                const isCond = trange.front.type == QuestionMarkOpenBracket;
                trange.popFront();

                if (trange.front.type == CloseBracket) {
                    if (isCond) {
                        assert(false, "Slicing cannot be conditional");
                    }

                    assert(false, "TODO"); // TODO: slice operator
                }

                auto args = trange.parseArguments();
                switch (trange.front.type) {
                    case CloseBracket:
                        loc.spanTo(trange.front.location);
                        expr = new AstIndexExpression(loc, expr, args, isCond);
                        break;

                    case DotDot:
                        trange.popFront();
                        auto end = trange.parseArguments();

                        loc.spanTo(trange.front.location);
                        expr = new AstSliceExpression(loc, expr, args, end, isCond);
                        break;

                    default:
                        trange.match(CloseBracket);
                }
                break;

            static if (mode == ParseMode.Greedy) {
            case Dot:
            case QuestionMarkDot:
                const isConditional = trange.front.type == QuestionMarkDot;
                trange.popFront();

                expr = trange.parseIdentifierExpression(trange.parseQualifiedIdentifier(loc, expr));
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


private auto parseIsExpression(ref TokenRange trange) {
    Location loc = trange.front.location;

    trange.match(TokenType.Is);
    trange.match(TokenType.OpenParen);

    auto type = trange.parseType();

    Name identifier;
    if (trange.front.type == TokenType.Identifier) {
        identifier = trange.front.name;
        trange.popFront();
    }

    if (trange.front.type == TokenType.Colon) {
        trange.popFront();
        // TODO
    } else if (trange.front.type == TokenType.EqualEqual) {
        trange.popFront();
        // TODO
    } else {
        trange.match(TokenType.EqualEqual);
    }

    switch (trange.front.type) with (TokenType) {
        case Struct, Union, Class, Interface, Enum,
            Super, Const, ReadOnly, Inout, Shared, Return:
            assert(false, "TODO"); // TODO:

        default:
            trange.parseType(); // TODO
    }

    while (trange.front.type == TokenType.Comma) {
        assert(false); // TODO: parse template arguments
    }

    trange.match(TokenType.CloseParen);

    loc.spanTo(trange.previous);
    return new IsExpression(loc, type);
}


AstExpression[] parseArguments(TokenType open)(ref TokenRange trange) {
    alias close = TokenType.CloseParen; // TODO: fix this

    trange.match(open);
    if (trange.front.type == close) {
        trange.popFront();
        return [];
    }

    auto args = trange.parseArguments();    
    trange.match(close);
    return args;
}


AstExpression[] parseArguments(ref TokenRange trange) {
    AstExpression[] args = [trange.parseAssignExpression()];

    while (trange.front.type == TokenType.Comma) {
        trange.popFront();
        args ~= trange.parseAssignExpression();
    }

    return args;
}


AstExpression parseIdentifierExpression(ref TokenRange trange, Identifier identifier) {
    if (trange.front.type != TokenType.OpenParen) {
        return new IdentifierExpression(identifier);
    }

    auto args = trange.parseArguments!(TokenType.OpenParen)();
    auto loc = identifier.location;

    loc.spanTo(trange.previous);
    return new IdentifierCallExpression(loc, identifier, args);
}


HtmlExpression parseHtmlTag(ref TokenRange trange) {
    Location loc = trange.front.location;
    trange.match(TokenType.Less);

    auto identifier = trange.front.name;
    trange.match(TokenType.Identifier);

    // TODO: parse attribs

    bool isClosed;
    if (trange.front.type == TokenType.Slash) { // <identifier />
        trange.popFront();
        isClosed = true;
    }

    trange.match(TokenType.More);

    AstExpression[] inner;
    while (!isClosed) {
        switch (trange.front.type) with(TokenType) {
            case Less:
                auto lookAhead = trange.save;
                lookAhead.popFront();

                if (lookAhead.front.type == Slash) {
                    trange.popFront();
                    trange.popFront();

                    assert(trange.front.name == identifier, "Miss matching HTML tag");
                    trange.match(Identifier);
                    trange.match(More);

                    isClosed = true;
                    break;
                }

                inner ~= trange.parseHtmlTag();
                break;

            case Identifier: assert(false); // TODO

            case OpenBrace:
                assert(false); // TODO
                //inner ~= trange.ParseStatement();
                //trange.match(CloseBrace);
                //break;

            default:
                assert(false);
        }
    }

    return new HtmlExpression(loc, identifier, inner);
}


private StringLiteral parseStringLiteral(ref TokenRange trange) {
    Location loc = trange.front.location;
    auto str = trange.front.name;
    trange.popFront();

    return new StringLiteral(loc, str.toString(trange.context));
}


private CharacterLiteral parseCharacterLiteral(ref TokenRange trange) {
    Location loc = trange.front.location;
    auto str = trange.front.name.toString(trange.context);
    assert(str.length == 1);

    trange.popFront();
    return new CharacterLiteral(loc, str[0], BuiltinType.Char);
}


private IntegerLiteral parseIntegerLiteral(ref TokenRange trange) {
	Location loc = trange.front.location;
	
	auto strVal = trange.front.name.toString(trange.context);
	assert(strVal.length > 0);
	
	trange.match(TokenType.IntegerLiteral);
	
	bool isUnsigned, isLong;
	if (strVal.length > 1) {
		switch (strVal[$ - 1]) {
			case 'U':
				isUnsigned = true;
				
				if (strVal[$ - 2] == 'L') {
					isLong = true;
					strVal = strVal[0 .. $ - 2];
				} else {
					strVal = strVal[0 .. $ - 1];
				}
				break;
			
			case 'L':
				isLong = true;
				
				if (strVal[$ - 2] == 'U') {
					isUnsigned = true;
					strVal = strVal[0 .. $ - 2];
				} else {
					strVal = strVal[0 .. $ - 1];
				}
				break;
			
			default:
		}
	}
	
	ulong value;
	
	assert(strVal.length > 0);
	if (strVal[0] != '0' || strVal.length < 3) {
		goto ParseDec;
	}
	
	switch (strVal[1]) {
		case 'x':
			value = strToHexInt(strVal[2 .. $]);
			goto CreateLiteral;
		
		case 'b':
			value = strToBinInt(strVal[2 .. $]);
			goto CreateLiteral;
		
		default:
	}
	
	ParseDec: value = strToDecInt(strVal);
	CreateLiteral:
	
	auto type = isUnsigned
		? ((isLong || value > uint.max) ? BuiltinType.Ulong : BuiltinType.Uint)
		: ((isLong || value > int.max) ? BuiltinType.Long : BuiltinType.Int);
	
	return new IntegerLiteral(loc, value, type);
}

ulong strToDecInt(string s) {
	ulong ret;
	
	for (uint i = 0; i < s.length; i++) {
		if (s[i] == '_') continue;
		
		ret *= 10;
		
		auto d = s[i] - '0';
		assert(d < 10, "Only digits are expected here");
		ret += d;
	}
	
	return ret;
}

ulong strToBinInt(string s) {
	ulong ret;
	
	for (uint i = 0; i < s.length; i++) {
		if (s[i] == '_') continue;
		
		ret <<= 1;
		auto d = s[i] - '0';
		assert(d < 2, "Only 0 and 1 are expected here");
		ret |= d;
	}
	
	return ret;
}

ulong strToHexInt(string s) {
	ulong ret;
	
	for (uint i = 0; i < s.length; i++) {
		if (s[i] == '_') continue;
		
		ret *= 16;
		
		auto d = s[i] - '0';
		if (d < 10) {
			ret += d;
			continue;
		}
		
		auto h = (s[i] | 0x20) - 'a' + 10;
		assert(h - 10 < 6, "Only hex digits are expected here");
		ret += h;
	}
	
	return ret;
}