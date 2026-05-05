package bevy.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;

class AnyOfMacro {
    static var generatedByClassAndArity:Map<String, TypePath> = new Map();

    macro public static function buildAnyOf():ComplexType {
        return switch Context.getLocalType() {
            case TInst(cls, args):
                var classType = cls.get();
                var arity = args.length;
                if (arity == 0) {
                    Context.error("AnyOf query data requires at least one type parameter", Context.currentPos());
                }

                var baseKey = classType.pack.concat([classType.name]).join(".");
                var cacheKey = baseKey + "#" + arity;
                if (!generatedByClassAndArity.exists(cacheKey)) {
                    generatedByClassAndArity.set(cacheKey, defineAnyOfClass(classType, arity));
                }

                var generated = generatedByClassAndArity.get(cacheKey);
                generated.params = [for (arg in args) {
                    switch arg {
                        case TInst(_.get().kind => KExpr(expr), _):
                            TPType(Context.typeof(expr).toComplexType());
                        case _:
                            TPType(arg.toComplexType());
                    }
                }];
                TPath(generated);
            case _:
                Context.error("AnyOf generic build can only be used on classes", Context.currentPos());
        };
    }

    static function defineAnyOfClass(base:ClassType, arity:Int):TypePath {
        var typeParams:Array<TypeParamDecl> = [];
        var fields:Array<Field> = [];

        for (i in 0...arity) {
            var typeParamName = 'T$i';
            var fieldName = '_$i';
            var optionType:ComplexType = TPath({
                pack: ["bevy", "ecs"],
                name: "Option",
                sub: null,
                params: [TPType(TPath({pack: [], name: typeParamName, sub: null, params: []}))]
            });

            typeParams.push({
                name: typeParamName,
                constraints: [],
                params: []
            });

            var field = (macro class Tmp {
                public var $fieldName:$optionType;
            }).fields[0];
            fields.push(field);
        }

        var constructor:Field = {
            name: "new",
            pos: base.pos,
            access: [APublic, AInline],
            meta: [],
            kind: FFun({
                args: [for (field in fields) {
                    {
                        name: field.name,
                        type: null,
                        opt: false,
                        value: null,
                        meta: []
                    };
                }],
                ret: null,
                expr: macro $b{[for (field in fields) {
                    var n = field.name;
                    macro this.$n = $i{n};
                }]},
                params: []
            })
        };

        var generatedName = base.name + "_" + arity;
        Context.defineType({
            pack: base.pack,
            name: generatedName,
            pos: base.pos,
            meta: [],
            params: typeParams,
            isExtern: false,
            kind: TDClass(null, []),
            fields: fields.concat([constructor])
        });

        return {
            pack: base.pack,
            name: generatedName,
            sub: null,
            params: []
        };
    }
}
#end
