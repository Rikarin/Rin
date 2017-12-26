module Print;
@safe:

import std.stdio;
import std.array;
import std.algorithm;

import Ast.Type;
import Ast.Statement;
import Ast.Expression;
import Ast.Declaration;
import Ast.Identifiers;

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

    void accept(TupleDeclaration decl) {
        writeln("TUPLE TODO");
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

    void accept(FileLiteral literal) {
        write("#file");
    }

    void accept(LineLiteral literal) {
        write("#line");
    }




    void accept(AstType type) {
        writeln("tyoe TODO");
    }





    void accept(BlockStatement statement) {
        assert(false); // TODO
    }

    void accept(ExpressionStatement statement) {
        assert(false); // TODO
    }

    void accept(DeclarationStatement statement) {
        assert(false); // TODO
    }

    void accept(IfStatement statement) {
        assert(false); // TODO
    }

    void accept(Statement x) { }
    void accept(Identifier x) { }
    void accept(TemplateArgument x) { }
}
