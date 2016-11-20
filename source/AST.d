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
    private Token[] m_vars;

    this(Token[] vars...) {
        m_vars = vars;
    }

    override string generate() {
        Appender!(char[]) buf;

        buf.put("(");
        foreach (x; m_vars) {
            if (x.type == TokenType.True) {
                buf.put("true");
            } else if (x.type == TokenType.False) {
                buf.put("false");
            } else if (BasicTypeValues.contains(x.type)) {
                buf.put(x.uvalue.to!(char[]));
            } else if (x.type == TokenType.Identifier) {
                buf.put(x.str);
            } else if (x.type == TokenType.StringExpr) {
                buf.put("\"");
                buf.put(x.str);
                buf.put("\"");
            }

            buf.put(", ");
        }

        buf.put(")");
        return buf.data.to!string;
    }
}


class NamedTupleSymbol : TupleSymbol {
    private string[] m_names;

    this(string[] names, Token[] vars) {
        m_names ~= names;
        super(vars);
    }

    override string generate() {
        Appender!(char[]) buf;

        buf.put("(");
        foreach (i, x; m_vars) {
            buf.put(m_names[i]);
            buf.put(": ");

            if (x.type == TokenType.True) {
                buf.put("true");
            } else if (x.type == TokenType.False) {
                buf.put("false");
            } else if (BasicTypeValues.contains(x.type)) {
                buf.put(x.uvalue.to!(char[]));
            } else if (x.type == TokenType.Identifier) {
                buf.put(x.str);
            } else if (x.type == TokenType.StringExpr) {
                buf.put("\"");
                buf.put(x.str);
                buf.put("\"");
            }

            buf.put(", ");
        }

        buf.put(")");
        return buf.data.to!string;
    }
}


class BinaryExprSymbol : Symbol {
    private Token  m_op;
    private Symbol m_lhs;
    private Symbol m_rhs;

    this(Token operator, Symbol lhs, Symbol rhs) {
        m_op  = operator;
        m_lhs = lhs;
        m_rhs = rhs;
    }

    override string generate() {
        return "binary expr";
    }
}


class CallExprSymbol : Symbol {
    private string   m_name;
    private Symbol[] m_args;

    this(string name, Symbol[] args) {
        m_name = name;
        m_args = args;
    }

    override string generate() {
        return "call expr";
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
    private Token   m_type;
    private string  m_name;
    private Token[] m_attribs;
    private Symbol  m_value;

    this(Token type, string name, Token[] attribs, Symbol value = null) {
        m_type    = type;
        m_name    = name;
        m_attribs = attribs;
        m_value   = value;
    }

    override string name() {
        return m_name;
    }

    override string generate() {
        return format("@var(%s) %s%s", m_type.str, m_name, (m_value ? " = " ~ m_value.generate : ""));
    }
}


class FunctionSymbol : Symbol {
    private string           m_name;
    private Token[]          m_attribs;
    private VariableSymbol[] m_args;
    private ScopeSymbol      m_scope;

    this(string name, Token[] attribs, VariableSymbol[] args, ScopeSymbol scope_) {
        m_name    = name;
        m_attribs = attribs;
        m_args    = args;
        m_scope   = scope_;
    }

    override string name() {
        return m_name;
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