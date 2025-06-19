// https://forum.mozilla-russia.org/viewtopic.php?pid=808453#p808453
try {
  (jsval => {
    var dbg, gref, genv = func => {
      var sandbox = new Cu.Sandbox(g, { freshCompartment: true });
      Cc["@mozilla.org/jsdebugger;1"].createInstance(Ci.IJSDebugger).addClass(sandbox);
      (dbg = new sandbox.Debugger()).addDebuggee(g);
      gref = dbg.makeGlobalObjectReference(g);
      return (genv = func => func && gref.makeDebuggeeValue(func).environment)(func);
    }
    var g = Cu.getGlobalForObject(jsval), o = g.Object, { freeze } = o, disleg;

    var lexp = () => lockPref("extensions.experiments.enabled", true);
    var MRS = "MOZ_REQUIRE_SIGNING", AC = "AppConstants", uac = `resource://gre/modules/${AC}.`;

    if (o.isFrozen(o)) { // Fx 102.0b7+
      lexp(); disleg = true; genv();

      dbg.onEnterFrame = frame => {
        var { script } = frame;
        try { if (!script.url.startsWith(uac)) return; } catch { return; }
        dbg.onEnterFrame = undefined;

        if (script.isModule) { // ESM, Fx 108+
          var env = frame.environment;
          frame.onPop = () => env.setVariable(AC, gref.makeDebuggeeValue(freeze(
            o.assign(new o(), env.getVariable(AC).unsafeDereference(), { [MRS]: false })
          )));
        }
        else { // JSM
          var nsvo = frame.this.unsafeDereference();
          nsvo.Object = {
            freeze(ac) {
              ac[MRS] = false;
              delete nsvo.Object;
              return freeze(ac);
            }
          };
        }
      }
    }
    else o.freeze = obj => {
      if (!Components.stack.caller.filename.startsWith(uac)) return freeze(obj);
      obj[MRS] = false;

      if ((disleg = "MOZ_ALLOW_ADDON_SIDELOAD" in obj)) lexp();
      else
        obj.MOZ_ALLOW_LEGACY_EXTENSIONS = true,
          lockPref("extensions.legacy.enabled", true);

      return (o.freeze = freeze)(obj);
    }
    lockPref("xpinstall.signatures.required", false);
    lockPref("extensions.langpacks.signatures.required", false);

    var useDbg = true, xpii = "resource://gre/modules/addons/XPIInstall.";
    if (Ci.nsINativeFileWatcherService) { // Fx < 100
      jsval = Cu.import(xpii + "jsm", {});
      var shouldVerify = jsval.shouldVerifySignedState;
      if (shouldVerify.length == 1)
        useDbg = false,
          jsval.shouldVerifySignedState = addon => !addon.id && shouldVerify(addon);
    }
    if (useDbg) { // Fx 99+
      try { var exp = ChromeUtils.importESModule(xpii + "sys.mjs"); }
      catch { exp = g.ChromeUtils.import(xpii + "jsm"); }
      jsval = o.assign({}, exp);

      var env = genv(jsval.XPIInstall.installTemporaryAddon);
      var ref = name => { try { return env.find(name).getVariable(name).unsafeDereference(); } catch { } }
      jsval.XPIDatabase = (ref("XPIExports") || ref("lazy") || {}).XPIDatabase || ref("XPIDatabase");

      var proto = ref("Package").prototype;
      var verify = proto.verifySignedState;
      proto.verifySignedState = function (id) {
        return id ? { cert: null, signedState: undefined } : verify.apply(this, arguments);
      }
      dbg.removeAllDebuggees();
    }
    if (disleg) jsval.XPIDatabase.isDisabledLegacy = () => false;
  })(
    "permitCPOWsInScope" in Cu ? Cu.import("resource://gre/modules/WebRequestCommon.jsm", {}) : Cu
  );
}
catch (ex) { Cu.reportError(ex); }