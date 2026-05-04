package haxe.window;

import haxe.app.App;
import haxe.app.Plugin;

/**
    Plugin for window management.

    This plugin sets up the windowing system and manages the primary window.
    It is part of the DefaultPlugins and should be added to the App before
    rendering systems run.

    ## Usage

    ```haxe
    app.addPlugin(WindowPlugin.withDefaults());
    ```

    Or with custom primary window settings:

    ```haxe
    var window = new Window();
    window.title = "My Game";
    window.width = 1920;
    window.height = 1080;
    app.addPlugin(new WindowPlugin(window));
    ```
*/
class WindowPlugin implements Plugin {
    /**
        The primary window configuration.
        If null, no primary window will be created.
    */
    public var primaryWindow:Null<Window>;

    /**
        Exit condition for the application.
    */
    public var exitCondition:ExitCondition;

    /**
        Whether to close the application when all windows are requested to close.
    */
    public var closeWhenRequested:Bool;

    /**
        Creates a WindowPlugin with default settings.
    */
    public static function withDefaults():WindowPlugin {
        return new WindowPlugin(new Window());
    }

    /**
        Creates a WindowPlugin without a primary window.
    */
    public static function withoutPrimary():WindowPlugin {
        return new WindowPlugin(null);
    }

    public function new(?primaryWindow:Window, ?exitCondition:ExitCondition, ?closeWhenRequested:Bool) {
        this.primaryWindow = primaryWindow;
        this.exitCondition = exitCondition != null ? exitCondition : ExitCondition.OnAllClosed;
        this.closeWhenRequested = closeWhenRequested != null ? closeWhenRequested : true;
    }

    /**
        Plugin name. Defaults to "WindowPlugin".
    */
    public var name(get, never):String;
    private inline function get_name():String return "WindowPlugin";

    /**
        Whether this plugin can only be added once. Default is true.
    */
    public var isUnique(get, never):Bool;
    private inline function get_isUnique():Bool return true;

    /**
        Called when the plugin is built into the app.
        Sets up the window resources and systems.
    */
    public function build(app:App):Void {
        // Register window as a resource
        if (primaryWindow != null) {
            app.world.setResource(primaryWindow);
            app.world.setResource(new PrimaryWindow());
        }

        // Register window-related systems
        app.addSystem(WindowSystem.update);
        app.addSystem(WindowSystem.closeWhenRequested);
    }

    /**
        Called when the app is ready. Returns true.
    */
    public function ready(app:App):Bool {
        return true;
    }

    /**
        Called after all plugins are ready.
    */
    public function finish(app:App):Void {
        // Initialize the window
        #if js
        WindowSystem.initWindow(app);
        #end
    }

    /**
        Called when the app is cleaned up.
    */
    public function cleanup(app:App):Void {
        // Cleanup window resources
        #if js
        WindowSystem.cleanup();
        #end
    }
}

/**
    Defines when the application should exit.
*/
enum ExitCondition {
    /**
        Close application when the primary window is closed.
    */
    OnPrimaryClosed;

    /**
        Close application when all windows are closed.
    */
    OnAllClosed;

    /**
        Keep application running even after all windows are closed.
        Use App.exit() to programmatically exit.
    */
    DontExit;
}

/**
    Internal window management systems.
*/
class WindowSystem {
    private static var canvasElement:js.html.CanvasElement = null;
    private static var resizeObserver:js.html.ResizeObserver = null;

    /**
        Initialize the window and create the canvas element.
    */
    public static function initWindow(app:App):Void {
        #if js
        var window:Window = app.world.getResource(Window);

        // Create or find the canvas element
        if (window.canvasId != null && window.canvasId.length > 0) {
            canvasElement = cast js.Browser.document.getElementById(window.canvasId);
        }

        if (canvasElement == null) {
            canvasElement = js.Browser.document.createCanvasElement();
            canvasElement.id = window.canvasId;
            js.Browser.document.body.appendChild(canvasElement);
        }

        // Apply window settings to canvas
        applyWindowSettings(window);

        // Set up resize observer
        setupResizeObserver(app);
        #end
    }

    #if js
    private static function applyWindowSettings(window:Window):Void {
        if (canvasElement == null) return;

        // Set canvas size
        canvasElement.width = Std.int(window.width);
        canvasElement.height = Std.int(window.height);

        // Set canvas style
        var style = canvasElement.style;
        style.position = "absolute";
        style.left = '${window.x}px';
        style.top = '${window.y}px';
        style.width = '${window.width}px';
        style.height = '${window.height}px';

        // Handle visibility
        style.display = window.visible ? "block" : "none";

        // Handle cursor
        applyCursorSettings(window);
    }

    private static function applyCursorSettings(window:Window):Void {
        if (canvasElement == null) return;

        if (!window.cursorVisible) {
            canvasElement.style.cursor = "none";
        } else {
            canvasElement.style.cursor = cursorToString(window.cursor);
        }
    }

