module main;

import std.stdio;
import std.file;

//import AST;
import Lexer;
//import Parser;
import Tokens;
import Domain.Context;

// TODO: create symbol table for all symbols

void main(string[] args) @safe {
    /*if (args.length < 2) {
        writeln("Specify file to compile!");
        return -1;
    }*/
    
    writeln("Rin compiler starting up");

//    auto buffer = "func test(name: string?, age: int) -> (bool?, int, int) { }";
    auto buffer = "namespace System.Test;

using System.IO;
var test = 42;
test.call();
let abc;
byte aa = \"test\";
const(char) abc;
const char cc;
let tupl = (method: \"str\", number: 42, randomType: false);
\0";


/*    auto buffer = "
import core.stdc.test
@my(const(char)) test
";
*/

//    auto buffer = "for x in array {";

    /*() @trusted {
        foreach (x; dirEntries("tests", SpanMode.shallow)) {
            writeln("Running test: ", x.name);
            auto parser = new Parser(x.name, x.readText);
            parser.nextToken();

            try parser.parse();
            catch (Exception e) writeln(e.msg);
            writeln("--------------");
        }
    }();*/
    
    

    TokenRange tr;
    tr.context = new Context;
    tr.content = buffer;
    tr.t.type = TokenType.Begin;

    /*while (!tr.empty) {
        writeln(tr.front);
        tr.popFront();
    }*/

    import Print;
    auto visitor = new PrintVisitor();

    import Parser.Declaration;
    auto ns = tr.parseNamespace();//.toString(tr.context);
    ns.visit(visitor);
}


// TODO: Type Parser, then Identifier Parser