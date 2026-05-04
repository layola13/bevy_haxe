package haxe.window;

import haxe.ecs.Component;

/**
    Represents a window in the application.

    This component stores all configuration and state for a single window,
    including dimensions, position, title, and various rendering options.
*/
class Window implements Component {
    /**
        The title of the window displayed in the title bar.
    */
    public var title:String;

    /**
        The logical width of the window in pixels.
    */
    public var width:Float;

    /**
        The logical height of the window in pixels.
    */
    public var height:Float;

    /**
        The x position of the window in pixels.
    */
    public var x:Float;

    /**
        The y position of the window in pixels.
    */
    public var y:Float;

    /**
        The resolution scale factor for the window.
    */
    public var scaleFactor:Float;

    /**
        The vertical synchronization (vsync) mode.
    */
    public var vsync:VsyncMode;

    /**
        Whether the window is resizable by the user.
    */
    public var resizable:Bool;

    /**
        Whether the window has a border/decorations.
    */
    public var decorations:Bool;

    /**
        Whether the window should be maximized on creation.
    */
    public var maximized:Bool;

    /**
        Whether the window should be visible.
    */
    public var visible:Bool;

    /**
        Whether the window should have focus on creation.
    */
    public var focused:Bool;

    /**
        The window resize constraints.
    */
    public var resizeConstraints:WindowResizeConstraints;

    /**
        The current cursor icon.
    */
    public var cursor:CursorIcon;

    /**
        Whether the cursor is visible.
    */
    public var cursorVisible:Bool;

    /**
        Whether the cursor is confined to the window.
    */
    public var cursorGrabbed:Bool;

    /**
        The window mode (Windowed, Minimized, Maximized, Fullscreen, etc.)
    */
    public var mode:WindowMode;

    /**
        The canvas element ID for web platforms.
    */
    public var canvasId:String;

    /**
        Internal flag to check if window has been requested to close.
    */
    public var requestedClose:Bool;

    /**
        Creates a new Window with default settings.
    */
    public function new() {
        title = "App";
        width = 1280;
        height = 720;
        x = 100;
        y = 100;
        scaleFactor = 1.0;
        vsync = VsyncMode.Fifo;
        resizable = true;
        decorations = true;
        maximized = false;
        visible = true;
        focused = true;
        resizeConstraints = new WindowResizeConstraints();
        cursor = CursorIcon.Default;
        cursorVisible = true;
        cursorGrabbed = false;
        mode = WindowMode.Windowed;
        canvasId = "bevy-canvas";
        requestedClose = false;
    }

    /**
        Returns the aspect ratio of the window (width / height).
    */
    public function aspectRatio():Float {
        return height > 0 ? width / height : 1.0;
    }

    /**
        Returns the center position of the window.
    */
    public function center():{x:Float, y:Float} {
        return {
            x: x + width / 2,
            y: y + height / 2
        };
    }

    /**
        Resizes the window to the specified dimensions.
    */
    public function resize(width:Float, height:Float):Void {
        this.width = width;
        this.height = height;
    }

    /**
        Moves the window to the specified position.
    */
    public function moveTo(x:Float, y:Float):Void {
        this.x = x;
        this.y = y;
    }

    /**
        Centers the window within the given bounds (typically screen dimensions).
    */
    public function centerInBounds(screenWidth:Float, screenHeight:Float):Void {
        x = (screenWidth - width) / 2;
        y = (screenHeight - height) / 2;
    }

    /**
        Requests the window to close.
    */
    public function requestClose():Void {
        requestedClose = true;
    }

    /**
        Resets the window to its default state.
    */
    public function reset():Void {
        title = "App";
        width = 1280;
        height = 720;
        x = 100;
        y = 100;
        scaleFactor = 1.0;
        vsync = VsyncMode.Fifo;
        resizable = true;
        decorations = true;
        maximized = false;
        visible = true;
        focused = true;
        resizeConstraints = new WindowResizeConstraints();
        cursor = CursorIcon.Default;
        cursorVisible = true;
        cursorGrabbed = false;
        mode = WindowMode.Windowed;
        requestedClose = false;
    }

