package app;

import bevy.app.App;
import bevy.app.AppError;
import bevy.app.AppError.AppErrorKind;
import bevy.app.MainSchedule;
import bevy.app.SystemConfig.SystemConfigBuilder;
import bevy.app.SystemConfig.SystemSetConfigBuilder;
import bevy.app.SystemClass;
import bevy.app.SystemRegistry;
import bevy.asset.Asset;
import bevy.asset.Handle;
import bevy.async.AsyncClass;
import bevy.async.AsyncRuntime;
import bevy.async.Future;
import bevy.ecs.All;
import bevy.ecs.Added;
import bevy.ecs.Changed;
import bevy.ecs.Commands;
import bevy.ecs.Component;
import bevy.ecs.Event;
import bevy.ecs.Events.EventReader;
import bevy.ecs.Events.EventWriter;
import bevy.ecs.Or;
import bevy.ecs.Query;
import bevy.ecs.Query.Query2;
import bevy.ecs.Query.Query3;
import bevy.ecs.Tuple.Tuple1;
import bevy.ecs.Tuple.Tuple2;
import bevy.ecs.Tuple.Tuple3;
import bevy.ecs.Tuple.Tuple4;
import bevy.ecs.Tuple.Tuple5;
import bevy.ecs.Tuple.Tuple10;
import bevy.ecs.Tuple.Tuple15;
import bevy.ecs.Tuple.Tuple;
import bevy.ecs.Res;
import bevy.ecs.ResMut;
import bevy.ecs.Resource;
import bevy.ecs.With;
import bevy.ecs.Without;
import bevy.ecs.World;

