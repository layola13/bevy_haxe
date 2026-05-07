package haxe.state;

import haxe.ds.Option;
import haxe.state.State.States;

/**
 * Represents the queued next state for a state machine.
 *
 * Use this to request a state transition. The transition will be applied
 * during the StateTransition schedule.
 */
@:generic
class NextState<T:States> {
    public var value(default, null):NextStateValue<T>;

    public inline function new() {
        this.value = Unchanged;
    }

    /**
     * Set a pending state transition to a specific state.
     */
    public inline function set(state:T) {
        this.value = Pending(state);
    }

    /**
     * Set a pending state transition, but only if the target state
     * differs from the current pending state.
     */
    public inline function setIfNeq(state:T) {
        var shouldSet = switch (value) {
            case Pending(s): s.hashCode() != state.hashCode();
            case PendingIfNeq(s): s.hashCode() != state.hashCode();
            case _: true;
        };
        if (shouldSet) {
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
