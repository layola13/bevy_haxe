package bevy.ecs;

@:genericBuild(bevy.macro.TupleMacro.buildTuple())
class Tuple<Rest> {
    @:noCompletion
    private function new() {
        throw "Tuple is a generic-build anchor and should resolve to a generated tuple data class";
    }
}

typedef Tuple1<T0> = Tuple<T0>;

typedef Tuple2<T0, T1> = Tuple<T0, T1>;

typedef Tuple3<T0, T1, T2> = Tuple<T0, T1, T2>;

typedef Tuple4<T0, T1, T2, T3> = Tuple<T0, T1, T2, T3>;

typedef Tuple5<T0, T1, T2, T3, T4> = Tuple<T0, T1, T2, T3, T4>;

typedef Tuple6<T0, T1, T2, T3, T4, T5> = Tuple<T0, T1, T2, T3, T4, T5>;

typedef Tuple7<T0, T1, T2, T3, T4, T5, T6> = Tuple<T0, T1, T2, T3, T4, T5, T6>;

typedef Tuple8<T0, T1, T2, T3, T4, T5, T6, T7> = Tuple<T0, T1, T2, T3, T4, T5, T6, T7>;

typedef Tuple9<T0, T1, T2, T3, T4, T5, T6, T7, T8> = Tuple<T0, T1, T2, T3, T4, T5, T6, T7, T8>;

typedef Tuple10<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9> = Tuple<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9>;

typedef Tuple11<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10> = Tuple<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>;

typedef Tuple12<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11> = Tuple<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11>;

typedef Tuple13<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12> = Tuple<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12>;

typedef Tuple14<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13> = Tuple<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13>;

typedef Tuple15<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14> = Tuple<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14>;
