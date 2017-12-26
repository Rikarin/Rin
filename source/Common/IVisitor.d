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


    // Statements
    void accept(BlockStatement statement);
    void accept(ExpressionStatement statement);
    void accept(DeclarationStatement statement);
    void accept(IfStatement statement);


     // undefined
    void accept(FileLiteral literal);
    void accept(LineLiteral literal);
    void accept(AstType type);

    // TODO: remove these dummies
    void accept(Statement x);
    void accept(Identifier x);
    void accept(TemplateArgument x);
}