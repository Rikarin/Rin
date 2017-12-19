module Common.Node;
@safe:

import Domain.Location;
import Domain.Context;
import Common.IVisitor;


abstract class Node {
	Location location;
	
	this(Location location) {
		this.location = location;
	}

	void visit(IVisitor decl);

	invariant() {
		// FIXME: reenable this when ct paradoxes know their location.
		assert(location != Location.init, "node location must never be init");
	}

final:
	//auto getFullLocation(Context c) const {
		//return location.getFullLocation(c);
	//}
}