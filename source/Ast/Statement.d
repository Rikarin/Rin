module Ast.Statement;
@safe:

import Ast.Expression;
import Ast.Identifiers;
import Ast.Declaration;

import Common.Node;
import Common.IVisitor;

import Domain.Name;
import Domain.Location;


abstract class Statement : Node {
    this(Location location) {
        super(location);
    }
}


final class BlockStatement : Statement {
    Statement[] statements;

    this(Location location, Statement[] statements) {
        super(location);

        this.statements = statements;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class ExpressionStatement : Statement {
    AstExpression expr;

    this(Location location, AstExpression expr) {
        super(location);

        this.expr = expr;
    }
    
    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class DeclarationStatement : Statement {
    Declaration decl;

    this(Location location, Declaration decl) {
        super(location);

        this.decl = decl;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class IfStatement : Statement {
    AstExpression condition;
    BlockStatement ifTrue;
    BlockStatement ifFalse;

    this(Location location, AstExpression condition, BlockStatement ifTrue, BlockStatement ifFalse) {
        super(location);

        this.condition = condition;
        this.ifTrue    = ifTrue;
        this.ifFalse   = ifFalse;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class WhileStatement : Statement {
    AstExpression condition;
    BlockStatement block;

    this(Location locaiton, AstExpression condition, BlockStatement block) {
        super(location);

        this.condition = condition;
        this.block     = block;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class RepeatStatement : Statement {
    AstExpression condition;
    BlockStatement block;

    this(Location locaiton, AstExpression condition, BlockStatement block) {
        super(location);

        this.condition = condition;
        this.block     = block;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


// TODO: what is this used for?
final class IdentifierAsteriskIdentifierStatement : Statement {
    Name name;
    Identifier identifier;
    AstExpression value;

    this(Location location, Name name, Identifier identifier, AstExpression value) {
        super(location);

        this.name       = name;
        this.identifier = identifier;
        this.value      = value;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class ForStatement : Statement {
    Statement initialize;
    AstExpression condition;
    AstExpression increment;
    BlockStatement block;

    this(Location location, Statement initialize, AstExpression condition, AstExpression increment, BlockStatement block) {
        super(location);

        this.initialize = initialize;
        this.condition  = condition;
        this.increment  = increment;
        this.block      = block;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class ForInStatement : Statement {
    ParamDecl[] params;
    AstExpression iterated;
    BlockStatement block;

    this(Location location, ParamDecl[] params, AstExpression iterated, BlockStatement block) {
        super(location);

        this.params    = params;
        this.iterated  = iterated;
        this.block     = block;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class ForInRangeStatement : Statement {
    ParamDecl[] params;
    AstExpression start;
    AstExpression stop;
    BlockStatement block;

    this(Location location, ParamDecl[] params, AstExpression start, AstExpression stop, BlockStatement block) {
        super(location);

        this.params    = params;
        this.start     = start;
        this.stop      = stop;
        this.block     = block;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class ReturnStatement : Statement {
    AstExpression value;    

    this(Location location, AstExpression value) {
        super(location);

        this.value = value;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class SwitchStatement : Statement {
    AstExpression expr;
    BlockStatement block;

    this(Location location, AstExpression expr, BlockStatement block) {
        super(location);

        this.expr  = expr;
        this.block = block;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class CaseStatement : Statement {
    AstExpression[] cases;

    this(Location location, AstExpression[] cases) {
        super(location);

        this.cases = cases;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class BreakStatement : Statement {
    this(Location location) {
        super(location);
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class ContinueStatement : Statement {
    this(Location location) {
        super(location);
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class GotoStatement : Statement {
    Name name;

    this(Location location, Name name) {
        super(location);

        this.name = name;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class LockStatement : Statement {
    Name name;
    BlockStatement block;

    this(Location location, Name name, BlockStatement block) {
        super(location);

        this.name  = name;
        this.block = block;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class UnsafeStatement : Statement {
    BlockStatement block;

    this(Location location, BlockStatement block) {
        super(location);

        this.block = block;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


enum DeferType {
    Exit,
    Success,
    Failure
}

final class DeferStatement : Statement {
    DeferType type;
    Statement statement;

    this(Location location, DeferType type, Statement statement) {
        super(location);

        this.type      = type;
        this.statement = statement;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class AssertStatement : Statement {
    AstExpression condition;
    AstExpression message;

    this(Location location, AstExpression condition, AstExpression message) {
        super(location);

        this.condition = condition;
        this.message   = message;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class ThrowStatement : Statement {
    AstExpression value;

    this(Location location, AstExpression value) {
        super(location);

        this.value = value;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class TryStatement : Statement {
    Statement tryStatement;
    CatchBlock[] catches;
    BlockStatement finallyBlock;
    bool isNullable;

    this(Location location, Statement tryStatement, bool isNullable, CatchBlock[] catches, BlockStatement finallyBlock) {
        super(location);

        this.tryStatement = tryStatement;
        this.isNullable   = isNullable;
        this.catches      = catches;
        this.finallyBlock = finallyBlock;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


struct CatchBlock {
    Location location;
    Identifier type;
    BlockStatement block;

    this(Location location, Identifier type, BlockStatement block) {
        this.location = location;
        this.type     = type;
        this.block    = block;
    }
}


final class GetStatement : Statement {
    BlockStatement block;

    this(Location location, BlockStatement block) {
        super(location);

        this.block = block;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class SetStatement : Statement {
    BlockStatement block;

    this(Location location, BlockStatement block) {
        super(location);

        this.block = block;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}