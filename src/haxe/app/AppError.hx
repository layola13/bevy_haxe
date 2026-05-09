package haxe.app;

enum AppErrorKind {
    PluginAlreadyAdded(pluginName:String);
    PluginGroupPluginMissing(groupName:String, pluginTypeKey:String);
    PluginGroupAddFailed(groupName:String, pluginName:String, cause:Dynamic);
    PluginWithoutRuntimeClass(pluginValue:String);
    PluginClassNameUnavailable;
}

class AppError extends haxe.Exception {
    public var kind(default, null):AppErrorKind;

    public function new(kind:AppErrorKind) {
        this.kind = kind;
        super(switch kind {
            case PluginAlreadyAdded(pluginName):
                'Plugin already added: $pluginName';
            case PluginGroupPluginMissing(groupName, pluginTypeKey):
                'Plugin does not exist in group $groupName: $pluginTypeKey';
            case PluginGroupAddFailed(groupName, pluginName, cause):
                'Error adding plugin $pluginName in group $groupName: $cause';
            case PluginWithoutRuntimeClass(pluginValue):
                'Plugin must have a runtime class: $pluginValue';
            case PluginClassNameUnavailable:
                "Plugin class name is unavailable";
        });
    }
}
