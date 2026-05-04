package async;

import bevy.async.Async;
import bevy.async.Async.async;
import bevy.async.Async.await;
import bevy.async.Async.forAwait;
import bevy.async.AsyncClass;
import bevy.async.AsyncRuntime;
import bevy.async.Future;
import bevy.async.Task;

class AsyncMacroTest {
    static function main():Void {
        testImmediateAwait();
        testAsyncSequentialAwait();
        testForAwait();
        testJoinRaceCancel();
        trace("AsyncMacroTest ok");
    }

    static function testImmediateAwait():Void {
        var value:Int = await(Future.resolved(41));
        assertEq(41, value, "immediate await");
    }

    static function testAsyncSequentialAwait():Void {
        var future = AsyncFixture.sequential();

        var seen = -1;
        future.handle(function(value) {
            seen = value;
        }, function(error) {
            throw error;
        });
        AsyncRuntime.flush();
        assertEq(42, seen, "async sequential await");
    }

    static function testForAwait():Void {
        var total = 0;
        var future = forAwait([1, 2, 3], value -> {
            var doubled = @await Future.resolved(value * 2);
            total += doubled;
        });
        future.handle(function(_) {}, function(error) throw error);
        AsyncRuntime.flush();
        assertEq(12, total, "forAwait");
    }

    static function testJoinRaceCancel():Void {
        var joined:Array<Dynamic> = null;
        Future.join([
            Future.resolved(1),
            Future.resolved(2),
            3
        ]).handle(function(value) {
            joined = value;
        }, function(error) throw error);
        AsyncRuntime.flush();
        assertEq(3, joined.length, "join length");
        assertEq(6, joined[0] + joined[1] + joined[2], "join values");

        var raced:Dynamic = null;
        Future.race([
            Future.resolved("first"),
            Future.resolved("second")
        ]).handle(function(value) {
            raced = value;
        }, function(error) throw error);
        AsyncRuntime.flush();
        assertEq("first", raced, "race");

        var task = Task.spawn(function() {
            return Future.resolved(1);
        });
        task.cancel();
        assert(task.isFinished(), "cancelled task should finish");
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

class AsyncFixture implements AsyncClass {
    @:async
    public static function sequential() {
        var a = @await Future.resolved(20);
        var b = @:await Future.resolved(22);
        return a + b;
    }

    @:async
    public static function fromDsl() {
        return @await Future.resolved("ok");
    }
}
