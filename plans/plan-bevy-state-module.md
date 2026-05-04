# Plan: Improved Bevy State Module for Haxe

## Overview

This plan improves the bevy_state module to better match the Rust Bevy API, adding comprehensive state machine support with proper generics, conditions, and plugin integration.

### Goals and Success Criteria
- Support generic state types `T: States`
- Implement complete state machine lifecycle (enter/exit/transition)
- Provide system conditions for state-based control flow
- Integrate properly with the app plugin system
- Match Rust Bevy State API semantics

### Scope
**Included:**
- State<T> resource for storing current state
- NextState<T> for queuing transitions
- FreelyMutableState interface for state types
- StateCondition functions for system conditions
- StatesPlugin for app integration
- Schedule labels (OnEnter, OnExit, OnTransition)
- State transition event support

**Excluded:**
- ComputedStates (future enhancement)
- SubStates (future enhancement)
- StateScoped (future enhancement)

---

## Implementation Steps

### Step 1: Enhance State.hx - State Machine Core

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/state/State.hx`

**Changes:**
1. Add `FreelyMutableState` interface for states that can be mutated
2. Add `FromWorld` support for initial state
3. Add `StateTransitionEvent` for transition notifications
4. Add `PreviousState` resource tracking
5. Implement proper change detection
6. Add state initialization methods

**Key Code:**
```haxe
// FreelyMutableState interface - states that can be set directly
interface FreelyMutableState extends States {
    // States with FromWorld implementation can be initialized with init_state
}

// State<T> improvements
@:generic
class State<T:States> {
    // Store current state value
    public var current(default, null):T;
    
    // Transition tracking
    public var transition(default, null):StateTransition<T>;
    
    // Change detection
    public var isChanged(default, null):Bool;
}
```

---

### Step 2: Enhance NextState.hx - Next State Requests

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/state/NextState.hx`

**Changes:**
1. Add `take()` method that returns state and clears
2. Add `trigger()` for state transitions
3. Improve enum handling with pattern matching
4. Add static `pending()` factory method

---

### Step 3: Consolidate StateCondition.hx - State Conditions

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/state/StateCondition.hx`

**Changes:**
1. Remove duplicate definitions from StateConditions.hx
2. Add `state_changed` condition
3. Add `state_exists` condition
4. Add `in_state` and `not_in_state` conditions
5. Add condition combinators (or, and, not)
6. Improve generic type handling

**Key Conditions:**
```haxe
// Check if state exists
function stateExists<T:States>(currentState:Option<State<T>>):Bool

// Check if in specific state  
function inState<T:States>(target:T):(Option<State<T>>) -> Bool

// Check if not in specific state
function notInState<T:States>(target:T):(Option<State<T>>) -> Bool

// Check if state changed this frame
function stateChanged<T:States>(currentState:Option<State<T>>):Bool

// Any of states
function anyInStates<T:States>(targets:Array<T>):(Option<State<T>>) -> Bool

// None of states
function noneInStates<T:States>(targets:Array<T>):(Option<State<T>>) -> Bool
```

---

### Step 4: Enhance StateConditions.hx - Condition Combinators

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/state/StateConditions.hx`

**Changes:**
1. Keep combinator functions (orEager, andEager, not)
2. Ensure compatibility with StateCondition.hx
3. Add fluent interface support

---

### Step 5: Create StatePlugin.hx - State Plugin and Schedules

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/state/StatePlugin.hx`

**Changes:**
1. Implement `StatesPlugin` class
2. Define `OnEnter<S>`, `OnExit<S>`, `OnTransition<S>` schedule labels
3. Define `StateTransition` schedule
4. Implement `StateTransitionSystems` for running transitions
5. Add `AppExtStates` for app methods
6. Implement `init_state` and `insert_state` app methods

**Key Components:**
```haxe
// Schedule labels
@:generic
class OnEnter<T:States> implements ScheduleLabel { ... }
@:generic
class OnExit<T:States> implements ScheduleLabel { ... }
@:generic
class OnTransition<T:States> implements ScheduleLabel { ... }

// Plugin
class StatesPlugin implements Plugin {
    function build(app:App):Void { ... }
}

// App extension methods
interface AppExtStates {
    function initState<T:FreelyMutableState + FromWorld>():App;
    function insertState<T:FreelyMutableState>(state:T):App;
    function getState<T:States>():State<T>;
    function getNextState<T:States>():NextState<T>;
}
```

---

### Step 6: Update Prelude Integration

**File:** `/home/vscode/projects/bevy_haxe/src/haxe/prelude/Prelude.hx`

**Changes:**
1. Add state module exports
2. Add type aliases for convenience

---

## File Changes Summary

| File | Action | Description |
|------|--------|-------------|
| `src/haxe/state/State.hx` | Modified | Enhanced state machine core |
| `src/haxe/state/NextState.hx` | Modified | Improved next state handling |
| `src/haxe/state/StateCondition.hx` | Modified | Consolidated state conditions |
| `src/haxe/state/StateConditions.hx` | Modified | Condition combinators |
| `src/haxe/state/StatePlugin.hx` | Modified | Complete plugin implementation |
| `src/haxe/prelude/Prelude.hx` | Modified | Add state exports |

---

## Testing Strategy

1. **Unit Tests:**
   - Test state initialization
   - Test state transitions
   - Test conditions with different states

2. **Integration Tests:**
   - Test StatesPlugin integration with App
   - Test schedule execution

3. **Manual Testing:**
   - Create example with multiple states
   - Verify transition schedules fire correctly

---

## Rollback Plan

To rollback:
1. Revert changes to each file individually
2. No data migration needed (stateless module)
3. Restore backup copies if needed

---

## Estimated Effort

- **Time:** 2-3 hours
- **Complexity:** Medium
- **Dependencies:** None (standalone module)
