package haxe.ecs;

abstract Entity({index:UInt, generation:UInt}) {
    public inline function new(index:UInt, generation:UInt) {
        this = {index: index, generation: generation};
    }

    @:from public static inline function fromBits(bits:UInt):Entity {
        return new Entity(bits & 0xFFFFFFFF, bits >> 32);
    }

    public inline function toBits():UInt {
        return this.index | (this.generation << 32);
    }

    public inline function index():UInt {
        return this.index;
    }

    public inline function generation():UInt {
        return this.generation;
    }

    public static var INVALID(default, null):Entity = new Entity(0, 0);

    public inline function isValid():Bool {
        return this.index != 0 || this.generation != 0;
    }

    public inline function isInvalid():Bool {
        return !isValid();
    }

    @:op(A == B) public inline function equals(other:Entity):Bool {
        return this.index == other.this.index && this.generation == other.this.generation;
    }

    @:op(A != B) public inline function notEquals(other:Entity):Bool {
        return !equals(other);
    }

    public inline function hashCode():Int {
        return Std.int(this.index) ^ Std.int(this.generation << 16);
    }

    public function toString():String {
        return 'Entity(index: ${this.index}, generation: ${this.generation})';
    }

    public static inline function fromIndex(index:UInt):Entity {
        return new Entity(index, 0);
    }
}
