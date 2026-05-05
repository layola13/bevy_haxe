package bevy.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;

class TupleMacro {
    static var generatedByClassAndArity:Map<String, TypePath> = new Map();

    macro public static function buildTuple():ComplexType {
        return switch Context.getLocalType() {
            case TInst(cls, args):
                var classType = cls.get();
                var arity = args.length;
                if (arity == 0) {
                    var callArgs = Context.getCallArguments();
                    if (callArgs == null || callArgs.length == 0) {
                        return null;
                    }
                    args = [for (expr in callArgs) Context.typeof(expr)];
                    arity = args.length;
                }

                var baseKey = classType.pack.concat([classType.name]).join(".");
                var cacheKey = baseKey + "#" + arity;
                if (!generatedByClassAndArity.exists(cacheKey)) {
                    generatedByClassAndArity.set(cacheKey, defineTupleClass(classType, arity));
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
                Context.error("Tuple generic build can only be used on classes", Context.currentPos());
        };
    }

    static function defineTupleClass(base:ClassType, arity:Int):TypePath {
        var typeParams:Array<TypeParamDecl> = [];
        var tupleFields:Array<Field> = [];

        for (i in 0...arity) {
            var typeParamName = 'T$i';
            var fieldName = '_$i';
            var paramType:ComplexType = TPath({pack: [], name: typeParamName, sub: null, params: []});

            typeParams.push({
                name: typeParamName,
                constraints: [],
                params: []
            });

            var field = (macro class Tmp {
                public var $fieldName:$paramType;
            }).fields[0];
            tupleFields.push(field);
        }

        var constructor:Field = {
            name: "new",
            pos: base.pos,
            access: [APublic, AInline],
            meta: [],
            kind: FFun({
                args: [for (field in tupleFields) {
                    {
                        name: field.name,
                        type: null,
                        opt: false,
                        value: null,
                        meta: []
                    };
                }],
                ret: null,
                expr: macro $b{[for (field in tupleFields) {
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
            kind: TDClass(),
            fields: tupleFields.concat([constructor])
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
