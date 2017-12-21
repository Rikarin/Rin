namespace System;

alias TODO = assert(false, "TODO");


public class Object {
    public virtual toString() const -> string => typeid(self).name;
    public virtual getHash() const -> size_t => 0;

    public type -> const(Type) => typeid(self);

    public virtual finalize() {

    }

    // TODO: operators
}


public equals(lhs: object, rhs: object) -> bool {
    if (lhs is null && rhs is null) {
        return true;
    }

    TODO;
}
