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
        testQueryPairRefDuplicateRejected();
        testQueryPairMutDuplicateRejected();
        testQueryPairRefMutDuplicateRejected();
        testQueryPairAddedConflictRejected();
        testQueryPairAddedDisjointAllowed();
        testQueryPairChangedConflictRejected();
        testQueryPairChangedDisjointAllowed();
        testQueryPairCompositeConflictRejected();
        testQueryPairCompositeDisjointAllowed();
        testQueryPairOrBranchConflictRejected();
        testQueryPairFilterTupleConflictRejected();
        testQueryPairFilterTupleDisjointAllowed();
        testQueryPairNestedTupleOrConflictRejected();
        testQueryPairNestedTupleOrDisjointAllowed();
        testQueryTripleAddedConflictRejected();
        testQueryTripleRefDuplicateRejected();
        testQueryTripleMutDuplicateRejected();
        testQueryTripleRefMutDuplicateRejected();
        testQueryTripleAddedDisjointAllowed();
        testQueryTripleEntityAddedConflictRejected();
        testQueryTripleEntityAddedDisjointAllowed();
        testQueryTripleChangedConflictRejected();
        testQueryTripleChangedDisjointAllowed();
        testQueryTripleEntityChangedConflictRejected();
        testQueryTripleEntityChangedDisjointAllowed();
        testQueryTripleCompositeConflictRejected();
        testQueryTripleCompositeDisjointAllowed();
        testQueryTripleOrBranchConflictRejected();
        testQueryTripleFilterTupleConflictRejected();
        testQueryTripleFilterTupleDisjointAllowed();
        testQueryTripleNestedTupleOrConflictRejected();
        testQueryTripleNestedTupleOrDisjointAllowed();
        testQueryTuple1ConflictRejected();
        testQueryTuple1DisjointAllowed();
        testQueryTupleGenericConflictRejected();
        testQueryTupleGenericDisjointAllowed();
        testQueryTupleGenericAddedConflictRejected();
        testQueryTupleGenericAddedDisjointAllowed();
        testQueryTupleGenericAddedCompositeConflictRejected();
        testQueryTupleGenericAddedCompositeDisjointAllowed();
        testQueryTupleGenericChangedConflictRejected();
        testQueryTupleGenericChangedDisjointAllowed();
        testQueryTupleGenericChangedCompositeConflictRejected();
        testQueryTupleGenericChangedCompositeDisjointAllowed();
        testQueryTupleGenericCompositeConflictRejected();
        testQueryTupleGenericCompositeDisjointAllowed();
        testQueryTupleGenericOrBranchConflictRejected();
        testQueryTupleGenericDuplicateRejected();
        testQueryTupleGenericDataDisjointAllowed();
        testQueryTupleGenericEntityConflictRejected();
        testQueryTupleGenericEntityDisjointAllowed();
        testQueryTupleGenericEntityChangedConflictRejected();
        testQueryTupleGenericEntityChangedDisjointAllowed();
        testQueryTupleConflictRejected();
        testQueryTupleDisjointAllowed();
        testQueryTupleCompositeConflictRejected();
        testQueryTupleOrBranchConflictRejected();
        testQueryTupleDuplicateRejected();
        testQueryTupleRefDuplicateRejected();
        testQueryTupleMutDuplicateRejected();
        testQueryTupleRefMutDuplicateRejected();
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
        testQueryTuple6ConflictRejected();
        testQueryTuple10ConflictRejected();
        testQueryTuple12ConflictRejected();
        testQueryTuple15ConflictRejected();
        testQueryTuple6DisjointAllowed();
        testQueryTuple12DisjointAllowed();
        testQueryTuple15DisjointAllowed();
        testQueryDisjointAllowed();
        testQueryCompositeConflictRejected();
        testQueryCompositeDisjointAllowed();
        testQueryFilterTupleConflictRejected();
        testQueryFilterTupleDisjointAllowed();
        testQuerySpawnedConflictRejected();
        testQuerySpawnedDisjointAllowed();
        testQuerySpawnDetailsNoConflictAllowed();
        testQueryHasNoConflictAllowed();
        testQueryTupleHasNoConflictAllowed();
        testQueryEntityRefConflictRejected();
        testQueryEntityRefDisjointAllowed();
        testQueryEntityWorldMutConflictRejected();
        testQueryEntityRefResMutConflictRejected();
        testQueryEntityRefResMutDisjointAllowed();
        testQueryEntityRefResMutIsResourceDisjointAllowed();
        testQueryEntityWorldMutResConflictRejected();
        testQueryEntityWorldMutResMutConflictRejected();
        testQueryEntityWorldMutResMutIsResourceDisjointAllowed();
        testQueryOptionConflictRejected();
        testQueryOptionDisjointAllowed();
        testQueryOptionAnyOfConflictRejected();
        testQueryOptionAnyOfDisjointAllowed();
        testQueryOptionEntityNoConflictAllowed();
        testQueryOptionSpawnDetailsNoConflictAllowed();
        testQueryOptionOptionConflictRejected();
        testQueryOptionOptionDisjointAllowed();
        testQueryOptionHasConflictWithMutAllowed();
        testQueryOptionHasNoConflictAllowed();
        testQueryOptionEntityRefConflictRejected();
        testQueryOptionEntityRefDisjointAllowed();
        testQueryOptionEntityWorldMutConflictRejected();
        testQueryOptionEntityWorldMutDisjointAllowed();
        testQueryOptionRefConflictRejected();
        testQueryOptionRefDisjointAllowed();
        testQueryOptionMutConflictRejected();
        testQueryOptionMutDisjointAllowed();
        testQueryRefConflictRejected();
        testQueryRefDisjointAllowed();
        testQueryMutConflictRejected();
        testQueryMutDisjointAllowed();
        testQueryRefMutConflictRejected();
        testQueryTupleRefConflictRejected();
        testQueryTupleRefDisjointAllowed();
        testQueryTupleMutConflictRejected();
        testQueryTupleMutDisjointAllowed();
        testQueryTupleRefMutConflictRejected();
        testQueryAnyOfConflictRejected();
        testQueryAnyOfDisjointAllowed();
        testQueryAnyOfEntityMutDisjointAllowed();
        testQueryAnyOfEntityRefConflictRejected();
        testQueryAnyOfEntityRefDisjointAllowed();
        testQueryAnyOfEntityWorldMutConflictRejected();
        testQueryAnyOfEntityWorldMutDisjointAllowed();
        testQueryAnyOfNestedConflictRejected();
        testQueryAnyOfNestedDisjointAllowed();
        testQueryAnyOfWithRefRefNoConflictAllowed();
        testQueryAnyOfWithMutAndRefConflictRejected();
        testQueryAnyOfWithRefAndMutConflictRejected();
        testQueryAnyOfMutOptionConflictRejected();
        testQueryAnyOfNoRequiredBranchConflictRejected();
        testQueryAnyOfNoRequiredBranchDisjointAllowed();
        testQueryAnyOfAndWithoutDisjointAllowed();
        testQueryPairAnyOfConflictRejected();
        testQueryPairAnyOfDisjointAllowed();
        testQueryPairAnyOfWithoutBranchConflictRejected();
        testQueryPairAnyOfWithoutBranchesDisjointAllowed();
        testQueryPairNestedAnyOfConflictRejected();
        testQueryPairNestedAnyOfDisjointAllowed();
        testQueryTripleAnyOfConflictRejected();
        testQueryTripleAnyOfDisjointAllowed();
        testQueryTripleAnyOfWithoutBranchConflictRejected();
        testQueryTripleAnyOfWithoutBranchesDisjointAllowed();
        testQueryTripleNestedAnyOfConflictRejected();
        testQueryTripleNestedAnyOfDisjointAllowed();
        testQueryTupleAnyOfConflictRejected();
        testQueryTupleAnyOfDisjointAllowed();
        testQueryTupleAnyOfWithoutBranchConflictRejected();
        testQueryTupleAnyOfWithoutBranchesDisjointAllowed();
        testQueryTupleNestedAnyOfConflictRejected();
        testQueryTupleNestedAnyOfDisjointAllowed();
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

    static function testQueryPairRefDuplicateRejected():Void {
        var result = runCompile("constraint/QueryPairRefDuplicateConstraint.hx", "constraint.QueryPairRefDuplicateConstraint");
        assert(result.code != 0, "Query2<Ref<T>, T> duplicate data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query pair Ref<T> duplicate diagnostic");
    }

    static function testQueryPairMutDuplicateRejected():Void {
        var result = runCompile("constraint/QueryPairMutDuplicateConstraint.hx", "constraint.QueryPairMutDuplicateConstraint");
        assert(result.code != 0, "Query2<Mut<T>, T> duplicate data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query pair Mut<T> duplicate diagnostic");
    }

    static function testQueryPairRefMutDuplicateRejected():Void {
        var result = runCompile("constraint/QueryPairRefMutDuplicateConstraint.hx", "constraint.QueryPairRefMutDuplicateConstraint");
        assert(result.code != 0, "Query2<Ref<T>, Mut<T>> duplicate data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query pair Ref<T>/Mut<T> duplicate diagnostic");
    }

    static function testQueryPairAddedConflictRejected():Void {
        var result = runCompile("constraint/QueryPairAddedConflictConstraint.hx", "constraint.QueryPairAddedConflictConstraint");
        assert(result.code != 0, "Query2 and Added<T> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query pair added conflict diagnostic");
    }

    static function testQueryPairAddedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryPairAddedDisjointConstraint.hx", "constraint.QueryPairAddedDisjointConstraint");
        assert(result.code == 0, "Query2 and Added<T> should compile when disjoint filters are explicit");
    }

    static function testQueryPairChangedConflictRejected():Void {
        var result = runCompile("constraint/QueryPairChangedConflictConstraint.hx", "constraint.QueryPairChangedConflictConstraint");
        assert(result.code != 0, "Query2 and Changed<T> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query pair changed conflict diagnostic");
    }

    static function testQueryPairChangedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryPairChangedDisjointConstraint.hx", "constraint.QueryPairChangedDisjointConstraint");
        assert(result.code == 0, "Query2 and Changed<T> should compile when disjoint filters are explicit");
    }

    static function testQueryPairCompositeConflictRejected():Void {
        var result = runCompile("constraint/QueryPairCompositeConflictConstraint.hx", "constraint.QueryPairCompositeConflictConstraint");
        assert(result.code != 0, "Query2 with composite Or/Without overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query pair composite conflict diagnostic");
    }

    static function testQueryPairCompositeDisjointAllowed():Void {
        var result = runCompile("constraint/QueryPairCompositeDisjointConstraint.hx", "constraint.QueryPairCompositeDisjointConstraint");
        assert(result.code == 0, "Query2 disjoint proofs should handle composite Or<...> filter branches");
    }

    static function testQueryPairOrBranchConflictRejected():Void {
        var result = runCompile("constraint/QueryPairOrBranchConflictConstraint.hx", "constraint.QueryPairOrBranchConflictConstraint");
        assert(result.code != 0, "Query2 should conflict when an Or branch allows overlap");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query pair Or-branch conflict diagnostic");
    }

    static function testQueryPairFilterTupleConflictRejected():Void {
        var result = runCompile("constraint/QueryPairFilterTupleConflictConstraint.hx", "constraint.QueryPairFilterTupleConflictConstraint");
        assert(result.code != 0, "Query2 should reject satisfiable overlapping tuple-filter branches");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query pair tuple-filter conflict diagnostic");
    }

    static function testQueryPairFilterTupleDisjointAllowed():Void {
        var result = runCompile("constraint/QueryPairFilterTupleDisjointConstraint.hx", "constraint.QueryPairFilterTupleDisjointConstraint");
        assert(result.code == 0, "Query2 should compile when tuple filters prove disjointness");
    }

    static function testQueryPairNestedTupleOrConflictRejected():Void {
        var result = runCompile("constraint/QueryPairNestedTupleOrConflictConstraint.hx", "constraint.QueryPairNestedTupleOrConflictConstraint");
        assert(result.code != 0, "Query2 should reject nested Or<Tuple...> when one branch overlaps");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query pair nested tuple-or conflict diagnostic");
    }

    static function testQueryPairNestedTupleOrDisjointAllowed():Void {
        var result = runCompile("constraint/QueryPairNestedTupleOrDisjointConstraint.hx", "constraint.QueryPairNestedTupleOrDisjointConstraint");
        assert(result.code == 0, "Query2 should compile nested Or<Tuple...> when all branches are disjoint");
    }

    static function testQueryTripleAddedConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleAddedConflictConstraint.hx", "constraint.QueryTripleAddedConflictConstraint");
        assert(result.code != 0, "Query3 and Added<T> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query triple added conflict diagnostic");
    }

    static function testQueryTripleRefDuplicateRejected():Void {
        var result = runCompile("constraint/QueryTripleRefDuplicateConstraint.hx", "constraint.QueryTripleRefDuplicateConstraint");
        assert(result.code != 0, "Query3<Ref<T>, T, ...> duplicate data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query triple Ref<T> duplicate diagnostic");
    }

    static function testQueryTripleMutDuplicateRejected():Void {
        var result = runCompile("constraint/QueryTripleMutDuplicateConstraint.hx", "constraint.QueryTripleMutDuplicateConstraint");
        assert(result.code != 0, "Query3<Mut<T>, T, ...> duplicate data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query triple Mut<T> duplicate diagnostic");
    }

    static function testQueryTripleRefMutDuplicateRejected():Void {
        var result = runCompile("constraint/QueryTripleRefMutDuplicateConstraint.hx", "constraint.QueryTripleRefMutDuplicateConstraint");
        assert(result.code != 0, "Query3<Ref<T>, Mut<T>, ...> duplicate data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query triple Ref<T>/Mut<T> duplicate diagnostic");
    }

    static function testQueryTripleAddedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleAddedDisjointConstraint.hx", "constraint.QueryTripleAddedDisjointConstraint");
        assert(result.code == 0, "Query3 and Added<T> should compile when disjoint filters are explicit");
    }

    static function testQueryTripleEntityAddedConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleEntityAddedConflictConstraint.hx", "constraint.QueryTripleEntityAddedConflictConstraint");
        assert(result.code != 0, "Query3<Entity, A, B> and Added<A> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query triple mixed-entity added conflict diagnostic");
    }

    static function testQueryTripleEntityAddedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleEntityAddedDisjointConstraint.hx", "constraint.QueryTripleEntityAddedDisjointConstraint");
        assert(result.code == 0, "Query3<Entity, A, B> and Added<A> should compile when disjoint filters are explicit");
    }

    static function testQueryTripleChangedConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleChangedConflictConstraint.hx", "constraint.QueryTripleChangedConflictConstraint");
        assert(result.code != 0, "Query3 and Changed<T> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query triple changed conflict diagnostic");
    }

    static function testQueryTripleChangedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleChangedDisjointConstraint.hx", "constraint.QueryTripleChangedDisjointConstraint");
        assert(result.code == 0, "Query3 and Changed<T> should compile when disjoint filters are explicit");
    }

    static function testQueryTripleEntityChangedConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleEntityChangedConflictConstraint.hx", "constraint.QueryTripleEntityChangedConflictConstraint");
        assert(result.code != 0, "Query3<Entity, A, B> and Changed<A> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query triple mixed-entity changed conflict diagnostic");
    }

    static function testQueryTripleEntityChangedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleEntityChangedDisjointConstraint.hx", "constraint.QueryTripleEntityChangedDisjointConstraint");
        assert(result.code == 0, "Query3<Entity, A, B> and Changed<A> should compile when disjoint filters are explicit");
    }

    static function testQueryTripleCompositeConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleCompositeConflictConstraint.hx", "constraint.QueryTripleCompositeConflictConstraint");
        assert(result.code != 0, "Query3 with composite Or/Without overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query triple composite conflict diagnostic");
    }

    static function testQueryTripleCompositeDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleCompositeDisjointConstraint.hx", "constraint.QueryTripleCompositeDisjointConstraint");
        assert(result.code == 0, "Query3 disjoint proofs should handle composite Or<...> filter branches");
    }

    static function testQueryTripleOrBranchConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleOrBranchConflictConstraint.hx", "constraint.QueryTripleOrBranchConflictConstraint");
        assert(result.code != 0, "Query3 should conflict when an Or branch allows overlap");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query triple Or-branch conflict diagnostic");
    }

    static function testQueryTripleFilterTupleConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleFilterTupleConflictConstraint.hx", "constraint.QueryTripleFilterTupleConflictConstraint");
        assert(result.code != 0, "Query3 should reject satisfiable overlapping tuple-filter branches");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query triple tuple-filter conflict diagnostic");
    }

    static function testQueryTripleFilterTupleDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleFilterTupleDisjointConstraint.hx", "constraint.QueryTripleFilterTupleDisjointConstraint");
        assert(result.code == 0, "Query3 should compile when tuple filters prove disjointness");
    }

    static function testQueryTripleNestedTupleOrConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleNestedTupleOrConflictConstraint.hx", "constraint.QueryTripleNestedTupleOrConflictConstraint");
        assert(result.code != 0, "Query3 should reject nested Or<Tuple...> when one branch overlaps");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query triple nested tuple-or conflict diagnostic");
    }

    static function testQueryTripleNestedTupleOrDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleNestedTupleOrDisjointConstraint.hx", "constraint.QueryTripleNestedTupleOrDisjointConstraint");
        assert(result.code == 0, "Query3 should compile nested Or<Tuple...> when all branches are disjoint");
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

    static function testQueryTupleGenericAddedCompositeConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleGenericAddedCompositeConflictConstraint.hx", "constraint.QueryTupleGenericAddedCompositeConflictConstraint");
        assert(result.code != 0, "generic tuple Query and Added<T> should fail under composite filters when at least one branch overlaps");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query generic tuple added composite conflict diagnostic");
    }

    static function testQueryTupleGenericAddedCompositeDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleGenericAddedCompositeDisjointConstraint.hx", "constraint.QueryTupleGenericAddedCompositeDisjointConstraint");
        assert(result.code == 0, "generic tuple Query and Added<T> should compile under composite filters when disjointness is explicit");
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

    static function testQueryTupleGenericChangedCompositeConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleGenericChangedCompositeConflictConstraint.hx", "constraint.QueryTupleGenericChangedCompositeConflictConstraint");
        assert(result.code != 0, "generic tuple Query and Changed<T> should fail under composite filters when at least one branch overlaps");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query generic tuple changed composite conflict diagnostic");
    }

    static function testQueryTupleGenericChangedCompositeDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleGenericChangedCompositeDisjointConstraint.hx", "constraint.QueryTupleGenericChangedCompositeDisjointConstraint");
        assert(result.code == 0, "generic tuple Query and Changed<T> should compile under composite filters when disjointness is explicit");
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

    static function testQueryTupleGenericEntityConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleGenericEntityConflictConstraint.hx", "constraint.QueryTupleGenericEntityConflictConstraint");
        assert(result.code != 0, "Query<Tuple<Entity, T>> and Query<T> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query generic tuple entity conflict diagnostic");
    }

    static function testQueryTupleGenericEntityDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleGenericEntityDisjointConstraint.hx", "constraint.QueryTupleGenericEntityDisjointConstraint");
        assert(result.code == 0, "Query<Tuple<Entity, T>> should compile when explicit filters make T disjoint");
    }

    static function testQueryTupleGenericEntityChangedConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleGenericEntityChangedConflictConstraint.hx", "constraint.QueryTupleGenericEntityChangedConflictConstraint");
        assert(result.code != 0, "Query<Tuple<Entity, A, B>> and Changed<A> overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query generic tuple entity changed conflict diagnostic");
    }

    static function testQueryTupleGenericEntityChangedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleGenericEntityChangedDisjointConstraint.hx", "constraint.QueryTupleGenericEntityChangedDisjointConstraint");
        assert(result.code == 0, "Query<Tuple<Entity, A, B>> and Changed<A> should compile when filters enforce disjointness");
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

    static function testQueryTupleRefDuplicateRejected():Void {
        var result = runCompile("constraint/QueryTupleRefDuplicateConstraint.hx", "constraint.QueryTupleRefDuplicateConstraint");
        assert(result.code != 0, "Query<Tuple<Ref<T>, T>> duplicate tuple data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query tuple Ref<T> duplicate diagnostic");
    }

    static function testQueryTupleMutDuplicateRejected():Void {
        var result = runCompile("constraint/QueryTupleMutDuplicateConstraint.hx", "constraint.QueryTupleMutDuplicateConstraint");
        assert(result.code != 0, "Query<Tuple<Mut<T>, T>> duplicate tuple data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query tuple Mut<T> duplicate diagnostic");
    }

    static function testQueryTupleRefMutDuplicateRejected():Void {
        var result = runCompile("constraint/QueryTupleRefMutDuplicateConstraint.hx", "constraint.QueryTupleRefMutDuplicateConstraint");
        assert(result.code != 0, "Query<Tuple<Ref<T>, Mut<T>>> duplicate tuple data access should fail compilation");
        assert(contains(result.stderr, "duplicate query component access"), "query tuple Ref<T>/Mut<T> duplicate diagnostic");
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

    static function testQueryTuple6ConflictRejected():Void {
        var result = runCompile("constraint/QueryTuple6ConflictConstraint.hx", "constraint.QueryTuple6ConflictConstraint");
        assert(result.code != 0, "Query<Tuple6<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple6 conflict diagnostic");
    }

    static function testQueryTuple10ConflictRejected():Void {
        var result = runCompile("constraint/QueryTuple10ConflictConstraint.hx", "constraint.QueryTuple10ConflictConstraint");
        assert(result.code != 0, "Query<Tuple10<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple10 conflict diagnostic");
    }

    static function testQueryTuple12ConflictRejected():Void {
        var result = runCompile("constraint/QueryTuple12ConflictConstraint.hx", "constraint.QueryTuple12ConflictConstraint");
        assert(result.code != 0, "Query<Tuple12<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple12 conflict diagnostic");
    }

    static function testQueryTuple15ConflictRejected():Void {
        var result = runCompile("constraint/QueryTuple15ConflictConstraint.hx", "constraint.QueryTuple15ConflictConstraint");
        assert(result.code != 0, "Query<Tuple15<...>> and Query overlap should fail compilation");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query tuple15 conflict diagnostic");
    }

    static function testQueryTuple6DisjointAllowed():Void {
        var result = runCompile("constraint/QueryTuple6DisjointConstraint.hx", "constraint.QueryTuple6DisjointConstraint");
        assert(result.code == 0, "disjoint tuple6 Query filters should compile");
    }

    static function testQueryTuple12DisjointAllowed():Void {
        var result = runCompile("constraint/QueryTuple12DisjointConstraint.hx", "constraint.QueryTuple12DisjointConstraint");
        assert(result.code == 0, "disjoint tuple12 Query filters should compile");
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

    static function testQueryFilterTupleConflictRejected():Void {
        var result = runCompile("constraint/QueryFilterTupleConflictConstraint.hx", "constraint.QueryFilterTupleConflictConstraint");
        assert(result.code != 0, "Query filter tuple should reject satisfiable overlapping query access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "query filter tuple conflict diagnostic");
    }

    static function testQueryFilterTupleDisjointAllowed():Void {
        var result = runCompile("constraint/QueryFilterTupleDisjointConstraint.hx", "constraint.QueryFilterTupleDisjointConstraint");
        assert(result.code == 0, "Query filter tuple should compile when tuple filters prove disjointness");
    }

    static function testQuerySpawnedConflictRejected():Void {
        var result = runCompile("constraint/QuerySpawnedConflictConstraint.hx", "constraint.QuerySpawnedConflictConstraint");
        assert(result.code != 0, "Spawned filter should not make overlapping Query<T> access disjoint");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Spawned query conflict diagnostic");
    }

    static function testQuerySpawnedDisjointAllowed():Void {
        var result = runCompile("constraint/QuerySpawnedDisjointConstraint.hx", "constraint.QuerySpawnedDisjointConstraint");
        assert(result.code == 0, "Spawned filter should compile when other filters prove disjointness");
    }

    static function testQuerySpawnDetailsNoConflictAllowed():Void {
        var result = runCompile("constraint/QuerySpawnDetailsNoConflictConstraint.hx", "constraint.QuerySpawnDetailsNoConflictConstraint");
        assert(result.code == 0, "SpawnDetails query data should not add component access conflicts");
    }

    static function testQueryHasNoConflictAllowed():Void {
        var result = runCompile("constraint/QueryHasNoConflictConstraint.hx", "constraint.QueryHasNoConflictConstraint");
        assert(result.code == 0, "Has<T> query data should not add normal component access conflicts");
    }

    static function testQueryTupleHasNoConflictAllowed():Void {
        var result = runCompile("constraint/QueryTupleHasNoConflictConstraint.hx", "constraint.QueryTupleHasNoConflictConstraint");
        assert(result.code == 0, "Has<T> inside tuple query data should not add normal component access conflicts");
    }

    static function testQueryEntityRefConflictRejected():Void {
        var result = runCompile("constraint/QueryEntityRefConflictConstraint.hx", "constraint.QueryEntityRefConflictConstraint");
        assert(result.code != 0, "EntityRef query data should conflict with overlapping component reads");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "EntityRef query conflict diagnostic");
    }

    static function testQueryEntityRefDisjointAllowed():Void {
        var result = runCompile("constraint/QueryEntityRefDisjointConstraint.hx", "constraint.QueryEntityRefDisjointConstraint");
        assert(result.code == 0, "EntityRef query data should compile when explicit filters prove disjointness");
    }

    static function testQueryEntityWorldMutConflictRejected():Void {
        var result = runCompile("constraint/QueryEntityWorldMutConflictConstraint.hx", "constraint.QueryEntityWorldMutConflictConstraint");
        assert(result.code != 0, "EntityWorldMut query data should conflict with other query component access");
        assert(contains(result.stderr, "query access overlaps with EntityWorldMut access"), "EntityWorldMut query conflict diagnostic");
    }

    static function testQueryEntityRefResMutConflictRejected():Void {
        var result = runCompile("constraint/QueryEntityRefResMutConflictConstraint.hx", "constraint.QueryEntityRefResMutConflictConstraint");
        assert(result.code != 0, "EntityRef query data should conflict with ResMut<T> access");
        assert(contains(result.stderr, "query access overlaps with EntityRef access"), "EntityRef+ResMut conflict diagnostic");
    }

    static function testQueryEntityRefResMutDisjointAllowed():Void {
        var result = runCompile("constraint/QueryEntityRefResMutDisjointConstraint.hx", "constraint.QueryEntityRefResMutDisjointConstraint");
        assert(result.code == 0, "EntityRef query data should compile with ResMut<T> when query excludes the resource component");
    }

    static function testQueryEntityRefResMutIsResourceDisjointAllowed():Void {
        var result = runCompile("constraint/QueryEntityRefResMutIsResourceDisjointConstraint.hx", "constraint.QueryEntityRefResMutIsResourceDisjointConstraint");
        assert(result.code == 0, "EntityRef query data should compile with ResMut<T> when query excludes IsResource");
    }

    static function testQueryEntityWorldMutResConflictRejected():Void {
        var result = runCompile("constraint/QueryEntityWorldMutResConflictConstraint.hx", "constraint.QueryEntityWorldMutResConflictConstraint");
        assert(result.code != 0, "EntityWorldMut query data should conflict with Res<T> access");
        assert(contains(result.stderr, "query access overlaps with EntityWorldMut access"), "EntityWorldMut+Res conflict diagnostic");
    }

    static function testQueryEntityWorldMutResMutConflictRejected():Void {
        var result = runCompile("constraint/QueryEntityWorldMutResMutConflictConstraint.hx", "constraint.QueryEntityWorldMutResMutConflictConstraint");
        assert(result.code != 0, "EntityWorldMut query data should conflict with ResMut<T> access");
        assert(contains(result.stderr, "query access overlaps with EntityWorldMut access"), "EntityWorldMut+ResMut conflict diagnostic");
    }

    static function testQueryEntityWorldMutResMutIsResourceDisjointAllowed():Void {
        var result = runCompile("constraint/QueryEntityWorldMutResMutIsResourceDisjointConstraint.hx", "constraint.QueryEntityWorldMutResMutIsResourceDisjointConstraint");
        assert(result.code == 0, "EntityWorldMut query data should compile with ResMut<T> when query excludes IsResource");
    }

    static function testQueryOptionConflictRejected():Void {
        var result = runCompile("constraint/QueryOptionConflictConstraint.hx", "constraint.QueryOptionConflictConstraint");
        assert(result.code != 0, "Option<T> query data should still conflict with overlapping Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Option<T> query conflict diagnostic");
    }

    static function testQueryOptionDisjointAllowed():Void {
        var result = runCompile("constraint/QueryOptionDisjointConstraint.hx", "constraint.QueryOptionDisjointConstraint");
        assert(result.code == 0, "Option<T> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryOptionAnyOfConflictRejected():Void {
        var result = runCompile("constraint/QueryOptionAnyOfConflictConstraint.hx", "constraint.QueryOptionAnyOfConflictConstraint");
        assert(result.code != 0, "Option<AnyOf<...>> query data should conflict with overlapping Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Option<AnyOf<...>> query conflict diagnostic");
    }

    static function testQueryOptionAnyOfDisjointAllowed():Void {
        var result = runCompile("constraint/QueryOptionAnyOfDisjointConstraint.hx", "constraint.QueryOptionAnyOfDisjointConstraint");
        assert(result.code == 0, "Option<AnyOf<...>> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryOptionEntityNoConflictAllowed():Void {
        var result = runCompile("constraint/QueryOptionEntityNoConflictConstraint.hx", "constraint.QueryOptionEntityNoConflictConstraint");
        assert(result.code == 0, "Option<Entity> query data should compile alongside normal component query access");
    }

    static function testQueryOptionSpawnDetailsNoConflictAllowed():Void {
        var result = runCompile("constraint/QueryOptionSpawnDetailsNoConflictConstraint.hx", "constraint.QueryOptionSpawnDetailsNoConflictConstraint");
        assert(result.code == 0, "Option<SpawnDetails> query data should compile alongside normal component query access");
    }

    static function testQueryOptionOptionConflictRejected():Void {
        var result = runCompile("constraint/QueryOptionOptionConflictConstraint.hx", "constraint.QueryOptionOptionConflictConstraint");
        assert(result.code != 0, "Option<Option<T>> query data should conflict with overlapping Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Option<Option<T>> query conflict diagnostic");
    }

    static function testQueryOptionOptionDisjointAllowed():Void {
        var result = runCompile("constraint/QueryOptionOptionDisjointConstraint.hx", "constraint.QueryOptionOptionDisjointConstraint");
        assert(result.code == 0, "Option<Option<T>> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryOptionHasConflictWithMutAllowed():Void {
        var result = runCompile("constraint/QueryOptionHasConflictConstraint.hx", "constraint.QueryOptionHasConflictConstraint");
        assert(result.code == 0, "Option<Has<T>> query data should compile when paired with Query<Mut<T>> access");
    }

    static function testQueryOptionHasNoConflictAllowed():Void {
        var result = runCompile("constraint/QueryOptionHasNoConflictConstraint.hx", "constraint.QueryOptionHasNoConflictConstraint");
        assert(result.code == 0, "Option<Has<T>> query data should compile when paired with Query<T> read access");
    }

    static function testQueryOptionEntityRefConflictRejected():Void {
        var result = runCompile("constraint/QueryOptionEntityRefConflictConstraint.hx", "constraint.QueryOptionEntityRefConflictConstraint");
        assert(result.code != 0, "Option<EntityRef> query data should conflict with overlapping Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Option<EntityRef> query conflict diagnostic");
    }

    static function testQueryOptionEntityRefDisjointAllowed():Void {
        var result = runCompile("constraint/QueryOptionEntityRefDisjointConstraint.hx", "constraint.QueryOptionEntityRefDisjointConstraint");
        assert(result.code == 0, "Option<EntityRef> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryOptionEntityWorldMutConflictRejected():Void {
        var result = runCompile("constraint/QueryOptionEntityWorldMutConflictConstraint.hx", "constraint.QueryOptionEntityWorldMutConflictConstraint");
        assert(result.code != 0, "Option<EntityWorldMut> query data should conflict with overlapping query component access");
        assert(contains(result.stderr, "EntityWorldMut access"), "Option<EntityWorldMut> query conflict diagnostic");
    }

    static function testQueryOptionEntityWorldMutDisjointAllowed():Void {
        var result = runCompile("constraint/QueryOptionEntityWorldMutDisjointConstraint.hx", "constraint.QueryOptionEntityWorldMutDisjointConstraint");
        assert(result.code == 0, "Option<EntityWorldMut> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryOptionRefConflictRejected():Void {
        var result = runCompile("constraint/QueryOptionRefConflictConstraint.hx", "constraint.QueryOptionRefConflictConstraint");
        assert(result.code != 0, "Option<Ref<T>> query data should conflict with overlapping Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Option<Ref<T>> query conflict diagnostic");
    }

    static function testQueryOptionRefDisjointAllowed():Void {
        var result = runCompile("constraint/QueryOptionRefDisjointConstraint.hx", "constraint.QueryOptionRefDisjointConstraint");
        assert(result.code == 0, "Option<Ref<T>> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryOptionMutConflictRejected():Void {
        var result = runCompile("constraint/QueryOptionMutConflictConstraint.hx", "constraint.QueryOptionMutConflictConstraint");
        assert(result.code != 0, "Option<Mut<T>> query data should conflict with overlapping Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Option<Mut<T>> query conflict diagnostic");
    }

    static function testQueryOptionMutDisjointAllowed():Void {
        var result = runCompile("constraint/QueryOptionMutDisjointConstraint.hx", "constraint.QueryOptionMutDisjointConstraint");
        assert(result.code == 0, "Option<Mut<T>> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryRefConflictRejected():Void {
        var result = runCompile("constraint/QueryRefConflictConstraint.hx", "constraint.QueryRefConflictConstraint");
        assert(result.code != 0, "Ref<T> query data should conflict with overlapping Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Ref<T> query conflict diagnostic");
    }

    static function testQueryRefDisjointAllowed():Void {
        var result = runCompile("constraint/QueryRefDisjointConstraint.hx", "constraint.QueryRefDisjointConstraint");
        assert(result.code == 0, "Ref<T> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryMutConflictRejected():Void {
        var result = runCompile("constraint/QueryMutConflictConstraint.hx", "constraint.QueryMutConflictConstraint");
        assert(result.code != 0, "Mut<T> query data should conflict with overlapping Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Mut<T> query conflict diagnostic");
    }

    static function testQueryMutDisjointAllowed():Void {
        var result = runCompile("constraint/QueryMutDisjointConstraint.hx", "constraint.QueryMutDisjointConstraint");
        assert(result.code == 0, "Mut<T> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryRefMutConflictRejected():Void {
        var result = runCompile("constraint/QueryRefMutConflictConstraint.hx", "constraint.QueryRefMutConflictConstraint");
        assert(result.code != 0, "Ref<T> and Mut<T> query data should conflict on overlapping access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Ref<T>/Mut<T> query conflict diagnostic");
    }

    static function testQueryTupleRefConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleRefConflictConstraint.hx", "constraint.QueryTupleRefConflictConstraint");
        assert(result.code != 0, "Tuple<Ref<T>, ...> query data should conflict with overlapping Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Tuple<Ref<T>> query conflict diagnostic");
    }

    static function testQueryTupleRefDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleRefDisjointConstraint.hx", "constraint.QueryTupleRefDisjointConstraint");
        assert(result.code == 0, "Tuple<Ref<T>, ...> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryTupleMutConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleMutConflictConstraint.hx", "constraint.QueryTupleMutConflictConstraint");
        assert(result.code != 0, "Tuple<Mut<T>, ...> query data should conflict with overlapping Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Tuple<Mut<T>> query conflict diagnostic");
    }

    static function testQueryTupleMutDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleMutDisjointConstraint.hx", "constraint.QueryTupleMutDisjointConstraint");
        assert(result.code == 0, "Tuple<Mut<T>, ...> query data should compile when explicit filters prove disjointness");
    }

    static function testQueryTupleRefMutConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleRefMutConflictConstraint.hx", "constraint.QueryTupleRefMutConflictConstraint");
        assert(result.code != 0, "Tuple<Ref<T>, ...> and Tuple<Mut<T>, ...> should conflict on overlapping access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Tuple<Ref<T>>/Tuple<Mut<T>> query conflict diagnostic");
    }

    static function testQueryAnyOfConflictRejected():Void {
        var result = runCompile("constraint/QueryAnyOfConflictConstraint.hx", "constraint.QueryAnyOfConflictConstraint");
        assert(result.code != 0, "AnyOf query data should conflict with overlapping component access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "AnyOf query conflict diagnostic");
    }

    static function testQueryAnyOfDisjointAllowed():Void {
        var result = runCompile("constraint/QueryAnyOfDisjointConstraint.hx", "constraint.QueryAnyOfDisjointConstraint");
        assert(result.code == 0, "AnyOf query data should compile when explicit filters prove disjointness");
    }

    static function testQueryAnyOfEntityMutDisjointAllowed():Void {
        var result = runCompile("constraint/QueryAnyOfEntityMutDisjointConstraint.hx", "constraint.QueryAnyOfEntityMutDisjointConstraint");
        assert(result.code == 0, "AnyOf<Entity, Mut<T>> should compile when overlapping mutable access is explicitly disjoint");
    }

    static function testQueryAnyOfEntityRefConflictRejected():Void {
        var result = runCompile("constraint/QueryAnyOfEntityRefConflictConstraint.hx", "constraint.QueryAnyOfEntityRefConflictConstraint");
        assert(result.code != 0, "AnyOf<EntityRef, T> should conflict with overlapping component access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "AnyOf<EntityRef, T> conflict diagnostic");
    }

    static function testQueryAnyOfEntityRefDisjointAllowed():Void {
        var result = runCompile("constraint/QueryAnyOfEntityRefDisjointConstraint.hx", "constraint.QueryAnyOfEntityRefDisjointConstraint");
        assert(result.code == 0, "AnyOf<EntityRef, T> should compile when explicit filters prove disjointness");
    }

    static function testQueryAnyOfEntityWorldMutConflictRejected():Void {
        var result = runCompile("constraint/QueryAnyOfEntityWorldMutConflictConstraint.hx", "constraint.QueryAnyOfEntityWorldMutConflictConstraint");
        assert(result.code != 0, "AnyOf<EntityWorldMut, T> should conflict with overlapping query access");
        assert(contains(result.stderr, "EntityWorldMut access"), "AnyOf<EntityWorldMut, T> conflict diagnostic");
    }

    static function testQueryAnyOfEntityWorldMutDisjointAllowed():Void {
        var result = runCompile("constraint/QueryAnyOfEntityWorldMutDisjointConstraint.hx", "constraint.QueryAnyOfEntityWorldMutDisjointConstraint");
        assert(result.code == 0, "AnyOf<EntityWorldMut, T> should compile when explicit filters prove disjointness");
    }

    static function testQueryAnyOfNestedConflictRejected():Void {
        var result = runCompile("constraint/QueryAnyOfNestedConflictConstraint.hx", "constraint.QueryAnyOfNestedConflictConstraint");
        assert(result.code != 0, "AnyOf<AnyOf<...>, T> should conflict with overlapping component access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "nested AnyOf conflict diagnostic");
    }

    static function testQueryAnyOfNestedDisjointAllowed():Void {
        var result = runCompile("constraint/QueryAnyOfNestedDisjointConstraint.hx", "constraint.QueryAnyOfNestedDisjointConstraint");
        assert(result.code == 0, "AnyOf<AnyOf<...>, T> should compile when explicit filters prove disjointness");
    }

    static function testQueryAnyOfWithRefRefNoConflictAllowed():Void {
        var result = runCompile("constraint/QueryAnyOfWithRefRefNoConflictConstraint.hx", "constraint.QueryAnyOfWithRefRefNoConflictConstraint");
        assert(result.code == 0, "AnyOf<T, T> should compile when both branches are read-only access");
    }

    static function testQueryAnyOfWithMutAndRefConflictRejected():Void {
        var result = runCompile("constraint/QueryAnyOfWithMutAndRefConflictConstraint.hx", "constraint.QueryAnyOfWithMutAndRefConflictConstraint");
        assert(result.code != 0, "AnyOf<Mut<T>, T> should reject duplicate mutable/read overlap on T");
        assert(contains(result.stderr, "duplicate query component access"), "AnyOf<Mut<T>, T> duplicate-data diagnostic");
    }

    static function testQueryAnyOfWithRefAndMutConflictRejected():Void {
        var result = runCompile("constraint/QueryAnyOfWithRefAndMutConflictConstraint.hx", "constraint.QueryAnyOfWithRefAndMutConflictConstraint");
        assert(result.code != 0, "AnyOf<T, Mut<T>> should reject duplicate mutable/read overlap on T");
        assert(contains(result.stderr, "duplicate query component access"), "AnyOf<T, Mut<T>> duplicate-data diagnostic");
    }

    static function testQueryAnyOfMutOptionConflictRejected():Void {
        var result = runCompile("constraint/QueryAnyOfMutOptionConflictConstraint.hx", "constraint.QueryAnyOfMutOptionConflictConstraint");
        assert(result.code != 0, "AnyOf<Mut<T>, Option<T>> should reject duplicate mutable/read overlap on T");
        assert(contains(result.stderr, "duplicate query component access"), "AnyOf<Mut<T>, Option<T>> duplicate-data diagnostic");
    }

    static function testQueryAnyOfNoRequiredBranchConflictRejected():Void {
        var result = runCompile("constraint/QueryAnyOfNoRequiredBranchConflictConstraint.hx", "constraint.QueryAnyOfNoRequiredBranchConflictConstraint");
        assert(result.code != 0, "AnyOf<Has<T>, Option<T>> should still conflict with Query<T> access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "AnyOf no-required-branch conflict diagnostic");
    }

    static function testQueryAnyOfNoRequiredBranchDisjointAllowed():Void {
        var result = runCompile("constraint/QueryAnyOfNoRequiredBranchDisjointConstraint.hx", "constraint.QueryAnyOfNoRequiredBranchDisjointConstraint");
        assert(result.code == 0, "AnyOf<Has<T>, Option<T>> should compile when explicit filters make T disjoint");
    }

    static function testQueryAnyOfAndWithoutDisjointAllowed():Void {
        var result = runCompile("constraint/QueryAnyOfAndWithoutDisjointConstraint.hx", "constraint.QueryAnyOfAndWithoutDisjointConstraint");
        assert(result.code == 0, "AnyOf<A, B> should compile with Query<C, Without<A>, Without<B>> when overlap is fully excluded");
    }

    static function testQueryPairAnyOfConflictRejected():Void {
        var result = runCompile("constraint/QueryPairAnyOfConflictConstraint.hx", "constraint.QueryPairAnyOfConflictConstraint");
        assert(result.code != 0, "Query2<AnyOf<...>, ...> should conflict with overlapping access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Query2 AnyOf conflict diagnostic");
    }

    static function testQueryPairAnyOfDisjointAllowed():Void {
        var result = runCompile("constraint/QueryPairAnyOfDisjointConstraint.hx", "constraint.QueryPairAnyOfDisjointConstraint");
        assert(result.code == 0, "Query2<AnyOf<...>, ...> should compile when explicit filters prove disjointness");
    }

    static function testQueryPairAnyOfWithoutBranchConflictRejected():Void {
        var result = runCompile("constraint/QueryPairAnyOfWithoutBranchConflictConstraint.hx", "constraint.QueryPairAnyOfWithoutBranchConflictConstraint");
        assert(result.code != 0, "Query2<AnyOf<...>, ...> should still conflict when only one AnyOf branch is excluded");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Query2 AnyOf Without-single-branch conflict diagnostic");
    }

    static function testQueryPairAnyOfWithoutBranchesDisjointAllowed():Void {
        var result = runCompile("constraint/QueryPairAnyOfWithoutBranchesDisjointConstraint.hx", "constraint.QueryPairAnyOfWithoutBranchesDisjointConstraint");
        assert(result.code == 0, "Query2<AnyOf<...>, ...> should compile when all AnyOf branches are excluded by filters");
    }

    static function testQueryPairNestedAnyOfConflictRejected():Void {
        var result = runCompile("constraint/QueryPairNestedAnyOfConflictConstraint.hx", "constraint.QueryPairNestedAnyOfConflictConstraint");
        assert(result.code != 0, "Query2<AnyOf<AnyOf<...>, ...>, ...> should conflict with overlapping access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Query2 nested AnyOf conflict diagnostic");
    }

    static function testQueryPairNestedAnyOfDisjointAllowed():Void {
        var result = runCompile("constraint/QueryPairNestedAnyOfDisjointConstraint.hx", "constraint.QueryPairNestedAnyOfDisjointConstraint");
        assert(result.code == 0, "Query2<AnyOf<AnyOf<...>, ...>, ...> should compile when explicit filters prove disjointness");
    }

    static function testQueryTripleAnyOfConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleAnyOfConflictConstraint.hx", "constraint.QueryTripleAnyOfConflictConstraint");
        assert(result.code != 0, "Query3<AnyOf<...>, ...> should conflict with overlapping access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Query3 AnyOf conflict diagnostic");
    }

    static function testQueryTripleAnyOfDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleAnyOfDisjointConstraint.hx", "constraint.QueryTripleAnyOfDisjointConstraint");
        assert(result.code == 0, "Query3<AnyOf<...>, ...> should compile when explicit filters prove disjointness");
    }

    static function testQueryTripleAnyOfWithoutBranchConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleAnyOfWithoutBranchConflictConstraint.hx", "constraint.QueryTripleAnyOfWithoutBranchConflictConstraint");
        assert(result.code != 0, "Query3<AnyOf<...>, ...> should still conflict when only one AnyOf branch is excluded");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Query3 AnyOf Without-single-branch conflict diagnostic");
    }

    static function testQueryTripleAnyOfWithoutBranchesDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleAnyOfWithoutBranchesDisjointConstraint.hx", "constraint.QueryTripleAnyOfWithoutBranchesDisjointConstraint");
        assert(result.code == 0, "Query3<AnyOf<...>, ...> should compile when all AnyOf branches are excluded by filters");
    }

    static function testQueryTripleNestedAnyOfConflictRejected():Void {
        var result = runCompile("constraint/QueryTripleNestedAnyOfConflictConstraint.hx", "constraint.QueryTripleNestedAnyOfConflictConstraint");
        assert(result.code != 0, "Query3<AnyOf<AnyOf<...>, ...>, ...> should conflict with overlapping access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Query3 nested AnyOf conflict diagnostic");
    }

    static function testQueryTripleNestedAnyOfDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTripleNestedAnyOfDisjointConstraint.hx", "constraint.QueryTripleNestedAnyOfDisjointConstraint");
        assert(result.code == 0, "Query3<AnyOf<AnyOf<...>, ...>, ...> should compile when explicit filters prove disjointness");
    }

    static function testQueryTupleAnyOfConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleAnyOfConflictConstraint.hx", "constraint.QueryTupleAnyOfConflictConstraint");
        assert(result.code != 0, "Query<Tuple<AnyOf<...>, ...>> should conflict with overlapping access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Tuple AnyOf conflict diagnostic");
    }

    static function testQueryTupleAnyOfDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleAnyOfDisjointConstraint.hx", "constraint.QueryTupleAnyOfDisjointConstraint");
        assert(result.code == 0, "Query<Tuple<AnyOf<...>, ...>> should compile when explicit filters prove disjointness");
    }

    static function testQueryTupleAnyOfWithoutBranchConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleAnyOfWithoutBranchConflictConstraint.hx", "constraint.QueryTupleAnyOfWithoutBranchConflictConstraint");
        assert(result.code != 0, "Query<Tuple<AnyOf<...>, ...>> should still conflict when only one AnyOf branch is excluded");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Tuple AnyOf Without-single-branch conflict diagnostic");
    }

    static function testQueryTupleAnyOfWithoutBranchesDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleAnyOfWithoutBranchesDisjointConstraint.hx", "constraint.QueryTupleAnyOfWithoutBranchesDisjointConstraint");
        assert(result.code == 0, "Query<Tuple<AnyOf<...>, ...>> should compile when all AnyOf branches are excluded by filters");
    }

    static function testQueryTupleNestedAnyOfConflictRejected():Void {
        var result = runCompile("constraint/QueryTupleNestedAnyOfConflictConstraint.hx", "constraint.QueryTupleNestedAnyOfConflictConstraint");
        assert(result.code != 0, "Query<Tuple<AnyOf<AnyOf<...>, ...>, ...>> should conflict with overlapping access");
        assert(contains(result.stderr, "overlapping query accesses must be disjoint"), "Tuple nested AnyOf conflict diagnostic");
    }

    static function testQueryTupleNestedAnyOfDisjointAllowed():Void {
        var result = runCompile("constraint/QueryTupleNestedAnyOfDisjointConstraint.hx", "constraint.QueryTupleNestedAnyOfDisjointConstraint");
        assert(result.code == 0, "Query<Tuple<AnyOf<AnyOf<...>, ...>, ...>> should compile when explicit filters prove disjointness");
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
