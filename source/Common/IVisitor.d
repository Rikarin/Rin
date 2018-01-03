module Common.IVisitor;

import Ast.Type;
import Ast.Statement;
import Ast.Expression;
import Ast.Identifiers;
import Ast.Declaration;


interface IVisitor {
@safe:
    // Expressions
    void visit(AstUnaryExpression expr);
    void visit(AstBinaryExpression expr);
    void visit(AstTernaryExpression expr);
    void visit(AstCastExpression expr);
    void visit(AstAsExpression expr);
    void visit(AstCallExpression expr);
    void visit(AstTypeCallExpression expr);
    void visit(AstIndexExpression expr);
    void visit(AstSliceExpression expr);
    void visit(AstVoidInitializer expr);
    void visit(AstTypeOfExpression expr);
    void visit(AstNameOfExpression expr);

    void visit(DollarExpression expr);
    void visit(SelfExpression expr);
    void visit(SuperExpression expr);
    void visit(ParenExpression expr);
    void visit(IdentifierExpression expr);
    void visit(IdentifierCallExpression expr);
    void visit(Lambda expr);
    void visit(IsExpression expr);
    void visit(HtmlExpression expr);


    // Declarations
    void visit(Namespace decl);
    void visit(UsingDeclaration decl);
    void visit(TupleDeclaration decl);
    void visit(VariableDeclaration decl);
    void visit(FunctionDeclaration decl);
    void visit(PropertyDeclaration decl);
    void visit(StructDeclaration decl);
    void visit(UnionDeclaration decl);
    void visit(ClassDeclaration decl);
    void visit(InterfaceDeclaration decl);
    void visit(EnumDeclaration decl);


    // Statements
    void visit(BlockStatement statement);
    void visit(ExpressionStatement statement);
    void visit(DeclarationStatement statement);
    void visit(IfStatement statement);
    void visit(WhileStatement statement);
    void visit(RepeatStatement statement);
    void visit(IdentifierAsteriskIdentifierStatement statement);
    void visit(ForStatement statement);
    void visit(ForInStatement statement);
    void visit(ForInRangeStatement statement);
    void visit(ReturnStatement statement);
    void visit(SwitchStatement statement);
    void visit(CaseStatement statement);
    void visit(BreakStatement statement);
    void visit(ContinueStatement statement);
    void visit(GotoStatement statement);
    void visit(LockStatement statement);
    void visit(UnsafeStatement statement);
    void visit(DeferStatement statement);
    void visit(AssertStatement statement);
    void visit(ThrowStatement statement);
    void visit(TryStatement statement);
    void visit(GetStatement statement);
    void visit(SetStatement statement);


    // Identifiers 
    void visit(BasicIdentifier identifier);
    void visit(IdentifierDotIdentifier identifier);
    void visit(TypeDotIdentifier identifier);
    void visit(ExpressionDotIdentifier identifier);
    void visit(DotIdentifier identifier);
    void visit(IdentifierBracketIdentifier identifier);
    void visit(IdentifierBracketExpression identifier);
    void visit(TypeTemplateArgument identifier);
    void visit(ValueTemplateArgument identifier);
    void visit(IdentifierTemplateArgument identifier);


     // undefined
    void visit(FileLiteral literal);
    void visit(LineLiteral literal);
    void visit(AstType type);


    // TODO: remove these dummies
    /*void visit(Statement x);
    void visit(Identifier x);
    void visit(TemplateArgument x);*/
}