    public function toString():String {
        return 'Window($title, ${width}x${height} at $x,$y)';
    }
}

/**
    Vertical synchronization mode for the window.
*/
enum VsyncMode {
    /**
        No vertical synchronization. Frames are presented immediately.
        May cause screen tearing.
    */
    None;

    /**
        Vertical synchronization enabled. Presentation happens on
        vertical blanking intervals. Prevents tearing.
    */
    Fifo;

    /**
        Vertical synchronization with late swap. Similar to Fifo but
        may reduce latency on some platforms.
    */
    FifoRelaxed;

    /**
        Immediate mode. Frames are presented immediately without waiting.
        Also known as "Vsync Off". May cause tearing.
    */
    Immediate;

    /**
        Mailbox mode. Keeps only the latest frame. If no new frame,
        repeats the previous one. No tearing, good for unthrottled rendering.
    */
    Mailbox;
}

/**
    Window mode (fullscreen state).
*/
enum WindowMode {
    Windowed;
    Minimized;
    Maximized;
    Fullscreen;
    FullscreenWithBorder;
}

/**
    Cursor icon types.
*/
enum CursorIcon {
    Default;
    Crosshair;
    Pointer;
    Move;
    Text;
    Wait;
    Help;
    Progress;
    NotAllowed;
    ContextMenu;
    Cell;
    VerticalText;
    Alias;
    Copy;
    NoDrop;
    Grab;
    Grabbing;
    AllScroll;
    ZoomIn;
    ZoomOut;
    RowResize;
    ColResize;
    NorthResize;
    SouthResize;
    EastResize;
    WestResize;
    NorthEastResize;
    NorthWestResize;
    SouthEastResize;
    SouthWestResize;
}

/**
    Window resize constraints defining min/max dimensions.
*/
class WindowResizeConstraints {
    public var minWidth:Float;
    public var maxWidth:Float;
    public var minHeight:Float;
    public var maxHeight:Float;

    public function new(
        minWidth:Float = 0,
        minHeight:Float = 0,
        ?maxWidth:Float,
        ?maxHeight:Float
    ) {
        this.minWidth = minWidth;
        this.minHeight = minHeight;
        this.maxWidth = maxWidth != null ? maxWidth : 999999;
        this.maxHeight = maxHeight != null ? maxHeight : 999999;
    }

    /**
        Clamps the given dimensions to fit within constraints.
    */
    public function clamp(width:Float, height:Float):{width:Float, height:Float} {
        return {
            width: Math.max(minWidth, Math.min(maxWidth, width)),
            height: Math.max(minHeight, Math.min(maxHeight, height))
        };
    }

    public function toString():String {
        return 'ResizeConstraints(${minWidth}x${minHeight} - ${maxWidth}x${maxHeight})';
    }
}

/**
    Marker component indicating the primary window.
*/
class PrimaryWindow implements Component {
    public inline function new() {}
}

/**
    Window position types.
*/
enum WindowPosition {
    /**
        Let the system decide the window position.
    */
    Automatic;

    /**
        Position the window at the center of the screen.
    */
    Center;

    /**
        Position the window at specific coordinates.
    */
    At(x:Float, y:Float);
}

/**
    Monitor information for displaying windows.
*/
class MonitorInfo {
    public var name:String;
    public var x:Float;
    public var y:Float;
    public var width:Float;
    public var height:Float;
    public var scaleFactor:Float;
    public var isPrimary:Bool;

    public function new() {
        name = "";
        x = 0;
        y = 0;
        width = 1920;
        height = 1080;
        scaleFactor = 1.0;
        isPrimary = true;
    }
}

/**
    Video mode information for a monitor.
*/
class VideoMode {
    public var width:Int;
    public var height:Int;
    public var refreshRate:Float;
    public var monitor:MonitorInfo;

    public function new(width:Int = 1920, height:Int = 1080, refreshRate:Float = 60.0) {
        this.width = width;
        this.height = height;
        this.refreshRate = refreshRate;
        this.monitor = new MonitorInfo();
    }

    public function toString():String {
        return 'VideoMode(${width}x${height}@${refreshRate}Hz)';
    }
}
