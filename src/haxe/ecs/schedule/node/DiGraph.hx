package haxe.ecs.schedule.node;

import haxe.ecs.schedule.InternedSystemSet;

/**
 * Directed graph implementation for schedule dependency ordering.
 */
class DiGraph {
    /** Nodes in the graph */
    private var nodes:Array<InternedSystemSet>;
    
    /** Adjacency list: node -> outgoing edges */
    private var edges:Map<Int, Array<Int>>;
    
    /** Reverse adjacency list: node -> incoming edges */
    private var reverseEdges:Map<Int, Array<Int>>;
    
    /** Number of edges */
    private var edgeCount:Int;
    
    /** Whether the graph has been topologically sorted */
    private var sorted:Bool;
    
    /** Cached topological order */
    private var topoOrder:Array<InternedSystemSet>;
    
    public function new() {
        nodes = [];
        edges = new Map();
        reverseEdges = new Map();
        edgeCount = 0;
        sorted = false;
        topoOrder = [];
    }
    
    /**
     * Adds a node to the graph.
     */
    public function addNode(node:InternedSystemSet):Void {
        var id = node.id;
        if (!edges.exists(id)) {
            nodes.push(node);
            edges.set(id, []);
            reverseEdges.set(id, []);
        }
    }
    
    /**
     * Adds a directed edge from source to target.
     */
    public function add_edge(source:InternedSystemSet, target:InternedSystemSet):Void {
        addNode(source);
        addNode(target);
        
        var sourceId = source.id;
        var targetId = target.id;
        
        var outgoing = edges.get(sourceId);
        if (!outgoing.contains(targetId)) {
            outgoing.push(targetId);
            reverseEdges.get(targetId).push(sourceId);
            edgeCount++;
            sorted = false;
        }
    }
    
    /**
     * Checks if an edge exists.
     */
    public function has_edge(source:InternedSystemSet, target:InternedSystemSet):Bool {
        var outgoing = edges.get(source.id);
        return outgoing != null && outgoing.contains(target.id);
    }
    
    /**
     * Gets outgoing edges from a node.
     */
    public function outgoing(node:InternedSystemSet):Array<InternedSystemSet> {
        var ids = edges.get(node.id);
        if (ids == null) return [];
        
        return ids
            .map(function(id:Int):InternedSystemSet {
                for (n in nodes) {
                    if (n.id == id) return n;
                }
                return null;
            })
            .filter(function(n:InternedSystemSet):Bool return n != null);
    }
    
    /**
     * Gets incoming edges to a node.
     */
    public function incoming(node:InternedSystemSet):Array<InternedSystemSet> {
        var ids = reverseEdges.get(node.id);
        if (ids == null) return [];
        
        return ids
            .map(function(id:Int):InternedSystemSet {
                for (n in nodes) {
                    if (n.id == id) return n;
                }
                return null;
            })
            .filter(function(n:InternedSystemSet):Bool return n != null);
    }
    
    /**
     * Gets the number of nodes.
     */
    public function node_count():Int {
        return nodes.length;
    }
    
    /**
     * Gets the number of edges.
     */
    public function edge_count():Int {
        return edgeCount;
    }
    
    /**
     * Checks if graph is empty.
     */
    public function is_empty():Bool {
        return nodes.length == 0;
    }
    
    /**
     * Performs topological sort using Kahn's algorithm.
     */
    public function topological_sort():Array<InternedSystemSet> {
        if (sorted) {
            return topoOrder.copy();
        }
        
        var result:Array<InternedSystemSet> = [];
        var inDegree:Map<Int, Int> = new Map();
        
        // Calculate in-degrees
        for (node in nodes) {
            var incomingEdges = reverseEdges.get(node.id);
            inDegree.set(node.id, incomingEdges != null ? incomingEdges.length : 0);
        }
        
        // Queue nodes with zero in-degree
        var queue:Array<InternedSystemSet> = [];
        for (node in nodes) {
            if (inDegree.get(node.id) == 0) {
                queue.push(node);
            }
        }
        
        // Process nodes
        while (queue.length > 0) {
            var current = queue.shift();
            result.push(current);
            
            var outgoing = edges.get(current.id);
            if (outgoing != null) {
                for (targetId in outgoing) {
                    var newDegree = inDegree.get(targetId) - 1;
                    inDegree.set(targetId, newDegree);
                    
                    if (newDegree == 0) {
                        for (node in nodes) {
                            if (node.id == targetId) {
                                queue.push(node);
                                break;
                            }
                        }
                    }
                }
            }
        }
        
        // Check for cycles
        if (result.length != nodes.length) {
            throw new CycleDetectedError("Graph contains a cycle - topological sort not possible");
        }
        
        topoOrder = result;
        sorted = true;
        return result.copy();
    }
    
    /**
     * Builds/validates the graph structure.
     */
    public function build():Void {
        // Ensure all referenced nodes exist
        // Reset sorted flag to force recalculation
        sorted = false;
    }
    
    /**
     * Gets all nodes.
     */
    public function nodes():Array<InternedSystemSet> {
        return nodes.copy();
    }
}

/**
 * Error thrown when a cycle is detected in the graph.
 */
class CycleDetectedError extends haxe.Exception {
    public function new(message:String) {
        super(message);
    }
}
