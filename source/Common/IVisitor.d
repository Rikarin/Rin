module Common.IVisitor;

import Ast.Type;
import Ast.Statement;
import Ast.Expression;
import Ast.Identifiers;
import Ast.Declaration;


interface IVisitor {
@safe:
    // Expressions
    void accept(AstUnaryExpression expr);
    void accept(AstBinaryExpression expr);
    void accept(AstTernaryExpression expr);
    void accept(AstCastExpression expr);
    void accept(AstAsExpression expr);
    void accept(AstCallExpression expr);
    void accept(AstTypeCallExpression expr);
    void accept(AstIndexExpression expr);
    void accept(AstSliceExpression expr);
    void accept(AstVoidInitializer expr);
    void accept(AstTypeOfExpression expr);
    void accept(AstNameOfExpression expr);

    void accept(DollarExpression expr);
    void accept(SelfExpression expr);
    void accept(SuperExpression expr);
    void accept(ParenExpression expr);
    void accept(IdentifierExpression expr);
    void accept(IdentifierCallExpression expr);
    void accept(Lambda expr);


    // Declarations
    void accept(Namespace decl);
    void accept(UsingDeclaration decl);
    void accept(TupleDeclaration decl);
    void accept(VariableDeclaration decl);
    void accept(FunctionDeclaration decl);
    void accept(PropertyDeclaration decl);


    // Statements
    void accept(BlockStatement statement);
    void accept(ExpressionStatement statement);
    void accept(DeclarationStatement statement);
    void accept(IfStatement statement);
    void accept(WhileStatement statement);
    void accept(RepeatStatement statement);
    void accept(IdentifierAsteriskIdentifierStatement statement);
    void accept(ForStatement statement);
    void accept(ForInStatement statement);
    void accept(ForInRangeStatement statement);
    void accept(ReturnStatement statement);
    void accept(SwitchStatement statement);
    void accept(CaseStatement statement);
    void accept(BreakStatement statement);
    void accept(ContinueStatement statement);
    void accept(GotoStatement statement);
    void accept(LockStatement statement);
    void accept(UnsafeStatement statement);
    void accept(DeferStatement statement);
    void accept(AssertStatement statement);
    void accept(ThrowStatement statement);
    void accept(TryStatement statement);
    void accept(GetStatement statement);
    void accept(SetStatement statement);


    // Identifiers 
    void accept(BasicIdentifier identifier);
    void accept(IdentifierDotIdentifier identifier);
    void accept(TypeDotIdentifier identifier);
    void accept(ExpressionDotIdentifier identifier);
    void accept(DotIdentifier identifier);
    void accept(IdentifierBracketIdentifier identifier);
    void accept(IdentifierBracketExpression identifier);
    void accept(TypeTemplateArgument identifier);
    void accept(ValueTemplateArgument identifier);
    void accept(IdentifierTemplateArgument identifier);


     // undefined
    void accept(FileLiteral literal);
    void accept(LineLiteral literal);
    void accept(AstType type);


    // TODO: remove these dummies
    /*void accept(Statement x);
    void accept(Identifier x);
    void accept(TemplateArgument x);*/
}