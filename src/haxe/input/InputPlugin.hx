package haxe.input;

/**
 * Input plugin for Bevy.
 * 
 * Registers keyboard, mouse, and gamepad input systems and resources.
 */
class InputPlugin {
    public var keyboard:Keyboard;
    public var mouse:Mouse;
    public var gamepad:GamepadInput;
    
    #if js
    private var keyboardHandler:KeyboardInputHandler;
    private var mouseHandler:MouseInputHandler;
    #end
    
    public function new() {
        keyboard = new Keyboard();
        mouse = new Mouse();
        gamepad = new GamepadInput(0.15);
    }
    
    /**
     * Builds the input plugin and registers systems.
     */
    public function build(app:Dynamic):Void {
        // Add input resources to app
        app.world.addResource(this);
        
        #if js
        // Initialize web platform handlers
        initWebInput();
        #end
    }
    
    #if js
    private function initWebInput():Void {
        keyboardHandler = new KeyboardInputHandler(keyboard, null, null);
        mouseHandler = new MouseInputHandler(mouse, null, null);
        
        // Register to window/document
        var doc = js.Browser.document;
        keyboardHandler.registerListeners(doc);
        mouseHandler.registerListeners(doc);
    }
    #end
    
    /**
     * Registers input handlers to a specific element.
     */
    public function registerToElement(element:Dynamic):Void {
        #if js
        if (Std.is(element, js.html.Element)) {
            keyboardHandler.unregisterListeners(js.Browser.document);
            mouseHandler.unregisterListeners(js.Browser.document);
            
            keyboardHandler.registerListeners(cast element);
            mouseHandler.registerListeners(cast element);
        }
        #end
    }
    
    /**
     * Updates input state (call each frame).
     */
    public function update():Void {
        #if js
        // Update gamepads from browser
        gamepad.updateFromBrowser();
        #end
        
        // Clear just pressed/released states
        keyboard.update();
        mouse.update();
    }
    
    /**
     * Resets frame-based input state.
     */
    public function resetFrame():Void {
        mouse.resetFrame();
    }
    
    /**
     * Clears all input state.
     */
    public function clear():Void {
        keyboard.clear();
        mouse.clear();
        gamepad.clear();
    }
    
    /**
     * Gets the keyboard input handler.
     */
    #if js
    public function getKeyboardHandler():KeyboardInputHandler {
        return keyboardHandler;
    }
    
    /**
     * Gets the mouse input handler.
     */
    public function getMouseHandler():MouseInputHandler {
        return mouseHandler;
    }
    #end
    
    /**
     * Sets keyboard event callbacks.
     */
    public function setKeyboardCallbacks(onPress:KeyCode->Void, onRelease:KeyCode->Void):Void {
        #if js
        keyboardHandler = new KeyboardInputHandler(keyboard, onPress, onRelease);
        keyboardHandler.registerListeners(js.Browser.document);
        #end
    }
    
    /**
     * Sets mouse event callbacks.
     */
    public function setMouseCallbacks(onPress:MouseButton->Void, onRelease:MouseButton->Void):Void {
        #if js
        mouseHandler = new MouseInputHandler(mouse, onPress, onRelease);
        mouseHandler.registerListeners(js.Browser.document);
        #end
    }
    
    /**
     * Checks if a key is currently pressed.
     */
    public function isKeyPressed(code:KeyCode):Bool {
        return keyboard.pressed(code);
    }
    
    /**
     * Checks if a key was just pressed this frame.
     */
    public function isKeyJustPressed(code:KeyCode):Bool {
        return keyboard.justPressed(code);
    }
    
    /**
     * Checks if a key was just released this frame.
     */
    public function isKeyJustReleased(code:KeyCode):Bool {
        return keyboard.justReleased(code);
    }
    
    /**
     * Checks if a mouse button is currently pressed.
     */
    public function isMouseButtonPressed(button:MouseButton):Bool {
        return mouse.pressed(button);
    }
    
