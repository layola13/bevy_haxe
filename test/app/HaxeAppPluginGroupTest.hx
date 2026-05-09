package app;

import haxe.app.App;
import haxe.app.AppError;
import haxe.app.AppError.AppErrorKind;
import haxe.app.LifecyclePlugin;
import haxe.app.Plugins;
import haxe.app.PluginsDsl;
import haxe.app.PluginGroup.NoopPluginGroup;
import haxe.app.PluginGroup.PluginGroupBuilder;

class HaxeAppPluginGroupTest {
    static function main():Void {
        testDuplicatePluginTypedError();
        testMissingTargetTypedError();
        testGroupAddFailedTypedError();
        testPluginWithoutRuntimeClassTypedError();
        testPluginClassNameUnavailableTypedError();
        testAddPluginsComposition();
        testAddPluginsDslVarargs();
        trace("HaxeAppPluginGroupTest ok");
    }

    static function testDuplicatePluginTypedError():Void {
        var app = new App();
        app.addPlugin(new AlphaPlugin());

        var typedError:AppError = null;
        try {
            app.addPlugin(new AlphaPlugin());
        } catch (error:AppError) {
            typedError = error;
        }

        assert(typedError != null, "duplicate plugin should throw AppError");
        switch typedError.kind {
            case PluginAlreadyAdded(name):
                assert(name != null && name != "", "duplicate plugin error should preserve plugin name");
            default:
                throw "unexpected error kind for duplicate plugin";
        }
    }

    static function testMissingTargetTypedError():Void {
        var typedError:AppError = null;
        try {
            PluginGroupBuilder.start(NoopPluginGroup)
                .add(new AlphaPlugin())
                .addBefore(BetaPlugin, new GammaPlugin());
        } catch (error:AppError) {
            typedError = error;
        }

        assert(typedError != null, "missing target should throw AppError");
        switch typedError.kind {
            case PluginGroupPluginMissing(groupName, pluginTypeKey):
                assert(groupName != null && groupName != "", "missing-target error should preserve group name");
                assert(pluginTypeKey != null && pluginTypeKey != "", "missing-target error should preserve type key");
            default:
                throw "unexpected error kind for missing target";
        }
    }

    static function testGroupAddFailedTypedError():Void {
        var app = new App();
        app.addPlugin(new AlphaPlugin());

        var typedError:AppError = null;
        try {
            app.addPluginGroup(
                PluginGroupBuilder.start(NoopPluginGroup)
                    .add(new AlphaPlugin())
            );
        } catch (error:AppError) {
            typedError = error;
        }

        assert(typedError != null, "group add failure should throw AppError");
        switch typedError.kind {
            case PluginGroupAddFailed(groupName, pluginName, cause):
                assert(groupName != null && groupName != "", "add-failed error should preserve group name");
                assert(pluginName != null && pluginName != "", "add-failed error should preserve plugin name");
                assert(cause != null, "add-failed error should preserve cause");
            default:
                throw "unexpected error kind for group add failure";
        }
    }

    static function testPluginWithoutRuntimeClassTypedError():Void {
        var typedError:AppError = null;
        try {
            PluginGroupBuilder.start(NoopPluginGroup).add(cast {});
        } catch (error:AppError) {
            typedError = error;
        }

        assert(typedError != null, "plugin without runtime class should throw AppError");
        switch typedError.kind {
            case PluginWithoutRuntimeClass(pluginValue):
                assert(pluginValue != null && pluginValue != "", "plugin-without-runtime-class should preserve plugin value");
            default:
                throw "unexpected error kind for plugin without runtime class";
        }
    }

    static function testPluginClassNameUnavailableTypedError():Void {
        var typedError:AppError = null;
        try {
            PluginGroupBuilder.start(NoopPluginGroup).disable(cast null);
        } catch (error:AppError) {
            typedError = error;
        }

        assert(typedError != null, "plugin class name unavailable should throw AppError");
        switch typedError.kind {
            case PluginClassNameUnavailable:
            default:
                throw "unexpected error kind for plugin class name unavailable";
        }
    }

    static function testAddPluginsComposition():Void {
        var app = new App();
        var trace:Array<String> = [];

        app.addPlugins(new AlphaTracePlugin(trace));

        var nested:Array<Plugins> = [];
        nested.push(new BetaTracePlugin(trace));
        nested.push([
            PluginGroupBuilder.start(NoopPluginGroup).add(new GammaTracePlugin(trace))
        ]);
        app.addPlugins(nested);

        assertEq("alpha,beta,gamma", trace.join(","), "addPlugins should compose plugin values and nested arrays");
    }

    static function testAddPluginsDslVarargs():Void {
        var app = new App();
        var trace:Array<String> = [];
        app.addPlugins(PluginsDsl.of(
            new AlphaTracePlugin(trace),
            [
                PluginGroupBuilder.start(NoopPluginGroup).add(new BetaTracePlugin(trace))
            ],
            new GammaTracePlugin(trace)
        ));
        assertEq("alpha,beta,gamma", trace.join(","), "PluginsDsl.of should support varargs and nested arrays");
    }

    static function assert(condition:Bool, label:String):Void {
        if (!condition) {
            throw label;
        }
    }

    static function assertEq(expected:Dynamic, actual:Dynamic, label:String):Void {
        if (expected != actual) {
            throw '$label expected $expected, got $actual';
        }
    }
}

private class AlphaPlugin extends LifecyclePlugin {
    public function new() {
        super();
    }
}

private class BetaPlugin extends LifecyclePlugin {
    public function new() {
        super();
    }
}

private class GammaPlugin extends LifecyclePlugin {
    public function new() {
        super();
    }
}

private class AlphaTracePlugin extends LifecyclePlugin {
    private var trace:Array<String>;

    public function new(trace:Array<String>) {
        super();
        this.trace = trace;
    }

    public override function build(app:App):Void {
        trace.push("alpha");
    }
}

private class BetaTracePlugin extends LifecyclePlugin {
    private var trace:Array<String>;

    public function new(trace:Array<String>) {
        super();
        this.trace = trace;
    }

    public override function build(app:App):Void {
        trace.push("beta");
    }
}

private class GammaTracePlugin extends LifecyclePlugin {
    private var trace:Array<String>;

    public function new(trace:Array<String>) {
        super();
        this.trace = trace;
    }

    public override function build(app:App):Void {
        trace.push("gamma");
    }
}
