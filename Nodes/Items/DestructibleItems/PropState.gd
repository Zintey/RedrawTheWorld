extends StateBase # 继承你的状态基类（如果你的基类叫 State，请改成 extends State）
class_name PropState

# 利用 owner 直接向上获取本体，极其稳定
@export var prop: DestructibleProp :
	get: return owner as DestructibleProp

# 就这么短！因为信号和虚函数全部从 StateBase 继承过来了！