    /**
     * Checks if a mouse button was just pressed this frame.
     */
    public function isMouseButtonJustPressed(button:MouseButton):Bool {
        return mouse.justPressed(button);
    }
    
    /**
     * Checks if a mouse button was just released this frame.
     */
    public function isMouseButtonJustReleased(button:MouseButton):Bool {
        return mouse.justReleased(button);
    }
    
    /**
     * Gets the current mouse position.
     */
    public function getMousePosition():{x:Float, y:Float} {
        return {x: mouse.position.x, y: mouse.position.y};
    }
    
    /**
     * Gets the mouse position delta since last frame.
     */
    public function getMousePositionDelta():{x:Float, y:Float} {
        return {x: mouse.positionDelta.x, y: mouse.positionDelta.y};
    }
    
    /**
     * Gets the mouse scroll delta.
     */
    public function getMouseScrollDelta():{x:Float, y:Float} {
        return {x: mouse.scrollDelta.x, y: mouse.scrollDelta.y};
    }
    
    /**
     * Checks if a gamepad button is pressed.
     */
    public function isGamepadButtonPressed(button:GamepadButton, gamepadIndex:Int = 0):Bool {
        var gamepad = gamepad.getGamepad(gamepadIndex);
        return gamepad != null && gamepad.buttonPressed(button);
    }
    
    /**
     * Checks if a gamepad button was just pressed this frame.
     */
    public function isGamepadButtonJustPressed(button:GamepadButton, gamepadIndex:Int = 0):Bool {
        return gamepad.justPressed(button);
    }
    
    /**
     * Gets a gamepad axis value.
     */
    public function getGamepadAxis(axis:GamepadAxis, gamepadIndex:Int = 0):Float {
        return gamepad.getAxis(gamepadIndex, axis);
    }
    
    /**
     * Gets all connected gamepads.
     */
    public function getConnectedGamepads():Array<Gamepad> {
        return gamepad.getGamepads();
    }
    
    /**
     * Checks if any gamepad is connected.
     */
    public function hasGamepad():Bool {
        return gamepad.getGamepads().length > 0;
    }
}

/**
 * Common input conditions for systems.
 */
class InputConditions {
    /**
     * Creates a condition that returns true when key is just pressed.
     */
    public static function keyJustPressed(code:KeyCode):Bool {
        return haxe.App.instance != null && 
               haxe.App.instance.input != null && 
               haxe.App.instance.input.isKeyJustPressed(code);
    }
    
    /**
     * Creates a condition that returns true when key is just released.
     */
    public static function keyJustReleased(code:KeyCode):Bool {
        return haxe.App.instance != null && 
               haxe.App.instance.input != null && 
               haxe.App.instance.input.isKeyJustReleased(code);
    }
    
    /**
     * Creates a condition that returns true when key is pressed.
     */
    public static function keyPressed(code:KeyCode):Bool {
        return haxe.App.instance != null && 
               haxe.App.instance.input != null && 
               haxe.App.instance.input.isKeyPressed(code);
    }
    
    /**
     * Creates a condition that returns true when mouse button is just pressed.
     */
    public static function mouseButtonJustPressed(button:MouseButton):Bool {
        return haxe.App.instance != null && 
               haxe.App.instance.input != null && 
               haxe.App.instance.input.isMouseButtonJustPressed(button);
    }
    
    /**
     * Creates a condition that returns true when mouse button is just released.
     */
    public static function mouseButtonJustReleased(button:MouseButton):Bool {
        return haxe.App.instance != null && 
               haxe.App.instance.input != null && 
               haxe.App.instance.input.isMouseButtonJustReleased(button);
    }
    
    /**
     * Creates a condition that returns true when mouse button is pressed.
     */
    public static function mouseButtonPressed(button:MouseButton):Bool {
        return haxe.App.instance != null && 
               haxe.App.instance.input != null && 
               haxe.App.instance.input.isMouseButtonPressed(button);
    }
}
