module Common.IVisitor;

import Ast.Declaration;
import Ast.Expression;


interface IVisitor {
@safe:
    void accept(Namespace decl);
    void accept(UsingDeclaration decl);

    void accept(AstUnaryExpression expr);
    void accept(AstBinaryExpression expr);


    void accept(AstCastExpression expr);
}