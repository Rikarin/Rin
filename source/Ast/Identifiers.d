module Ast.Identifiers;
@safe:

import Domain.Name;
import Domain.Location;

import Common.Node;
import Common.IVisitor;

import Ast.Type;
import Ast.Expression;


abstract class Identifier : Node {
    Name name;

    this(Location location, Name name) {
        super(location);

        this.name = name;
    }
}


abstract class TemplateArgument : Node {
    this(Location location) {
        super(location);
    }
}


final class BasicIdentifier : Identifier {
    this(Location location, Name name) {
        super(location, name);
    }

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// identifier.identifier
final class IdentifierDotIdentifier : Identifier {
    Identifier identifier;

    this(Location location, Name name, Identifier identifier) {
        super(location, name);

        this.identifier = identifier;
    }

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// type.identifier
final class TypeDotIdentifier : Identifier {
    AstType type;

    this(Location location, Name name, AstType type) {
        super(location, name);

        this.type = type;
    }

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// expression.identifier
final class ExpressionDotIdentifier : Identifier {
    AstExpression expression;

    this(Location location, Name name, AstExpression expression) {
        super(location, name);

        this.expression = expression;
    }

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// TODO: template stuff


final class TypeTemplateArgument : TemplateArgument {
    AstType type;

    this(Location location, AstType type) {
        super(location);

        this.type = type;
    }

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
} 


final class ValueTemplateArgument : TemplateArgument {
    AstExpression value;

    this(AstExpression value) {
        super(value.location);

        this.value = value;
    }

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


final class IdentifierTemplateArgument : TemplateArgument {
    Identifier identifier;

    this(Identifier identifier) {
        super(identifier.location);

        this.identifier = identifier;
    }

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// .identifier
final class DotIdentifier : Identifier {
    this(Location location, Name name) {
        super(location, name);
    }

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// identifier[identifier]
final class IdentifierBracketIdentifier : Identifier {
    Identifier indexed;
    Identifier index;

    this(Location location, Identifier indexed, Identifier index) {
        super(location, indexed.name);

        this.indexed = indexed;
        this.index   = index;
    }

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// identifier[expression]
final class IdentifierBracketExpression : Identifier {
    Identifier indexed;
    AstExpression index;

    this(Location location, Identifier indexed, AstExpression index) {
        super(location, indexed.name);

        this.indexed = indexed;
        this.index   = index;
    }

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}






// TODO type? = try? expression; // ak to throwne excp, tak sa nastavy null
// TODO: explicit throws
// TODO: rename scope(exit) to defer
// TODO: get/set, willSet/didSet
// miesto if pri fci pouzit where

// partial class
// for (x in array) miesto foreachu, reverse je sracka, implementovat to v libke. for (x in array.reverse);

// konverzi zo stringu na int, const x = int("123");
// zrusit virtual. vsetko bude defaultne virtual a to co virtual byt nema, sa oznaci za final


// unwraping:
// const test: int? = 42;
// const x: int = test!;

// var test: Test? = Foo as? Test;

// rename __LINE__ to #line

// add 'any' variable types (C#'s dynamic equivalent)
// foo() -> any { } is equivalent to D's auto foo() { } even if it use any and not var keyword