package haxe.input;

import haxe.math.Vec2;

/**
 * A button on a mouse device.
 */
enum MouseButton {
    Left;
    Right;
    Middle;
    Extra1;
    Extra2;
}

/**
 * A mouse button input event.
 */
class MouseButtonInput {
    public var button:MouseButton;
    public var state:ButtonState;
    
    public function new(button:MouseButton, state:ButtonState) {
        this.button = button;
        this.state = state;
    }
}

/**
 * Mouse wheel event.
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

enum MouseScrollUnit {
    Line;
    Pixel;
}

/**
 * Mouse motion event.
 */
class MouseMotion {
    public var delta:Vec2;
    
    public function new(delta:Vec2) {
        this.delta = delta;
    }
}

/**
 * Mouse position information.
 */
class MousePosition {
    public var x:Float;
    public var y:Float;
    
    public function new(x:Float = 0, y:Float = 0) {
        this.x = x;
        this.y = y;
    }
    
    public function toVec2():Vec2 {
        return new Vec2(x, y);
    }
}

/**
 * Mouse input state manager.
 */
class Mouse extends Input<MouseButton> {
    public var position:MousePosition;
    public var positionDelta:Vec2;
    public var scrollDelta:Vec2;
    public var scrollUnit:MouseScrollUnit;
    
    private var lastPosition:Vec2;
    
    public function new() {
        super();
        position = new MousePosition();
        positionDelta = Vec2.ZERO;
        scrollDelta = Vec2.ZERO;
        scrollUnit = Line;
        lastPosition = Vec2.ZERO;
    }
    
    /**
     * Updates mouse position.
     */
    public function updatePosition(x:Float, y:Float):Void {
        position.x = x;
        position.y = y;
        positionDelta = new Vec2(x, y) - lastPosition;
        lastPosition = new Vec2(x, y);
    }
    
    /**
     * Updates scroll wheel.
     */
    public function updateScroll(x:Float, y:Float, unit:MouseScrollUnit = Line):Void {
        scrollDelta.x += x;
        scrollDelta.y += y;
        scrollUnit = unit;
    }
    
    /**
     * Resets accumulated values.
     */
    public function resetFrame():Void {
        positionDelta = Vec2.ZERO;
        scrollDelta = Vec2.ZERO;
    }
    
    /**
     * Gets the current mouse position as Vec2.
     */
    public function getPosition():Vec2 {
        return position.toVec2();
    }
}

// Web platform mouse event handling
#if js
class MouseInputHandler {
    private var mouse:Mouse;
    private var onButtonPress:MouseButton->Void;
    private var onButtonRelease:MouseButton->Void;
    
    public function new(mouse:Mouse, 
                       onButtonPress:MouseButton->Void,
                       onButtonRelease:MouseButton->Void) {
        this.mouse = mouse;
        this.onButtonPress = onButtonPress;
        this.onButtonRelease = onButtonRelease;
    }
    
    public function handleMouseDown(event:js.html.MouseEvent):Void {
        var button = domToMouseButton(event.button);
        mouse.press(button);
        if (onButtonPress != null) {
            onButtonPress(button);
        }
    }
    
    public function handleMouseUp(event:js.html.MouseEvent):Void {
        var button = domToMouseButton(event.button);
        mouse.release(button);
        if (onButtonRelease != null) {
            onButtonRelease(button);
        }
    }
    
    public function handleMouseMove(event:js.html.MouseEvent):Void {
        mouse.updatePosition(cast event.clientX, cast event.clientY);
    }
    
    public function handleWheel(event:js.html.WheelEvent):Void {
        var unit:MouseScrollUnit = event.deltaMode == 1.0 ? Line : Pixel;
        mouse.updateScroll(event.deltaX, event.deltaY, unit);
    }
    
    public function handleContextMenu(event:js.html.Event):Void {
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
    
    public function registerListeners(element:js.html.Element):Void {
        element.addEventListener("mousedown", handleMouseDown);
        element.addEventListener("mouseup", handleMouseUp);
        element.addEventListener("mousemove", handleMouseMove);
        element.addEventListener("wheel", handleWheel);
        element.addEventListener("contextmenu", handleContextMenu);
    }
    
    public function unregisterListeners(element:js.html.Element):Void {
        element.removeEventListener("mousedown", handleMouseDown);
        element.removeEventListener("mouseup", handleMouseUp);
        element.removeEventListener("mousemove", handleMouseMove);
        element.removeEventListener("wheel", handleWheel);
        element.removeEventListener("contextmenu", handleContextMenu);
    }
}
#end
