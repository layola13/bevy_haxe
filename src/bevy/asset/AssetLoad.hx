package bevy.asset;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

class AssetLoad {
    #if macro
    public static macro function load(server:Expr, path:Expr):Expr {
        var expected = Context.getExpectedType();
        var assetPath = extractHandleAssetPath(expected, path.pos);
        var assetExpr = Context.parse(assetPath.join("."), path.pos);
        return macro {
            var __bevyAssetServer:bevy.asset.AssetServer = $server;
            var __bevyAssets = bevy.asset.AssetApp.requireAssets(cast __bevyAssetServer.__world, $assetExpr);
            __bevyAssetServer.loadTyped(__bevyAssets, $path);
        };
    }

    static function extractHandleAssetPath(type:Type, pos:Position):Array<String> {
        return switch type {
            case TInst(_.get() => cls, params):
                var full = cls.pack.length == 0 ? cls.name : cls.pack.join(".") + "." + cls.name;
                if (full != "bevy.asset.Handle" && cls.name != "Handle") {
                    Context.error("AssetServer.load must be used where Handle<T> is the expected type", pos);
                }
                if (params.length != 1) {
                    Context.error("Handle<T> must specify exactly one asset type", pos);
                }
                switch params[0] {
                    case TInst(_.get() => assetCls, _):
                        assetCls.pack.concat([assetCls.name]);
                    default:
                        Context.error("Handle<T> asset type must be a class", pos);
                }
            default:
                Context.error("AssetServer.load requires an expected Handle<T> type", pos);
        }
    }
    #end
}
