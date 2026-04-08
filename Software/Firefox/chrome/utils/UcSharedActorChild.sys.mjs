'use strict';

function patternToRegExp(pattern) {
    if (!pattern || pattern === '*') {
        return /^.*$/i;
    }
    if (pattern.startsWith('/') && pattern.endsWith('/')) {
        return new RegExp(pattern.slice(1, -1));
    }
    const escaped = pattern
        .replace(/[.+?^${}()|[\]\\]/g, '\\$&')
        .replace(/\*/g, '.*');
    return new RegExp(`^${escaped}$`, 'i');
}

function resolveModuleExport(moduleNS, exportedModule) {
    if (exportedModule && moduleNS?.[exportedModule]) {
        return moduleNS[exportedModule];
    }
    return null;
}

export class UcSharedActorChild extends JSWindowActorChild {
    async handleEvent(event) {
        const href = this.contentWindow?.location?.href;
        if (!href || href === 'about:blank') {
            return;
        }
        const definitions = await this.getDefinitions();
        for (const definition of definitions) {
            if (!definition?.events?.[event.type]) {
                continue;
            }
            if (!this.matchesDefinition(definition, href)) {
                continue;
            }
            await this.runDefinition(definition, event);
        }
    }

    async getDefinitions() {
        if (!this._definitionsPromise) {
            this._definitionsPromise = Promise.resolve(
                this.sendQuery('UcSharedActor:GetDefinitions')
            ).catch(ex => {
                Cu.reportError(ex);
                return [];
            });
        }
        return this._definitionsPromise;
    }

    matchesDefinition(definition, href) {
        const matches = definition.matches || [];
        if (!matches.length) {
            return true;
        }
        return matches.some(match => patternToRegExp(match).test(href));
    }

    async runDefinition(definition, event) {
        try {
            const moduleNS = ChromeUtils.importESModule(definition.moduleURI);
            const exportedModule = resolveModuleExport(moduleNS, definition.exportedModule);
            const handlers = exportedModule?.contentHandlers || moduleNS?.contentHandlers;
            const handler =
                typeof handlers?.[event.type] === 'function'
                    ? handlers[event.type]
                    : typeof handlers?.handleEvent === 'function'
                        ? handlers.handleEvent
                        : null;
            if (typeof handler !== 'function') {
                return;
            }

            const context = this.createContext(definition, event);
            handler.call(exportedModule || handlers || moduleNS, context);
        } catch (ex) {
            Cu.reportError(ex);
        }
    }

    createContext(definition, event) {
        return {
            actor: this,
            contentDocument: this.contentWindow?.document || null,
            contentWindow: this.contentWindow || null,
            event,
            sandbox: definition.sandbox ? this.getSandbox(definition.id) : null,
            scriptId: definition.id,
            sendToChrome: (name, data = {}) => this.sendAsyncMessage('UcSharedActor:ChromeBridge', {
                scriptId: definition.id,
                name,
                data,
            }),
            setUnloadMap: (key, func, handlerContext) => this.setUnloadMap(definition.id, key, func, handlerContext),
            getDelUnloadMap: (key, del = false) => this.getUnloadMap(definition.id, key, del),
        };
    }

    getSandbox(scriptId) {
        if (!this._sandboxes) {
            this._sandboxes = new Map();
        }
        if (this._sandboxes.has(scriptId)) {
            return this._sandboxes.get(scriptId);
        }
        const win = this.contentWindow;
        let principal = win.document.nodePrincipal;
        const options = {
            sandboxName: `UcSharedActor:${scriptId}`,
            wantComponents: true,
            wantExportHelpers: true,
            wantXrays: true,
            freezeBuiltins: false,
            sameZoneAs: win,
            sandboxPrototype: win,
        };
        if (!principal.isSystemPrincipal) {
            principal = [principal];
            options.wantComponents = false;
        }
        const sandbox = Cu.Sandbox(principal, options);
        Cu.exportFunction((key, func, handlerContext) => this.setUnloadMap(scriptId, key, func, handlerContext), sandbox, { defineAs: 'setUnloadMap' });
        Cu.exportFunction((key, del = false) => this.getUnloadMap(scriptId, key, del), sandbox, { defineAs: 'getDelUnloadMap' });
        Cu.exportFunction((name, data = {}) => this.sendAsyncMessage('UcSharedActor:ChromeBridge', {
            scriptId,
            name,
            data,
        }), sandbox, { defineAs: 'sendToChrome' });
        this._sandboxes.set(scriptId, sandbox);
        this.ensureUnloadListener();
        return sandbox;
    }

    ensureUnloadListener() {
        if (this._hasUnloadListener || !this.contentWindow) {
            return;
        }
        this._hasUnloadListener = true;
        this.contentWindow.addEventListener('unload', () => this.destructor(), { once: true });
    }

    setUnloadMap(scriptId, key, func, handlerContext) {
        if (!this._unloadMaps) {
            this._unloadMaps = new Map();
        }
        let unloadMap = this._unloadMaps.get(scriptId);
        if (!unloadMap) {
            unloadMap = new Map();
            this._unloadMaps.set(scriptId, unloadMap);
        }
        unloadMap.set(key, { func, context: handlerContext });
    }

    getUnloadMap(scriptId, key, del = false) {
        const unloadMap = this._unloadMaps?.get(scriptId);
        const value = unloadMap?.get(key);
        if (value && del) {
            unloadMap.delete(key);
        }
        return value;
    }

    destructor() {
        for (const unloadMap of this._unloadMaps?.values() || []) {
            for (const [key, value] of unloadMap) {
                try {
                    value.func?.call(value.context, key);
                } catch (ex) {
                    Cu.reportError(ex);
                }
            }
            unloadMap.clear();
        }
        this._unloadMaps?.clear();
        for (const sandbox of this._sandboxes?.values() || []) {
            try {
                Cu.nukeSandbox(sandbox);
            } catch (ex) {
                Cu.reportError(ex);
            }
        }
        this._sandboxes?.clear();
    }
}
