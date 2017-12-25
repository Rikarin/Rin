module Ast.Identifiers;

import Domain.Name;
import Domain.Location;
import Common.Node;


abstract class Identifier : Node {
    Name name;

    this(Location location, Name name) {
        super(location);

        this.name = name;
    }
}


abstract class TemplateArgument : Node {
    this(Location location) {
        super(location);
    }
}


//final class Basic


// TODO type? = try? expression; // ak to throwne excp, tak sa nastavy null
// TODO: explicit throws
// TODO: rename scope(exit) to defer
// TODO: get/set, willSet/didSet
// miesto if pri fci pouzit where

// partial class
// for (x in array) miesto foreachu, reverse je sracka, implementovat to v libke. for (x in array.reverse);

// konverzi zo stringu na int, const x = int("123");
// zrusit virtual. vsetko bude defaultne virtual a to co virtual byt nema, sa oznaci za final


// unwraping:
// const test: int? = 42;
// const x: int = test!;

// var test: Test? = Foo as? Test;

// rename __LINE__ to #line