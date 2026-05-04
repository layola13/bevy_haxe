package haxe.state;

import haxe.ds.Option;
import haxe.ds.GenericStack;

/**
 * Types that can define world-wide states in a finite-state machine.
 * 
 * The `Default` trait defines the starting state.
 * Multiple states can be defined for the same world,
 * allowing you to classify the state of the world across orthogonal dimensions.
 * 
 * To define a State type, implement this interface along with:
 * - `haxe.ISpecialize`
 * - `haxe.Equatable`
 * - `haxe.Hashable`
 */
interface States {
    /**
     * Compare equality with another States value.
     */
    function equals(other:States):Bool;

    /**
     * Compute a hash code for this state value.
     */
    function hashCode():Int;

    /**
     * Clone / copy this state value.
     */
    function clone():States;
}

/**
 * A finite-state machine whose transitions have associated schedules
 * (OnEnter(state) and OnExit(state)).
 * 
 * The current state value can be accessed through this resource. To change the state,
 * queue a transition in the NextState<S> resource, and it will be applied during the
 * StateTransition schedule.
 */
@:generic
class State<T:States> {
    public var current(default, null):T;
    
    // Transition tracking
    public var transition(default, null):StateTransition<T>;
    
    public function new(initial:T) {
        this.current = initial;
        this.transition = new StateTransition<T>(initial);
    }
    
    /**
     * Get the current state value
     */
    public inline function get():T {
        return current;
    }
    
    /**
     * Set the state directly (internal use only)
     */
    public function set(newState:T) {
        this.current = newState;
    }
    
    /**
     * Apply pending transition from NextState
     */
    public function applyTransition(next:T, shouldRunTransitions:Bool) {
        var previous = current;
        
        if (shouldRunTransitions && !previous.equals(next)) {
            transition.exited = previous;
            transition.entered = next;
            transition.shouldRun = true;
        } else if (shouldRunTransitions && previous.equals(next)) {
            transition.exited = previous;
            transition.entered = next;
            transition.shouldRun = transition.allowSameStateTransitions;
        } else {
            transition.exited = null;
            transition.entered = null;
            transition.shouldRun = false;
        }
        
        current = next;
    }
    
    /**
     * Reset the transition tracker
     */
    public inline function resetTransition() {
        transition.exited = null;
        transition.entered = null;
        transition.shouldRun = false;
    }
    
    /**
     * Check if state has changed this frame
     */
    public function isChanged():Bool {
        return transition.shouldRun;
    }
}

/**
 * Tracks state transition information
 */
@:generic
class StateTransition<T:States> {
    public var exited:T;
    public var entered:T;
    public var shouldRun:Bool;
    public var allowSameStateTransitions:Bool;
    
    public function new(initial:T) {
        this.exited = null;
        this.entered = null;
        this.shouldRun = false;
        this.allowSameStateTransitions = true;
    }
}

/**
 * Represents the previous state before transition
 */
@:generic
class PreviousState<T:States> {
    public var previous(default, null):Option<T>;
    
    public function new() {
        this.previous = None;
    }
    
    public function newWithValue(state:T) {
        this.previous = Some(state);
    }
    
    public inline function get():T {
        return switch (previous) {
            case Some(v): v;
            case None: null;
        }
    }
}
