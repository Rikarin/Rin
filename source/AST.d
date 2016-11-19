module AST;

import std.conv;
import std.format;
import std.array;
import std.stdio;
import std.ascii;
import std.algorithm.searching;

import Tokens;

@safe:
abstract class Symbol {
    protected Symbol m_parent; // Parent scope

    string name() {
        return null;
    }

    string generate(); // Generate my own pseudo code until we don't get working frontend, then port it to LLVM
}


class NumericSymbol : Symbol {
    private TokenType m_token;
    private double    m_value;

    this(TokenType token, double value) {
        m_token = token;
        m_value = value;
    }

    override string generate() {
        return format("(%s)%s", m_token, m_value);
    }
}


class StringSymbol : Symbol {
    private string m_value;

    this(string value) {
        m_value = value;
    }

    override string generate() {
        return m_value;
    }
}


class TupleSymbol : Symbol {
    private string[] m_vars;

    this(in string[] vars...) {
    //    m_vars = vars;
    }

    override string generate() {
        return "tuple";
    }
}

/*
class TypeSymbol : Symbol { 
    private string  m_name;
    private Symbol  m_as;
    private Token[] m_attribs;

    this(string name, Token attrib = Token.None) {
        m_name   = name;
        m_attrib = attrib;
    }

    override string name() {
        return m_name;
    }

    override string generate() {
        return m_name;
    }
}*/


class VariableSymbol : Symbol {
    private string   m_type;
    private string   m_name;
    private string[] m_attribs;
    private Symbol   m_value;

    this(string type, string name, string[] attribs, Symbol value = null) {
        m_type    = type;
        m_name    = name;
        m_attribs = attribs;
        m_value   = value;
    }

    override string name() {
        return m_name;
    }

    override string generate() {
        return format("@var(%s) %s%s", m_type, m_name, (m_value ? " = " ~ m_value.generate : ""));
    }
}


class PrototypeSymbol : Symbol {
    private string  m_name;
    private Token[] m_attribs;
    private VariableSymbol[] m_args;

    this(string name, Token[] attribs, VariableSymbol[] args) {
        m_name    = name;
        m_attribs = attribs;
        m_args    = args;
    }

    override string name() {
        return m_name; // TODO: make name from name + args:  func test(name: string, age: int) -> bool     === test:name:age
    }

    override string generate() {
        return "prototype";
    }
}


class FunctionSymbol : Symbol {
    private PrototypeSymbol m_proto;
    private ScopeSymbol     m_scope;

    this(PrototypeSymbol proto, ScopeSymbol scope_) {
        m_proto = proto;
        m_scope = scope_;
    }

    override string name() {
        return m_proto.name;
    }

    override string generate() {
        return "function";
    }
}


class ScopeSymbol : Symbol {
    private Symbol[] m_symbols;

    this() {

    }

    override string name() {
        return "scope";
    }

    override string generate() {
        return "Scope";
    }

    void insert(Symbol symbol) {
        m_symbols ~= symbol;
    }

    Symbol lookup(string name) {
        foreach (x; m_symbols) {
            if (x.name == name) {
                return x;
            }
        }

        return null;
    }
}





/*

class SymbolTable {
    private Symbol[] m_symbols;

    static SymbolTable current() {
        static SymbolTable m_current;
        if (m_current is null) {
            m_current = new SymbolTable;
        }

        return m_current;
    }

    void addSymbol(Symbol symbol) {
        if (!findSymbol(symbol.name)) {
            m_symbols ~= symbol;
        }
    }

    Symbol findSymbol(string name) {
        foreach (x; m_symbols) {
            if (x.name == name) {
                return x;
            }
        }

        return null;
    }

    Symbol findOrAddType(Token token, string name) {
        if (BasicTypes.contains(token)) {
            name = token.to!string;
        }

        auto ret = findSymbol(name);
        if (!ret) {
            if (BasicTypes.contains(token)) {
                ret = new TypeSymbol(token.to!string);
                m_symbols ~= ret;
            }
        }

        return ret;
    }
}*/