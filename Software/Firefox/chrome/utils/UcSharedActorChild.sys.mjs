'use strict';

const ALL_URLS_SCHEMES = new Set(['http:', 'https:', 'ftp:', 'file:', 'ws:', 'wss:', 'data:']);
const WILDCARD_SCHEMES = new Set(['http:', 'https:', 'ws:', 'wss:']);
const HOST_LOCATOR_SCHEMES = new Set([
    'http:', 'https:', 'ws:', 'wss:', 'file:', 'ftp:', 'moz-extension:',
    'chrome:', 'resource:', 'moz:', 'moz-icon:', 'moz-gio:',
]);

function globMatches(value, pattern) {
    const escaped = pattern.replace(/[.+?^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '.*');
    return new RegExp(`^${escaped}$`, 'i').test(value);
}

// This follows the MatchPattern forms accepted by registerWindowActor. The
// shared actor needs the same per-script check after its union registration.
function matchesPattern(pattern, href) {
    if (pattern === '<all_urls>') {
        try {
            return ALL_URLS_SCHEMES.has(new URL(href).protocol);
        } catch {
            return false;
        }
    }

    const separator = pattern.indexOf(':');
    if (separator <= 0) {
        return false;
    }

    let url;
    try {
        url = new URL(href);
    } catch {
        return false;
    }

    const scheme = pattern.slice(0, separator).toLowerCase();
    const expectedProtocol = `${scheme}:`;
    if (scheme === '*') {
        if (!WILDCARD_SCHEMES.has(url.protocol)) {
            return false;
        }
    } else if (url.protocol !== expectedProtocol) {
        return false;
    }

    const remainder = pattern.slice(separator + 1);
    if (scheme !== '*' && !HOST_LOCATOR_SCHEMES.has(expectedProtocol)) {
        return globMatches(url.href.slice(url.href.indexOf(':') + 1).split('#', 1)[0], remainder);
    }

    const match = /^\/\/([^/]*)(\/.*)$/.exec(remainder);
    if (!match) {
        return false;
    }

    const [, host, path] = match;
    const hostname = url.hostname.toLowerCase();
    const expectedHost = host.toLowerCase();
    if (expectedHost === '*') {
        // Any host is valid for the selected scheme.
    } else if (expectedHost.startsWith('*.')) {
        const domain = expectedHost.slice(2);
        if (hostname !== domain && !hostname.endsWith(`.${domain}`)) {
            return false;
        }
    } else if (hostname !== expectedHost) {
        return false;
    }

    return globMatches(`${url.pathname}${url.search}`, path);
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
            if (definition.allFrames === false && !this.isTopLevelFrame()) {
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
        return matches.some(match => matchesPattern(match, href));
    }

    isTopLevelFrame() {
        try {
            return !this.browsingContext?.parent;
        } catch {
            return false;
        }
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
        return sandbox;
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

    didDestroy() {
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
