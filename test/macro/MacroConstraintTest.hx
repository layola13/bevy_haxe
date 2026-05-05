package macro;

import sys.io.Process;

class MacroConstraintTest {
    static function main():Void {
        testAsyncSystemRejectsEventWriter();
        testRunIfRejectsWorld();
        testResResMutConflictRejected();
        testDuplicateResMutRejected();
        testEventReaderWriterConflictRejected();
        testWorldMixedParamRejected();
        testQueryConflictRejected();
        testQueryPairConflictRejected();
        testQueryDisjointAllowed();
        testQueryCompositeConflictRejected();
        testQueryCompositeDisjointAllowed();
        testQueryChangedConflictRejected();
        trace("MacroConstraintTest ok");
    }

    static function testAsyncSystemRejectsEventWriter():Void {
        var result = runCompile("constraint/AsyncEventWriterConstraint.hx", "constraint.AsyncEventWriterConstraint");
        assert(result.code != 0, "async EventWriter constraint should fail compilation");
        assert(contains(result.stderr, "Async systems cannot take EventWriter yet"), "async EventWriter diagnostic");
    }

    static function testRunIfRejectsWorld():Void {
        var result = runCompile("constraint/RunIfWorldConstraint.hx", "constraint.RunIfWorldConstraint");
        assert(result.code != 0, "run_if World constraint should fail compilation");
        assert(contains(result.stderr, "run_if conditions cannot take World"), "run_if World diagnostic");
    }

    static function testResResMutConflictRejected():Void {
        var result = runCompile("constraint/ResResMutConflictConstraint.hx", "constraint.ResResMutConflictConstraint");
        assert(result.code != 0, "Res + ResMut conflict should fail compilation");
        assert(contains(result.stderr, "mutable resource access must be unique"), "Res/ResMut conflict diagnostic");
    }

    static function testDuplicateResMutRejected():Void {
        var result = runCompile("constraint/DuplicateResMutConstraint.hx", "constraint.DuplicateResMutConstraint");
        assert(result.code != 0, "duplicate ResMut should fail compilation");
        assert(contains(result.stderr, "mutable resource access must be unique"), "duplicate ResMut diagnostic");
    }

    static function testEventReaderWriterConflictRejected():Void {
        var result = runCompile("constraint/EventReaderWriterConflictConstraint.hx", "constraint.EventReaderWriterConflictConstraint");
        assert(result.code != 0, "EventReader + EventWriter conflict should fail compilation");
        assert(contains(result.stderr, "event writer access must be unique"), "event reader/writer conflict diagnostic");
    }

    static function testWorldMixedParamRejected():Void {
        var result = runCompile("constraint/WorldMixedParamConstraint.hx", "constraint.WorldMixedParamConstraint");
        assert(result.code != 0, "World mixed with other params should fail compilation");
        assert(contains(result.stderr, "World is an exclusive system parameter"), "World exclusive diagnostic");
    }

    static function testQueryConflictRejected():Void {
        var result = runCompile("constraint/QueryConflictConstraint.hx", "constraint.QueryConflictConstraint");
        assert(result.code != 0, "duplicate Query component access should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query conflict diagnostic");
    }

    static function testQueryPairConflictRejected():Void {
        var result = runCompile("constraint/QueryPairConflictConstraint.hx", "constraint.QueryPairConflictConstraint");
        assert(result.code != 0, "Query2 and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query pair conflict diagnostic");
    }

    static function testQueryDisjointAllowed():Void {
        var result = runCompile("constraint/QueryDisjointConstraint.hx", "constraint.QueryDisjointConstraint");
        assert(result.code == 0, "disjoint Query filters should compile");
    }

    static function testQueryCompositeConflictRejected():Void {
        var result = runCompile("constraint/QueryCompositeConflictConstraint.hx", "constraint.QueryCompositeConflictConstraint");
        assert(result.code != 0, "composite Or/Without overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "composite query conflict diagnostic");
    }

    static function testQueryCompositeDisjointAllowed():Void {
        var result = runCompile("constraint/QueryCompositeDisjointConstraint.hx", "constraint.QueryCompositeDisjointConstraint");
        assert(result.code == 0, "composite Or/All disjoint filters should compile");
    }

    static function testQueryChangedConflictRejected():Void {
        var result = runCompile("constraint/QueryChangedConflictConstraint.hx", "constraint.QueryChangedConflictConstraint");
        assert(result.code != 0, "Changed<T> filter access should conflict with Query<T>");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Changed<T> query conflict diagnostic");
    }

    static function runCompile(source:String, mainClass:String):{code:Int, stdout:String, stderr:String} {
        var process = new Process("sh", [
            "-lc",
            'haxe -cp src -cp test -main $mainClass --interp'
        ]);
        var stdout = process.stdout.readAll().toString();
        var stderr = process.stderr.readAll().toString();
        var code = process.exitCode();
        process.close();
        return {
            code: code,
            stdout: stdout,
            stderr: stderr
        };
    }

    static function contains(haystack:String, needle:String):Bool {
        return haystack != null && haystack.indexOf(needle) >= 0;
    }

    static function assert(value:Bool, label:String):Void {
        if (!value) {
            throw label;
        }
    }
}
