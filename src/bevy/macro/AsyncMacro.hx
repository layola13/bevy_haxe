package bevy.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

typedef AwaitReplacement = {
    var future:Expr;
    var expr:Expr;
}

class AsyncMacro {
    static var counter:Int = 0;

    public static function async(fn:Expr):Expr {
        return switch fn.expr {
            case EFunction(kind, f):
                var futureExpr = createFuture(normalizeBody(f.expr), fn.pos);
                if (f.args.length == 0) {
                    futureExpr;
                } else {
                    {
                        expr: EFunction(kind, {
                            args: f.args,
                            ret: macro:bevy.async.Future<Dynamic>,
                            expr: macro return $futureExpr,
                            params: f.params
                        }),
                        pos: fn.pos
                    };
                }
            default:
                Context.error("Async.async expects a function expression", fn.pos);
        }
    }

    public static function transformFunction(fn:Function, pos:Position):Function {
        return {
            args: fn.args,
            ret: macro:bevy.async.Future<Dynamic>,
            expr: macro return ${createFuture(normalizeBody(fn.expr), pos)},
            params: fn.params
        };
    }

    public static function await(value:Expr):Expr {
        return macro bevy.async.AsyncRuntime.awaitImmediate($value);
    }

    public static function forAwait(source:Expr, fn:Expr):Expr {
        return switch fn.expr {
            case EFunction(kind, f):
                if (f.args.length != 1) {
                    Context.error("Async.forAwait expects a one-argument callback", fn.pos);
                }
                var callback:Expr = {
                    expr: EFunction(kind, transformFunction(f, fn.pos)),
                    pos: fn.pos
                };
                #if async_macro_debug
                Context.warning(ExprTools.toString(callback), fn.pos);
                #end
                macro bevy.async.Async.forAwaitRuntime($source, $callback);
            default:
                Context.error("Async.forAwait expects a callback function", fn.pos);
        }
    }

    static function createFuture(body:Array<Expr>, pos:Position):Expr {
        var resolve = unique("__resolve");
        var reject = unique("__reject");
        var runnerBody = emitStatements(body, resolve, reject, pos);
        var runner = makeFunction([
            {name: resolve, opt: false, type: null, value: null},
            {name: reject, opt: false, type: null, value: null}
        ], runnerBody, pos);
        return macro bevy.async.Future.create($runner);
    }

    static function emitStatements(statements:Array<Expr>, resolve:String, reject:String, pos:Position):Expr {
        if (statements.length == 0) {
            return callIdent(resolve, [macro null], pos);
        }

        var first = statements[0];
        var rest = statements.slice(1);

        return switch first.expr {
            case EBlock(inner):
                emitStatements(inner.concat(rest), resolve, reject, first.pos);
            case EVars(vars):
                emitVarStatements(vars, rest, resolve, reject, first.pos);
            case EReturn(value):
                if (value == null) {
                    callIdent(resolve, [macro null], first.pos);
                } else {
                    emitValue(value, function(result) return callIdent(resolve, [result], first.pos), reject, first.pos);
                }
            case EThrow(value):
                emitValue(value, function(result) return callIdent(reject, [result], first.pos), reject, first.pos);
            case EIf(condition, thenExpr, elseExpr):
                emitIf(condition, thenExpr, elseExpr, rest, resolve, reject, first.pos);
            case ETry(_, _):
                if (containsAwait(first)) {
                    Context.error("await inside try/catch is not supported yet; use Future.recover around the awaited future", first.pos);
                }
                block([first, emitStatements(rest, resolve, reject, pos)], first.pos);
            case EFor(_, _) | EWhile(_, _, _):
                if (containsAwait(first)) {
                    Context.error("await inside native for/while is not supported; use Async.forAwait for asynchronous iteration", first.pos);
                }
                block([first, emitStatements(rest, resolve, reject, pos)], first.pos);
            case ESwitch(_, _, _):
                if (containsAwait(first)) {
                    Context.error("await inside switch is not supported yet", first.pos);
                }
                block([first, emitStatements(rest, resolve, reject, pos)], first.pos);
            default:
                if (containsAwait(first)) {
                    emitValue(first, function(_) return emitStatements(rest, resolve, reject, pos), reject, first.pos);
                } else {
                    block([first, emitStatements(rest, resolve, reject, pos)], first.pos);
                }
        }
    }

