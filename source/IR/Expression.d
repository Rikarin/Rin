module IR.Expression;
@safe:

import Ast.Expression;
import Common.IVisitor;
import Domain.Location;
import Domain.BuiltinType;


class Type {
    // TODO

    static Type get(BuiltinType type) {
        return new Type;
    }
}


abstract class Expression : AstExpression {
    Type type;

    this(Location location, Type type) {
        super(location);

        this.type = type;
    }

    bool isLvalue() const {
        return false;
    }
}


abstract class CompileTimeExpression : Expression {
    this(Location location, Type type) {
        super(location, type);
    } 
}


final class NullLiteral : CompileTimeExpression {
    this(Location location) {
        super(location, Type.get(BuiltinType.Null));
    }

    override void accept(IVisitor visitor) {
        //visitor.visit(this);
    }
}


final class BooleanLiteral : CompileTimeExpression {
    bool value;

    this(Location location, bool value) {
        super(location, Type.get(BuiltinType.Bool));

        this.value = value;
    }

    override void accept(IVisitor visitor) {
        //visitor.visit(this);
    }
}


final class IntegerLiteral : CompileTimeExpression {
    ulong value;

    this(Location location, ulong value, BuiltinType type) {
        super(location, Type.get(type));

        this.value = value;
    }

    override void accept(IVisitor visitor) {
        //visitor.visit(this);
    }
}


final class CharacterLiteral : CompileTimeExpression {
    dchar value;

    this(Location location, dchar value, BuiltinType type) {
        super(location, Type.get(type));

        this.value = value;
    }

    override void accept(IVisitor visitor) {
        //visitor.visit(this);
    }
}


final class StringLiteral : CompileTimeExpression {
    string value;

    this(Location location, string value) {
        super(location, Type.get(BuiltinType.Char)); // TODO

        this.value = value;
    }

    override void accept(IVisitor visitor) {
        //visitor.visit(this);
    }
}
