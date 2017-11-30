module Domain.Context;

import Domain.Name;
import Domain.Location;


final class Context {
    package NameManager m_nameManager;

    this() {
        m_nameManager = NameManager.get();
    }

    alias m_nameManager this;

    ref inout(NameManager) nameManager() inout {
        return m_nameManager;
    }
}