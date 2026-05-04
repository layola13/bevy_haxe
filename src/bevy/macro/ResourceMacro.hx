package bevy.macro;

#if macro
import haxe.macro.Expr;

class ResourceMacro {
    public static function build():Array<Field> {
        return EcsRegistrationMacro.build("bevy.ecs.ResourceRegistry", "Resource");
    }
}
#end
