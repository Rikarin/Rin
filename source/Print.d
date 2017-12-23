module Print;
@safe:

import std.stdio;
import std.array;
import std.algorithm;

import Ast.Type;
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
        write(unarizeString("", expr.op));
        expr.expr.visit(this);
    }

    void accept(AstBinaryExpression expr) {
        expr.lhs.visit(this);
        write(" ", expr.op, " ");
        expr.rhs.visit(this);
    }

    void accept(AstTernaryExpression expr) {
        expr.condition.visit(this);
        write(" ? ");
        expr.ifTrue.visit(this);
        write(" : ");
        expr.ifFalse.visit(this);
    }

    void accept(AstCastExpression expr) {
        write("(");
        expr.type.visit(this);
        write(")");
        expr.expr.visit(this);
    }

    void accept(AstAsExpression expr) {
        expr.expr.visit(this);
        write(" as ");
        expr.type.visit(this);
    }

    void accept(AstCallExpression expr) {
        expr.callee.visit(this);
        write("(");
        foreach (x; expr.args) {
            x.visit(this);
            write(", ");
        }

        write(")");
    }

    void accept(AstIndexExpression expr) {
        writeln("index expr TODO");
    }

    void accept(AstSliceExpression expr) {
        writeln("slice expr TODO");
    }

    void accept(AstDollarExpression expr) {
        write("$");
    }

    /*void accept(AstIsExpression expr) {
        writeln("is TODO");
    }*/

    void accept(AstSelfExpression expr) {
        write("self");
    }

    void accept(__File__Literal literal) {
        write("__FILE__");
    }

    void accept(__Line__Literal literal) {
        write("__LINE__");
    }




    void accept(AstType type) {
        writeln("tyoe TODO");
    }
}
