package bevy.ecs;

/**
 * Marker component used in query filters to exclude resource-bearing entities.
 *
 * In this runtime, resources are stored out-of-band from normal entity component
 * storage, but we still expose this marker type so query borrow checks can use
 * `Without<IsResource>` as an explicit disjointness proof, matching Bevy-style APIs.
 */
class IsResource implements Component {
    public var resourceKey(default, null):Null<String>;

    public function new(?resourceKey:String) {
        this.resourceKey = resourceKey;
    }
}
