package constraint;

import bevy.app.App;
import bevy.app.MainSchedule;
import bevy.async.AsyncRuntime;

class ConstraintRuntime {
    public static function runUpdate(label:String):Void {
        var app = new App();
        app.addRegisteredSystems(MainSchedule.Update);
        runUpdateApp(label, app);
    }

    public static function runUpdateWithCounter(label:String, setup:App->Void, expectedTotal:Int, expectedWrites:Int = 1):Void {
        var app = new App();
        app.world.insertResource(new ConstraintCounter());
        setup(app);
        app.addRegisteredSystems(MainSchedule.Update);
        runUpdateApp(label, app);

        var counter = app.world.getResource(ConstraintCounter);
        if (counter == null) {
            throw 'constraint runtime missing counter for ' + label;
        }
        if (counter.total != expectedTotal || counter.writes != expectedWrites) {
            throw label + ' expected counter total=' + expectedTotal + ', writes=' + expectedWrites
                + ', got total=' + counter.total + ', writes=' + counter.writes;
        }
    }

    private static function runUpdateApp(label:String, app:App):Void {
        var done = false;
        var failure:Null<Dynamic> = null;
        app.runSchedule(MainSchedule.Update).handle(function(_) {
            done = true;
        }, function(error) {
            failure = error;
        });
        AsyncRuntime.flush();

        if (failure != null) {
            throw 'constraint runtime failed for ' + label + ': ' + Std.string(failure);
        }
        if (!done) {
            throw 'constraint runtime did not resolve for ' + label;
        }
    }
}