class AppScheduleTest {
    static function main():Void {
        testRegisteredSystemOrdering();
        testRunIfConditions();
        testSetOrderingAndConditions();
        testRuntimeBuilders();
        testScheduleTypedErrors();

        var app = new App();
        app.world.insertResource(new Counter());
        app.world.insertResource(new ChangeStep(0));
        app.world.spawn([
            new AppPosition(1),
            new AppVelocity(2),
            new AppHealth(12),
            new AppArmor(20),
            new AppStatA(3),
            new AppStatB(4),
            new AppStatC(5),
            new AppStatD(6),
            new AppStatE(7),
            new AppStatF(8),
            new AppStatG(9),
            new AppStatH(10),
            new AppStatI(11),
            new AppStatJ(13),
            new AppTag()
        ]);
        app.world.spawn([new AppPosition(5)]);
        var handleAKey = bevy.ecs.TypeKey.ofParameterizedClass(Handle, [cast AppAssetA]);
        var handleBKey = bevy.ecs.TypeKey.ofParameterizedClass(Handle, [cast AppAssetB]);
        app.world.spawn([
            new Handle<AppAssetA>(101, handleAKey),
            new Handle<AppAssetB>(201, handleBKey),
            new HandleProbeTag()
        ]);
        app.world.spawn([
            new Handle<AppAssetA>(102, handleAKey),
            new HandleProbeTag()
        ]);
        app.world.initEvents(AppSignal);
        app.addRegisteredSystems(MainSchedule.Update);

        var firstDone = false;
        app.update().handle(function(_) {
            firstDone = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        var secondDone = false;
        app.update().handle(function(_) {
            secondDone = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(firstDone, "first update future should resolve");
        assert(secondDone, "second update future should resolve");
        assertEq(16, app.world.getResource(Counter).value, "sync and async systems should run in order across two updates");
        assertEq("sync", app.world.getResource(CommandFlag).value, "sync command should apply");
        assertEq(9, app.world.getResource(AsyncValue).value, "async system should persist awaited value");
        assertEq(9, app.world.getResource(AsyncCommandFlag).value, "sync command should apply async result");
        assertEq(16, app.world.getResource(ReadBack).value, "Res param should read resource");
        assertEq(3, app.world.getResource(QueryTotal).value, "Query2 param should read components");
        assertEq(1, app.world.getResource(QueryPairFilterCount).value, "Query2<DataA, DataB, Filter> param should respect filter type");
        assertEq(1, app.world.getResource(QueryEntityPairCount).value, "Query2<Entity, Data> param should inject mixed entity/component queries");
        assertEq(3, app.world.getResource(QueryTuplePairTotal).value, "Query<Tuple2<DataA, DataB>> should inject tuple query data");
        assertEq(6, app.world.getResource(QueryTupleOneTotal).value, "Query<Tuple1<DataA>> should inject one-item tuple query data");
        assertEq(1, app.world.getResource(QueryTupleHandlePairCount).value, "Query<Tuple2<Handle<A>, Handle<B>>> should inject generic tuple query data");
        assertEq(302, app.world.getResource(QueryTupleHandlePairIdTotal).value, "Query<Tuple2<Handle<A>, Handle<B>>> should preserve typed handle ids");
        assertEq(1, app.world.getResource(QueryTupleHandleFilterCount).value, "Query<Tuple..., With<Handle<B>>> should honor generic filter keys");
        assertEq(3, app.world.getResource(QueryTripleTotal).value, "Query3 param should read three-component tuples");
        assertEq(1, app.world.getResource(QueryTripleFilterCount).value, "Query3<DataA, DataB, DataC, Filter> param should respect filter type");
        assertEq(1, app.world.getResource(QueryEntityTripleCount).value, "Query3<Entity, DataA, DataB> param should inject mixed entity/component queries");
        assertEq(1, app.world.getResource(QueryTupleTripleFilterCount).value, "Query<Tuple3<DataA, DataB, DataC>, Filter> should respect tuple query filters");
        assertEq(15, app.world.getResource(QueryTupleFourTotal).value, "Query<Tuple4<...>> should inject four-item tuple query data");
        assertEq(35, app.world.getResource(QueryTupleFiveTotal).value, "Query<Tuple5<...>> should inject five-item tuple query data");
        assertEq(60, app.world.getResource(QueryTupleTenTotal).value, "Query<Tuple10<...>> should inject higher-arity tuple query data");
        assertEq(111, app.world.getResource(QueryTupleFifteenTotal).value, "Query<Tuple15<...>> should inject fifteen-item tuple query data");
        assertEq(3, app.world.getResource(QueryTupleGenericTotal).value, "Query<Tuple<...>> should inject tuple query data without fixed-arity type names");
        assertEq(1, app.world.getResource(QueryTupleGenericEntityPairCount).value, "Query<Tuple<Entity, Data>, Filter> should inject mixed generic tuple data");
        assertEq(1, app.world.getResource(QueryTupleGenericFilterCount).value, "Query<Tuple<...>, With<T>> should honor generic tuple query filters");
        assertEq(1, app.world.getResource(QueryTupleGenericAddedFirst).value, "Query<Tuple<...>, Added<T>> should see first-run additions");
        var tupleGenericAddedSecond = app.world.getResource(QueryTupleGenericAddedSecond);
        assertEq(0, tupleGenericAddedSecond == null ? 0 : tupleGenericAddedSecond.value, "Query<Tuple<...>, Added<T>> should stop matching after first run");
        assertEq(1, app.world.getResource(QueryTupleGenericChangedFirst).value, "Query<Tuple<...>, Changed<T>> should include startup inserts on first run");
        assertEq(1, app.world.getResource(QueryTupleGenericChangedSecond).value, "Query<Tuple<...>, Changed<T>> should include later tuple component mutations");
        assertEq(1, app.world.getResource(QueryTupleGenericCompositeOrCount).value, "Query<Tuple<...>, Or<...>> should compose generic tuple filters at runtime");
        assertEq(0, app.world.getResource(QueryTupleGenericCompositeAllCount).value, "Query<Tuple<...>, All<...>> should compose generic tuple filters at runtime");
        assertEq(1, app.world.getResource(QueryTupleGenericAddedCompositeOrFirst).value, "Query<Tuple<...>, Or<Added<T>, ...>> should include startup additions on first run");
        assertEq(0, app.world.getResource(QueryTupleGenericAddedCompositeOrSecond).value, "Query<Tuple<...>, Or<Added<T>, ...>> should stop matching once additions are stale");
        assertEq(1, app.world.getResource(QueryTupleGenericChangedCompositeOrFirst).value, "Query<Tuple<...>, Or<Changed<T>, ...>> should include startup inserts on first run");
        assertEq(1, app.world.getResource(QueryTupleGenericChangedCompositeOrSecond).value, "Query<Tuple<...>, Or<Changed<T>, ...>> should include later tuple component mutations");
        assertEq(1, app.world.getResource(QueryTupleGenericHandlePairCount).value, "Query<Tuple<Handle<A>, Handle<B>>> should inject generic tuple data");
        assertEq(302, app.world.getResource(QueryTupleGenericHandlePairIdTotal).value, "Query<Tuple<Handle<A>, Handle<B>>> should preserve parameterized handle ids");
        assertEq(1, app.world.getResource(QueryTupleGenericHandleFilterCount).value, "Query<Tuple<...>, With<Handle<B>>> should honor generic handle filter keys");
        assertEq(1, app.world.getResource(QueryTupleCompositeOrCount).value, "Query<Tuple..., Or<...>> should compose tuple-query filters at runtime");
        assertEq(0, app.world.getResource(QueryTupleCompositeAllCount).value, "Query<Tuple..., All<...>> should compose tuple-query filters at runtime");
        assertEq(1, app.world.getResource(QueryTupleAddedFirst).value, "Query<Tuple..., Added<T>> should see first-run additions");
        var tupleAddedSecond = app.world.getResource(QueryTupleAddedSecond);
        assertEq(0, tupleAddedSecond == null ? 0 : tupleAddedSecond.value, "Query<Tuple..., Added<T>> should stop matching after first run");
        assertEq(1, app.world.getResource(QueryTupleAddedCompositeOrFirst).value, "Query<Tuple..., Or<Added<T>, ...>> should include startup additions on first run");
        assertEq(0, app.world.getResource(QueryTupleAddedCompositeOrSecond).value, "Query<Tuple..., Or<Added<T>, ...>> should stop matching once additions are stale");
        assertEq(1, app.world.getResource(QueryTupleChangedFirst).value, "Query<Tuple..., Changed<T>> should include startup inserts on first run");
        assertEq(1, app.world.getResource(QueryTupleChangedSecond).value, "Query<Tuple..., Changed<T>> should include later tuple component mutations");
        assertEq(1, app.world.getResource(QueryTupleChangedCompositeOrFirst).value, "Query<Tuple..., Or<Changed<T>, ...>> should include startup inserts on first run");
        assertEq(1, app.world.getResource(QueryTupleChangedCompositeOrSecond).value, "Query<Tuple..., Or<Changed<T>, ...>> should include later tuple component mutations");
        assertEq(1, app.world.getResource(FilterCount).value, "Query<Data, Filter> param should respect filter type");
        assertEq(1, app.world.getResource(TaggedEntityCount).value, "Query<Entity, Filter> param should inject entity-only queries");
        assertEq(2, app.world.getResource(OrFilterCount).value, "Query<Data, Or<...>> param should compose filters");
        assertEq(1, app.world.getResource(AddedCountFirst).value, "Query<Data, Added<T>> param should see first-run additions");
        assertEq(0, app.world.getResource(AddedCountSecond).value, "Query<Data, Added<T>> param should stop matching after first run");
        assertEq(2, app.world.getResource(ChangedCountFirst).value, "Changed<T> should include startup inserts on first run");
        assertEq(1, app.world.getResource(ChangedCountSecond).value, "Changed<T> should match data mutated after last run");
        assertEq("received", app.world.getResource(EventStatus).value, "events should flow through systems");
        trace("AppScheduleTest ok");
    }

    static function testRegisteredSystemOrdering():Void {
        var app = new App();
        app.world.insertResource(new OrderTrace());
        app.addRegisteredSystems(MainSchedule.PostUpdate);

        var done = false;
        app.runSchedule(MainSchedule.PostUpdate).handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "ordered schedule should resolve");
        assertEq("first,middle,last", app.world.getResource(OrderTrace).values.join(","), "before/after metadata should reorder registered systems");
    }

    static function testRunIfConditions():Void {
        var app = new App();
        app.world.insertResource(new RunIfTrace());
        app.world.insertResource(new RunIfState(true, false));
        app.world.spawn([new AppPosition(3), new AppTag()]);
        app.addRegisteredSystems(MainSchedule.First);

        var done = false;
        app.runSchedule(MainSchedule.First).handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "run_if schedule should resolve");
        assertEq("sync,query", app.world.getResource(RunIfTrace).values.join(","), "run_if should gate systems by sync, async, and query-backed conditions");
    }

    static function testSetOrderingAndConditions():Void {
        var app = new App();
        app.world.insertResource(new SetTrace());
        app.world.insertResource(new SetGate(true, false));
        app.addRegisteredSystems(MainSchedule.Last);

        var firstDone = false;
        app.runSchedule(MainSchedule.Last).handle(function(_) {
            firstDone = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(firstDone, "set-based schedule should resolve");
        assertEq("alpha", app.world.getResource(SetTrace).values.join(","), "set run_if should block disabled set and set ordering should keep alpha first");

        app.world.getResource(SetGate).betaEnabled = true;
        app.world.insertResource(new SetTrace());

        var secondDone = false;
        app.runSchedule(MainSchedule.Last).handle(function(_) {
            secondDone = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(secondDone, "set-based schedule second pass should resolve");
        assertEq("alpha,beta", app.world.getResource(SetTrace).values.join(","), "set before/after and setRunIf should control grouped systems");
    }

    static function testRuntimeBuilders():Void {
        var app = new App();
        app.world.insertResource(new BuilderTrace());
        app.world.insertResource(new BuilderGate(true, false));

        app.configureSet(MainSchedule.Startup, SystemSetConfigBuilder.named("builder_alpha"));
        app.configureSet(MainSchedule.Startup, SystemSetConfigBuilder.named("builder_beta").after("builder_alpha").runIf(function(world) {
            return world.getResource(BuilderGate).betaEnabled;
        }));

        app.addSystemConfig(MainSchedule.Startup, SystemConfigBuilder.named("builder.first", function(world) {
            world.getResource(BuilderTrace).push("first");
            return null;
        }).inSet("builder_alpha"));

        app.addSystemConfig(MainSchedule.Startup, SystemConfigBuilder.named("builder.second", function(world) {
            world.getResource(BuilderTrace).push("second");
            return null;
        }).inSet("builder_beta"));

        app.addSystemConfig(MainSchedule.Startup, SystemConfigBuilder.named("builder.third", function(world) {
            world.getResource(BuilderTrace).push("third");
            return null;
        }).after("builder.first"));

        var done = false;
        app.runSchedule(MainSchedule.Startup).handle(function(_) {
            done = true;
        }, function(error) throw error);
        AsyncRuntime.flush();

        assert(done, "runtime builder schedule should resolve");
        assertEq("first,third", app.world.getResource(BuilderTrace).values.join(","), "runtime system/set builders should enforce ordering and conditions");
    }

    static function testScheduleTypedErrors():Void {
        testScheduleOrderingCycleError();
        testScheduleOrderingMissingTargetError();
        testScheduleSetEmptyNameError();
        testScheduleSetHasNoSystemsError();
        testScheduleRunIfNotBoolError();
    }

    static function testScheduleOrderingCycleError():Void {
        var app = new App();
        app.addSystemConfig(MainSchedule.PreUpdate, SystemConfigBuilder.named("cycle.a", function(_) return null).after("cycle.b"));
        app.addSystemConfig(MainSchedule.PreUpdate, SystemConfigBuilder.named("cycle.b", function(_) return null).after("cycle.a"));

        var typedError:AppError = null;
        try {
            app.runSchedule(MainSchedule.PreUpdate);
        } catch (error:AppError) {
            typedError = error;
        }
        assert(typedError != null, "cycle should throw typed schedule error");
        switch typedError.kind {
            case ScheduleOrderingCycle(scheduleLabel):
                assertEq(MainSchedule.PreUpdate, scheduleLabel, "cycle error should keep schedule label");
            default:
                throw "unexpected cycle typed error kind";
        }
    }

    static function testScheduleOrderingMissingTargetError():Void {
        var app = new App();
        app.addSystemConfig(MainSchedule.PreUpdate, SystemConfigBuilder.named("missing.target", function(_) return null).after("missing.other"));
        app.addSystemConfig(MainSchedule.PreUpdate, SystemConfigBuilder.named("missing.anchor", function(_) return null));

        var typedError:AppError = null;
        try {
            app.runSchedule(MainSchedule.PreUpdate);
        } catch (error:AppError) {
            typedError = error;
        }
        assert(typedError != null, "missing ordering target should throw typed schedule error");
        switch typedError.kind {
            case ScheduleOrderingSourceMissing(scheduleLabel, source):
                assertEq(MainSchedule.PreUpdate, scheduleLabel, "missing-target error should keep schedule label");
                assertEq("missing.other", source, "missing-target error should keep missing system name");
            default:
                throw "unexpected missing-target typed error kind";
        }
    }

    static function testScheduleSetEmptyNameError():Void {
        var app = new App();
        var typedError:AppError = null;
        try {
            app.configureSet(MainSchedule.Update, SystemSetConfigBuilder.named(""));
        } catch (error:AppError) {
            typedError = error;
        }
        assert(typedError != null, "empty set name should throw typed schedule error");
        switch typedError.kind {
            case ScheduleSetEmptyName(scheduleLabel):
                assertEq(MainSchedule.Update, scheduleLabel, "empty-name error should keep schedule label");
            default:
                throw "unexpected empty-set typed error kind";
        }
    }

    static function testScheduleSetHasNoSystemsError():Void {
        var app = new App();
        app.configureSet(MainSchedule.Update, SystemSetConfigBuilder.named("lonely_set").after("other_set"));
        app.configureSet(MainSchedule.Update, SystemSetConfigBuilder.named("other_set"));
        app.addSystemConfig(MainSchedule.Update, SystemConfigBuilder.named("set.guard.a", function(_) return null));
        app.addSystemConfig(MainSchedule.Update, SystemConfigBuilder.named("set.guard.b", function(_) return null));

        var typedError:AppError = null;
        try {
            app.runSchedule(MainSchedule.Update);
        } catch (error:AppError) {
            typedError = error;
        }
        assert(typedError != null, "set without members should throw typed schedule error");
        switch typedError.kind {
            case ScheduleSetHasNoSystems(scheduleLabel, setName):
                assertEq(MainSchedule.Update, scheduleLabel, "set-has-no-systems error should keep schedule label");
                assertEq("lonely_set", setName, "set-has-no-systems error should keep set name");
            default:
                throw "unexpected set-has-no-systems typed error kind";
        }
    }

    static function testScheduleRunIfNotBoolError():Void {
        var app = new App();
        app.addSystemConfig(MainSchedule.First, SystemConfigBuilder.named("bad.run_if", function(_) return null).runIf(function(_) return 1));

        var typedError:AppError = null;
        app.runSchedule(MainSchedule.First).handle(function(_) {
            throw "run_if non-bool should not resolve successfully";
        }, function(error) {
            if (Std.isOfType(error, AppError)) {
                typedError = cast error;
                return;
            }
            throw error;
        });
        AsyncRuntime.flush();

        assert(typedError != null, "run_if non-bool should reject with typed schedule error");
        switch typedError.kind {
            case ScheduleRunIfNotBool(scheduleLabel):
                assertEq(MainSchedule.First, scheduleLabel, "run_if-not-bool error should keep schedule label");
            default:
                throw "unexpected run_if-not-bool typed error kind";
        }
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

class Counter implements Resource {
    public var value:Int = 0;
    public function new() {}
}

class CommandFlag implements Resource {
    public var value:String;
    public function new(value:String) {
        this.value = value;
    }
}

class AsyncCommandFlag implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AsyncValue implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AsyncCounterDelta implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class ReadBack implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryPairFilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryEntityPairCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTuplePairTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleOneTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleHandlePairCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleHandlePairIdTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleHandleFilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTripleFilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryEntityTripleCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleTripleFilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleFourTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleFiveTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleTenTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleFifteenTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericEntityPairCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericFilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericAddedFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericAddedSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericChangedFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericChangedSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericCompositeOrCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericCompositeAllCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericAddedCompositeOrFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericAddedCompositeOrSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericChangedCompositeOrFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericChangedCompositeOrSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericHandlePairCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericHandlePairIdTotal implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleGenericHandleFilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleCompositeOrCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleCompositeAllCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAddedFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAddedSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAddedCompositeOrFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleAddedCompositeOrSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleChangedFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleChangedSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleChangedCompositeOrFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class QueryTupleChangedCompositeOrSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}


class FilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class TaggedEntityCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class OrFilterCount implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AddedCountFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AddedCountSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class ChangedCountFirst implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class ChangedCountSecond implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class EventStatus implements Resource {
    public var value:String;
    public function new(value:String) {
        this.value = value;
    }
}

class OrderTrace implements Resource {
    public var values:Array<String>;

    public function new() {
        values = [];
    }

    public function push(value:String):Void {
        values.push(value);
    }
}

class RunIfTrace implements Resource {
    public var values:Array<String>;

    public function new() {
        values = [];
    }

    public function push(value:String):Void {
        values.push(value);
    }
}

class RunIfState implements Resource {
    public var syncEnabled:Bool;
    public var asyncEnabled:Bool;

    public function new(syncEnabled:Bool, asyncEnabled:Bool) {
        this.syncEnabled = syncEnabled;
        this.asyncEnabled = asyncEnabled;
    }
}

class SetTrace implements Resource {
    public var values:Array<String>;

    public function new() {
        values = [];
    }

    public function push(value:String):Void {
        values.push(value);
    }
}

class SetGate implements Resource {
    public var alphaEnabled:Bool;
    public var betaEnabled:Bool;

    public function new(alphaEnabled:Bool, betaEnabled:Bool) {
        this.alphaEnabled = alphaEnabled;
        this.betaEnabled = betaEnabled;
    }
}

class BuilderTrace implements Resource {
    public var values:Array<String>;

    public function new() {
        values = [];
    }

    public function push(value:String):Void {
        values.push(value);
    }
}

class BuilderGate implements Resource {
    public var alphaEnabled:Bool;
    public var betaEnabled:Bool;

    public function new(alphaEnabled:Bool, betaEnabled:Bool) {
        this.alphaEnabled = alphaEnabled;
        this.betaEnabled = betaEnabled;
    }
}

class AppPosition implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppVelocity implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppTag implements Component {
    public function new() {}
}

class HandleProbeTag implements Component {
    public function new() {}
}

class AppHealth implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppArmor implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppStatA implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppStatB implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppStatC implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppStatD implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppStatE implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppStatF implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppStatG implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppStatH implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppStatI implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppStatJ implements Component {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class AppSignal implements Event {
    public var value:String;
    public function new(value:String) {
        this.value = value;
    }
}

class AppAssetA implements Asset {
    public function new() {}
}

class AppAssetB implements Asset {
    public function new() {}
}

class ChangeStep implements Resource {
    public var value:Int;
    public function new(value:Int) {
        this.value = value;
    }
}

class CounterSystems implements SystemClass implements AsyncClass {
    @:system("Last")
    @:inSet("alpha")
    @:setRunIf("app.CounterSetConditions.allowAlpha")
    public static function setAlpha(trace:ResMut<SetTrace>):Void {
        trace.value.push("alpha");
    }

    @:system("Last")
    @:inSet("beta")
    @:setAfter("alpha")
    @:setRunIf("app.CounterSetConditions.allowBeta")
    public static function setBeta(trace:ResMut<SetTrace>):Void {
        trace.value.push("beta");
    }

    @:system("First")
    @:runIf("app.CounterConditions.allowSync")
    public static function gatedSync(trace:ResMut<RunIfTrace>):Void {
        trace.value.push("sync");
    }

    @:system("First")
    @:runIf("app.CounterConditions.allowAsync")
    public static function gatedAsync(trace:ResMut<RunIfTrace>):Void {
        trace.value.push("async");
    }

    @:system("First")
    @:runIf("app.CounterConditions.hasTaggedPosition")
    public static function gatedQuery(trace:ResMut<RunIfTrace>):Void {
        trace.value.push("query");
    }

    @:system("PostUpdate")
    @:before("app.CounterSystems.orderedMiddle")
    public static function orderedFirst(trace:ResMut<OrderTrace>):Void {
        trace.value.push("first");
    }

    @:system("PostUpdate")
    @:after("app.CounterSystems.orderedFirst")
    @:before("app.CounterSystems.orderedLast")
    public static function orderedMiddle(trace:ResMut<OrderTrace>):Void {
        trace.value.push("middle");
    }

    @:system("PostUpdate")
    @:after("app.CounterSystems.orderedMiddle")
    public static function orderedLast(trace:ResMut<OrderTrace>):Void {
        trace.value.push("last");
    }

    @:system("Update")
    public static function addOne(counter:ResMut<Counter>):Void {
        counter.value.value += 1;
    }

    @:async
    @:system("Update")
    public static function addAsync(world:World) {
        var value = @await Future.resolved(7);
        world.insertResource(new AsyncCounterDelta(value));
    }

    @:system("Update")
    public static function commandFlag(commands:Commands):Void {
        commands.insertResource(new CommandFlag("sync"));
    }

    @:async
    @:system("Update")
    public static function asyncValue(world:World) {
        var value = @await Future.resolved(9);
        world.insertResource(new AsyncValue(value));
    }

    @:system("Update")
    public static function storeAsyncValue(value:Res<AsyncValue>, commands:Commands):Void {
        if (value != null) {
            commands.insertResource(new AsyncCommandFlag(value.value.value));
        }
    }

    @:system("Update")
    @:after("app.CounterSystems.applyAsyncCounterDelta")
    public static function readBack(counter:Res<Counter>, commands:Commands):Void {
        commands.insertResource(new ReadBack(counter.value.value));
    }

    @:system("Update")
    public static function querySystem(query:Query2<AppPosition, AppVelocity>, commands:Commands):Void {
        var total = 0;
        for (item in query.toArray()) {
            total += item.a.value + item.b.value;
        }
        commands.insertResource(new QueryTotal(total));
    }

    @:system("Update")
    public static function filteredPairQuerySystem(query:Query2<AppPosition, AppVelocity, With<AppTag>>, commands:Commands):Void {
        commands.insertResource(new QueryPairFilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function entityPairQuerySystem(query:Query2<bevy.ecs.Entity, AppPosition, With<AppTag>>, commands:Commands):Void {
        var count = 0;
        for (item in query.toArray()) {
            if (item.entity.index == item.a.index && item.b.value > 0) {
                count++;
            }
        }
        commands.insertResource(new QueryEntityPairCount(count));
    }

    @:system("Update")
    public static function tuplePairQuerySystem(query:Query<Tuple2<AppPosition, AppVelocity>>, commands:Commands):Void {
        var total = 0;
        for (item in query.toArray()) {
            total += item.component._0.value + item.component._1.value;
        }
        commands.insertResource(new QueryTuplePairTotal(total));
    }

    @:system("Update")
    public static function tupleOneQuerySystem(query:Query<Tuple1<AppPosition>>, commands:Commands):Void {
        var total = 0;
        for (item in query.toArray()) {
            total += item.component._0.value;
        }
        commands.insertResource(new QueryTupleOneTotal(total));
    }

    @:system("Update")
    public static function tupleGenericHandlePairQuerySystem(query:Query<Tuple2<Handle<AppAssetA>, Handle<AppAssetB>>, With<HandleProbeTag>>, commands:Commands):Void {
        var count = 0;
        var total = 0;
        for (item in query.toArray()) {
            count++;
            total += item.component._0.id + item.component._1.id;
        }
        commands.insertResource(new QueryTupleHandlePairCount(count));
        commands.insertResource(new QueryTupleHandlePairIdTotal(total));
    }

    @:system("Update")
    public static function tupleGenericHandleFilterQuerySystem(query:Query<Tuple2<Handle<AppAssetA>, HandleProbeTag>, With<Handle<AppAssetB>>>, commands:Commands):Void {
        commands.insertResource(new QueryTupleHandleFilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function tripleQuerySystem(query:Query3<AppPosition, AppVelocity, AppTag>, commands:Commands):Void {
        commands.insertResource(new QueryTripleTotal(query.toArray().length * 3));
    }

    @:system("Update")
    public static function filteredTripleQuerySystem(query:Query3<AppPosition, AppVelocity, AppTag, With<AppTag>>, commands:Commands):Void {
        commands.insertResource(new QueryTripleFilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function entityTripleQuerySystem(query:Query3<bevy.ecs.Entity, AppPosition, AppVelocity, With<AppTag>>, commands:Commands):Void {
        var count = 0;
        for (item in query.toArray()) {
            if (item.entity.index == item.a.index && item.b.value > 0 && item.c.value > 0) {
                count++;
            }
        }
        commands.insertResource(new QueryEntityTripleCount(count));
    }

    @:system("Update")
    public static function tupleTripleFilteredQuerySystem(query:Query<Tuple3<bevy.ecs.Entity, AppPosition, AppVelocity>, With<AppTag>>, commands:Commands):Void {
        var count = 0;
        for (item in query.toArray()) {
            if (item.entity.index == item.component._0.index && item.component._1.value > 0 && item.component._2.value > 0) {
                count++;
            }
        }
        commands.insertResource(new QueryTupleTripleFilterCount(count));
    }

    @:system("Update")
    public static function tupleFourQuerySystem(query:Query<Tuple4<bevy.ecs.Entity, AppPosition, AppVelocity, AppHealth>, With<AppTag>>, commands:Commands):Void {
        var total = 0;
        for (item in query.toArray()) {
            var tuple = item.component;
            if (item.entity.index == tuple._0.index) {
                total += tuple._1.value + tuple._2.value + tuple._3.value;
            }
        }
        commands.insertResource(new QueryTupleFourTotal(total));
    }

    @:system("Update")
    public static function tupleFiveQuerySystem(query:Query<Tuple5<bevy.ecs.Entity, AppPosition, AppVelocity, AppHealth, AppArmor>, With<AppTag>>, commands:Commands):Void {
        var total = 0;
        for (item in query.toArray()) {
            var tuple = item.component;
            if (item.entity.index == tuple._0.index) {
                total += tuple._1.value + tuple._2.value + tuple._3.value + tuple._4.value;
            }
        }
        commands.insertResource(new QueryTupleFiveTotal(total));
    }

    @:system("Update")
    public static function tupleTenQuerySystem(query:Query<Tuple10<bevy.ecs.Entity, AppPosition, AppVelocity, AppHealth, AppArmor, AppStatA, AppStatB, AppStatC, AppStatD, AppStatE>, With<AppTag>>, commands:Commands):Void {
        var total = 0;
        for (item in query.toArray()) {
            var tuple = item.component;
            if (item.entity.index == tuple._0.index) {
                total += tuple._1.value
                    + tuple._2.value
                    + tuple._3.value
                    + tuple._4.value
                    + tuple._5.value
                    + tuple._6.value
                    + tuple._7.value
                    + tuple._8.value
                    + tuple._9.value;
            }
        }
        commands.insertResource(new QueryTupleTenTotal(total));
    }

    @:system("Update")
    public static function tupleFifteenQuerySystem(query:Query<Tuple15<bevy.ecs.Entity, AppPosition, AppVelocity, AppHealth, AppArmor, AppStatA, AppStatB, AppStatC, AppStatD, AppStatE, AppStatF, AppStatG, AppStatH, AppStatI, AppStatJ>, With<AppTag>>, commands:Commands):Void {
        var total = 0;
        for (item in query.toArray()) {
            var tuple = item.component;
            if (item.entity.index == tuple._0.index) {
                total += tuple._1.value
                    + tuple._2.value
                    + tuple._3.value
                    + tuple._4.value
                    + tuple._5.value
                    + tuple._6.value
                    + tuple._7.value
                    + tuple._8.value
                    + tuple._9.value
                    + tuple._10.value
                    + tuple._11.value
                    + tuple._12.value
                    + tuple._13.value
                    + tuple._14.value;
            }
        }
        commands.insertResource(new QueryTupleFifteenTotal(total));
    }

    @:system("Update")
    public static function tupleGenericQuerySystem(query:Query<Tuple<AppPosition, AppVelocity>>, commands:Commands):Void {
        var total = 0;
        for (item in query.toArray()) {
            total += item.component._0.value + item.component._1.value;
        }
        commands.insertResource(new QueryTupleGenericTotal(total));
    }

    @:system("Update")
    public static function tupleGenericEntityPairQuerySystem(query:Query<Tuple<bevy.ecs.Entity, AppPosition>, With<AppTag>>, commands:Commands):Void {
        var count = 0;
        for (item in query.toArray()) {
            if (item.entity.index == item.component._0.index && item.component._1.value > 0) {
                count++;
            }
        }
        commands.insertResource(new QueryTupleGenericEntityPairCount(count));
    }

    @:system("Update")
    public static function tupleGenericFilteredQuerySystem(query:Query<Tuple<AppPosition, AppVelocity>, With<AppTag>>, commands:Commands):Void {
        commands.insertResource(new QueryTupleGenericFilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function tupleGenericAddedQuerySystem(query:Query<Tuple<AppPosition, AppVelocity>, Added<AppTag>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value == 0) {
            commands.insertResource(new QueryTupleGenericAddedFirst(count));
        } else {
            commands.insertResource(new QueryTupleGenericAddedSecond(count));
        }
    }

    @:system("Update")
    @:after("app.CounterSystems.mutateTrackedPosition")
    public static function tupleGenericChangedQuerySystem(query:Query<Tuple<AppPosition, AppVelocity>, Changed<AppPosition>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value <= 1) {
            commands.insertResource(new QueryTupleGenericChangedFirst(count));
        } else {
            commands.insertResource(new QueryTupleGenericChangedSecond(count));
        }
    }

    @:system("Update")
    public static function tupleGenericCompositeOrQuerySystem(query:Query<Tuple<AppPosition, AppVelocity>, Or<With<AppTag>, Without<AppHealth>>>, commands:Commands):Void {
        commands.insertResource(new QueryTupleGenericCompositeOrCount(query.toArray().length));
    }

    @:system("Update")
    public static function tupleGenericCompositeAllQuerySystem(query:Query<Tuple<AppPosition, AppVelocity>, All<Without<AppTag>, Without<AppHealth>>>, commands:Commands):Void {
        commands.insertResource(new QueryTupleGenericCompositeAllCount(query.toArray().length));
    }

    @:system("Update")
    public static function tupleGenericAddedCompositeOrQuerySystem(query:Query<Tuple<AppPosition, AppVelocity>, Or<Added<AppTag>, Without<AppHealth>>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value == 0) {
            commands.insertResource(new QueryTupleGenericAddedCompositeOrFirst(count));
        } else {
            commands.insertResource(new QueryTupleGenericAddedCompositeOrSecond(count));
        }
    }

    @:system("Update")
    @:after("app.CounterSystems.mutateTrackedPosition")
    public static function tupleGenericChangedCompositeOrQuerySystem(query:Query<Tuple<AppPosition, AppVelocity>, Or<Changed<AppPosition>, Without<AppHealth>>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value <= 1) {
            commands.insertResource(new QueryTupleGenericChangedCompositeOrFirst(count));
        } else {
            commands.insertResource(new QueryTupleGenericChangedCompositeOrSecond(count));
        }
    }

    @:system("Update")
    public static function tupleUniversalHandlePairQuerySystem(query:Query<Tuple<Handle<AppAssetA>, Handle<AppAssetB>>, With<HandleProbeTag>>, commands:Commands):Void {
        var count = 0;
        var total = 0;
        for (item in query.toArray()) {
            count++;
            total += item.component._0.id + item.component._1.id;
        }
        commands.insertResource(new QueryTupleGenericHandlePairCount(count));
        commands.insertResource(new QueryTupleGenericHandlePairIdTotal(total));
    }

    @:system("Update")
    public static function tupleUniversalHandleFilterQuerySystem(query:Query<Tuple<Handle<AppAssetA>, HandleProbeTag>, With<Handle<AppAssetB>>>, commands:Commands):Void {
        commands.insertResource(new QueryTupleGenericHandleFilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function tupleCompositeOrQuerySystem(query:Query<Tuple2<AppPosition, AppVelocity>, Or<With<AppTag>, Without<AppHealth>>>, commands:Commands):Void {
        commands.insertResource(new QueryTupleCompositeOrCount(query.toArray().length));
    }

    @:system("Update")
    public static function tupleCompositeAllQuerySystem(query:Query<Tuple2<AppPosition, AppVelocity>, All<Without<AppTag>, Without<AppHealth>>>, commands:Commands):Void {
        commands.insertResource(new QueryTupleCompositeAllCount(query.toArray().length));
    }

    @:system("Update")
    public static function tupleAddedQuerySystem(query:Query<Tuple2<AppPosition, AppVelocity>, Added<AppTag>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value == 0) {
            commands.insertResource(new QueryTupleAddedFirst(count));
        } else {
            commands.insertResource(new QueryTupleAddedSecond(count));
        }
    }

    @:system("Update")
    public static function tupleAddedCompositeOrQuerySystem(query:Query<Tuple2<AppPosition, AppVelocity>, Or<Added<AppTag>, Without<AppHealth>>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value == 0) {
            commands.insertResource(new QueryTupleAddedCompositeOrFirst(count));
        } else {
            commands.insertResource(new QueryTupleAddedCompositeOrSecond(count));
        }
    }

    @:system("Update")
    @:after("app.CounterSystems.mutateTrackedPosition")
    public static function tupleChangedQuerySystem(query:Query<Tuple2<AppPosition, AppVelocity>, Changed<AppPosition>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value <= 1) {
            commands.insertResource(new QueryTupleChangedFirst(count));
        } else {
            commands.insertResource(new QueryTupleChangedSecond(count));
        }
    }

    @:system("Update")
    @:after("app.CounterSystems.mutateTrackedPosition")
    public static function tupleChangedCompositeOrQuerySystem(query:Query<Tuple2<AppPosition, AppVelocity>, Or<Changed<AppPosition>, Without<AppHealth>>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value <= 1) {
            commands.insertResource(new QueryTupleChangedCompositeOrFirst(count));
        } else {
            commands.insertResource(new QueryTupleChangedCompositeOrSecond(count));
        }
    }

    @:system("Update")
    public static function filteredQuerySystem(query:Query<AppPosition, All<With<AppTag>>>, commands:Commands):Void {
        commands.insertResource(new FilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function taggedEntitySystem(query:Query<bevy.ecs.Entity, With<AppTag>>, commands:Commands):Void {
        commands.insertResource(new TaggedEntityCount(query.toArray().length));
    }

    @:system("Update")
    public static function orFilteredQuerySystem(query:Query<AppPosition, Or<With<AppTag>, Without<AppVelocity>>>, commands:Commands):Void {
        commands.insertResource(new OrFilterCount(query.toArray().length));
    }

    @:system("Update")
    public static function addedQuerySystem(query:Query<AppPosition, Added<AppTag>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value == 0) {
            commands.insertResource(new AddedCountFirst(count));
        } else {
            commands.insertResource(new AddedCountSecond(count));
        }
    }

    @:system("Update")
    public static function mutateTrackedPosition(world:World):Void {
        var step = world.getResource(ChangeStep);
        if (step.value == 0) {
            step.value = 1;
            return;
        }
        var target = world.query(AppPosition).with(AppTag).getSingle();
        if (target != null) {
            world.insert(target.entity, new AppPosition(target.component.value + 10));
        }
        step.value = 2;
    }

    @:system("Update")
    public static function changedQuerySystem(query:Query<AppPosition, Changed<AppPosition>>, step:Res<ChangeStep>, commands:Commands):Void {
        var count = query.toArray().length;
        if (step.value.value <= 1) {
            commands.insertResource(new ChangedCountFirst(count));
        } else {
            commands.insertResource(new ChangedCountSecond(count));
        }
    }

    @:system("Update")
    @:after("app.CounterSystems.addAsync")
    @:before("app.CounterSystems.readBack")
    public static function applyAsyncCounterDelta(counter:ResMut<Counter>, delta:Res<AsyncCounterDelta>, commands:Commands):Void {
        counter.value.value += delta.value.value;
        commands.removeResource(AsyncCounterDelta);
    }

    @:system("Update")
    public static function sendEvent(writer:EventWriter<AppSignal>):Void {
        writer.send(new AppSignal("received"));
    }

    @:system("Update")
    public static function readEvent(reader:EventReader<AppSignal>, commands:Commands):Void {
        for (event in reader.read()) {
            commands.insertResource(new EventStatus(event.value));
        }
    }
}

class CounterConditions {
    public static function allowSync(state:Res<RunIfState>):Bool {
        return state.value.syncEnabled;
    }

    public static function allowAsync(state:Res<RunIfState>):Future<Bool> {
        return Future.resolved(state.value.asyncEnabled);
    }

    public static function hasTaggedPosition(query:Query<AppPosition, With<AppTag>>):Bool {
        return !query.isEmpty();
    }
}

class CounterSetConditions {
    public static function allowAlpha(gate:Res<SetGate>):Bool {
        return gate.value.alphaEnabled;
    }

    public static function allowBeta(gate:Res<SetGate>):Bool {
        return gate.value.betaEnabled;
    }
}
