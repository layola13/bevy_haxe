package bevy.app;

interface Plugin {
    function build(app:App):Void;
}

class PluginTools {
    public static function isReady(plugin:Plugin, app:App):Bool {
        var hook = Reflect.field(plugin, "ready");
        if (hook == null) {
            return true;
        }
        return cast Reflect.callMethod(plugin, hook, [app]);
    }

    public static function finish(plugin:Plugin, app:App):Void {
        var hook = Reflect.field(plugin, "finish");
        if (hook != null) {
            Reflect.callMethod(plugin, hook, [app]);
        }
    }

    public static function cleanup(plugin:Plugin, app:App):Void {
        var hook = Reflect.field(plugin, "cleanup");
        if (hook != null) {
            Reflect.callMethod(plugin, hook, [app]);
        }
    }

    public static function name(plugin:Plugin):String {
        var hook = Reflect.field(plugin, "name");
        if (hook != null) {
            return cast Reflect.callMethod(plugin, hook, []);
        }

        var cls = Type.getClass(plugin);
        if (cls != null) {
            var full = Type.getClassName(cls);
            if (full != null) {
                return full;
            }
        }
        return Std.string(plugin);
    }

    public static function isUnique(plugin:Plugin):Bool {
        var hook = Reflect.field(plugin, "isUnique");
        if (hook == null) {
            return true;
        }
        return cast Reflect.callMethod(plugin, hook, []);
    }
}
