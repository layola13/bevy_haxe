package bevy.macro;

#if macro
import haxe.macro.Expr;

class EventMacro {
    public static function build():Array<Field> {
        return EcsRegistrationMacro.build("bevy.ecs.EventRegistry", "Event");
    }
}
#end
