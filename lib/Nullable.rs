namespace System;


// This class is returned from ?. and ?[] operator usages. same as monad e.g. 'value: int?'
public final class Nullable(T) {
    private T    _value;
    private bool _hasValue;

    public self() {

    }

    public self(T value) {
        _value    = value;
        _hasValue = true;
    }

    public hasValue -> bool => _hasValue;

    public value -> T {
        if (!_hasValue) {
            throw new InvalidOperationException;
        }

        return _value;
    }
}
