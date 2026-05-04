package haxe.app;

import haxe.ds.Map;

/**
    Base plugin class with lifecycle hooks.

    Extend this class to create plugins with custom lifecycle behavior.
    Override only the methods you need.
**/
class LifecyclePlugin implements Plugin {
    /**
        The unique name of this plugin.
        Override to provide a custom name.
    **/
    public var name(get, never):String;

    /**
        Whether this plugin can be added multiple times.
        Override to return `false` if needed.
    **/
    public var isUnique(get, never):Bool;

    /**
        Creates a new LifecyclePlugin with the given name.
    **/
    public function new(?name:String) {
        this._name = name;
    }

    var _name:String;

    function get_name():String {
        if (_name != null)
            return _name;
        return Type.getClassName(Type.getClass(this));
    }

    function get_isUnique():Bool {
        return true;
    }

    /**
        Configures the App.
        Override in subclasses to add systems, resources, etc.
    **/
    public function build(app:App):Void {}

    /**
        Returns whether this plugin is ready to run.
        Override to implement lazy initialization.
    **/
    public function ready(app:App):Bool {
        return true;
    }

    /**
        Called after all plugins are ready, before the first update.
        Override to perform post-build setup.
    **/
    public function finish(app:App):Void {}

    /**
        Called when the App is cleaned up.
        Override to perform cleanup.
    **/
    public function cleanup(app:App):Void {}
}