    private static function cursorToString(cursor:CursorIcon):String {
        return switch (cursor) {
            case Default: "default";
            case Crosshair: "crosshair";
            case Pointer: "pointer";
            case Move: "move";
            case Text: "text";
            case Wait: "wait";
            case Help: "help";
            case Progress: "progress";
            case NotAllowed: "not-allowed";
            case ContextMenu: "context-menu";
            case Cell: "cell";
            case VerticalText: "vertical-text";
            case Alias: "alias";
            case Copy: "copy";
            case NoDrop: "no-drop";
            case Grab: "grab";
            case Grabbing: "grabbing";
            case AllScroll: "all-scroll";
            case ZoomIn: "zoom-in";
            case ZoomOut: "zoom-out";
            case RowResize: "row-resize";
            case ColResize: "col-resize";
            case NorthResize: "n-resize";
            case SouthResize: "s-resize";
            case EastResize: "e-resize";
            case WestResize: "w-resize";
            case NorthEastResize: "ne-resize";
            case NorthWestResize: "nw-resize";
            case SouthEastResize: "se-resize";
            case SouthWestResize: "sw-resize";
        };
    }

    private static function setupResizeObserver(app:App):Void {
        resizeObserver = new js.html.ResizeObserver(function(entries:Array<js.html.ResizeObserverEntry>) {
            for (entry in entries) {
                var window:Window = app.world.getResource(Window);
                if (window != null && window.resizable) {
                    var contentRect = entry.contentRect;
                    window.width = contentRect.width;
                    window.height = contentRect.height;
                }
            }
        });

        if (canvasElement != null) {
            resizeObserver.observe(canvasElement);
        }
    }
    #end

    /**
        Update window state. Called each frame.
    */
    public static function update(app:App):Void {
        // Update window state each frame
        // This could include checking for external changes to window size
        #if js
        if (canvasElement != null) {
            var window:Window = app.world.getResource(Window);
            if (window != null) {
                // Sync any external changes
            }
        }
        #end
    }

    /**
        Check if windows should be closed.
    */
    public static function closeWhenRequested(app:App):Void {
        var window:Window = app.world.getResource(Window);
        if (window != null && window.requestedClose) {
            #if js
            // Dispatch close event
            var event = new js.html.CustomEvent("window-close", bubbles: true);
            if (canvasElement != null) {
                canvasElement.dispatchEvent(event);
            }
            #end
        }
    }

    /**
        Cleanup window resources.
    */
    public static function cleanup():Void {
        #if js
        if (resizeObserver != null) {
            resizeObserver.disconnect();
            resizeObserver = null;
        }
        canvasElement = null;
        #end
    }

    /**
        Get the canvas element for rendering.
    */
    public static function getCanvas():js.html.CanvasElement {
        return canvasElement;
    }

    /**
        Set the window title.
    */
    public static function setTitle(app:App, title:String):Void {
        var window:Window = app.world.getResource(Window);
        if (window != null) {
            window.title = title;
            #if js
            if (js.Browser.document != null) {
                js.Browser.document.title = title;
            }
            #end
        }
    }

    /**
        Resize the window.
    */
    public static function resize(app:App, width:Float, height:Float):Void {
        var window:Window = app.world.getResource(Window);
        if (window != null) {
            var clamped = window.resizeConstraints.clamp(width, height);
            window.resize(clamped.width, clamped.height);

            #if js
            if (canvasElement != null) {
                canvasElement.width = Std.int(clamped.width);
                canvasElement.height = Std.int(clamped.height);
                canvasElement.style.width = '${clamped.width}px';
                canvasElement.style.height = '${clamped.height}px';
            }
            #end
        }
    }

    /**
        Set the window position.
    */
    public static function setPosition(app:App, x:Float, y:Float):Void {
        var window:Window = app.world.getResource(Window);
        if (window != null) {
            window.moveTo(x, y);

            #if js
            if (canvasElement != null) {
                canvasElement.style.left = '${x}px';
                canvasElement.style.top = '${y}px';
            }
            #end
        }
    }

    /**
        Set the cursor icon.
    */
    public static function setCursor(app:App, cursor:CursorIcon):Void {
        var window:Window = app.world.getResource(Window);
        if (window != null) {
            window.cursor = cursor;
            #if js
            applyCursorSettings(window);
            #end
        }
    }

    /**
        Set cursor visibility.
    */
    public static function setCursorVisible(app:App, visible:Bool):Void {
        var window:Window = app.world.getResource(Window);
        if (window != null) {
            window.cursorVisible = visible;
            #if js
            if (canvasElement != null) {
                canvasElement.style.cursor = visible ? "default" : "none";
            }
            #end
        }
    }

    /**
        Set cursor grab mode.
    */
    public static function setCursorGrabbed(app:App, grabbed:Bool):Void {
        var window:Window = app.world.getResource(Window);
        if (window != null) {
            window.cursorGrabbed = grabbed;
            #if js
            // Request pointer lock for cursor grabbing
            if (grabbed && canvasElement != null) {
                canvasElement.requestPointerLock();
            } else {
                js.Browser.document.exitPointerLock();
            }
            #end
        }
    }
}
