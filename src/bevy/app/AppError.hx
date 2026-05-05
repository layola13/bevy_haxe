package bevy.app;

enum AppErrorKind {
    PluginAlreadyAdded(pluginName:String);
    PluginGroupPluginMissing(groupName:String, pluginTypeKey:String);
    PluginGroupAddFailed(groupName:String, pluginName:String, cause:Dynamic);
    PluginWithoutRuntimeClass(pluginValue:String);
    PluginClassNameUnavailable;
    ScheduleOrderingCycle(scheduleLabel:String);
    ScheduleOrderingSourceMissing(scheduleLabel:String, source:String);
    ScheduleOrderingTargetMissing(scheduleLabel:String, target:String);
    ScheduleSetEmptyName(scheduleLabel:String);
    ScheduleSetHasNoSystems(scheduleLabel:String, setName:String);
    ScheduleRunIfNotBool(scheduleLabel:String);
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
            case ScheduleOrderingCycle(scheduleLabel):
                'Schedule ordering cycle detected in "$scheduleLabel"';
            case ScheduleOrderingSourceMissing(scheduleLabel, source):
                'System ordering reference "$source" was not found in schedule "$scheduleLabel"';
            case ScheduleOrderingTargetMissing(scheduleLabel, target):
                'System ordering reference "$target" was not found in schedule "$scheduleLabel"';
            case ScheduleSetEmptyName(scheduleLabel):
                'System set name must not be empty in schedule "$scheduleLabel"';
            case ScheduleSetHasNoSystems(scheduleLabel, setName):
                'System set "$setName" has no systems in schedule "$scheduleLabel"';
            case ScheduleRunIfNotBool(scheduleLabel):
                'run_if condition in schedule "$scheduleLabel" must resolve to Bool';
        });
    }
}
