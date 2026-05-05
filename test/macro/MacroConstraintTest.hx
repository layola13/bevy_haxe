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
        testQueryTuple1ConflictRejected();
        testQueryTuple1DisjointAllowed();
        testQueryTupleGenericConflictRejected();
        testQueryTupleGenericDisjointAllowed();
        testQueryTupleGenericAddedConflictRejected();
        testQueryTupleGenericAddedDisjointAllowed();
        testQueryTupleGenericChangedConflictRejected();
        testQueryTupleGenericChangedDisjointAllowed();
        testQueryTupleGenericCompositeConflictRejected();
        testQueryTupleGenericCompositeDisjointAllowed();
        testQueryTupleGenericOrBranchConflictRejected();
        testQueryTupleGenericDuplicateRejected();
        testQueryTupleGenericDataDisjointAllowed();
        testQueryTupleConflictRejected();
        testQueryTupleDisjointAllowed();
        testQueryTupleCompositeConflictRejected();
        testQueryTupleOrBranchConflictRejected();
        testQueryTupleDuplicateRejected();
        testQueryTupleChangedConflictRejected();
        testQueryTupleAddedConflictRejected();
        testQueryTupleAddedDisjointAllowed();
        testQueryTupleAddedCompositeConflictRejected();
        testQueryTupleAddedCompositeDisjointAllowed();
        testQueryTupleChangedCompositeConflictRejected();
        testQueryTupleChangedCompositeDisjointAllowed();
        testQueryTupleChangedDisjointAllowed();
        testQueryTupleDataDisjointAllowed();
        testQueryPairDataDisjointAllowed();
        testQueryTripleDataDisjointAllowed();
        testQueryTupleCompositeDisjointAllowed();
        testQueryTuple4ConflictRejected();
        testQueryTuple5ConflictRejected();
        testQueryTuple10ConflictRejected();
        testQueryTuple15ConflictRejected();
        testQueryTuple15DisjointAllowed();
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

    static function testQueryTuple1ConflictRejected():Void {
        var result = runCompile("constraint/QueryTuple1ConflictConstraint.hx", "constraint.QueryTuple1ConflictConstraint");
        assert(result.code != 0, "Query<Tuple1<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple1 conflict diagnostic");
    }

    static function testQueryTuple1DisjointAllowed():Void {
        var result = runCompile("constraint/QueryTuple1DisjointConstraint.hx", "constraint.QueryTuple1DisjointConstraint");
        assert(result.code == 0, "disjoint tuple1 Query filters should compile");
    }

    static function testQueryTupleGenericConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleGenericConflictConstraint.hx", "constraint.QueryTupleGenericConflictConstraint");
        assert(result.code != 0, "Query<Tuple<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple generic conflict diagnostic");
    }

    static function testQueryTupleGenericDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleGenericDisjointConstraint.hx", "constraint.QueryTupleGenericDisjointConstraint");
        assert(result.code == 0, "disjoint generic tuple Query filters should compile");
    }

    static function testQueryTupleGenericAddedConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleGenericAddedConflictConstraint.hx", "constraint.QueryTupleGenericAddedConflictConstraint");
        assert(result.code != 0, "generic tuple Query and Added<T> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query generic tuple added conflict diagnostic");
    }

    static function testQueryTupleGenericAddedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleGenericAddedDisjointConstraint.hx", "constraint.QueryTupleGenericAddedDisjointConstraint");
        assert(result.code == 0, "generic tuple Query and Added<T> should compile when disjoint filters are explicit");
    }

    static function testQueryTupleGenericChangedConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleGenericChangedConflictConstraint.hx", "constraint.QueryTupleGenericChangedConflictConstraint");
        assert(result.code != 0, "generic tuple Query and Changed<T> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query generic tuple changed conflict diagnostic");
    }

    static function testQueryTupleGenericChangedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleGenericChangedDisjointConstraint.hx", "constraint.QueryTupleGenericChangedDisjointConstraint");
        assert(result.code == 0, "generic tuple Query and Changed<T> should compile when disjoint filters are explicit");
    }

    static function testQueryTupleGenericCompositeConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleGenericCompositeConflictConstraint.hx", "constraint.QueryTupleGenericCompositeConflictConstraint");
        assert(result.code != 0, "generic tuple Query with composite Or/Without overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query generic tuple composite conflict diagnostic");
    }

    static function testQueryTupleGenericCompositeDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleGenericCompositeDisjointConstraint.hx", "constraint.QueryTupleGenericCompositeDisjointConstraint");
        assert(result.code == 0, "generic tuple Query disjoint proofs should handle composite Or<...> filter branches");
    }

    static function testQueryTupleGenericOrBranchConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleGenericOrBranchConflictConstraint.hx", "constraint.QueryTupleGenericOrBranchConflictConstraint");
        assert(result.code != 0, "generic tuple Query should conflict when an Or branch allows overlap");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query generic tuple Or-branch conflict diagnostic");
    }

    static function testQueryTupleGenericDuplicateRejected():Void {
        var result = runCompile("constraint/QueryTupleGenericDuplicateConstraint.hx", "constraint.QueryTupleGenericDuplicateConstraint");
        assert(result.code != 0, "Query<Tuple<T, T>> duplicate generic tuple data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query generic tuple duplicate diagnostic");
    }

    static function testQueryTupleGenericDataDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleGenericDataDisjointConstraint.hx", "constraint.QueryTupleGenericDataDisjointConstraint");
        assert(result.code == 0, "generic tuple Query data should contribute required-components for disjoint proofs");
    }

    static function testQueryTupleConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleConflictConstraint.hx", "constraint.QueryTupleConflictConstraint");
        assert(result.code != 0, "Query<Tuple2<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple conflict diagnostic");
    }

    static function testQueryTupleDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleDisjointConstraint.hx", "constraint.QueryTupleDisjointConstraint");
        assert(result.code == 0, "disjoint tuple Query filters should compile");
    }

    static function testQueryTupleCompositeConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleCompositeConflictConstraint.hx", "constraint.QueryTupleCompositeConflictConstraint");
        assert(result.code != 0, "tuple Query with composite Or/Without overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple composite conflict diagnostic");
    }

    static function testQueryTupleOrBranchConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleOrBranchConflictConstraint.hx", "constraint.QueryTupleOrBranchConflictConstraint");
        assert(result.code != 0, "tuple Query should conflict when an Or branch allows overlap");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple Or-branch conflict diagnostic");
    }

    static function testQueryTupleDuplicateRejected():Void {
        var result = runCompile("constraint/QueryTupleDuplicateConstraint.hx", "constraint.QueryTupleDuplicateConstraint");
        assert(result.code != 0, "Query<Tuple2<T, T>> duplicate tuple data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query tuple duplicate diagnostic");
    }

    static function testQueryTupleChangedConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleChangedConflictConstraint.hx", "constraint.QueryTupleChangedConflictConstraint");
        assert(result.code != 0, "tuple Query and Changed<T> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple changed conflict diagnostic");
    }

    static function testQueryTupleAddedConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleAddedConflictConstraint.hx", "constraint.QueryTupleAddedConflictConstraint");
        assert(result.code != 0, "tuple Query and Added<T> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple added conflict diagnostic");
    }

    static function testQueryTupleAddedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleAddedDisjointConstraint.hx", "constraint.QueryTupleAddedDisjointConstraint");
        assert(result.code == 0, "tuple Query and Added<T> should compile when disjoint filters are explicit");
    }

    static function testQueryTupleAddedCompositeConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleAddedCompositeConflictConstraint.hx", "constraint.QueryTupleAddedCompositeConflictConstraint");
        assert(result.code != 0, "tuple Query and Added<T> should fail under composite filters when at least one branch overlaps");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple added composite conflict diagnostic");
    }

    static function testQueryTupleAddedCompositeDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleAddedCompositeDisjointConstraint.hx", "constraint.QueryTupleAddedCompositeDisjointConstraint");
        assert(result.code == 0, "tuple Query and Added<T> should compile under composite filters when disjointness is explicit");
    }

    static function testQueryTupleChangedCompositeConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleChangedCompositeConflictConstraint.hx", "constraint.QueryTupleChangedCompositeConflictConstraint");
        assert(result.code != 0, "tuple Query and Changed<T> should fail under composite filters when at least one branch overlaps");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple changed composite conflict diagnostic");
    }

    static function testQueryTupleChangedCompositeDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleChangedCompositeDisjointConstraint.hx", "constraint.QueryTupleChangedCompositeDisjointConstraint");
        assert(result.code == 0, "tuple Query and Changed<T> should compile under composite filters when disjointness is explicit");
    }

    static function testQueryTupleChangedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleChangedDisjointConstraint.hx", "constraint.QueryTupleChangedDisjointConstraint");
        assert(result.code == 0, "tuple Query and Changed<T> should compile when disjoint filters are explicit");
    }

    static function testQueryTupleDataDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleDataDisjointConstraint.hx", "constraint.QueryTupleDataDisjointConstraint");
        assert(result.code == 0, "tuple Query data should contribute required-components for disjoint proofs");
    }

    static function testQueryPairDataDisjointAllowed():Void {
        var result = runCompile("constraint/QueryPairDataDisjointConstraint.hx", "constraint.QueryPairDataDisjointConstraint");
        assert(result.code == 0, "Query2 data should contribute required-components for disjoint proofs");
    }

    static function testQueryTripleDataDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleDataDisjointConstraint.hx", "constraint.QueryTripleDataDisjointConstraint");
        assert(result.code == 0, "Query3 data should contribute required-components for disjoint proofs");
    }

    static function testQueryTupleCompositeDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleCompositeDisjointConstraint.hx", "constraint.QueryTupleCompositeDisjointConstraint");
        assert(result.code == 0, "tuple Query disjoint proofs should handle composite Or<...> filter branches");
    }

    static function testQueryTuple4ConflictRejected():Void {
        var result = runCompile("constraint/QueryTuple4ConflictConstraint.hx", "constraint.QueryTuple4ConflictConstraint");
        assert(result.code != 0, "Query<Tuple4<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple4 conflict diagnostic");
    }

    static function testQueryTuple5ConflictRejected():Void {
        var result = runCompile("constraint/QueryTuple5ConflictConstraint.hx", "constraint.QueryTuple5ConflictConstraint");
        assert(result.code != 0, "Query<Tuple5<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple5 conflict diagnostic");
    }

    static function testQueryTuple10ConflictRejected():Void {
        var result = runCompile("constraint/QueryTuple10ConflictConstraint.hx", "constraint.QueryTuple10ConflictConstraint");
        assert(result.code != 0, "Query<Tuple10<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple10 conflict diagnostic");
    }

    static function testQueryTuple15ConflictRejected():Void {
        var result = runCompile("constraint/QueryTuple15ConflictConstraint.hx", "constraint.QueryTuple15ConflictConstraint");
        assert(result.code != 0, "Query<Tuple15<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple15 conflict diagnostic");
    }

    static function testQueryTuple15DisjointAllowed():Void {
        var result = runCompile("constraint/QueryTuple15DisjointConstraint.hx", "constraint.QueryTuple15DisjointConstraint");
        assert(result.code == 0, "disjoint tuple15 Query filters should compile");
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
