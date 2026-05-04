from pathlib import Path

base = Path("/home/vscode/projects/bevy_haxe/src/haxe")

# 1. Fix State.hx: remove ISpecialize dependency
p = base / "state/State.hx"
s = p.read_text()
s = s.replace('interface States extends ISpecialize {', 'interface States {')
s = s.replace(" * - `haxe.ISpecialize`\n", "")
s = s.replace(" * - Implementation for 'static lifetime is handled by haxe.ISpecialize\n", "")
p.write_text(s)
print("Fixed State.hx: removed ISpecialize")

# 2. Fix NextState.hx: fix setIfNeq pattern match syntax
p = base / "state/NextState.hx"
s = p.read_text()
old_setifneq = """    public inline function setIfNeq(state:T) {
        if (!matches(this.value, Pending(s)) || !s.equals(state)) {
            this.value = PendingIfNeq(state);
        }
    }"""
new_setifneq = """    public inline function setIfNeq(state:T) {
        var shouldSet = switch (value) {
            case Pending(s): s != state;
            case PendingIfNeq(s): s != state;
            case Unchanged: true;
        };
        if (shouldSet) {
            this.value = PendingIfNeq(state);
        }
    }"""
s = s.replace(old_setifneq, new_setifneq)
p.write_text(s)
print("Fixed NextState.hx: setIfNeq")

print("Done")
