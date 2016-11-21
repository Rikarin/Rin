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
    private Token m_token;

    this(Token token) {
        m_token = token;
    }

    override string generate() {
        return format("(%s)%s", m_token.type, m_token.uvalue);
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
            } else if (x.type.isBasicTypeValue) {
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
            } else if (x.type.isBasicTypeValue) {
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


class RangeSymbol : Symbol {
    private Symbol m_start;
    private Symbol m_end;

    this(Symbol start, Symbol end) {
        m_start = start;
        m_end   = end;
    }

    override string generate() {
        return m_start.generate ~ " .. " ~ m_end.generate;
    }
}


class TypeSymbol : Symbol { // int, bool, customType, etc.
    private Token m_type;
    private bool  m_isMonad;

    this(Token type, bool isMonad = false) {
        m_type    = type;
        m_isMonad = isMonad;
    }

    override string generate() {
        return m_type.tokenToString ~ (m_isMonad ? "?" : "");
    }
}


class ArrayTypeSymbol : Symbol {
    private Symbol m_child;
    private Token  m_assocType;

    this(Symbol child, Token assocType) {
        m_child     = child;
        m_assocType = assocType;
    }

    override string generate() {
        return m_child.generate ~ "[]";
    }
}


class AttribTypeSymbol : Symbol {
    private Symbol m_child;
    private Token  m_attrib;

    this(Symbol child, Token attrib) {
        m_child  = child;
        m_attrib = attrib;
    }

    override string generate() {
        return m_attrib.tokenToString ~ "(" ~ m_child.generate ~ ")";
    }
}


class PointerTypeSymbol : Symbol {
    private Symbol m_child;

    this(Symbol child) {
        m_child  = child;
    }

    override string generate() {
        return m_child.generate ~ "*";
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
    private string[] m_stages;
    private string   m_name;
    private string[] m_argNames;
    private Symbol[] m_args;

    this(string[] stages, string name, string[] argNames, Symbol[] args) {
        m_stages   = stages;
        m_name     = name;
        m_argNames = argNames;
        m_args     = args;
    }

    override string generate() {
        return m_name;
    }
}


class VariableSymbol : Symbol {
    private Symbol m_type;
    private string m_name;
    private Symbol m_value;

    this(Symbol type, string name, Symbol value = null) {
        m_type  = type;
        m_name  = name;
        m_value = value;
    }

    override string name() {
        return m_name;
    }

    override string generate() {
        return format("@var(%s) %s%s", (m_type ? m_type.generate : ""), m_name, (m_value ? " = " ~ m_value.generate : ""));
    }
}


class ImportSymbol : Symbol {
    private string [] m_stages;

    this(string[] stages...) {
        m_stages = stages;
    }

    override string generate() {
        return "import ";
    }
}


// We need prototype for extern(C) funcs & protos in import headers
class PrototypeSymbol : Symbol {
    private string m_name;
    private Symbol m_returnType;
    private VariableSymbol[] m_args;

    this(string name, VariableSymbol[] args, Symbol returnType) {
        m_name       = name;
        m_args       = args;
        m_returnType = returnType;
    }

    override string name() {
        return m_name;
    }

    override string generate() {
        return "func " ~ m_name ~ "()" ~ (m_returnType ? " -> " ~ m_returnType.generate : "");
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
        return m_proto.generate ~ m_scope.generate;
    }
}


class AttribScopeSymbol : Symbol {
    private Symbol m_child;
    private Symbol m_value;
    private Token  m_attrib;

    this(Token attrib, Symbol value, Symbol child) {
        m_child  = child;
        m_value  = value;
        m_attrib = attrib;
    }

    override string generate() {
        return m_attrib.tokenToString ~ (m_value ? m_value.generate : "") ~ m_child.generate;
    }
}



class ForSymbol : Symbol {
    private Symbol      m_primary;
    private Symbol      m_secondary;
    private ScopeSymbol m_scope;

    this(Symbol primary, Symbol secondary, ScopeSymbol scope_) {
        m_primary   = primary;
        m_secondary = secondary;
        m_scope     = scope_;
    }

    override string generate() {
        return "for " ~ m_primary.generate ~ " in " ~ m_secondary.generate ~ " " ~ m_scope.generate;
    }
}


class ScopeSymbol : Symbol {
    private Symbol[] m_symbols;
    // TODO: symbol table for vars, funcs, classes, structs, enums, etc.

    this() {

    }

    override string name() {
        return "scope";
    }

    override string generate() {
        Appender!(char[]) buf;

        buf.put("{\n");
        foreach (x; m_symbols) {
            buf.put(x.generate);
            buf.put("\n");
        }

        buf.put("}\n");
        return buf.data.to!string;
    }

    void add(Symbol symbol) {
        m_symbols ~= symbol;
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



string tokenToString(ref Token tok) {
    import std.string;

    if (tok.type == TokenType.Identifier) {
        return tok.str;
    }

    if (tok.type == TokenType.StringExpr) {
        return "\"" ~ tok.str ~ "\"";
    }

    if (tok.type.isBasicTypeValue) {
        return tok.uvalue.to!string;
    }

    return tok.type.to!string.toLower;
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