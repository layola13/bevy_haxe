package bevy.app;

import bevy.app.PluginGroup.PluginGroupBuilder;

private enum PluginsData {
    SinglePlugin(plugin:Plugin);
    PluginGroupValue(group:PluginGroup);
    Many(values:Array<Plugins>);
}

abstract Plugins(PluginsData) {
    inline function new(data:PluginsData) {
        this = data;
    }

    @:from
    public static function fromPlugin(plugin:Plugin):Plugins {
        return new Plugins(SinglePlugin(plugin));
    }

    @:from
    public static function fromPluginGroup(group:PluginGroup):Plugins {
        return new Plugins(PluginGroupValue(group));
    }

    @:from
    public static function fromPluginArray(values:Array<Plugin>):Plugins {
        var items:Array<Plugins> = [];
        if (values != null) {
            for (value in values) {
                items.push(fromPlugin(value));
            }
        }
        return new Plugins(Many(items));
    }

    @:from
    public static function fromPluginGroupArray(values:Array<PluginGroup>):Plugins {
        var items:Array<Plugins> = [];
        if (values != null) {
            for (value in values) {
                items.push(fromPluginGroup(value));
            }
        }
        return new Plugins(Many(items));
    }

    @:from
    public static function fromPluginGroupBuilderArray(values:Array<PluginGroupBuilder>):Plugins {
        var items:Array<Plugins> = [];
        if (values != null) {
            for (value in values) {
                items.push(fromPluginGroup(value));
            }
        }
        return new Plugins(Many(items));
    }

    @:from
    public static function fromPluginsArray(values:Array<Plugins>):Plugins {
        return new Plugins(Many(values != null ? values.copy() : []));
    }

    public function addToApp(app:App):Void {
        switch (cast this : PluginsData) {
            case SinglePlugin(plugin):
                app.addPlugin(plugin);
            case PluginGroupValue(group):
                group.build().finish(app);
            case Many(values):
                for (value in values) {
                    value.addToApp(app);
                }
        }
    }
}