    static function emitVarStatements(vars:Array<Var>, rest:Array<Expr>, resolve:String, reject:String, pos:Position):Expr {
        if (vars.length == 0) {
            return emitStatements(rest, resolve, reject, pos);
        }
        var firstVar = vars[0];
        var remainingVars = vars.slice(1);
        var remainingStatements = remainingVars.length == 0 ? rest : [varDecls(remainingVars, pos)].concat(rest);

        if (firstVar.expr == null || !containsAwait(firstVar.expr)) {
            return block([varDecls([firstVar], pos), emitStatements(remainingStatements, resolve, reject, pos)], pos);
        }

        return emitValue(firstVar.expr, function(result) {
            var nextVar:Var = {
                name: firstVar.name,
                type: firstVar.type,
                expr: result,
                isFinal: firstVar.isFinal,
                meta: firstVar.meta
            };
            return block([varDecls([nextVar], pos), emitStatements(remainingStatements, resolve, reject, pos)], pos);
        }, reject, pos);
    }

    static function emitIf(condition:Expr, thenExpr:Expr, elseExpr:Null<Expr>, rest:Array<Expr>, resolve:String, reject:String, pos:Position):Expr {
        return emitValue(condition, function(result) {
            var thenBody = emitStatements([thenExpr].concat(rest), resolve, reject, thenExpr.pos);
            var elseBody = elseExpr != null
                ? emitStatements([elseExpr].concat(rest), resolve, reject, elseExpr.pos)
                : emitStatements(rest, resolve, reject, pos);
            return {
                expr: EIf(result, thenBody, elseBody),
                pos: pos
            };
        }, reject, pos);
    }

    static function emitValue(expr:Expr, onValue:Expr->Expr, reject:String, pos:Position):Expr {
        var replacement = replaceFirstAwait(expr);
        if (replacement == null) {
            var valueName = unique("__value");
            return block([
                varDecl(valueName, expr, pos),
                onValue(ident(valueName, pos))
            ], pos);
        }

        var awaitedName = unique("__awaited");
        var successBody = emitValue(replacement.expr, onValue, reject, pos);
        var success = makeFunction([
            {name: awaitedName, opt: false, type: null, value: null}
        ], successBody, pos);
        var replaced = replaceIdentifier(success, "__await_placeholder__", awaitedName);
        var future = macro bevy.async.Future.fromDynamic(${replacement.future});
        return {
            expr: ECall(field(future, "handle", pos), [replaced, ident(reject, pos)]),
            pos: pos
        };
    }

    static function replaceFirstAwait(expr:Expr):Null<AwaitReplacement> {
        switch expr.expr {
            case EMeta(meta, inner) if (isAwaitMetadata(meta.name)):
                return {
                    future: inner,
                    expr: ident("__await_placeholder__", expr.pos)
                };
            default:
        }

        if (isAwaitCall(expr)) {
            return {
                future: getAwaitArgument(expr),
                expr: ident("__await_placeholder__", expr.pos)
            };
        }

        return switch expr.expr {
            case EParenthesis(inner):
                replaceChild(expr, inner, function(next) return {expr: EParenthesis(next), pos: expr.pos});
            case EMeta(meta, inner):
                replaceChild(expr, inner, function(next) return {expr: EMeta(meta, next), pos: expr.pos});
            case EField(target, fieldName):
                replaceChild(expr, target, function(next) return {expr: EField(next, fieldName), pos: expr.pos});
            case EArray(target, index):
                replaceTwo(expr, target, index, function(a, b) return {expr: EArray(a, b), pos: expr.pos});
            case EBinop(op, left, right):
                replaceTwo(expr, left, right, function(a, b) return {expr: EBinop(op, a, b), pos: expr.pos});
            case EUnop(op, postFix, inner):
                replaceChild(expr, inner, function(next) return {expr: EUnop(op, postFix, next), pos: expr.pos});
            case ECall(target, params):
                var targetResult = replaceFirstAwait(target);
                if (targetResult != null) {
                    return {
                        future: targetResult.future,
                        expr: {expr: ECall(targetResult.expr, params), pos: expr.pos}
                    };
                }
                replaceArray(params, function(nextParams) return {expr: ECall(target, nextParams), pos: expr.pos});
            case EArrayDecl(values):
                replaceArray(values, function(nextValues) return {expr: EArrayDecl(nextValues), pos: expr.pos});
            case EObjectDecl(fields):
                for (i in 0...fields.length) {
                    var result = replaceFirstAwait(fields[i].expr);
                    if (result != null) {
                        var next = fields.copy();
                        next[i] = {
                            field: fields[i].field,
                            expr: result.expr,
                            quotes: fields[i].quotes
                        };
                        return {future: result.future, expr: {expr: EObjectDecl(next), pos: expr.pos}};
                    }
                }
                null;
            case ETernary(condition, ifTrue, ifFalse):
                replaceThree(expr, condition, ifTrue, ifFalse, function(a, b, c) return {expr: ETernary(a, b, c), pos: expr.pos});
            default:
                null;
        }
    }

