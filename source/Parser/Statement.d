module Parser.Statement;

import Lexer;
import Tokens;
import Domain.Name;
import Domain.Location;
import Ast.Statement;
import Ast.Expression;

import Parser.Utils;
import Parser.Expression;
import Parser.Identifiers;


Statement parseStatement(ref TokenRange trange) {
    Location loc = trange.front.location;

    switch (trange.front.type) with (TokenType) {
        case OpenBrace: return trange.parseBlock();

        case Identifier:
            /*auto lookAhead = trange.save;
            lookAhead.popFront();

            if (lookAhead.front.type == TokenType.Colon) {
                goto case Default;
            }*/

            goto default; // parse ambigous

        case If:
            trange.popFront();
            trange.match(OpenParen);

            auto cond = trange.parseExpression();
            trange.match(CloseParen);

            auto ifTrue = trange.parseBlock();
            
            BlockStatement ifFalse;
            if (trange.front.type == Else) {
                trange.popFront();
                ifFalse = trange.parseBlock();
            }

            loc.spanTo(trange.previous);
            return new IfStatement(loc, cond, ifTrue, ifFalse);

        case While:
            trange.popFront();

            trange.match(OpenParen);
            auto cond = trange.parseExpression();
            trange.match(CloseParen);

            auto block = trange.parseBlock();

            loc.spanTo(trange.previous);
            return new WhileStatement(loc, cond, block);

        case Repeat:
            trange.popFront();
            auto block = trange.parseBlock();

            trange.match(OpenParen);
            auto cond = trange.parseExpression();
            trange.match(CloseParen);
            trange.match(Semicolon);

            loc.spanTo(trange.previous);
            return new RepeatStatement(loc, cond, block);

        case For:
            trange.popFront();
            trange.match(OpenParen);

            // It's range
            if (trange.front.type == Identifier || trange.front.type == Ref) {
                // TODO: refactor this, we can have for (i, ref x in range)
                bool isRef;
                if (trange.front.type == Ref) {
                    trange.popFront();
                    isRef = true;
                }

                auto iter = trange.front.name;
                trange.match(Identifier);
                trange.match(In);

                auto expr = trange.parseExpression();
                AstExpression end;

                if (trange.front.type == DotDot) {
                    trange.popFront();
                    end = trange.parseExpression();
                }

                trange.match(CloseParen);
                auto block = trange.parseBlock();

                loc.spanTo(trange.previous);
                // TODO: fix nulls
                return end ? 
                    new ForInRangeStatement(loc, null, expr, end, block) : 
                    new ForInStatement(loc, null, expr, block);
            }

            Statement init;
            if (trange.front.type != Semicolon) {
                init = trange.parseStatement();
            } else {
                trange.popFront();
            }

            AstExpression cond;
            if (trange.front.type != Semicolon) {
                cond = trange.parseExpression();
            }

            trange.match(Semicolon);

            AstExpression increment;
            if (trange.front.type != CloseParen) {
                increment = trange.parseExpression();
            }

            trange.match(CloseParen);
            auto block = trange.parseBlock();

            loc.spanTo(trange.previous);
            return new ForStatement(loc, init, cond, increment, block);

        case Return:
            trange.popFront();

            AstExpression value;
            if (trange.front.type != Semicolon) {
                value = trange.parseExpression();
            }

            trange.match(Semicolon);

            loc.spanTo(trange.previous);
            return new ReturnStatement(loc, value);

        case Break:
            trange.popFront();
            trange.match(Semicolon);

            loc.spanTo(trange.previous);
            return new BreakStatement(loc);

        case Continue:
            trange.popFront();
            trange.match(Semicolon);

            loc.spanTo(trange.previous);
            return new ContinueStatement(loc);

        case Switch:
            trange.popFront();
            trange.match(OpenParen);

            auto expr = trange.parseExpression();
            trange.match(CloseParen);

            auto block = trange.parseBlock();

            loc.spanTo(trange.previous);
            return new SwitchStatement(loc, expr, block);

        case Case:
            trange.popFront();

            auto args = trange.parseArguments();
            trange.match(Colon);

            loc.spanTo(trange.previous);
            return new CaseStatement(loc, args);

        case Default:
            assert(false);

        case Goto:
            trange.popFront();
            Name name;

            switch (trange.front.type) {
                case Identifier, Default, Case:
                    name = trange.front.name;
                    trange.popFront();
                    break;

                default:
                    trange.match(Identifier);
            }

            loc.spanTo(trange.previous);
            return new GotoStatement(loc, name);

        case Defer:
            trange.popFront();
            auto type = DeferType.Exit;

            if (trange.front.type == OpenParen) {
                trange.popFront();
                auto name = trange.front.name;
                trange.match(Identifier);

                if (name == BuiltinName!"success") {
                    type = DeferType.Success;
                } else if (name == BuiltinName!"failure") {
                    type = DeferType.Failure;
                } else {
                    assert(false, name.toString(trange.context) ~ " is not a valid scope identifier.");
                }

                trange.match(CloseParen);
            }

            auto block = trange.parseBlock();

            loc.spanTo(trange.previous);
            return new DeferStatement(loc, type, block);

        case Assert:
            trange.popFront();
            trange.match(OpenParen);

            auto expr = trange.parseAssignExpression();
            AstExpression msg;
            if (trange.front.type == Comma) {
                trange.popFront();

                msg = trange.parseAssignExpression();
            }

            trange.match(CloseParen);
            trange.match(Semicolon);

            loc.spanTo(trange.previous);
            return new AssertStatement(loc, expr, msg);
            
        case Throw:
            trange.popFront();

            auto value = trange.parseExpression();
            trange.match(Semicolon);
            
            loc.spanTo(trange.previous);
            return new ThrowStatement(loc, value);

        case Try:
            trange.popFront();

            bool isNullable;
            if (trange.front.type == QuestionMark) {
                trange.popFront();
                isNullable = true;
            }

            auto tryStatement = isNullable ? 
                new ExpressionStatement(trange.front.location, trange.parseExpression()) :
                trange.parseBlock();

            CatchBlock[] catches;
            while (!isNullable && trange.front.type == Catch) {
                trange.popFront();
                trange.match(OpenParen);

                auto type = trange.parseIdentifier();
                Name name;

                if (trange.front.type == Identifier) {
                    name = trange.front.name;
                    trange.popFront();
                }

                auto block = trange.parseBlock();


                // TODO
            }

            // TODO: parse catches

            BlockStatement finallyBlock;
            if (!isNullable && trange.front.type == Finally) {
                trange.popFront();
                finallyBlock = trange.parseBlock();
            }

            loc.spanTo(trange.previous);
            return new TryStatement(loc, tryStatement, isNullable, null, finallyBlock);

        case Mixin:
            assert(false);
        case Static:
            assert(false);
        case Version:
            assert(false);
        case Debug:
            assert(false);

        case Lock:
            trange.popFront();

            Name name;    
            if (trange.front.type == OpenParen) {
                trange.popFront();
                name = trange.front.name;
                trange.match(CloseParen);
            }

            auto block = trange.parseBlock();
            loc.spanTo(trange.previous);
            return new LockStatement(loc, name, block);

        case Unsafe:
            trange.popFront();
            auto block = trange.parseBlock();

            loc.spanTo(trange.previous);
            return new UnsafeStatement(loc, block);

        default:
            // parse ambigous
    }
    
    assert(false);
}


BlockStatement parseBlock(ref TokenRange trange) {
    Location loc = trange.front.location;
    trange.match(TokenType.OpenBrace);

    Statement[] statements;
    while (trange.front.type != TokenType.CloseBrace) {
        statements ~= trange.parseStatement();
    }

    trange.popFront();
    loc.spanTo(trange.previous);
    return new BlockStatement(loc, statements);
}
