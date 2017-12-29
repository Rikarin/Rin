module Lexer;
@safe: pure:

import std.utf;
import std.conv;
import std.array;
import std.stdio;
import std.ascii;
import std.algorithm.searching;

import Tokens;
import Domain.Name;
import Domain.Context;
import Domain.Location;


struct TokenRange {
    Token t;
    uint index;

    Position previous;
    Position base;

    Context context;
    string content;

    @disable this(this);

    auto front() const {
        return t;
    }

    void popFront() {
        previous = base.getWithOffset(index);
        t = getNextToken();
    }

	inout(TokenRange) save() inout {
		return inout(TokenRange)(t, index, previous, base, context, content);
	}

    bool empty() const {
        return t.type == TokenType.End;
    }

    private void popChar() {
        index++;
    }

    private char frontChar() const {
        return content[index];
    }

    private auto getNextToken() {
        while (true) {
            mixin(lexerMixin);
        }
    }


    private auto lexWhiteSpace(string s)() {
		// Just skip over whitespace.
	}
	
	private auto lexComment(string s)() {
		auto c = frontChar;
		
		static if (s == "//") {
			// TODO: check for unicode line break.
			while(c != '\n' && c != '\r') {
				popChar();
				c = frontChar;
			}
			
			popChar();
			if (c == '\r') {
				if (frontChar == '\n') popChar();
			}
		} else static if (s == "/*") {
			Pump: while(1) {
				// TODO: check for unicode line break.
				while(c != '*') {
					popChar();
					c = frontChar;
				}
				
				auto match = c;
				popChar();
				c = frontChar;
				
				if (c == '/') {
					popChar();
					break Pump;
				}
			}
		} else static if (s == "/+") {
			uint stack = 0;
			Pump: while(1) {
				// TODO: check for unicode line break.
				while(c != '+' && c != '/') {
					popChar();
					c = frontChar;
				}
				
				auto match = c;
				popChar();
				c = frontChar;
				
				switch(match) {
					case '+' :
						if (c == '/') {
							popChar();
							if (!stack) break Pump;
							
							c = frontChar;
							stack--;
						}
						
						break;
					
					case '/' :
						if (c == '+') {
							popChar();
							c = frontChar;
							
							stack++;
						}
						
						break;
					
					default :
						assert(0, "Unreachable.");
				}
			}
		} else {
			static assert(0, s ~ " isn't a known type of comment.");
		}
	}
	
	auto lexIdentifier(string s)() {
		static if (s == "") {
			if (isIdChar(frontChar)) {
				popChar();
				return lexIdentifier(1);
			}
			
			// XXX: proper error reporting.
			assert(frontChar & 0x80, "lex error");
			
			// XXX: Dafuq does this need to be a size_t ?
			size_t i = index;
			
			import std.uni;
			auto u = content.decode(i);
			assert(isAlpha(u), "lex error");
			
			auto l = cast(ubyte) (i - index);
			index += l;
			return lexIdentifier(l);
		} else {
			return lexIdentifier(s.length);
		}
	}
	
	auto lexIdentifier(uint prefixLength) in {
		assert(prefixLength > 0);
		assert(index >= prefixLength);
	} body {
		Token t;
		t.type = TokenType.Identifier;
		auto ibegin = index - prefixLength;
		auto begin = base.getWithOffset(ibegin);
		
		while(true) {
			while(isIdChar(frontChar)) {
				popChar();
			}
			
			if (!(frontChar | 0x80)) {
				break;
			}
			
			// XXX: Dafuq does this need to be a size_t ?
			size_t i = index;
			
			import std.uni;
			auto u = content.decode(i);
			if (!isAlpha(u)) {
				break;
			}
			
			index = cast(uint) i;
		}
		
		t.location = Location(begin, base.getWithOffset(index));
		t.name = context.getName(content[ibegin .. index]);
		
		return t;
	}
	
