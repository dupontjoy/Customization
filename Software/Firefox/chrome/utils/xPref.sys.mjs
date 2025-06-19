const Services = globalThis.Services || ChromeUtils.import("resource://gre/modules/Services.jsm").Services;

export const xPref = {
    get: function (prefPath, def = false, valueIfUndefined, setDefault = true) {
        let sPrefs = def ? Services.prefs.getDefaultBranch(null) : Services.prefs;

        try {
            switch (sPrefs.getPrefType(prefPath)) {
                case 0:
                    if (valueIfUndefined !== undefined)
                        return this.set(prefPath, valueIfUndefined, setDefault);
                    else
                        return undefined;
                case 32:
                    return sPrefs.getStringPref(prefPath);
                case 64:
                    return sPrefs.getIntPref(prefPath);
                case 128:
                    return sPrefs.getBoolPref(prefPath);
            }
        } catch (ex) {
            return undefined;
        }
        return;
    },

    set: function (prefPath, value, def = false) {
        let sPrefs = def ? Services.prefs.getDefaultBranch(null) : Services.prefs;

        switch (typeof value) {
            case 'string':
                return sPrefs.setStringPref(prefPath, value) || value;
            case 'number':
                return sPrefs.setIntPref(prefPath, value) || value;
            case 'boolean':
                return sPrefs.setBoolPref(prefPath, value) || value;
        }
        return;
    },

    lock: function (prefPath, value) {
        let sPrefs = Services.prefs;
        this.lockedBackupDef[prefPath] = this.get(prefPath, true);
        if (sPrefs.prefIsLocked(prefPath))
            sPrefs.unlockPref(prefPath);

        this.set(prefPath, value, true);
        sPrefs.lockPref(prefPath);
    },

    lockedBackupDef: {},

    unlock: function (prefPath) {
        Services.prefs.unlockPref(prefPath);
        let bkp = this.lockedBackupDef[prefPath];
        if (bkp === undefined)
            Services.prefs.deleteBranch(prefPath);
        else
            this.set(prefPath, bkp, true);
    },

    clear: Services.prefs.clearUserPref,

    addListener: function (prefPath, trat) {
        let observer = (aSubject, aTopic, prefPath) => {
            return trat(xPref.get(prefPath), prefPath);
        };

        Services.prefs.addObserver(prefPath, observer);
        return {
            prefPath: prefPath,
            observer: observer
        };
    },

    removeListener: function (obs) {
        Services.prefs.removeObserver(obs.prefPath, obs.observer);
    }
};