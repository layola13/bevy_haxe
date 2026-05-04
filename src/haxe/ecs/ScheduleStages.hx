package haxe.ecs;

/**
 * Defines the main stages in the ECS update loop.
 * 
 * These stages are executed in order each frame:
 * - First: Running before anything else (useful for setup)
 * - PreUpdate: Systems that prepare data before main update
 * - Update: Main game logic systems
 * - PostUpdate: Systems that process results of main update
 * - Last: Final systems (e.g., rendering, cleanup)
 * - StateTransition: Systems that handle state changes
 */
enum ScheduleStages {
    /** Systems that run first, before all other systems */
    First;
    
    /** Systems that run before the main update stage */
    PreUpdate;
    
    /** Systems that run during the main update stage */
    Update;
    
    /** Systems that run after the main update stage */
    PostUpdate;
    
    /** Systems that run last, after all other systems */
    Last;
    
    /** Systems for state transitions */
    StateTransition;
    
    /** Custom stage with a specific name */
    Custom(name:String);
}

/**
 * Helper class for working with schedule stages.
 */
class ScheduleStagesHelper {
    /**
     * Gets the order index of a stage (lower = earlier).
     */
    public static function getOrder(stage:ScheduleStages):Int {
        return switch (stage) {
            case First: 0;
            case PreUpdate: 1;
            case Update: 2;
            case PostUpdate: 3;
            case Last: 4;
            case StateTransition: 5;
            case Custom(_): 100;
        }
    }
    
    /**
     * Gets a display name for a stage.
     */
    public static function getName(stage:ScheduleStages):String {
        return switch (stage) {
            case First: "First";
            case PreUpdate: "PreUpdate";
            case Update: "Update";
            case PostUpdate: "PostUpdate";
            case Last: "Last";
            case StateTransition: "StateTransition";
            case Custom(name): name;
        }
    }
    
    /**
     * Gets all default stages in order.
     */
    public static function getDefaultStages():Array<ScheduleStages> {
        return [
            First,
            PreUpdate,
            Update,
            PostUpdate,
            Last
        ];
    }
}
