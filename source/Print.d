module Print;
@safe:

import std.stdio;
import std.array;
import std.algorithm;

import Ast.Declaration;
import Ast.Expression;

import Domain.Context;
import Common.IVisitor;


class PrintVisitor : IVisitor {
    private Context _context;

    this(Context context) {
        _context = context;
    }

    void accept(Namespace decl) {
        writeln("namespace ", decl.name.map!(x => x.toString(_context)).array().join("."), ";");

        foreach (x; decl.declarations) {
            x.visit(this);
        }
    }

    void accept(UsingDeclaration decl) {
        writeln("using ", decl.namespace.map!(x => x.toString(_context)).array().join("."), ";");
    }

    void accept(AstUnaryExpression expr) {
        writeln("unary expr TODO");
    }

    void accept(AstBinaryExpression expr) {
        writeln("binary expr TODO");
    }

    void accept(AstCastExpression expr) {
        writeln("cast TODO");
    }

    void accept(AstAsExpression expr) {
        writeln("identifier as type TODO");
    }

    void accept(AstCallExpression expr) {
        writeln("call expression TODO");
    }

    void accept(AstIndexExpression expr) {
        writeln("index expr TODO");
    }

    void accept(AstSliceExpression expr) {
        writeln("slice expr TODO");
    }

    void accept(AstDollarExpression expr) {
        writeln("$");
    }

    void accept(AstIsExpression expr) {
        writeln("is TODO");
    }

    void accept(AstSelfExpression expr) {
        writeln("self");
    }

    void accept(__File__Literal literal) {
        writeln("__FILE__");
    }

    void accept(__Line__Literal literal) {
        writeln("__LINE__");
    }
}