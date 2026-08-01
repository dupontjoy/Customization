/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

// Minimal compatibility surface for scripts written for fx-autoconfig's UC_API.
// Contract reference: https://github.com/MrOtherGuy/fx-autoconfig

const VALID_MODIFIERS = new Set(["accel", "alt", "ctrl", "meta", "shift"]);

function createElement(doc, tag, props = {}, isHTML = false) {
  const element = isHTML
    ? doc.createElement(tag)
    : doc.createXULElement(tag);
  for (const [name, value] of Object.entries(props)) {
    element.setAttribute(name, value);
  }
  return element;
}

function waitForWindow(window) {
  if (!window || window.closed) {
    return Promise.reject(new Error("Cannot attach a hotkey to a closed window"));
  }
  if (window.document?.readyState === "complete") {
    return Promise.resolve();
  }
  return new Promise(resolve => {
    window.addEventListener("load", resolve, { once: true });
  });
}

class ChromeDirectoryResult {
  entry() {
    return Services.dirsvc.get("UChrm", Ci.nsIFile).clone();
  }
}

const FileSystem = Object.freeze({
  chromeDir() {
    return new ChromeDirectoryResult();
  },
});

class HotkeyDefinition {
  #matchingSelector;
  #suppressedKeys = new WeakMap();

  constructor(trigger, command) {
    this.trigger = trigger;
    this.command = command;
    this.#matchingSelector = null;
  }

  get matchingSelector() {
    if (!this.#matchingSelector) {
      const trigger = this.trigger;
      const keySelector = trigger.key
        ? `key="${trigger.key}"`
        : `keycode="${trigger.keycode}"`;
      this.#matchingSelector =
        `key[modifiers="${trigger.modifiers}"][${keySelector}]`;
    }
    return this.#matchingSelector;
  }

  async attachToWindow(window, options = {}) {
    await waitForWindow(window);
    const doc = window.document;
    if (doc.getElementById(this.trigger.id)) {
      return;
    }

    if (options.suppressOriginal || options.suppressOriginalKey) {
      this.suppressOriginalKey(window);
    }

    if (this.command) {
      this.#createCommand(doc);
    }
    this.#createKey(doc);
  }

  suppressOriginalKey(window) {
    const oldKey = window.document.querySelector(this.matchingSelector);
    if (!oldKey || oldKey.id === this.trigger.id) {
      return;
    }
    this.#suppressedKeys.set(window, oldKey);
    oldKey.setAttribute("disabled", "true");
  }

  restoreOriginalKey(window) {
    const oldKey = this.#suppressedKeys.get(window);
    if (!oldKey) {
      return;
    }
    oldKey.removeAttribute("disabled");
    this.#suppressedKeys.delete(window);
  }

  #createKey(doc) {
    let keyset = doc.getElementById("ucKeySet");
    if (!keyset) {
      keyset = createElement(doc, "keyset", { id: "ucKeySet" });
      (doc.body || doc.documentElement).appendChild(keyset);
    }
    keyset.appendChild(createElement(doc, "key", this.trigger));
  }

  #createCommand(doc) {
    const commandId = this.command.id;
    if (doc.getElementById(commandId)) {
      return;
    }

    let commandset = doc.getElementById("ucCommandSet");
    if (!commandset) {
      commandset = createElement(doc, "commandset", { id: "ucCommandSet" });
      const parent = doc.body || doc.documentElement;
      parent.insertBefore(commandset, parent.firstChild);
    }

    const command = createElement(doc, "command", { id: commandId });
    command.addEventListener("command", event => {
      this.command.callback(event.view || doc.defaultView, event);
    });
    commandset.insertBefore(command, commandset.firstChild);
  }
}

class Hotkeys {
  static define(details) {
    const key = String(details?.key || "").toUpperCase();
    const isNormalKey = /^[\w-]$/.test(key);
    const isFunctionKey = /^F(?:1[0-2]|[1-9])$/.test(key);
    const isVirtualKey = /^VK_[A-Z0-9_]+$/.test(key);
    if (!isNormalKey && !isFunctionKey && !isVirtualKey) {
      throw new Error(`Provided key '${details?.key}' is invalid`);
    }

    const commandType = typeof details.command;
    if (commandType !== "string" && commandType !== "function") {
      throw new Error("command must be either a string or function");
    }
    if (commandType === "function" && !details.id) {
      throw new Error("command id must be specified when callback is a function");
    }

    const modifiers = String(details.modifiers || "")
      .toLowerCase()
      .split(/\s+/)
      .filter(modifier => VALID_MODIFIERS.has(modifier))
      .map(modifier => modifier === "ctrl" ? "accel" : modifier);
    if (isNormalKey && modifiers.length === 0) {
      throw new Error("Normal hotkeys require at least one modifier");
    }

    const trigger = {
      id: details.id,
      modifiers: [...new Set(modifiers)].join(","),
      command: commandType === "string"
        ? details.command
        : `cmd_${details.id}`,
    };
    if (details.reserved) {
      trigger.reserved = "true";
    }
    if (isNormalKey) {
      trigger.key = key;
    } else {
      trigger.keycode = isFunctionKey ? `VK_${key}` : key;
    }

    const command = commandType === "function"
      ? { id: trigger.command, callback: details.command }
      : null;
    return new HotkeyDefinition(trigger, command);
  }
}

export const UC_API = Object.freeze({
  FileSystem,
  Hotkeys,
  Utils: Object.freeze({ createElement }),
});
