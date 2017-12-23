module main;

import std.stdio;
import std.file;

import Lexer;
import Tokens;
import Print;
import Domain.Context;
import Parser.Declaration;

void main(string[] args) @safe {
    /*if (args.length < 2) {
        writeln("Specify file to compile!");
        return -1;
    }*/
    
    writeln("Rin compiler starting up");

    auto buffer = "namespace System.Test;

using System.IO;
using System.Core.Test;

private async test() -> Task!int {

}

var test = 42;
test.call();
let abc;
byte aa = \"test\";
const(char) abc;
const char cc;
let tupl = (method: \"str\", number: 42, randomType: false);
\0";

    /*() @trusted {
        foreach (x; dirEntries("lib", SpanMode.shallow)) {
            writeln("building: ", x.name);
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
    tr.t.type  = TokenType.Begin;

    auto visitor = new PrintVisitor(tr.context);

    auto ns = tr.parseNamespace();
    ns.visit(visitor);
}
