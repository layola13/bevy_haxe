package haxe.state;

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
function stateExists<T:States>(currentState:Null<State<T>>):Bool {
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
 *     mySystem.runIf(inState(GameState.Playing))
 * );
 * ```
 */
@:generic
function inState<T:States>(targetState:T):(currentState:Null<State<T>>) -> Bool {
    return function(currentState:Null<State<T>>):Bool {
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
 *     mySystem.runIf(notInState(GameState.GameOver))
 * );
 * ```
 */
@:generic
function notInState<T:States>(targetState:T):(currentState:Null<State<T>>) -> Bool {
    return function(currentState:Null<State<T>>):Bool {
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
 *     mySystem.runIf(anyInStates([GameState.Playing, GameState.Paused]))
 * );
 * ```
 */
@:generic
function anyInStates<T:States>(targetStates:Array<T>):(currentState:Null<State<T>>) -> Bool {
    return function(currentState:Null<State<T>>):Bool {
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
 * System condition that returns true if the state machine is NOT in any of the provided states.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(notAnyInStates([GameState.Paused, GameState.GameOver]))
 * );
 * ```
 */
@:generic
function notAnyInStates<T:States>(targetStates:Array<T>):(currentState:Null<State<T>>) -> Bool {
    return function(currentState:Null<State<T>>):Bool {
        if (currentState == null) {
            return true;
        }
        var current = currentState.get();
        for (state in targetStates) {
            if (current.equals(state)) {
                return false;
            }
        }
        return true;
    };
}

/**
 * System condition that returns true if the state machine has just changed to a different state.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(stateChanged<GameState>())
 * );
 * ```
 */
@:generic
function stateChanged<T:States>(currentState:Null<State<T>>):Bool {
    if (currentState == null) {
        return false;
    }
    return currentState.isChanged();
}

/**
 * System condition that returns true if the state machine has just changed from the specified state.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(stateJustChangedFrom(GameState.Menu))
 * );
 * ```
 */
@:generic
function stateJustChangedFrom<T:States>(fromState:T):(currentState:Null<State<T>>) -> Bool {
    return function(currentState:Null<State<T>>):Bool {
        if (currentState == null) {
            return false;
        }
        var exited = currentState.transition.exited;
        if (exited == null) {
            return false;
        }
        return exited.equals(fromState) && currentState.isChanged();
    };
}

/**
 * System condition that returns true if the state machine has just changed to the specified state.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(stateJustChangedTo(GameState.Playing))
 * );
 * ```
 */
@:generic
function stateJustChangedTo<T:States>(toState:T):(currentState:Null<State<T>>) -> Bool {
    return function(currentState:Null<State<T>>):Bool {
        if (currentState == null) {
            return false;
        }
        var entered = currentState.transition.entered;
        if (entered == null) {
            return false;
        }
        return entered.equals(toState) && currentState.isChanged();
    };
}

/**
 * System condition that returns true if the previous state equals the given state.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(previousState(GameState.Paused))
 * );
 * ```
 */
@:generic
function previousState<T:States>(targetState:T):(previousState:Null<PreviousState<T>>) -> Bool {
    return function(previousState:Null<PreviousState<T>>):Bool {
        if (previousState == null || !previousState.hasPrevious()) {
            return false;
        }
        return previousState.get().equals(targetState);
    };
}

/**
 * Combine multiple state conditions with OR logic.
 * 
 * # Example
 * ```haxe
 * app.addSystems(Update, 
 *     mySystem.runIf(
 *         inState(GameState.Playing)
 *             .or(inState(GameState.Paused))
 *     )
 * );
 * ```
 */
@:generic
function orState<T:States>(first:(Null<State<T>>) -> Bool):(other:(Null<State<T>>) -> Bool) -> (Null<State<T>>) -> Bool {
    return function(other:(Null<State<T>>) -> Bool):(Null<State<T>>) -> Bool {
        return function(currentState:Null<State<T>>):Bool {
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
 *             .and(inState(GameState.Playing))
 *     )
 * );
 * ```
 */
@:generic
function andState<T:States>(first:(Null<State<T>>) -> Bool):(other:(Null<State<T>>) -> Bool) -> (Null<State<T>>) -> Bool {
    return function(other:(Null<State<T>>) -> Bool):(Null<State<T>>) -> Bool {
        return function(currentState:Null<State<T>>):Bool {
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
 *     mySystem.runIf(notState(inState(GameState.GameOver)))
 * );
 * ```
 */
@:generic
function notState<T:States>(condition:(Null<State<T>>) -> Bool):(Null<State<T>>) -> Bool {
    return function(currentState:Null<State<T>>):Bool {
        return !condition(currentState);
    };
}
