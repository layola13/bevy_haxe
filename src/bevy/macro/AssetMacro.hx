package bevy.macro;

#if macro
import haxe.macro.Expr;

class AssetMacro {
    public static function build():Array<Field> {
        return EcsRegistrationMacro.build("bevy.ecs.ResourceRegistry", "Asset");
    }
}
#end
