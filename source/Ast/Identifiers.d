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