    static function replaceChild(parent:Expr, child:Expr, rebuild:Expr->Expr):Null<AwaitReplacement> {
        var result = replaceFirstAwait(child);
        if (result == null) {
            return null;
        }
        return {future: result.future, expr: rebuild(result.expr)};
    }

    static function replaceTwo(parent:Expr, left:Expr, right:Expr, rebuild:(Expr, Expr)->Expr):Null<AwaitReplacement> {
        var leftResult = replaceFirstAwait(left);
        if (leftResult != null) {
            return {future: leftResult.future, expr: rebuild(leftResult.expr, right)};
        }
        var rightResult = replaceFirstAwait(right);
        if (rightResult != null) {
            return {future: rightResult.future, expr: rebuild(left, rightResult.expr)};
        }
        return null;
    }

    static function replaceThree(parent:Expr, a:Expr, b:Expr, c:Expr, rebuild:(Expr, Expr, Expr)->Expr):Null<AwaitReplacement> {
        var aResult = replaceFirstAwait(a);
        if (aResult != null) {
            return {future: aResult.future, expr: rebuild(aResult.expr, b, c)};
        }
        var bResult = replaceFirstAwait(b);
        if (bResult != null) {
            return {future: bResult.future, expr: rebuild(a, bResult.expr, c)};
        }
        var cResult = replaceFirstAwait(c);
        if (cResult != null) {
            return {future: cResult.future, expr: rebuild(a, b, cResult.expr)};
        }
        return null;
    }

    static function replaceArray(values:Array<Expr>, rebuild:Array<Expr>->Expr):Null<AwaitReplacement> {
        for (i in 0...values.length) {
            var result = replaceFirstAwait(values[i]);
            if (result != null) {
                var next = values.copy();
                next[i] = result.expr;
                return {future: result.future, expr: rebuild(next)};
            }
        }
        return null;
    }

    static function containsAwait(expr:Expr):Bool {
        return replaceFirstAwait(expr) != null;
    }

    static function isAwaitCall(expr:Expr):Bool {
        return switch expr.expr {
            case ECall(target, params):
                params.length == 1 && switch target.expr {
                    case EConst(CIdent("await")):
                        true;
                    case EField(_, "await"):
                        true;
                    default:
                        false;
                };
            default:
                false;
        }
    }

    static function isAwaitMetadata(name:String):Bool {
        return name == ":await" || name == "await";
    }

    static function getAwaitArgument(expr:Expr):Expr {
        return switch expr.expr {
            case ECall(_, params):
                params[0];
            default:
                Context.error("internal async macro error: expected await call", expr.pos);
        }
    }

    static function normalizeBody(expr:Expr):Array<Expr> {
        return switch expr.expr {
            case EBlock(statements):
                statements;
            case EReturn({expr: EBlock(statements)}):
                statements;
            case EMeta(_, {expr: EReturn({expr: EBlock(statements)})}):
                statements;
            case EReturn(_):
                [expr];
            default:
                [{expr: EReturn(expr), pos: expr.pos}];
        }
    }

