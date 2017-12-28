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

        /*foreach (x; decl.declarations) {
            x.visit(this);
        }*/
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

    void accept(IdentifierCallExpression expr) {
        expr.callee.visit(this);
        write("(");
        foreach (x; expr.args) {
            x.visit(this);
            write(", ");
        }

        write(")");
    }

    void accept(AstTypeCallExpression expr) {
        expr.type.visit(this);
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

    void accept(DollarExpression expr) {
        write("$");
    }

    void accept(SelfExpression expr) {
        write("self");
    }

    void accept(SuperExpression expr) {
        write("super");
    }

    void accept(ParenExpression expr) {
        write("(");
        expr.visit(this);
        write(")");
    }

    void accept(IdentifierExpression expr) {
        expr.identifier.visit(this);
    }

    void accept(FileLiteral literal) {
        write("#file");
    }

    void accept(LineLiteral literal) {
        write("#line");
    }

    void accept(AstVoidInitializer expr) {
        write("void");
    }

    void accept(AstTypeOfExpression expr) {
        write("typeof(");
        expr.identifier.visit(this);    
        write(")");
    }

    void accept(AstNameOfExpression expr) {
        write("nameof(");
        expr.identifier.visit(this);    
        write(")");
    }

    void accept(Lambda expr) {
        assert(false, "TODO");
    }



    void accept(AstType type) {
        writeln("tyoe TODO");
    }



    void accept(VariableDeclaration decl) {
        writeln("VARIABLE"); // TODO
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

    void accept(WhileStatement statement) { }
    void accept(RepeatStatement statement) { }
    void accept(IdentifierAsteriskIdentifierStatement statement) { }
    void accept(ForStatement statement) { }
    void accept(ForInStatement statement) { }
    void accept(ForInRangeStatement statement) { }
    void accept(ReturnStatement statement) { }
    void accept(SwitchStatement statement) { }
    void accept(CaseStatement statement) { }
    void accept(BreakStatement statement) { }
    void accept(ContinueStatement statement) { }
    void accept(GotoStatement statement) { }
    void accept(LockStatement statement) { }
    void accept(UnsafeStatement statement) { }
    void accept(DeferStatement statement) { }
    void accept(AssertStatement statement) { }
    void accept(ThrowStatement statement) { }
    void accept(TryStatement statement) { }

    void accept(BasicIdentifier identifier) { }
    void accept(IdentifierDotIdentifier identifier) { }
    void accept(TypeDotIdentifier identifier) { }
    void accept(ExpressionDotIdentifier identifier) { }
    void accept(DotIdentifier identifier) { }
    void accept(IdentifierBracketIdentifier identifier) { }
    void accept(IdentifierBracketExpression identifier) { }
    void accept(TypeTemplateArgument identifier) { }
    void accept(ValueTemplateArgument identifier) { }
    void accept(IdentifierTemplateArgument identifier) { }

    /*void accept(Statement x) { }
    void accept(Identifier x) { }
    void accept(TemplateArgument x) { }*/
}
