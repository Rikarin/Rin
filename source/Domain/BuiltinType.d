module Domain.BuiltinType;

enum BuiltinType : ubyte {
	None,
	Void,
	Bool,
	Char, Wchar, Dchar,
	Byte, Ubyte,
	Short, Ushort,
	Int, Uint,
	Long, Ulong,
	Cent, Ucent,
	Float, Double, Real,
	Null,
}