    static function replaceIdentifier(expr:Expr, from:String, to:String):Expr {
        function map(e:Expr):Expr {
            return switch e.expr {
                case EConst(CIdent(name)) if (name == from):
                    ident(to, e.pos);
                case EBlock(values):
                    {expr: EBlock(values.map(map)), pos: e.pos};
                case EVars(vars):
                    var next = [
                        for (v in vars) {
                            name: v.name,
                            type: v.type,
                            expr: v.expr != null ? map(v.expr) : null,
                            isFinal: v.isFinal,
                            meta: v.meta
                        }
                    ];
                    {expr: EVars(next), pos: e.pos};
                case EReturn(value):
                    {expr: EReturn(value != null ? map(value) : null), pos: e.pos};
                case EThrow(value):
                    {expr: EThrow(map(value)), pos: e.pos};
                case EIf(condition, thenExpr, elseExpr):
                    {expr: EIf(map(condition), map(thenExpr), elseExpr != null ? map(elseExpr) : null), pos: e.pos};
                case ECall(target, params):
                    {expr: ECall(map(target), params.map(map)), pos: e.pos};
                case EFunction(kind, fn):
                    {
                        expr: EFunction(kind, {
                            args: [
                                for (arg in fn.args) {
                                    name: arg.name,
                                    opt: arg.opt,
                                    type: arg.type,
                                    value: arg.value != null ? map(arg.value) : null,
                                    meta: arg.meta
                                }
                            ],
                            ret: fn.ret,
                            expr: map(fn.expr),
                            params: fn.params
                        }),
                        pos: e.pos
                    };
                case EField(target, fieldName):
                    {expr: EField(map(target), fieldName), pos: e.pos};
                case EArray(target, index):
                    {expr: EArray(map(target), map(index)), pos: e.pos};
                case EBinop(op, left, right):
                    {expr: EBinop(op, map(left), map(right)), pos: e.pos};
                case EUnop(op, postFix, inner):
                    {expr: EUnop(op, postFix, map(inner)), pos: e.pos};
                case EParenthesis(inner):
                    {expr: EParenthesis(map(inner)), pos: e.pos};
                case EMeta(meta, inner):
                    {expr: EMeta(meta, map(inner)), pos: e.pos};
                case EArrayDecl(values):
                    {expr: EArrayDecl(values.map(map)), pos: e.pos};
                case EObjectDecl(fields):
                    {
                        expr: EObjectDecl([
                            for (field in fields) {
                                field: field.field,
                                expr: map(field.expr),
                                quotes: field.quotes
                            }
                        ]),
                        pos: e.pos
                    };
                case ETernary(condition, ifTrue, ifFalse):
                    {expr: ETernary(map(condition), map(ifTrue), map(ifFalse)), pos: e.pos};
                default:
                    e;
            }
        }
        return map(expr);
    }

    static function makeFunction(args:Array<FunctionArg>, body:Expr, pos:Position):Expr {
        return {
            expr: EFunction(null, {
                args: args,
                ret: null,
                expr: body,
                params: []
            }),
            pos: pos
        };
    }

    static function varDecl(name:String, value:Expr, pos:Position):Expr {
        return varDecls([{name: name, type: null, expr: value}], pos);
    }

    static function varDecls(vars:Array<Var>, pos:Position):Expr {
        return {
            expr: EVars(vars),
            pos: pos
        };
    }

    static function block(exprs:Array<Expr>, pos:Position):Expr {
        return {
            expr: EBlock(exprs),
            pos: pos
        };
    }

    static function ident(name:String, pos:Position):Expr {
        return {
            expr: EConst(CIdent(name)),
            pos: pos
        };
    }

    static function field(target:Expr, name:String, pos:Position):Expr {
        return {
            expr: EField(target, name),
            pos: pos
        };
    }

    static function callIdent(name:String, args:Array<Expr>, pos:Position):Expr {
        return {
            expr: ECall(ident(name, pos), args),
            pos: pos
        };
    }

    static function unique(prefix:String):String {
        return prefix + "_" + counter++;
    }
}
#end
