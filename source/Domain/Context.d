module Domain.Context;

import Domain.Name;
import Domain.Location;


final class Context {
@safe: pure:
    public NameManager _nameManager;

    this() {
        _nameManager = NameManager.get();
    }

    alias _nameManager this;

    ref inout(NameManager) nameManager() inout {
        return _nameManager;
    }
}