	auto lexEscapeSequence() in {
		assert(frontChar == '\\', frontChar ~ " is not a valid escape sequence.");
	} body {
		popChar();
		scope(success) popChar();
		
		switch(frontChar) {
			case '\'' :
				return '\'';
			
			case '"' :
				return '"';
			
			case '?' :
				assert(0, "WTF is \\?");
			
			case '\\' :
				return '\\';
			
			case '0' :
				return '\0';
			
			case 'a' :
				return '\a';
			
			case 'b' :
				return '\b';
			
			case 'f' :
				return '\f';
			
			case 'r' :
				return '\r';
			
			case 'n' :
				return '\n';
			
			case 't' :
				return '\t';
			
			case 'v' :
				return '\v';
			
			default :
				assert(0, "Don't know about " ~ frontChar);
		}
	}
	
	auto lexEscapeChar() {
		auto c = frontChar;
		switch(c) {
			case '\0' :
				assert(0, "unexpected end :(");
			
			case '\\' :
				return lexEscapeSequence();
			
			case '\'' :
				assert(0, "Empty character litteral is bad, very very bad !");
			
			default :
				if (c & 0x80) {
					assert(0, "Unicode not supported here");
				} else {
					popChar();
					return c;
				}
		}
	}
	
	Token lexString(string s)() in {
		assert(index >= s.length);
	} body {
		Token t;
		t.type = TokenType.StringLiteral;
		auto begin = base.getWithOffset(index - cast(uint) s.length);
		
		auto c = frontChar;
		
		static if (s == "\"") {
			mixin CharPumper!false;
			
			Pump: while(true) {
				// TODO: check for unicode line break.
				while(c != '\"') {
					putChar(lexEscapeChar());
					c = frontChar;
				}
				
				// End of string.
				popChar();
				break Pump;
			}
			
			t.location = Location(begin, base.getWithOffset(index));
			t.name = getValue();
			
			return t;
		} else {
			assert(0, "string literal using " ~ s ~ "not supported");
		}
	}
	
	auto lexChar(string s)() if(s == "'") {
		Token t;
		t.type = TokenType.CharacterLiteral;
		auto begin = base.getWithOffset(index - 1);
		
		t.name = context.getName([lexEscapeChar()]);
		
		if (frontChar != '\'') {
			assert(0, "In '' must be character literal only!");
		}
		
		popChar();
		
		t.location = Location(begin, base.getWithOffset(index));
		return t;
	}
	
	auto lexNumeric(string s)() if(s.length == 1 && isDigit(s[0])) {
		return lexNumeric(s[0]);
	}
	
	Token lexNumeric(string s)() if(s.length == 2 && s[0] == '0') {
		Token t;
		t.type = TokenType.IntegerLiteral;
		auto ibegin = index - 2;
		auto begin = base.getWithOffset(ibegin);
		
		auto c = frontChar;
		switch(s[1] | 0x20) {
			case 'b' :
				assert(c == '0' || c == '1', "invalid integer literal");
				while(1) {
					while(c == '0' || c == '1') {
						popChar();
						c = frontChar;
					}
					
					if (c == '_') {
						popChar();
						c = frontChar;
						continue;
					}
					break;
				}
				break;
			
			case 'x' :
				auto hc = c | 0x20;
				assert((c >= '0' && c <= '9') || (hc >= 'a' && hc <= 'f'), "invalid integer literal");
				while(1) {
					hc = c | 0x20;
					while((c >= '0' && c <= '9') || (hc >= 'a' && hc <= 'f')) {
						popChar();
						c = frontChar;
						hc = c | 0x20;
					}
					
					if (c == '_') {
						popChar();
						c = frontChar;
						continue;
					}
					break;
				}
				break;
			
			default :
				assert(0, s ~ " is not a valid prefix.");
		}
		
		switch(c | 0x20) {
			case 'u' :
				popChar();
				
				c = frontChar;
				if (c == 'L' || c == 'l') {
					popChar();
				}
				break;
			
			case 'l' :
				popChar();
				
				c = frontChar;
				if (c == 'U' || c == 'u') {
					popChar();
				}
				break;
			
			default:
				break;
		}
		
		t.location = Location(begin, base.getWithOffset(index));
		t.name = context.getName(content[ibegin .. index]);
		
		return t;
	}
	
