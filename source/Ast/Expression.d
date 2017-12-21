module Ast.Expression;
@safe:

import Domain.Location;
import Domain.Context;
import Common.Node;
import Common.IVisitor;
import Ast.Type;


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
	Not
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
		case Complement:  return "~" ~ s;
	}
}

class AstUnaryExpression : AstExpression {
	AstExpression expression;
	UnaryOp op;

	this(Location location, UnaryOp op, AstExpression expression) {
		super(location);

		this.op = op;
		this.expression = expression;
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
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
	As, // TODO: parse in postfix? (cuz (int) is parsed in prefix)
	NullCoalescing, // TODO
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

class AstBinaryExpression : AstExpression {
	BinaryOp op;
	AstExpression lhs;
	AstExpression rhs;

	this(Location location, BinaryOp op, AstExpression lhs, AstExpression rhs) {
		super(location);

		this.op  = op;
		this.lhs = lhs;
		this.rhs = rhs;
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// (int)expr
class AstCastExpression : AstExpression {
	AstType type;
	AstExpression expr;

	this(Location location, AstType type, AstExpression expr) {
		super(location);

		this.type = type;
		this.expr = expr;
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// expr as Type
class AstAsExpression : AstExpression {
	AstType type;
	AstExpression expr;

	this(Location location, AstType type, AstExpression expr) {
		super(location);

		this.type = type;
		this.expr = expr;
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// callee(args)
class AstCallExpression : AstExpression {
	AstExpression callee;
	AstExpression[] args;

	this(Location location, AstExpression callee, AstExpression[] args) {
		super(location);

		this.callee = callee;
		this.args   = args;
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// indexed[arguments]
class AstIndexExpression : AstExpression {
	AstExpression indexed;
	AstExpression[] arguments;
	bool isConditional;

	this(Location location, AstExpression indexed, AstExpression[] arguments, bool isConditional) {
		super(location);

		this.indexed       = indexed;
		this.arguments     = arguments;
		this.isConditional = isConditional;
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// sliced[start .. end]
class AstSliceExpression : AstExpression {
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

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// identifier is identifier
class AstIsExpression : AstExpression {
	AstType tested;

	this(Location location, AstType tested) {
		super(location);

		this.tested = tested;
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// $
class AstDollarExpression : AstExpression {
	this(Location location) {
		super(location);
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// self
class AstSelfExpression : AstExpression {
	this(Location location) {
		super(location);
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// __FILE__
class __File__Literal : AstExpression {
	this(Location location) {
		super(location);
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


// __LINE__
class __Line__Literal : AstExpression {
	this(Location location) {
		super(location);
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}