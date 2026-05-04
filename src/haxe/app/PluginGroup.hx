package haxe.app;

import haxe.ds.Map;

/**
    Builder for constructing a plugin group.

    Allows adding multiple plugins with optional configuration
    before adding the group to an App.
**/
class PluginGroupBuilder {
    var plugins:Array<{plugin:Plugin, settings:Dynamic}>;
    var order:Array<String>;

    /**
        Creates a new PluginGroupBuilder starting with the given group type.
    **/
    public function new(groupName:String) {
        plugins = [];
        order = [];
    }

    /**
        Adds a plugin to this group.
    **/
    public function add<T:Plugin>(plugin:T):PluginGroupBuilder {
        plugins.push({plugin: plugin, settings: null});
        order.push(plugin.name);
        return this;
    }

    /**
        Adds a plugin with configuration settings.
    **/
    public function addWithSettings<T:Plugin>(plugin:T, settings:Dynamic):PluginGroupBuilder {
        plugins.push({plugin: plugin, settings: settings});
        order.push(plugin.name);
        return this;
    }

    /**
        Adds all plugins from another group.
    **/
    public function addGroup<T:PluginGroup>(group:T):PluginGroupBuilder {
        var builder = group.build();
        for (p in builder.plugins) {
            plugins.push(p);
            order.push(p.plugin.name);
        }
        return this;
    }

    /**
        Sets the order of plugins in this group.
    **/
    public function setOrder(order:Array<String>):PluginGroupBuilder {
        this.order = order;
        return this;
    }

    /**
        Builds and returns the plugin group.
    **/
    public function build():BuiltPluginGroup {
        return new BuiltPluginGroup(plugins, order);
    }
}

/**
    Internal class representing a built plugin group.
**/
class BuiltPluginGroup {
    var plugins:Array<{plugin:Plugin, settings:Dynamic}>;
    var order:Array<String>;

    public function new(plugins:Array<{plugin:Plugin, settings:Dynamic}>, order:Array<String>) {
        this.plugins = plugins;
        this.order = order;
    }

    /**
        Adds all plugins in this group to the App.
    **/
    public function addToApp(app:App):Void {
        for (name in order) {
            for (p in plugins) {
                if (p.plugin.name == name) {
                    app.addPluginDirectly(p.plugin);
                    break;
                }
            }
        }
    }
}

/**
    Interface for a group of plugins.

    Implement this interface to create a collection of related plugins
    that can be added to an App with a single call.
**/
interface PluginGroup {
    /**
        Builds the plugin group and returns a builder.
    **/
    function build():PluginGroupBuilder;
}
