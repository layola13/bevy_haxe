package haxe.state;

import haxe.app.App;
import haxe.ecs.Schedule;
import haxe.ecs.SystemSet;
import haxe.ecs.World;

/**
 * The label of a Schedule that only runs whenever State<S> enters the provided state.
 * 
 * This schedule ignores identity transitions.
 */
@:generic
class OnEnter<T:States> implements SystemSetLabel {
    public var state(default, null):T;
    
    public function new(state:T) {
        this.state = state;
    }
    
    public function toString():String {
        return 'OnEnter(${state})';
    }

    public function getTypeId():Any {
        return Type.typeof(this);
    }
}

/**
 * The label of a Schedule that only runs whenever State<S> exits the provided state.
 * 
 * This schedule ignores identity transitions.
 */
@:generic
class OnExit<T:States> implements SystemSetLabel {
    public var state(default, null):T;
    
    public function new(state:T) {
        this.state = state;
    }
    
    public function toString():String {
        return 'OnExit(${state})';
    }

    public function getTypeId():Any {
        return Type.typeof(this);
    }
}

/**
 * The label of a Schedule that runs whenever State<S> exits AND enters
 * the provided exited and entered states.
 * 
 * Systems added to this schedule are always ran after OnExit, and before OnEnter.
 * This schedule will run on identity transitions.
 */
@:generic
class OnTransition<T:States> implements SystemSetLabel {
    public var exited:T;
    public var entered:T;
    
    public function new(exited:T, entered:T) {
        this.exited = exited;
        this.entered = entered;
    }
    
    public function toString():String {
        return 'OnTransition(${exited} -> ${entered})';
    }

    public function getTypeId():Any {
        return Type.typeof(this);
    }
}

/**
 * Label for the StateTransition schedule.
 * 
 * Runs state transitions. By default, it will be triggered once before PreStartup
 * and then each frame after PreUpdate.
 */
class StateTransitionSchedule implements SystemSetLabel {
    public static var instance(default, null):StateTransitionSchedule = new StateTransitionSchedule();
    
    private function new() {}
    
    public function toString():String {
        return 'StateTransition';
    }

    public function getTypeId():Any {
        return Type.typeof(this);
    }
}

/**
 * Plugin that enables state machine functionality.
 * 
 * This plugin:
 * - Inserts initial state resources
 * - Sets up the StateTransition schedule
 * - Configures schedule ordering for state transitions
 */
@:generic
class StatePlugin<T:States> implements IPlugin {
    /**
     * Initialize state resources in the app
     */
    public static function init(app:App):Void {
        // Insert State resource with default initial value
        // Note: We need a way to get the default value for T
        app.addSystems(StateTransitionSchedule.instance, StateTransitionSystems.runStateTransitions);
    }
    
    /**
     * Set up schedules for state transitions
     */
    public static function setupSchedules(app:App):Void {
        // Configure StateTransition to run after PreUpdate
        // and before PostUpdate
    }
}

/**
 * Internal systems for state transitions
 */
class StateTransitionSystems {
    /**
     * Run state transition logic
     */
    public static function runStateTransitions<T:States>(
        world:World,
        state:State<T>,
        nextState:NextState<T>,
        previousState:PreviousState<T>
    ):Void {
        var maybeTransition = nextState.take();
        
        if (maybeTransition == null) {
            // No pending transition
            return;
        }
        
        var transition = maybeTransition;
        var currentState = state.get();
        
        // Store previous state
        previousState.previous = Some(currentState);
        
        // Apply the transition
        state.applyTransition(transition.state, transition.shouldRunTransitions);
    }
}
