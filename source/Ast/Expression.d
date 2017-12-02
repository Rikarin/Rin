module Ast.Expression;
@safe:

import Domain.Location;
import Domain.Context;
import Common.Node;


abstract class AstExpression : Node {
	this(Location location) {
		super(location);
	}
	
	string toString(const Context) const {
		assert(0, "toString not implement for " ~ typeid(this).toString());
	}
}