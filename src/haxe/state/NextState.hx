package haxe.state;

import haxe.ds.Option;

/**
 * Represents the queued next state for a state machine.
 * 
 * Use this to request a state transition. The transition will be applied
 * during the StateTransition schedule.
 * 
 * # Example
 * ```haxe
 * fn handle_escape_pressed(mut next_state:ResMut<NextState<GameState>>) {
 *     if (escape_pressed) {
 *         next_state.set(GameState::SettingsMenu);
 *     }
 * }
 * ```
 */
@:generic
class NextState<T:States> {
    public var value(default, null):NextStateValue<T>;
    
    public inline function new() {
        this.value = Unchanged;
    }
    
    /**
     * Set a pending state transition to a specific state.
     * 
     * This will run the transition schedules even if transitioning
     * to the same state. To avoid running schedules for same-state
     * transitions, use `setIfNeq` instead.
     */
    public inline function set(state:T) {
        this.value = Pending(state);
    }
    
    /**
     * Set a pending state transition, but only if the target state
     * differs from the current pending state.
     * 
     * Unlike `set`, this will not run transition schedules when
     * transitioning to the same state.
     */
    public inline function setIfNeq(state:T) {
        if (!matches(this.value, Pending(s)) || !s.equals(state)) {
            this.value = PendingIfNeq(state);
        }
    }
    
    /**
     * Remove any pending changes to State<S>
     */
    public inline function reset() {
        this.value = Unchanged;
    }
    
    /**
     * Check if there is a pending transition
     */
    public inline function hasPending():Bool {
        return switch (value) {
            case Unchanged: false;
            case Pending(_): true;
            case PendingIfNeq(_): true;
        }
    }
    
    /**
     * Get the pending state value if any
     */
    public inline function getPending():Option<T> {
        return switch (value) {
            case Unchanged: None;
            case Pending(s): Some(s);
            case PendingIfNeq(s): Some(s);
        }
    }
    
    /**
     * Take the pending state and clear this NextState.
     * Returns the state and whether transitions should run.
     */
    public function take():Option<{state: T, shouldRunTransitions: Bool}> {
        return switch (value) {
            case Unchanged:
                this.value = Unchanged;
                null;
            case Pending(s):
                this.value = Unchanged;
                Some({state: s, shouldRunTransitions: true});
            case PendingIfNeq(s):
                this.value = Unchanged;
                Some({state: s, shouldRunTransitions: false});
        };
    }
}

/**
 * Enum representing the possible values of NextState
 */
enum NextStateValue<T:States> {
    /** No pending state change */
    Unchanged;
    /** Pending transition, will run schedules even if same state */
    Pending(state: T);
    /** Pending transition, will skip schedules if same state */
    PendingIfNeq(state: T);
}
