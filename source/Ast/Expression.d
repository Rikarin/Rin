module Ast.Expression;
@safe:

import Domain.Name;
import Domain.Location;
import Domain.Context;
import Common.Node;
import Common.IVisitor;

import Ast.Type;
import Ast.Identifiers;
import Ast.Declaration;


abstract class AstExpression : Node {
	this(Location location) {
		super(location);
	}
	
	string toString(const Context) const {
		assert(0, "toString not implement for " ~ typeid(this).toString());
	}
}


// Unary operators
enum UnaryOp {
	AddressOf,
	Await,
	Dereference,
	PreInc,
	PreDec,
	PostInc,
	PostDec,
	Plus,
	Minus,
	Complement,
	Not,
	Unwrap
}

string unarizeString(string s, UnaryOp op) {
	final switch(op) with(UnaryOp) {
		case AddressOf:   return "&" ~ s;
		case Await:       return "await " ~ s;
		case Dereference: return "*" ~ s;
		case PreInc:      return "++" ~ s;
		case PreDec:      return "--" ~ s;
		case PostInc:     return s ~ "++";
		case PostDec:     return s ~ "--";
		case Plus:        return "+" ~ s;
		case Minus:       return "-" ~ s;
		case Not:         return "!" ~ s;
		case Unwrap:      return s ~ "!";
		case Complement:  return "~" ~ s;
	}
}

final class AstUnaryExpression : AstExpression {
	AstExpression expr;
	UnaryOp op;

	this(Location location, UnaryOp op, AstExpression expr) {
		super(location);

		this.op   = op;
		this.expr = expr;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// Binary operators
enum BinaryOp {
	Comma,
	Assign,
	Add,
	Sub,
	Mul,
	Pow,
	Div,
	Rem,
	Or,
	And,
	Xor,
	LeftShift,
	URightShift,
	SRightShift,
	LogicalOr,
	LogicalAnd,
	Concat,
	AddAssign,
	SubAssign,
	MulAssign,
	PowAssign,
	DivAssign,
	RemAssign,
	OrAssign,
	AndAssign,
	XorAssign,

	LeftShiftAssign,
	URightShiftAssign,
	SRightShiftAssign,
	LogicalOrAssign,
	LogicalAndAssign,
	ConcatAssign,
	Equal,
	NotEqual,
	Identical,
	NotIdentical,
	In,
	NotIn,
	As,
	NullCoalescing,
	Greater,
	GreaterEqual,
	Less,
	LessEqual,

	// Some floating stuff
	LessGreater,
	LessEqualGreater,
	UnorderedLess,
	UnorderedLessEqual,
	UnorderedGreater,
	UnorderedGreaterEqual,
	Unordered,
	UnorderedEqual
}

final class AstBinaryExpression : AstExpression {
	BinaryOp op;
	AstExpression lhs;
	AstExpression rhs;

	this(Location location, BinaryOp op, AstExpression lhs, AstExpression rhs) {
		super(location);

		this.op  = op;
		this.lhs = lhs;
		this.rhs = rhs;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


final class AstTernaryExpression : AstExpression {
	AstExpression condition;
	AstExpression ifTrue;
	AstExpression ifFalse;

	this(Location location, AstExpression condition, AstExpression ifTrue, AstExpression ifFalse) {
		super(location);

		this.condition = condition;
		this.ifTrue    = ifTrue;
		this.ifFalse   = ifFalse;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// (int)expr
final class AstCastExpression : AstExpression {
	AstType type;
	AstExpression expr;

	this(Location location, AstType type, AstExpression expr) {
		super(location);

		this.type = type;
		this.expr = expr;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// expr as Type
final class AstAsExpression : AstExpression {
	AstType type;
	bool isNullable;
	AstExpression expr;

	this(Location location, AstType type, bool isNullable, AstExpression expr) {
		super(location);

		this.type       = type;
		this.isNullable = isNullable;
		this.expr       = expr;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// identifier(args)
final class IdentifierCallExpression : AstExpression {
	Identifier callee;
	AstExpression[] args;

	this(Location location, Identifier callee, AstExpression[] args) {
		super(location);

		this.callee = callee;
		this.args   = args;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// type(args)
final class AstTypeCallExpression : AstExpression {
	AstType type;
	AstExpression[] args;

	this(Location location, AstType type, AstExpression[] args) {
		super(location);

		this.type = type;
		this.args = args;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// callee(args)
final class AstCallExpression : AstExpression {
	AstExpression callee;
	AstExpression[] args;

	this(Location location, AstExpression callee, AstExpression[] args) {
		super(location);

		this.callee = callee;
		this.args   = args;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// indexed[arguments]
final class AstIndexExpression : AstExpression {
	AstExpression indexed;
	AstExpression[] arguments;
	bool isConditional;

	this(Location location, AstExpression indexed, AstExpression[] arguments, bool isConditional) {
		super(location);

		this.indexed       = indexed;
		this.arguments     = arguments;
		this.isConditional = isConditional;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// sliced[start .. end]
final class AstSliceExpression : AstExpression {
	AstExpression sliced;
	AstExpression[] start;
	AstExpression[] end;
	bool isConditional;

	this(Location location, AstExpression sliced, AstExpression[] start, AstExpression[] end, bool isConditional) {
		super(location);

		this.sliced        = sliced;
		this.start         = start;
		this.end           = end;
		this.isConditional = isConditional;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// ()
final class ParenExpression : AstExpression {
	AstExpression expr;

	this(Location location, AstExpression expr) {
		super(location);

		this.expr = expr;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// identifier
final class IdentifierExpression : AstExpression {
	Identifier identifier;

	this(Identifier identifier) {
		super(identifier.location);

		this.identifier = identifier;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// TODO: delegate


// lambda
final class Lambda : AstExpression {
	ParamDecl[] params;
	AstExpression value;

	this(Location location, ParamDecl[] params, AstExpression value) {
		super(location);

		this.params = params;
		this.value  = value;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// $
final class DollarExpression : AstExpression {
	this(Location location) {
		super(location);
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// self
class SelfExpression : AstExpression {
	this(Location location) {
		super(location);
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// super
class SuperExpression : AstExpression {
	this(Location location) {
		super(location);
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// #file
class FileLiteral : AstExpression {
	this(Location location) {
		super(location);
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// #line
class LineLiteral : AstExpression {
	this(Location location) {
		super(location);
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// identifier = void;
final class AstVoidInitializer : AstExpression {
	this(Location location) {
		super(location);
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// typeof(identifier)
final class AstTypeOfExpression : AstExpression {
	Identifier identifier;

	this(Location location, Identifier identifier) {
		super(location);
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// nameof(identifier)
final class AstNameOfExpression : AstExpression {
	Identifier identifier;

	this(Location location, Identifier identifier) {
		super(location);
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// is()
final class IsExpression : AstExpression {
	AstType type;

	this(Location location, AstType type) {
		super(location);

		this.type = type;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


// <html> tags
final class HtmlExpression : AstExpression {
	Name identifier;
	// attribs
	AstExpression[] inner;

	this(Location location, Name identifier, AstExpression[] inner) {
		super(location);

		this.identifier = identifier;
		this.inner      = inner;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}