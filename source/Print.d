module Print;
@safe:

import std.stdio;
import std.array;
import std.algorithm;

import Ast.Declaration;
import Ast.Expression;

import Common.IVisitor;


class PrintVisitor : IVisitor {
    void accept(Namespace decl) {
        //writeln("namespace ", decl.name.map!(x => x.toString()).array().join("."));
        writeln("namespace TODO;");

        foreach (x; decl.declarations) {
            x.visit(this);
        }
    }

    void accept(UsingDeclaration decl) {
        writeln("using TODO;");
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
}