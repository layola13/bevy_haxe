package haxe.ecs;

/**
 * An archetype represents a unique combination of components.
 * All entities with the same set of components belong to the same archetype.
 */
class Archetype {
    /** Unique identifier for this archetype */
    public final id:ArchetypeId;
    
    /** Set of component ids that entities in this archetype have */
    private var componentIds:Array<ComponentId>;
    
    /** Entities currently in this archetype */
    private var entities:Array<Entity>;
    
    /** Table row indices for each entity (for dense storage lookup) */
    private var tableRows:Array<TableRow>;

    public function new(id:ArchetypeId, componentIds:Array<ComponentId> = null) {
        this.id = id;
        this.componentIds = componentIds != null ? componentIds : [];
        this.entities = [];
        this.tableRows = [];
    }

    /**
     * Returns the number of entities in this archetype
     */
    public inline function entityCount():Int {
        return entities.length;
    }

    /**
     * Returns the set of component ids for this archetype
     */
    public inline function getComponentIds():Array<ComponentId> {
        return componentIds.copy();
    }

    /**
     * Checks if this archetype contains a specific component
     */
    public inline function hasComponent(componentId:ComponentId):Bool {
        return componentIds.indexOf(componentId) >= 0;
    }

    /**
     * Adds an entity to this archetype
     */
    public function addEntity(entity:Entity, tableRow:TableRow):Void {
        entities.push(entity);
        tableRows.push(tableRow);
    }

    /**
     * Removes an entity from this archetype by index
     * Uses swap-remove for efficiency
     */
    public function removeEntity(index:Int):Entity {
        if (index < 0 || index >= entities.length) {
            throw new ECSException('Invalid archetype entity index: $index');
        }
        
        final lastIndex = entities.length - 1;
        final removedEntity = entities[index];
        final removedRow = tableRows[index];
        
        if (index != lastIndex) {
            // Swap with last
            entities[index] = entities[lastIndex];
            tableRows[index] = tableRows[lastIndex];
        }
        
        entities.pop();
        tableRows.pop();
        
        return removedEntity;
    }

    /**
     * Gets the entity at the given index
     */
    public inline function getEntity(index:Int):Entity {
        return entities[index];
    }

    /**
     * Gets the table row for the entity at the given index
     */
    public inline function getTableRow(index:Int):TableRow {
        return tableRows[index];
    }

    /**
     * Finds the index of an entity in this archetype
     */
    public function entityIndex(entity:Entity):Int {
        for (i in 0...entities.length) {
            if (entities[i].equals(entity)) {
                return i;
            }
        }
        return -1;
    }

    /**
     * Returns all entities in this archetype
     */
    public inline function getEntities():Array<Entity> {
        return entities.copy();
    }

    /**
     * Checks if this archetype is a subset of another (all components of this are in other)
     */
    public function isSubsetOf(other:Archetype):Bool {
        for (cid in componentIds) {
            if (!other.hasComponent(cid)) {
                return false;
            }
        }
        return true;
    }

    /**
     * Checks if this archetype is a superset of another (other has all components of this)
     */
    public inline function isSupersetOf(other:Archetype):Bool {
        return other.isSubsetOf(this);
    }

    public function toString():String {
        return 'Archetype[$id](${componentIds.join(", ")})';
    }
}

/**
 * Manages all archetypes in the world
 */
class Archetypes {
    /** All archetypes indexed by id */
    private var archetypes:Array<Archetype>;
    
    /** Map from component set hash to archetype id */
    private var componentHashMap:Map<String, ArchetypeId>;
    
    /** Generation counter for archetype changes */
    private var generation:Int = 0;

    public function new() {
        archetypes = [];
        componentHashMap = new Map();
        
        // Create the empty archetype (entities with no components)
        final empty = new Archetype(0, []);
        archetypes.push(empty);
        componentHashMap.set("[]", 0);
    }

    /**
     * Gets the archetype by id
     */
    public inline function get(id:ArchetypeId):Null<Archetype> {
        return if (id < archetypes.length) archetypes[id] else null;
    }

    /**
     * Gets or creates an archetype with the given component ids
     */
    public function getOrInsert(componentIds:Array<ComponentId>):ArchetypeId {
        // Sort component ids for consistent hashing
        final sorted = componentIds.copy();
        sorted.sort((a, b) -> Reflect.compare(a, b));
        final hash = sorted.join(",");
        
        // Check if archetype already exists
        final existingId = componentHashMap.get(hash);
        if (existingId != null) {
            return existingId;
        }
        
        // Create new archetype
        final id:ArchetypeId = archetypes.length;
        final archetype = new Archetype(id, componentIds.copy());
        archetypes.push(archetype);
        componentHashMap.set(hash, id);
        generation++;
        
        return id;
    }

    /**
     * Returns the number of archetypes
     */
    public inline function count():Int {
        return archetypes.length;
    }

    /**
     * Returns the current generation
     */
    public inline function getGeneration():Int {
        return generation;
    }

    /**
     * Iterates over all archetypes
     */
    public function iterator():Iterator<Archetype> {
        return archetypes.iterator();
    }

    /**
     * Gets all archetypes that contain a specific component
     */
    public function getArchetypesWithComponent(componentId:ComponentId):Array<Archetype> {
        final result:Array<Archetype> = [];
        for (archetype in archetypes) {
            if (archetype.hasComponent(componentId)) {
                result.push(archetype);
            }
        }
        return result;
    }
}

class ECSException extends haxe.Exception {
    public function new(message:String) {
        super(message);
    }
}
