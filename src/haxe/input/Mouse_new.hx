package haxe.input;

import haxe.math.Vec2;

/**
    A button on a mouse device.
*/
enum MouseButton {
    /// The left mouse button.
    Left;
    /// The right mouse button.
    Right;
    /// The middle mouse button (scroll wheel button).
    Middle;
    /// The fourth mouse button (usually "Back").
    Extra1;
    /// The fifth mouse button (usually "Forward").
    Extra2;
}

/**
    A mouse button input event.
*/
class MouseButtonInput {
    public var button:MouseButton;
    public var state:ButtonState;
    public var window:Int;

    public function new(button:MouseButton, state:ButtonState, window:Int = 0) {
        this.button = button;
        this.state = state;
        this.window = window;
    }
}

/**
    Mouse wheel event for scroll input.
*/
class MouseWheel {
    public var x:Float;
    public var y:Float;
    public var unit:MouseScrollUnit;

    public function new(x:Float = 0, y:Float = 0, unit:MouseScrollUnit = Line) {
        this.x = x;
        this.y = y;
        this.unit = unit;
    }
}

/**
    Unit for mouse scroll values.
*/
enum MouseScrollUnit {
    /// Scroll amount measured in lines (typical mouse wheel).
    Line;
    /// Scroll amount measured in pixels (high precision scroll).
    Pixel;
}

/**
    Mouse motion event for cursor movement.
*/
class MouseMotion {
    public var delta:Vec2;

    public function new(delta:Vec2) {
        this.delta = delta;
    }
}

/**
    Accumulated mouse motion since last frame.
*/
class AccumulatedMouseMotion {
    public var delta:Vec2;

    public function new() {
        delta = Vec2.ZERO;
    }
}

/**
    Accumulated mouse scroll since last frame.
*/
class AccumulatedMouseScroll {
    public var unit:MouseScrollUnit;
    public var delta:Vec2;

    public function new() {
        unit = MouseScrollUnit.Line;
        delta = Vec2.ZERO;
    }
}

/**
    Mouse position information.
*/
class MousePosition {
    public var x:Float;
    public var y:Float;

    public function new(x:Float = 0, y:Float = 0) {
        this.x = x;
        this.y = y;
    }

    public inline function toVec2():Vec2 {
        return new Vec2(x, y);
    }
}

/**
    Mouse input state manager.

    Manages mouse button, motion, and scroll input.
*/
class Mouse extends Input<MouseButton> {
    /**
        Current mouse position.
    */
    public var position:MousePosition;

    /**
        Mouse position change since last frame.
    */
    public var positionDelta:Vec2;

    /**
        Mouse scroll delta since last frame.
    */
    public var scrollDelta:Vec2;

    /**
        Scroll unit (Line or Pixel).
    */
    public var scrollUnit:MouseScrollUnit;

    /**
        Accumulated mouse motion resource.
    */
    public var accumulatedMotion:AccumulatedMouseMotion;

    /**
        Accumulated mouse scroll resource.
    */
    public var accumulatedScroll:AccumulatedMouseScroll;

    private var _lastPosition:Vec2;

    public function new() {
        super();
        position = new MousePosition();
        positionDelta = Vec2.ZERO;
        scrollDelta = Vec2.ZERO;
        scrollUnit = MouseScrollUnit.Line;
        accumulatedMotion = new AccumulatedMouseMotion();
        accumulatedScroll = new AccumulatedMouseScroll();
        _lastPosition = Vec2.ZERO;
    }

    /**
        Updates the mouse position.
    */
    public function updatePosition(x:Float, y:Float):Void {
        position.x = x;
        position.y = y;

        var newPos = new Vec2(x, y);
        positionDelta = newPos - _lastPosition;
        accumulatedMotion.delta = positionDelta;
        _lastPosition = newPos;
    }

    /**
        Updates the mouse scroll.
    */
    public function updateScroll(x:Float, y:Float, unit:MouseScrollUnit = Line):Void {
        scrollDelta.x += x;
        scrollDelta.y += y;
        scrollUnit = unit;
        accumulatedScroll.delta = scrollDelta;
        accumulatedScroll.unit = unit;
    }

    /**
        Clears per-frame state (call at end of frame).
    */
    public override function clear():Void {
        super.clear();
        positionDelta = Vec2.ZERO;
        scrollDelta = Vec2.ZERO;
        accumulatedMotion.delta = Vec2.ZERO;
        accumulatedScroll.delta = Vec2.ZERO;
    }

    /**
        Gets the current mouse position as Vec2.
    */
    public inline function getPositionVec2():Vec2 {
        return new Vec2(position.x, position.y);
    }

    #if js
    private function handleMouseDown(event:js.html.MouseEvent):Void {
        event.preventDefault();
        var button = domToMouseButton(event.button);
        press(button);
        updatePosition(event.clientX, event.clientY);
    }

    private function handleMouseUp(event:js.html.MouseEvent):Void {
        var button = domToMouseButton(event.button);
        release(button);
        updatePosition(event.clientX, event.clientY);
    }

    private function handleMouseMove(event:js.html.MouseEvent):Void {
        updatePosition(event.clientX, event.clientY);
    }

    private function handleWheel(event:js.html.WheelEvent):Void {
        event.preventDefault();
        var unit = event.deltaMode == 1.0 ? MouseScrollUnit.Line : MouseScrollUnit.Pixel;
        updateScroll(event.deltaX, event.deltaY, unit);
    }

    private function handleContextMenu(event:js.html.Event):Void {
        event.preventDefault();
    }

    private function domToMouseButton(code:Int):MouseButton {
        return switch (code) {
            case 0: Left;
            case 1: Middle;
            case 2: Right;
            case 3: Extra1;
            case 4: Extra2;
            default: Left;
        };
    }

    /**
        Register mouse event listeners on an element.
    */
    public function registerListeners(element:js.html.Element):Void {
        element.addEventListener("mousedown", handleMouseDown);
        element.addEventListener("mouseup", handleMouseUp);
        element.addEventListener("mousemove", handleMouseMove);
        element.addEventListener("wheel", handleWheel);
        element.addEventListener("contextmenu", handleContextMenu);
    }

    /**
        Unregister mouse event listeners.
    */
    public function unregisterListeners(element:js.html.Element):Void {
        element.removeEventListener("mousedown", handleMouseDown);
        element.removeEventListener("mouseup", handleMouseUp);
        element.removeEventListener("mousemove", handleMouseMove);
        element.removeEventListener("wheel", handleWheel);
        element.removeEventListener("contextmenu", handleContextMenu);
    }
    #end
}
