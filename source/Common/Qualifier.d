module Common.Qualifier;


enum Visibility {
	Default, // This is there because variable inside class has different default visibility, than method
    Private,
    Protected,
    Internal,
    Public,
	Extern
}


enum Linkage {
    Rin,
    C
}


enum Storage {
    Local,
    Capture,
    Static,
    Enum
}


bool isGlobal(Storage s) {
    return s > Storage.Capture;
}


enum ParamKind {
	Regular,
	Final,
	Ref
}


enum TypeQualifier {
    Mutable,
    Inout,
    Const,
    Shared,
    ConstShared,
    ReadOnly
}

auto add(TypeQualifier actual, TypeQualifier added) {
	if ((actual == TypeQualifier.Shared && added == TypeQualifier.Const) ||
			(added == TypeQualifier.Shared && actual == TypeQualifier.Const)) {
		return TypeQualifier.ConstShared;
	}
	
	import std.algorithm;
	return max(actual, added);
}

bool isConvertible(TypeQualifier from, TypeQualifier to) {
	if (from == to) {
		return true;
	}
	
	final switch (to) with (TypeQualifier) {
		case Mutable, Inout, Shared, ReadOnly:
			// Some qualifier are not safely castable to.
			return false;
		
		case Const:
			return from == Mutable || from == ReadOnly || from == Inout;
		
		case ConstShared:
			return from == Shared || from == ReadOnly;
	}
}