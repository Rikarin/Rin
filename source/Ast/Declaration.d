module Ast.Declaration;
@safe:

import Domain.Location;
import Domain.Context;
import Domain.Name;

import Common.Node;
import Common.IVisitor;
import Common.Qualifier;

import std.bitmanip;


struct StorageClass {
	mixin(bitfields!(
		TypeQualifier, "qualifier",      3,
		Linkage,       "linkage",        3,
		//bool,          "hasLinkage",     1,
		Visibility,    "visibility",     3,
		//bool,          "hasVisibility",  1,
		//bool,          "hasQualifier",   1,
		bool,          "isRef",          1,
		bool,          "isStatic",       1,
		bool,          "isEnum",         1,
		bool,          "isFinal",        1,
		bool,          "isAbstract",     1,
		bool,          "isDeprecated",   1,
		bool,          "isThrow",        1,
		bool,          "isOverride",     1,
		bool,          "isPure",         1,
		bool,          "isSynchronized", 1,
		bool,          "isGlobal",       1,
		bool,          "isProperty",     1,
		bool,          "isNoGC",         1,

		bool,          "isAsync",        1,
		bool,          "isUnsafe",       1,
		bool,          "isPartial",      1,
		uint,          "",               7,
	));

    static StorageClass defaults() {
        StorageClass ret;
        ret.visibility = Visibility.Default;

        return ret;
    }
}



abstract class Declaration : Node {
	this(Location location) {
		super(location);
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

    override void visit(IVisitor visitor) {
        visitor.accept(this);
    }
}


final class UsingDeclaration : Declaration {
    Name[] namespace;

    this(Location location, Name[] namespace) {
        super(location);

        this.namespace = namespace;
    }

    override void visit(IVisitor visitor) {
        visitor.accept(this);
    }
}


final class TupleDeclaration : Declaration {
	ParamDecl[] params;

	this(Location location, ParamDecl[] params) {
		super(location);

		this.params = params;
	}

	override void visit(IVisitor visitor) {
		visitor.accept(this);
	}
}


class ParamDecl {

}