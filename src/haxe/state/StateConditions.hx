package haxe.state;

import haxe.ecs.system.Condition;

/**
 * System condition that returns true if the state machine for S exists.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(stateExists<GameState>())
 * );
 * ```
 * 
 * `state_exists` will only return true if the given state exists.
 */
@:generic
function stateExists<T:States>(currentState:Option<State<T>>):Bool {
    return currentState != null;
}

/**
 * System condition that returns true if the state machine is currently in `state`.
 * 
 * Will return false if the state does not exist or if not in `state`.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(inState(GameState::Playing))
 * );
 * ```
 */
@:generic
function inState<T:States>(targetState:T):(currentState:Option<State<T>>) -> Bool {
    return function(currentState:Option<State<T>>):Bool {
        if (currentState == null) {
            return false;
        }
        return currentState.get().equals(targetState);
    };
}

/**
 * System condition that returns true if the state machine is currently NOT in `state`.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(notInState(GameState::GameOver))
 * );
 * ```
 */
@:generic
function notInState<T:States>(targetState:T):(currentState:Option<State<T>>) -> Bool {
    return function(currentState:Option<State<T>>):Bool {
        if (currentState == null) {
            return true;
        }
        return !currentState.get().equals(targetState);
    };
}

/**
 * System condition that returns true if the state machine is in any of the provided states.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(anyInStates([GameState::Playing, GameState::Paused]))
 * );
 * ```
 */
@:generic
function anyInStates<T:States>(targetStates:Array<T>):(currentState:Option<State<T>>) -> Bool {
    return function(currentState:Option<State<T>>):Bool {
        if (currentState == null) {
            return false;
        }
        var current = currentState.get();
        for (state in targetStates) {
            if (current.equals(state)) {
                return true;
            }
        }
        return false;
    };
}

/**
 * System condition that returns true if the state machine's state has just changed.
 * 
 * This only triggers once at the moment of transition.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(stateChanged<GameState>())
 * );
 * ```
 */
@:generic
function stateChanged<T:States>(currentState:Option<State<T>>):Bool {
    if (currentState == null) {
        return false;
    }
    return currentState.isChanged();
}

/**
 * System condition that returns true if the state machine's previous state matches.
 * 
 * Useful for detecting when we just exited a state.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(previousStateMatches(GameState::Playing))
 * );
 * ```
 */
@:generic
function previousStateMatches<T:States>(targetState:T):(previousState:Option<PreviousState<T>>) -> Bool {
    return function(previousState:Option<PreviousState<T>>):Bool {
        if (previousState == null) {
            return false;
        }
        var prev = previousState.get();
        return prev != null && prev.equals(targetState);
    };
}

/**
 * Combine multiple state conditions with OR logic.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(
 *         inState(GameState::Menu)
 *             .or(inState(GameState::Pause))
 *     )
 * );
 * ```
 */
@:generic
function orState<T:States>(first:(Option<State<T>>) -> Bool):(other:(Option<State<T>>) -> Bool) -> (Option<State<T>>) -> Bool {
    return function(other:(Option<State<T>>) -> Bool):(Option<State<T>>) -> Bool {
        return function(currentState:Option<State<T>>):Bool {
            return first(currentState) || other(currentState);
        };
    };
}

/**
 * Combine multiple state conditions with AND logic.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(
 *         stateExists<GameState>()
 *             .and(inState(GameState::Playing))
 *     )
 * );
 * ```
 */
@:generic
function andState<T:States>(first:(Option<State<T>>) -> Bool):(other:(Option<State<T>>) -> Bool) -> (Option<State<T>>) -> Bool {
    return function(other:(Option<State<T>>) -> Bool):(Option<State<T>>) -> Bool {
        return function(currentState:Option<State<T>>):Bool {
            return first(currentState) && other(currentState);
        };
    };
}

/**
 * Negate a state condition.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(notState(inState(GameState::GameOver)))
 * );
 * ```
 */
@:generic
function notState<T:States>(condition:(Option<State<T>>) -> Bool):(Option<State<T>>) -> Bool {
    return function(currentState:Option<State<T>>):Bool {
        return !condition(currentState);
    };
}
