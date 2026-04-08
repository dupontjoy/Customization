'use strict';

const {
    dispatchSharedMessageToChrome,
    getSharedScripts,
} = ChromeUtils.importESModule('chrome://userchromejs/content/utils/UcActorRegistry.sys.mjs');

export class UcSharedActorParent extends JSWindowActorParent {
    receiveMessage({ name, data }) {
        switch (name) {
            case 'UcSharedActor:GetDefinitions':
                return getSharedScripts();
            case 'UcSharedActor:ChromeBridge': {
                const windowGlobal = this.manager?.browsingContext?.currentWindowGlobal;
                const browser = windowGlobal?.rootFrameLoader?.ownerElement;
                const win = browser?.ownerGlobal;
                if (!win) {
                    return false;
                }
                return dispatchSharedMessageToChrome(win, data?.scriptId, {
                    name: data?.name,
                    data: data?.data,
                    browser,
                    actor: this,
                });
            }
        }
        return null;
    }
}
