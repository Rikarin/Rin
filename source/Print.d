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
        print("namespace");
        printn(1, decl.name.map!(x => x.toString(_context)).array().join("."));

        foreach (x; decl.declarations) {
            if (x)
            x.visit(this);
        }
    }

    void accept(UsingDeclaration decl) {
        print("using");
        printn(1, decl.namespace.map!(x => x.toString(_context)).array().join("."));
    }

    void accept(TupleDeclaration decl) {
        assert(false);
    }

    void accept(FunctionDeclaration decl) {
        print("function TODO");
        decl.block.visit(this);
    }

    void accept(PropertyDeclaration decl) {
        print("property TODO");
        decl.block.visit(this);
    }

    void accept(AstUnaryExpression expr) {
        print(unarizeString("", expr.op));
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
        print("lambda TODO");
    }

    void accept(AstType type) {
        print("type TODO");
    }

    void accept(GetStatement statement) {
        print("get");

        if (statement.block) {
            statement.block.visit(this);
        }
    }

    void accept(SetStatement statement) {
        print("set");

        if (statement.block) {
            statement.block.visit(this);
        }
    }

    void accept(VariableDeclaration decl) {
        print("variable TODO");
    }

    void accept(BlockStatement statement) {
        _space++;
        foreach (x; statement.statements) {
            x.visit(this);
        }
        _space--;
    }

    void accept(ExpressionStatement statement) {
        statement.expr.visit(this);
    }

    void accept(DeclarationStatement statement) {
        statement.decl.visit(this);
    }

    void accept(IfStatement statement) {
        print("if TODO");
    }

    void accept(WhileStatement statement) {
        print("while TODO");
    }

    void accept(RepeatStatement statement) {
        print("repeat TODO");
    }

    void accept(IdentifierAsteriskIdentifierStatement statement) {
        print("TODO");
    }

    void accept(ForStatement statement) {
        print("TODO");
    }

    void accept(ForInStatement statement) {
        print("TODO");
    }

    void accept(ForInRangeStatement statement) {
        print("TODO");
    }

    void accept(ReturnStatement statement) {
        print("return TODO");
    }
    
    void accept(SwitchStatement statement) { 
        print("TODO");
    }

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
    void accept(IsExpression expr) { }



    private int _space;

    private void printn(int add, string msg) {
        add = (add + _space) * 2;

        foreach (i; 0 .. add) {
            write(" ");
        }

        writeln(msg);
    }

    private void print(string msg) {
        foreach (i; 0 .. _space * 2) {
            write(" ");
        }

        writeln(msg);
    }
}
