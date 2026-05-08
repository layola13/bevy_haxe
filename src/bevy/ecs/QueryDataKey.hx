package bevy.ecs;

class QueryDataKey {
    public static inline var ANY_OF_PREFIX:String = "__bevy_anyof__:";
    public static inline var ANY_OF_ITEM_COMPONENT_PREFIX:String = "component:";
    public static inline var ANY_OF_ITEM_ENTITY:String = "entity";
    public static inline var ANY_OF_ITEM_ENTITY_REF:String = "entity_ref";
    public static inline var ANY_OF_ITEM_ENTITY_WORLD_MUT:String = "entity_world_mut";
    public static inline var ANY_OF_ITEM_SPAWN_DETAILS:String = "spawn_details";
    public static inline var ANY_OF_ITEM_HAS_PREFIX:String = "has:";
    public static inline var ANY_OF_ITEM_OPTION_PREFIX:String = "option:";
    public static inline var ANY_OF_ITEM_REF_PREFIX:String = "ref:";
    public static inline var ANY_OF_ITEM_MUT_PREFIX:String = "mut:";

    public static function encodeAnyOfKeys(keys:Array<String>):String {
        var encoded:Array<String> = [];
        if (keys != null) {
            for (key in keys) {
                encoded.push(encodeSegment(key));
            }
        }
        return ANY_OF_PREFIX + encoded.join("|");
    }

    public static function parseAnyOfKeys(typeKey:Null<String>):Null<Array<String>> {
        if (typeKey == null || !StringTools.startsWith(typeKey, ANY_OF_PREFIX)) {
            return null;
        }
        var payload = typeKey.substr(ANY_OF_PREFIX.length);
        if (payload.length == 0) {
            return [];
        }
        var result:Array<String> = [];
        for (part in payload.split("|")) {
            result.push(decodeSegment(part));
        }
        return result;
    }

    public static inline function isAnyOfKey(typeKey:Null<String>):Bool {
        return typeKey != null && StringTools.startsWith(typeKey, ANY_OF_PREFIX);
    }

    public static inline function anyOfComponentItem(typeKey:String):String {
        return ANY_OF_ITEM_COMPONENT_PREFIX + normalizeTypeKey(typeKey);
    }

    public static inline function anyOfEntityItem():String {
        return ANY_OF_ITEM_ENTITY;
    }

    public static inline function anyOfEntityRefItem():String {
        return ANY_OF_ITEM_ENTITY_REF;
    }

    public static inline function anyOfEntityWorldMutItem():String {
        return ANY_OF_ITEM_ENTITY_WORLD_MUT;
    }

    public static inline function anyOfSpawnDetailsItem():String {
        return ANY_OF_ITEM_SPAWN_DETAILS;
    }

    public static inline function anyOfHasItem(typeKey:String):String {
        return ANY_OF_ITEM_HAS_PREFIX + normalizeTypeKey(typeKey);
    }

    public static inline function anyOfOptionItem(typeKey:String):String {
        return ANY_OF_ITEM_OPTION_PREFIX + normalizeTypeKey(typeKey);
    }

    public static inline function anyOfRefItem(typeKey:String):String {
        return ANY_OF_ITEM_REF_PREFIX + normalizeTypeKey(typeKey);
    }

    public static inline function anyOfMutItem(typeKey:String):String {
        return ANY_OF_ITEM_MUT_PREFIX + normalizeTypeKey(typeKey);
    }

    static inline function normalizeTypeKey(typeKey:Null<String>):String {
        return typeKey == null ? "" : TypeKey.named(typeKey);
    }

    static inline function encodeSegment(value:String):String {
        return value == null ? "" : StringTools.urlEncode(value);
    }

    static inline function decodeSegment(value:String):String {
        return value == null ? "" : StringTools.urlDecode(value);
    }
}
