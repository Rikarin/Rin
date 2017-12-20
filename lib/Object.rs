namespace System;


public class Object {
    public virtual string toString() const => typeid(self).name;
    public virtual size_t getHash() const => 0;

    public const(Type) type => typeid(self);

    public virtual void finalize() {

    }

    // TODO: operators
}
