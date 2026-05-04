package haxe.app;

import haxe.ds.Map;

/**
    Plugin interface for modular app configuration.

    Plugins configure an App. When an App registers a plugin,
    the plugin's `build` function is run. By default, a plugin
    can only be added once to an App.

    ## Lifecycle of a plugin

    When adding a plugin to an App:
    - the app calls `build` immediately and registers the plugin
    - once the app starts, it will wait for all registered `ready` to return `true`
    - it will then call all registered `finish`
    - and call all registered `cleanup`
**/
interface Plugin {
    /**
        The unique name of this plugin.
        Defaults to the class name.
    **/
    var name(get, never):String;

    /**
        Returns whether this plugin can be added multiple times.
        Override to return `false` if the plugin may need to be added twice or more.
    **/
    var isUnique(get, never):Bool;

    /**
        Configures the App by adding systems, resources, etc.
    **/
    function build(app:App):Void;

    /**
        Called when the App is ready to run.
        Returns `true` if the plugin is ready.
    **/
    function ready(app:App):Bool;

    /**
        Called after all plugins are ready, before the first update.
    **/
    function finish(app:App):Void;

    /**
        Called when the App is cleaned up or dropped.
    **/
    function cleanup(app:App):Void;
}
