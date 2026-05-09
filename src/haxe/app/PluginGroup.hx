package haxe.app;

import haxe.app.AppError;
import haxe.app.AppError.AppErrorKind;

private typedef PluginGroupEntry = {
    var typeKey:String;
    var plugin:Plugin;
    var enabled:Bool;
}

class PluginGroupBuilder implements PluginGroup {
    private var groupName:String;
    private var plugins:Array<PluginGroupEntry>;

    public function new(groupName:String) {
        this.groupName = groupName;
        this.plugins = [];
    }

    public static function start<T:PluginGroup>(cls:Class<T>):PluginGroupBuilder {
        return new PluginGroupBuilder(resolveGroupName(cls));
    }

    public static function resolveGroupName<T:PluginGroup>(cls:Class<T>):String {
        var name = Type.getClassName(cls);
        return name != null ? name : "PluginGroup";
    }

    public function contains<T:Plugin>(cls:Class<T>):Bool {
        return indexOf(cls) >= 0;
    }

    public function enabled<T:Plugin>(cls:Class<T>):Bool {
        var index = indexOf(cls);
        return index >= 0 && plugins[index].enabled;
    }

    public function set<T:Plugin>(plugin:T):PluginGroupBuilder {
        if (!trySet(plugin)) {
            throw new AppError(AppErrorKind.PluginGroupPluginMissing(groupName, typeKeyForPlugin(plugin)));
        }
        return this;
    }

    public function trySet<T:Plugin>(plugin:T):Bool {
        var index = indexOfTypeKey(typeKeyForPlugin(plugin));
        if (index < 0) {
            return false;
        }
        plugins[index] = {
            typeKey: plugins[index].typeKey,
            plugin: plugin,
            enabled: plugins[index].enabled
        };
        return true;
    }

    public function add<T:Plugin>(plugin:T):PluginGroupBuilder {
        upsert(plugin, plugins.length);
        return this;
    }

    public function tryAdd<T:Plugin>(plugin:T):Bool {
        if (indexOfTypeKey(typeKeyForPlugin(plugin)) >= 0) {
            return false;
        }
        add(plugin);
        return true;
    }

    public function addGroup(group:PluginGroup):PluginGroupBuilder {
        var nested = group.build();
        for (entry in nested.plugins) {
            upsertEntry({
                typeKey: entry.typeKey,
                plugin: entry.plugin,
                enabled: entry.enabled
            }, plugins.length);
        }
        return this;
    }

    public function addBefore<Target:Plugin>(target:Class<Target>, plugin:Plugin):PluginGroupBuilder {
        var index = indexOf(target);
        if (index < 0) {
            throw new AppError(AppErrorKind.PluginGroupPluginMissing(groupName, typeKeyForClass(target)));
        }
        upsert(plugin, index);
        return this;
    }

    public function tryAddBefore<Target:Plugin, Insert:Plugin>(target:Class<Target>, plugin:Insert):Bool {
        if (indexOfTypeKey(typeKeyForPlugin(plugin)) >= 0) {
            return false;
        }
        var index = indexOf(target);
        if (index < 0) {
            return false;
        }
        upsert(plugin, index);
        return true;
    }

    public function tryAddBeforeOverwrite<Target:Plugin, Insert:Plugin>(target:Class<Target>, plugin:Insert):Bool {
        var index = indexOf(target);
        if (index < 0) {
            return false;
        }
        upsert(plugin, index);
        return true;
    }

    public function addAfter<Target:Plugin>(target:Class<Target>, plugin:Plugin):PluginGroupBuilder {
        var index = indexOf(target);
        if (index < 0) {
            throw new AppError(AppErrorKind.PluginGroupPluginMissing(groupName, typeKeyForClass(target)));
        }
        upsert(plugin, index + 1);
        return this;
    }

    public function tryAddAfter<Target:Plugin, Insert:Plugin>(target:Class<Target>, plugin:Insert):Bool {
        if (indexOfTypeKey(typeKeyForPlugin(plugin)) >= 0) {
            return false;
        }
        var index = indexOf(target);
        if (index < 0) {
            return false;
        }
        upsert(plugin, index + 1);
        return true;
    }

    public function tryAddAfterOverwrite<Target:Plugin, Insert:Plugin>(target:Class<Target>, plugin:Insert):Bool {
        var index = indexOf(target);
        if (index < 0) {
            return false;
        }
        upsert(plugin, index + 1);
        return true;
    }

    public function disable<T:Plugin>(cls:Class<T>):PluginGroupBuilder {
        var index = indexOf(cls);
        if (index < 0) {
            throw new AppError(AppErrorKind.PluginGroupPluginMissing(groupName, typeKeyForClass(cls)));
        }
        plugins[index].enabled = false;
        return this;
    }

    public function enable<T:Plugin>(cls:Class<T>):PluginGroupBuilder {
        var index = indexOf(cls);
        if (index < 0) {
            throw new AppError(AppErrorKind.PluginGroupPluginMissing(groupName, typeKeyForClass(cls)));
        }
        plugins[index].enabled = true;
        return this;
    }

    public function finish(app:App):App {
        for (entry in plugins) {
            if (entry.enabled) {
                try {
                    app.addPlugin(entry.plugin);
                } catch (error:Dynamic) {
                    throw new AppError(AppErrorKind.PluginGroupAddFailed(groupName, entry.plugin.name, error));
                }
            }
        }
        return app;
    }

    public function build():PluginGroupBuilder {
        return this;
    }

    private function upsert(plugin:Plugin, targetIndex:Int):Void {
        upsertEntry({
            typeKey: typeKeyForPlugin(plugin),
            plugin: plugin,
            enabled: true
        }, targetIndex);
    }

    private function upsertEntry(entry:PluginGroupEntry, targetIndex:Int):Void {
        var existing = indexOfTypeKey(entry.typeKey);
        if (existing >= 0) {
            plugins.splice(existing, 1);
            if (existing < targetIndex) {
                targetIndex--;
            }
        }
        plugins.insert(targetIndex, entry);
    }

    private function indexOf<T:Plugin>(cls:Class<T>):Int {
        return indexOfTypeKey(typeKeyForClass(cls));
    }

    private function indexOfTypeKey(typeKey:String):Int {
        for (i in 0...plugins.length) {
            if (plugins[i].typeKey == typeKey) {
                return i;
            }
        }
        return -1;
    }

    private static function typeKeyForPlugin(plugin:Plugin):String {
        var cls = Type.getClass(plugin);
        if (cls == null) {
            throw new AppError(AppErrorKind.PluginWithoutRuntimeClass(Std.string(plugin)));
        }
        return typeKeyForClass(cast cls);
    }

    private static function typeKeyForClass<T>(cls:Class<T>):String {
        var name = Type.getClassName(cls);
        if (name == null) {
            throw new AppError(AppErrorKind.PluginClassNameUnavailable);
        }
        return name;
    }
}

interface PluginGroup {
    function build():PluginGroupBuilder;
}

class NoopPluginGroup implements PluginGroup {
    public function new() {}

    public function build():PluginGroupBuilder {
        return PluginGroupBuilder.start(NoopPluginGroup);
    }
}

class PluginGroupBuilderGroup implements PluginGroup {
    private var builder:PluginGroupBuilder;

    public function new(builder:PluginGroupBuilder) {
        this.builder = builder;
    }

    public function build():PluginGroupBuilder {
        return builder;
    }
}

class PluginGroupTools {
    public static function name<T:PluginGroup>(cls:Class<T>):String {
        return PluginGroupBuilder.resolveGroupName(cls);
    }
}
