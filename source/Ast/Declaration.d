module Ast.Declaration;
@safe:

import Ast.Type;
import Ast.Statement;
import Ast.Expression;
import Ast.Identifiers;

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
		bool,          "isThrows",       1,
		bool,          "isOverride",     1,
		bool,          "isPure",         1,
		bool,          "isSynchronized", 1,
		bool,          "isGlobal",       1,
		bool,          "isProperty",     1,

		bool,          "isAsync",        1,
		bool,          "isUnsafe",       1,
		bool,          "isPartial",      1,
		uint,          "",               7 + 1,
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


abstract class StorageClassDeclaration : Declaration {
	StorageClass storageClass;

	this(Location location, StorageClass storageClass) {
		super(location);

		this.storageClass = storageClass;
	}
}


abstract class NamedDeclaration : StorageClassDeclaration {
	Name name;

	this(Location location, StorageClass storageClass, Name name) {
		super(location, storageClass);

		this.name = name;
	}
}


abstract class AstTemplateParameter : Declaration {
	Name name;

	this(Location location, Name name) {
		super(location);

		this.name = name;
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

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class UsingDeclaration : Declaration {
    Name[] namespace;

    this(Location location, Name[] namespace) {
        super(location);

        this.namespace = namespace;
    }

    override void accept(IVisitor visitor) {
        visitor.visit(this);
    }
}


final class TupleDeclaration : Declaration {
	ParamDecl[] params;

	this(Location location, ParamDecl[] params) {
		super(location);

		this.params = params;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


struct ParamDecl {
	Location location;
	AstType type;
	Name name;
	AstExpression value;
	
	this(Location location, AstType type, Name name, AstExpression value) {
		this.location = location;
		this.type     = type;
		this.name     = name;
		this.value    = value;
	}
}


final class VariableDeclaration : NamedDeclaration {
	AstType type;
	AstExpression value;

	this(Location location, StorageClass storageClass, Name name, AstType type, AstExpression value) {
		super(location, storageClass, name);

		this.type  = type;
		this.value = value;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


final class FunctionDeclaration : NamedDeclaration {
	AstType returnType;
	ParamDecl[] params;
	BlockStatement block;

	bool isVariadic;

	this(Location location, StorageClass storageClass, Name name, AstType returnType,
		ParamDecl[] params, bool isVariadic, BlockStatement block
	) {
		super(location, storageClass, name);

		this.returnType = returnType;
		this.params     = params;
		this.isVariadic = isVariadic;
		this.block      = block;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


final class PropertyDeclaration : NamedDeclaration {
	AstType returnType;
	BlockStatement block;

	this(Location location, StorageClass storageClass, Name name, AstType returnType, BlockStatement block) {
		super(location, storageClass, name);

		this.returnType = returnType;
		this.block = block;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


final class StructDeclaration : NamedDeclaration {
	Declaration[] members;

	this(Location location, StorageClass storageClass, Name name, Declaration[] members) {
		super(location, storageClass, name);

		this.members = members;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


final class UnionDeclaration : NamedDeclaration {
	Declaration[] members;

	this(Location location, StorageClass storageClass, Name name, Declaration[] members) {
		super(location, storageClass, name);

		this.members = members;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


final class ClassDeclaration : NamedDeclaration {
	Identifier[] bases;
	Declaration[] members;

	this(Location location, StorageClass storageClass, Name name, Identifier[] bases, Declaration[] members) {
		super(location, storageClass, name);

		this.bases   = bases;
		this.members = members;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


final class InterfaceDeclaration : NamedDeclaration {
	Identifier[] bases;
	Declaration[] members;

	this(Location location, StorageClass storageClass, Name name, Identifier[] bases, Declaration[] members) {
		super(location, storageClass, name);

		this.bases   = bases;
		this.members = members;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}


final class EnumDeclaration : NamedDeclaration {
	AstType type;
	VariableDeclaration[] variables;

	this(Location location, StorageClass storageClass, Name name, AstType type, VariableDeclaration[] variables) {
		super(location, storageClass, name);

		this.type      = type;
		this.variables = variables;
	}

	override void accept(IVisitor visitor) {
		visitor.visit(this);
	}
}