package haxe.utils;

/**
 * Label system for naming and identifying entities, components, and systems.
 * Labels provide flexible naming with efficient comparison through interning.
 * 
 * Labels can be converted to/from interned strings for consistent identity.
 */
@:structInit
class Label {
    /**
     * The interned string representation of this label
     */
    public var name(default, null):InternedString;
    
    /**
     * Optional namespace for organizing labels
     */
    public var namespace(default, null):Null<InternedString>;
    
    public inline function new(name:InternedString, ?namespace:InternedString) {
        this.name = name;
        this.namespace = namespace;
    }
    
    /**
     * Create a new label from a string.
     */
    public static function of(name:String, ?namespace:String):Label {
        var internedName = InternedString.intern(name);
        var internedNamespace:Null<InternedString> = namespace != null 
            ? InternedString.intern(namespace) 
            : null;
        return new Label(internedName, internedNamespace);
    }
    
    /**
     * Create a label in the default namespace.
     */
    public static function fromName(name:String):Label {
        return of(name);
    }
    
    /**
     * Get the full qualified name (namespace::name or just name).
     */
    public var fullName(get, never):String;
    private function get_fullName():String {
        if (namespace != null) {
            return namespace.value + "::" + name.value;
        }
        return name.value;
    }
    
    /**
     * Check if this label is in a specific namespace.
     */
    public inline function inNamespace(ns:InternedString):Bool {
        return namespace != null && namespace.is(ns);
    }
    
    /**
     * Get the label's hash code (uses interned string index).
     */
    public function hashCode():Int {
        return name.hashCode();
    }
    
    /**
     * Check if two labels are equal.
     */
    @:op(A == B)
    public static function equals(a:Label, b:Label):Bool {
        return a.name.is(b.name) && 
            ((a.namespace == null && b.namespace == null) ||
             (a.namespace != null && b.namespace != null && a.namespace.is(b.namespace)));
    }
    
    @:op(A != B)
    public static function notEquals(a:Label, b:Label):Bool {
        return !equals(a, b);
    }
    
    public function toString():String {
        return fullName;
    }
}

/**
 * Extension trait for labels to support additional operations.
 */
class LabelTools {
    /**
     * Parse a qualified label from a string (supports "namespace::name" format).
     */
    public static function parseQualified(s:String):Label {
        var parts = s.split("::");
        if (parts.length == 2) {
            return Label.of(parts[1], parts[0]);
        }
        return Label.fromName(s);
    }
    
    /**
     * Check if a label matches a pattern.
     * Supports wildcard matching with "*".
     */
    public static function matches(label:Label, pattern:String):Bool {
        if (pattern == "*") return true;
        if (!pattern.contains("::")) {
            return label.name.equalsStr(pattern);
        }
        var parts = pattern.split("::");
        if (parts.length != 2) return false;
        
        var nsMatches = label.namespace != null && label.namespace.equalsStr(parts[0]);
        var nameMatches = label.name.equalsStr(parts[1]);
        return nsMatches && nameMatches;
    }
}

/**
 * A label set for managing multiple labels on an entity.
 */
@:generic
class LabelSet {
    private var labels:Array<Label>;
    
    public inline function new() {
        labels = [];
    }
    
    /**
     * Add a label to the set.
     */
    public inline function add(label:Label):Void {
        if (!has(label)) {
            labels.push(label);
        }
    }
    
    /**
     * Add a label from a string.
     */
    public inline function addName(name:String):Void {
        add(Label.fromName(name));
    }
    
    /**
     * Check if the set contains a label.
     */
    public inline function has(label:Label):Bool {
        for (l in labels) {
            if (l == label) return true;
        }
        return false;
    }
    
    /**
     * Check if the set contains any of the given labels.
     */
    public inline function hasAny(other:LabelSet):Bool {
        for (l in other.labels) {
            if (has(l)) return true;
        }
        return false;
    }
    
    /**
     * Check if the set contains all of the given labels.
     */
    public inline function hasAll(other:LabelSet):Bool {
        for (l in other.labels) {
            if (!has(l)) return false;
        }
        return true;
    }
    
    /**
     * Remove a label from the set.
     */
    public inline function remove(label:Label):Void {
        labels = labels.filter(l -> !l.equals(label));
    }
    
    /**
     * Get the number of labels.
     */
    public var length(get, never):Int;
    private inline function get_length():Int return labels.length;
    
    /**
     * Get all labels as an array.
     */
    public inline function toArray():Array<Label> {
        return labels.copy();
    }
    
    /**
     * Get an iterator over the labels.
     */
    public inline function iterator():Iterator<Label> {
        return labels.iterator();
    }
    
    /**
     * Clear all labels.
     */
    public inline function clear():Void {
        labels = [];
    }
}

/**
 * Label hash map - stores values by label keys for efficient lookup.
 */
@:generic
class LabelHashMap<V> {
    private var data:Map<Int, V>;
    
    public inline function new() {
        data = new Map();
    }
    
    /**
     * Insert a value for a label.
     */
    public inline function set(label:Label, value:V):Null<V> {
        var old = data.get(label.hashCode());
        data.set(label.hashCode(), value);
        return old;
    }
    
    /**
     * Get a value for a label.
     */
    public inline function get(label:Label):Null<V> {
        return data.get(label.hashCode());
    }
    
    /**
     * Check if a label exists.
     */
    public inline function exists(label:Label):Bool {
        return data.exists(label.hashCode());
    }
    
    /**
     * Remove a label.
     */
    public inline function remove(label:Label):Bool {
        return data.remove(label.hashCode());
    }
    
    /**
     * Clear all entries.
     */
    public inline function clear():Void {
        data.clear();
    }
    
    public var length(get, never):Int;
    private inline function get_length():Int return data.count();
    
    public var isEmpty(get, never):Bool;
    private inline function get_isEmpty():Bool return data.isEmpty();
    
    public inline function iterator():Iterator<V> {
        return data.iterator();
    }
}
