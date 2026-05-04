package bevy.macro;

#if macro
import haxe.macro.Expr;

class ComponentMacro {
    public static function build():Array<Field> {
        return EcsRegistrationMacro.build("bevy.ecs.ComponentRegistry", "Component");
    }
}
#end