	auto lexNumeric(char c) {
		Token t;
		t.type = TokenType.IntegerLiteral;
		auto ibegin = index - 1;
		auto begin = base.getWithOffset(ibegin);
		
		assert(c >= '0' && c <= '9', "invalid integer literal");
		
		c = frontChar;
		while(1) {
			while(c >= '0' && c <= '9') {
				popChar();
				c = frontChar;
			}
			
			if (c == '_') {
				popChar();
				c = frontChar;
				continue;
			}
			break;
		}
		
		switch(c) {
			case '.' :
				auto lookAhead = content;
				lookAhead.popFront();
				
				if (lookAhead.front.isDigit()) {
					popChar();
					
					t.type = TokenType.FloatLiteral;
					
					assert(0, "No floating point ATM");
					// pumpChars!isDigit(content);
				}
				break;
			
			case 'U', 'u' :
				popChar();
				
				c = frontChar;
				if (c == 'L' || c == 'l') {
					popChar();
				}
				break;
			
			case 'L', 'l' :
				popChar();
				
				c = frontChar;
				if (c == 'U' || c == 'u') {
					popChar();
				}
				break;
			
			default:
				break;
		}
		
		t.location = Location(begin, base.getWithOffset(index));
		t.name = context.getName(content[ibegin .. index]);
		
		return t;
	}
	
	auto lexKeyword(string s)() {
		auto c = frontChar;
		if (isIdChar(c)) {
			popChar();
			return lexIdentifier(s.length + 1);
		}
		
		if (c & 0x80) {
			size_t i = index;
			
			import std.uni;
			auto u = content.decode(i);
			if (isAlpha(u)) {
				auto l = cast(ubyte) (i - index);
				index += l;
				return lexIdentifier(s.length + l);
			}
		}
		
		enum type = keywordsMap()[s];
		uint l = s.length;
		
		Token t;
		t.type = type;
		t.location = Location(base.getWithOffset(index - l), base.getWithOffset(index));
		t.name = BuiltinName!s;
		
		return t;
	}
	
	auto lexOperator(string s)() {
		enum type = operatorsMap()[s];
		uint l = s.length;
		
		Token t;
		t.type = type;
		t.location = Location(base.getWithOffset(index - l), base.getWithOffset(index));
		t.name = BuiltinName!s;
		
		return t;
	}
}

private char front(string s) {
	return s[0];
}

private void popFront(ref string s) {
	s = s[1 .. $];
}

private auto isIdChar(char c) {
	import std.ascii;
	return c == '_' || isAlphaNum(c);
}

private auto isDigit(char c) {
	import std.ascii;
	return std.ascii.isDigit(c);
}

private mixin template CharPumper(bool decode = true) {
	// Nothing that we lex should be bigger than this (except very rare cases).
	enum BufferSize = 128;
	char[BufferSize] buffer = void;
	string heapBuffer;
	size_t i;
	
	void pumpChars(alias condition, R)(ref R r) {
		char c;
		
		Begin:
		if (i < BufferSize) {
			do {
				c = r.front;
				
				if (condition(c)) {
					buffer[i++] = c;
					popChar();
					
					continue;
				} else static if (decode) {
					// Check if if have an unicode character.
					if (c & 0x80) {
						size_t i = index;
						auto u = content.decode(i);
						
						if (condition(u)) {
							auto l = cast(ubyte) (i - index);
							while(l--) {
								putChar(r.front);
								popChar();
							}
							
							goto Begin;
						}
					}
				}
				
				return;
			} while(i < BufferSize);
			
			// Buffer is full, we need to work on heap;
			heapBuffer = buffer.idup;
		}
		
		while(true) {
			 c = r.front;
			 
			 if (condition(c)) {
				heapBuffer ~= c;
				popChar();
				
				continue;
			 } else static if (decode) {
				// Check if if have an unicode character.
				if (c & 0x80) {
					size_t i = index;
					auto u = content.decode(i);
					
					if (condition(u)) {
						auto l = cast(ubyte) (i - index);
						heapBuffer.reserve(l);
						
						while(l--) {
							heapBuffer ~= r.front;
							popChar();
						}
					}
				}
			}
			
			return;
		}
	}
	
	void putChar(char c) {
		if (i < BufferSize) {
			buffer[i++] = c;
			
			if (i == BufferSize) {
				// Buffer is full, we need to work on heap;
				heapBuffer = buffer.idup;
			}
		} else {
			heapBuffer ~= c;
		}
	}
	
	void putString(string s) {
		auto finalSize = i + s.length;
		if (finalSize < BufferSize) {
			buffer[i .. finalSize][] = s[];
			i = finalSize;
		} else if (i < BufferSize) {
			heapBuffer.reserve(finalSize);
			heapBuffer ~= buffer[0 .. i];
			heapBuffer ~= s;
			
			i = BufferSize;
		} else {
			heapBuffer ~= s;
		}
	}
	
	auto getValue() {
		return context.getName(
			(i < BufferSize)
				? buffer[0 .. i].idup
				: heapBuffer
		);
	}
}


