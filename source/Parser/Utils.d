module Parser.Utils;
@safe:

import Lexer;
import Tokens;
import Domain.Location;
import Domain.Context;

import std.conv, std.string;


enum ParseMode {
    Greedy,
    Reluctant
}


class CompileException : Exception {
    Location location;
    
    CompileException more;
    string fixHint;
    
    this(Location loc, string message) {
        super(message);
        location = loc;
    }
    
    this(Location loc, string message, CompileException more) {
        this.more = more;
        this(loc, message);
    }

    //auto getFullLocation(Context c) const {
        //return location.getFullLocation(c);
    //}
}


void match(ref TokenRange trange, TokenType type) {
    auto token = trange.front;
	
    if (token.type != type) {
        auto error = format("expected '%s', got '%s'.", to!string(type), to!string(token.type));
        throw new CompileException(token.location, error);
    }
	
    trange.popFront();
}