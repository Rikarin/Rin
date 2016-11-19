module AST;

import std.format;
import std.array;

import Tokens;

@safe:


struct Type {
    string  name;
    ExprAST ast;
}


struct Arg {
    Type    type;
    string  name;
    Token   attrib; // Just one attrib for now
    //Token[] attribs;
}




interface ExprAST { // better name pls
    string generate(); // Generate my own pseudo code until we don't get working frontend, then port it to LLVM
}

class NumberExprAST : ExprAST {
    private Token  m_token;
    private double m_value;

    this(Token token, double value) {
        m_token = token;
        m_value = value;
    }

    override string generate() {
        return format("@number(%s) %s", m_token, m_value);
    }
}


class VariableExprAST : ExprAST {
    private Token  m_token;
    private string m_name;

    this(Token token, string name) {
        m_token = token;
        m_name = name;
    }

    override string generate() {
        return format("@var(%s) %s", m_token, m_name);
    }
}




class PrototypeAST : ExprAST {
    private string m_name;
    private Arg[]  m_args;

    this(string name, Arg[] args) {
        m_name = name;
        m_args = args;
    }

    override string generate() {
        return "prototype";
    }
}


class FunctionAST : ExprAST {
    private PrototypeAST m_proto;
    private ScopeAST     m_scope;

    this(PrototypeAST proto, ScopeAST scope_) {
        m_proto = proto;
        m_scope = scope_;
    }

    override string generate() {
        return "function";
    }
}



class ScopeAST : ExprAST {
    private ExprAST[] m_expressions;

    this() {

    }

    override string generate() {
        return "Scope";
    }
}



class TupleAST : ExprAST {
    this() {

    }

    override string generate() {
        return "tuple";
    }
}