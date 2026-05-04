package macro;

import bevy.reflect.Reflect;
import bevy.reflect.TypeInfo.TypeKind;
import bevy.reflect.TypeRegistry;

class ReflectMacroTest {
    static function main():Void {
        var value = new ReflectedPosition(1, 2);
        assertEq(1, value.getField("x"), "get reflected field");
        assert(value.setField("y", 7), "set reflected field");
        assertEq(7, value.y, "field should be updated");
        assert(!value.setField("missing", 0), "missing field should fail");

        var info = value.typeInfo();
        assertEq(TypeKind.Reflectable, info.kind, "reflect kind");
        assert(info.fields.indexOf("x") >= 0, "typeInfo includes x");
        assert(TypeRegistry.global().has(ReflectedPosition), "reflected class should auto-register");
        trace("ReflectMacroTest ok");
    }

    static function assertEq<T>(expected:T, actual:T, label:String):Void {
        if (expected != actual) {
            throw '$label expected $expected, got $actual';
        }
    }

    static function assert(value:Bool, label:String):Void {
        if (!value) {
            throw label;
        }
    }
}

class ReflectedPosition implements Reflect {
    public var x:Int;
    public var y:Int;

    public function new(x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }
}
