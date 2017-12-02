module Ast.Declaration;
@safe:

import Domain.Location;
import Domain.Context;
import Domain.Name;
import Common.Node;


abstract class Declaration : Node {
	this(Location location) {
		super(location);
	}
	
	string toString(const Context) const {
		assert(0, "toString not implement for " ~ typeid(this).toString());
	}
}


final class Namespace : Declaration {
    Name[] name;
    Declaration[] declarations;

    this(Location location, Name[] name, Declaration[] declarations) {
        super(location);

        this.name = name;
        this.declarations = declarations;
    }
}


final class UsingDeclaration : Declaration {
    Name[] namespace;

    this(Location location, Name[] namespace) {
        super(location);

        this.namespace = namespace;
    }
}