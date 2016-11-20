module main;

import std.stdio;

import AST;
import Lexer;
import Parser;
import Tokens;

// TODO: create symbol table for all symbols

void main(string[] args) @safe {
    /*if (args.length < 2) {
        writeln("Specify file to compile!");
        return -1;
    }*/
    
    writeln("Rin compiler starting up");

//    auto buffer = "func test(name: string?, age: int) -> (bool?, int, int) { }";
   /* auto buffer = "var test = 42
test.call()
let abc
byte aa = 'test'
const(char) abc
const char cc
let tupl = (method: \"str\", number: 42, randomType: false)";
*/

    auto buffer = "@my(const(char)) test";


    auto parser = new Parser(buffer);
    parser.nextToken();

    try parser.parse();
    catch (Exception e) writeln(e.msg);

/*    auto lexer = new Lexer(buffer);
    while (lexer.token.type != TokenType.Eof) {
        writeln(*lexer.token);
        lexer.nextToken();
    }*/
}