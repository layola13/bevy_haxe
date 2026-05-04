package bevy.asset;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

class AssetLoad {
    public static macro function load(server:Expr, path:Expr):Expr {
        var assetExpr = assetClassExprFromHandleType(Context.getExpectedType(), path.pos);
        return macro {
            var __bevyAssetServer:bevy.asset.AssetServer = $server;
            var __bevyAssetWorld = __bevyAssetServer.__world;
            if (__bevyAssetWorld == null) {
                throw "AssetServer is not attached to a World";
            }
            var __bevyAssets = bevy.asset.AssetApp.requireAssets(__bevyAssetWorld, $assetExpr);
            __bevyAssetServer.loadTyped(__bevyAssets, $path);
        };
    }

    public static macro function loadState(server:Expr, handle:Expr):Expr {
        var assetExpr = assetClassExprFromHandleType(Context.typeof(handle), handle.pos);
        return macro {
            var __bevyAssetServer:bevy.asset.AssetServer = $server;
            var __bevyAssetWorld = __bevyAssetServer.__world;
            if (__bevyAssetWorld == null) {
                throw "AssetServer is not attached to a World";
            }
            var __bevyAssets = bevy.asset.AssetApp.requireAssets(__bevyAssetWorld, $assetExpr);
            __bevyAssetServer.loadStateTyped(__bevyAssets, $handle);
        };
    }

    #if macro
    static function assetClassExprFromHandleType(type:Type, pos:Position):Expr {
        var assetPath = extractHandleAssetPath(type, pos);
        return Context.parse(assetPath.join("."), pos);
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
