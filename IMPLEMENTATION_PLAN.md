# Bevy State Module Implementation Plan

## Overview

This plan documents the implementation of the Bevy state machine module in Haxe, ported from the Rust `bevy_state` crate. The state module provides finite-state machine functionality for Bevy applications.

## Goals

- Create a complete state machine system ported from Rust Bevy
- Support state transitions with associated schedules
- Provide system conditions for state-based control flow

## Scope

### Included
- `State<T>` - Main state resource with current value and transition tracking
- `NextState<T>` - Resource for queuing state transitions
- `StateCondition` - System conditions for state checking
- `StatePlugin` - Plugin for registering state schedules

### Excluded
- `ComputedStates` - Complex derived state functionality (future enhancement)
- `SubStates` - Hierarchical state functionality (future enhancement)

## File Structure

```
src/haxe/state/
├── State.hx          - States interface, State<T>, StateTransitionData<T>, PreviousState<T>
├── NextState.hx      - NextState<T>, NextStateValue enum, NextStateTake typedef
├── StateCondition.hx - stateExists, inState, notInState, etc.
└── StatePlugin.hx    - OnEnter, OnExit, OnTransition, StatePlugin, StateTransitionSystems
```

## Key Features

### State.hx
- `States` interface - Marker trait for state types
- `State<T>` class - Contains `current`, `next`, `transition` fields
- `transition(newState)` - Request a state transition
- `applyNext()` - Apply the pending state transition
- `StateTransitionData<T>` - Tracks exited/entered states
- `PreviousState<T>` - Stores the previous state value

### NextState.hx
- `NextState<T>` class - Queue pending transitions
- `set(state)` - Set pending transition
- `setIfNeq(state)` - Set only if different
- `take()` - Consume pending transition

### StateCondition.hx
- `stateExists<T>()` - Check if state exists
- `inState<T>(target)` - Check if in specific state
- `notInState<T>(target)` - Check if not in state
- `anyInStates<T>(targets)` - Check if in any of states
- `stateChanged<T>()` - Check if state changed this frame
- `previousState<T>(target)` - Check previous state

### StatePlugin.hx
- `OnEnter<T>` - Schedule label for entering state
- `OnExit<T>` - Schedule label for exiting state
- `OnTransition<T>` - Schedule label for state transition
- `StateTransitionSchedule` - Main state transition schedule
- `StatePlugin` - Plugin to register state machinery
- `StateTransitionSystems` - Internal transition logic

## Testing Strategy

1. Create test enum implementing States interface
2. Test State creation and get/set
3. Test NextState set/take operations
4. Test state conditions with runIf
5. Test state transitions with OnEnter/OnExit schedules

## Usage Example

```haxe
// Define a state enum
enum GameState implements States {
    MainMenu;
    Playing;
    Paused;
}

// In a system
function handleInput(nextState:ResMut<NextState<GameState>>) {
    if (escapePressed) {
        nextState.set(GameState.Paused);
    }
}

// Add state-aware systems
app.addSystems(OnEnter(GameState.Playing), startGame);
app.addSystems(Update, gameLogic.runIf(inState(GameState.Playing)));
```
