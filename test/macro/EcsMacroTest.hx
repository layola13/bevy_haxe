package macro;

import bevy.ecs.Component;
import bevy.ecs.ComponentRegistry;
import bevy.ecs.Bundle;
import bevy.ecs.BundleRegistry;
import bevy.ecs.Event;
import bevy.ecs.EventRegistry;
import bevy.ecs.Resource;
import bevy.ecs.ResourceRegistry;
import bevy.reflect.TypeInfo.TypeKind;
import bevy.reflect.TypeRegistry;

class EcsMacroTest {
    static function main():Void {
        testComponentRegistration();
        testResourceRegistration();
        testEventRegistration();
        testBundleRegistration();
        trace("EcsMacroTest ok");
    }

    static function testComponentRegistration():Void {
        assert(ComponentRegistry.has(MacroPosition), "component should auto-register");
        var info = TypeRegistry.global().get(MacroPosition);
        assert(info != null, "component should be in type registry");
        assertEq(TypeKind.Component, info.kind, "component type kind");
        assert(info.fields.indexOf("x") >= 0, "component field reflected");
    }

    static function testResourceRegistration():Void {
        assert(ResourceRegistry.has(MacroTime), "resource should auto-register");
        var info = TypeRegistry.global().get(MacroTime);
        assert(info != null, "resource should be in type registry");
        assertEq(TypeKind.Resource, info.kind, "resource type kind");
    }

    static function testEventRegistration():Void {
        assert(EventRegistry.has(MacroDamage), "event should auto-register");
        var info = TypeRegistry.global().get(MacroDamage);
        assert(info != null, "event should be in type registry");
        assertEq(TypeKind.Event, info.kind, "event type kind");
    }

    static function testBundleRegistration():Void {
        assert(BundleRegistry.has(MacroBundle), "bundle should auto-register");
        var bundle = new MacroBundle(new MacroPosition(3));
        assertEq(1, bundle.toBundle().length, "bundle should expose fields");
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

class MacroPosition implements Component {
    public var x:Int;

    public function new(x:Int) {
        this.x = x;
    }
}

class MacroTime implements Resource {
    public var seconds:Float;

    public function new(seconds:Float) {
        this.seconds = seconds;
    }
}

class MacroDamage implements Event {
    public var amount:Int;

    public function new(amount:Int) {
        this.amount = amount;
    }
}

class MacroBundle implements Bundle {
    public var position:MacroPosition;

    public function new(position:MacroPosition) {
        this.position = position;
    }
}
