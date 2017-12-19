module Ast.Expression;
@safe:

import Domain.Location;
import Domain.Context;
import Common.Node;
import Common.IVisitor;


abstract class AstExpression : Node {
	this(Location location) {
		super(location);
	}
	
	string toString(const Context) const {
		assert(0, "toString not implement for " ~ typeid(this).toString());
	}
}



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



enum BinaryOp {
	//Comma,
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
	LeftShirt,
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
	ContactAssign,
	Equal,
	NotEqual,
	Identical,
	NotIdentical,
	In,
	NotIn,
	As, // TODO
	NullCoalescing, // TODO
	Greater,
	GreaterEqual,
	Less,
	LessEqual,

	// Some float stuff
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




class AstCastExpression : AstExpression {
	// TODO: type
	AstExpression expr;

	this(Location location, AstExpression expr) {
		super(location);

		this.expr = expr;
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}