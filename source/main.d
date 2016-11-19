module main;

import std.stdio;

import AST;
import Lexer;
import Parser;
import Tokens;


int main(string[] args) @safe {
    /*if (args.length < 2) {
        writeln("Specify file to compile!");
        return -1;
    }*/
    
    writeln("Rin compiler starting up");

    auto parser = new Parser((() @trusted => stdin)());

    while (true) {
       /* auto tok = parser.nextToken();

        write(tok);
        if (tok == Token.Identifier) {
            writeln(" = ", parser.identifier);
        } else if (tok == Token.Double) {
            writeln(" = ", parser.numeric);
        } else {
            write("\n");
        }*/

        parser.parse();
    }
}