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

    void visit(Namespace decl) {
        print("namespace");
        printn(1, decl.name.map!(x => x.toString(_context)).array().join("."));

        foreach (x; decl.declarations) {
            if (x)
            x.accept(this);
        }
    }

    void visit(UsingDeclaration decl) {
        print("using");
        printn(1, decl.namespace.map!(x => x.toString(_context)).array().join("."));
    }

    void visit(TupleDeclaration decl) {
        assert(false);
    }

    void visit(FunctionDeclaration decl) {
        print("function TODO");
        decl.block.accept(this);
    }

    void visit(PropertyDeclaration decl) {
        print("property TODO");
        decl.block.accept(this);
    }

    void visit(AstUnaryExpression expr) {
        print(unarizeString("", expr.op));
        expr.expr.accept(this);
    }

    void visit(AstBinaryExpression expr) {
        expr.lhs.accept(this);
        write(" ", expr.op, " ");
        expr.rhs.accept(this);
    }

    void visit(AstTernaryExpression expr) {
        expr.condition.accept(this);
        write(" ? ");
        expr.ifTrue.accept(this);
        write(" : ");
        expr.ifFalse.accept(this);
    }

    void visit(AstCastExpression expr) {
        write("(");
        expr.type.accept(this);
        write(")");
        expr.expr.accept(this);
    }

    void visit(AstAsExpression expr) {
        expr.expr.accept(this);
        write(" as ");
        expr.type.accept(this);
    }

    void visit(AstCallExpression expr) {
        expr.callee.accept(this);
        write("(");
        foreach (x; expr.args) {
            x.accept(this);
            write(", ");
        }

        write(")");
    }

    void visit(IdentifierCallExpression expr) {
        expr.callee.accept(this);
        write("(");
        foreach (x; expr.args) {
            x.accept(this);
            write(", ");
        }

        write(")");
    }

    void visit(AstTypeCallExpression expr) {
        expr.type.accept(this);
        write("(");
        foreach (x; expr.args) {
            x.accept(this);
            write(", ");
        }

        write(")");
    }

    void visit(AstIndexExpression expr) {
        writeln("index expr TODO");
    }

    void visit(AstSliceExpression expr) {
        writeln("slice expr TODO");
    }

    void visit(DollarExpression expr) {
        write("$");
    }

    void visit(SelfExpression expr) {
        write("self");
    }

    void visit(SuperExpression expr) {
        write("super");
    }

    void visit(ParenExpression expr) {
        write("(");
        expr.accept(this);
        write(")");
    }

    void visit(IdentifierExpression expr) {
        expr.identifier.accept(this);
    }

    void visit(FileLiteral literal) {
        write("#file");
    }

    void visit(LineLiteral literal) {
        write("#line");
    }

    void visit(AstVoidInitializer expr) {
        write("void");
    }

    void visit(AstTypeOfExpression expr) {
        write("typeof(");
        expr.identifier.accept(this);    
        write(")");
    }

    void visit(AstNameOfExpression expr) {
        write("nameof(");
        expr.identifier.accept(this);    
        write(")");
    }

    void visit(Lambda expr) {
        print("lambda TODO");
    }

    void visit(AstType type) {
        print("type TODO");
    }

    void visit(GetStatement statement) {
        print("get");

        if (statement.block) {
            statement.block.accept(this);
        }
    }

    void visit(SetStatement statement) {
        print("set");

        if (statement.block) {
            statement.block.accept(this);
        }
    }

    void visit(VariableDeclaration decl) {
        print("variable TODO");
    }

    void visit(BlockStatement statement) {
        _space++;
        foreach (x; statement.statements) {
            x.accept(this);
        }
        _space--;
    }

    void visit(ExpressionStatement statement) {
        statement.expr.accept(this);
    }

    void visit(DeclarationStatement statement) {
        statement.decl.accept(this);
    }

    void visit(IfStatement statement) {
        print("if TODO");
    }

    void visit(WhileStatement statement) {
        print("while TODO");
    }

    void visit(RepeatStatement statement) {
        print("repeat TODO");
    }

    void visit(IdentifierAsteriskIdentifierStatement statement) {
        print("TODO");
    }

    void visit(ForStatement statement) {
        print("TODO");
    }

    void visit(ForInStatement statement) {
        print("TODO");
    }

    void visit(ForInRangeStatement statement) {
        print("TODO");
    }

    void visit(ReturnStatement statement) {
        print("return");
        _space++;
        if (statement.value) {
            statement.value.accept(this);
        }
        _space--;
    }
    
    void visit(SwitchStatement statement) { 
        print("TODO");
    }

    void visit(CaseStatement statement) { }
    void visit(BreakStatement statement) { }
    void visit(ContinueStatement statement) { }
    void visit(GotoStatement statement) { }
    void visit(LockStatement statement) { }
    void visit(UnsafeStatement statement) { }
    void visit(DeferStatement statement) { }
    void visit(AssertStatement statement) { }
    void visit(ThrowStatement statement) { }
    void visit(TryStatement statement) { }

    void visit(BasicIdentifier identifier) { }
    void visit(IdentifierDotIdentifier identifier) { }
    void visit(TypeDotIdentifier identifier) { }
    void visit(ExpressionDotIdentifier identifier) { }
    void visit(DotIdentifier identifier) { }
    void visit(IdentifierBracketIdentifier identifier) { }
    void visit(IdentifierBracketExpression identifier) { }
    void visit(TypeTemplateArgument identifier) { }
    void visit(ValueTemplateArgument identifier) { }
    void visit(IdentifierTemplateArgument identifier) { }
    void visit(IsExpression expr) { }

    void visit(StructDeclaration decl) {

    }

    void visit(UnionDeclaration decl) {

    }

    void visit(ClassDeclaration decl) {

    }

    void visit(InterfaceDeclaration decl) {

    }

    void visit(EnumDeclaration decl) {

    }

    void visit(HtmlExpression expr) {
        print("HTML");
        _space++;
        print(expr.identifier.toString(_context));
        foreach (x; expr.inner) {
            x.accept(this);
        }

        _space--;
    }



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
