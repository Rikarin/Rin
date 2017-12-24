module Common.IVisitor;

import Ast.Statement;
import Ast.Declaration;
import Ast.Expression;
import Ast.Type;


interface IVisitor {
@safe:
    void accept(Namespace decl);
    void accept(UsingDeclaration decl);
    void accept(TupleDeclaration decl);

    void accept(AstUnaryExpression expr);
    void accept(AstBinaryExpression expr);
    void accept(AstTernaryExpression expr);

    void accept(AstCastExpression expr);
    void accept(AstAsExpression expr);
    void accept(AstCallExpression expr);
    //void accept(AstIsExpression expr);
    void accept(AstSelfExpression expr);

    void accept(AstIndexExpression expr);
    void accept(AstSliceExpression expr);
    void accept(AstDollarExpression expr);

    void accept(__File__Literal literal);
    void accept(__Line__Literal literal);



    void accept(AstType type);


    // Statements
    void accept(BlockStatement statement);
    void accept(ExpressionStatement statement);
    void accept(DeclarationStatement statement);
    void accept(IfStatement statement);

    void accept(Statement x);
}