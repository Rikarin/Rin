module Parser.Statement;

import Lexer;
import Tokens;
import Domain.Name;
import Domain.Location;
import Ast.Statement;
import Ast.Expression;

import Parser.Expression;
import Parser.Utils;


Statement parseStatement(ref TokenRange trange) {
    Location loc = trange.front.location;

    switch (trange.front.type) with (TokenType) {
        case OpenBrace: return trange.parseBlock();

        case Identifier: assert(false, "TODO");

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

                loc.spanTo(ifFalse.location);
            } else {
                loc.spanTo(ifTrue.location);
            }

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

        case Foreach: // TODO: reverse?
            assert(false); // TODO

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
        //case Goto:
            //assert(false);
        case Scope:
            assert(false);
        case Assert:
            assert(false);
        case Throw:
            assert(false);
        case Try:
            assert(false);
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