private auto lexerMap() {
    auto ret = [
        // Whitespaces
        " ":    "?lexWhiteSpace",
        "\t":   "?lexWhiteSpace",
        "\v":   "?lexWhiteSpace",
        "\f":   "?lexWhiteSpace",
        "\n":   "?lexWhiteSpace",
        "\r":   "?lexWhiteSpace",
        "\r\n": "?lexWhiteSpace",

        // Comments
        "//":   "?lexComment",
        "/+":   "?lexComment",
        "/*":   "?lexComment",

        // Integer Literals
        "0x":   "lexNumeric",
        "0b":   "lexNumeric",

        // String Literals
        "`":    "lexString", // format style
        `r"`:   "lexString", // WYSIWYG
        `"`:    "lexString",
        `x"`:   "lexString", // HEX string?
        `q{`:   "lexString",

        "'":    "lexChar",
        // TODO: Add support for regex
    ];

    foreach (k, v; operatorsMap()) {
        ret[k] = "lexOperator";
    }

    foreach (k, v; keywordsMap()) {
        ret[k] = "lexKeyword";
    }

    foreach (i; 0 .. 10) {
        ret[i.to!string] = "lexNumeric";
    }

    return ret;    
}

auto stringify(string s) {
	return "`" ~ s.replace("`", "` ~ \"`\" ~ `").replace("\0", "` ~ \"\\0\" ~ `") ~ "`";
}

auto getReturnOrBreak(string fun, string base) {
	auto cmd = "!(" ~ stringify(base) ~ ")()";
	
	if (fun[0] == '?') {
		cmd = fun[1 .. $] ~ cmd;
		return "
				static if(is(typeof(" ~ cmd ~ ") == void)) {
					" ~ cmd ~ ";
					continue;
				} else {
					return " ~ cmd ~ ";
				}";
	} else {
		cmd = fun ~ cmd;
		return "
				return " ~ cmd ~ ";";
	}
}

string lexerMixin(string base = "", string def = "lexIdentifier", string[string] ids = lexerMap()) {
	auto defaultFun = def;
	string[string][char] nextLevel;
	foreach(id, fun; ids) {
		if (id == "") {
			defaultFun = fun;
		} else {
			nextLevel[id[0]][id[1 .. $]] = fun;
		}
	}
	
	auto ret = "
		switch(frontChar) {";
	
	foreach(c, ids; nextLevel) {
		// TODO: have a real function to handle that.
		string charLit;
		switch(c) {
			case '\0' :
				charLit = "\\0";
				break;
			
			case '\'' :
				charLit = "\\'";
				break;
			
			case '\n' :
				charLit = "\\n";
				break;
			
			case '\r' :
				charLit = "\\r";
				break;
			
			default:
				charLit = [c];
		}
		
		ret ~= "
			case '" ~ charLit ~ "' :
				popChar();";
		
		auto newBase = base ~ c;
		if (ids.length == 1) {
			if (auto cdef = "" in ids) {
				ret ~= getReturnOrBreak(*cdef, newBase);
				continue;
			}
		}
		
		ret ~= lexerMixin(newBase, def, nextLevel[c]);
	}
	
	ret ~= "
			default :" ~ getReturnOrBreak(defaultFun, base) ~ "
		}
		";
	
	return ret;
}
