# Godot 项目协作规范（程序 × 美术）

> 本文档用于规范 **程序 & 美术** 在同一个 Godot 项目中的协作方式，
> 目标是：**避免 Git 冲突、明确职责、降低沟通成本、让两个人都能安心干活。**

---

## 一、协作总原则（必须遵守）

1. **必须使用 Git 进行版本控制**，任何改动都需要 commit
2. **同一时间，不允许两个人修改同一个 `.tscn` 文件**
3. **程序不直接改关卡，美术不直接改逻辑脚本**
4. 所有可供美术调整的内容，**必须通过 `@export` 暴露**

---

## 二、目录结构 & 所有权（定死规则）

> 以下规则为 **硬性约定**，不是建议

```
res://
├─ Assets/
├─ Audio/
├─ AutoLoadNode/
├─ Components/
├─ Maps/
├─ Nodes/
├─ Resources/
├─ ScriptTemplates/
├─ Shader/
└─ UI/
```

### 📁 Assets/

**用途**：原始美术素材

* 内容：图片、模型、贴图、序列帧
* ❌ 禁止放 `.tscn` / `.gd`

**所有权**：🎨 美术

---

### 📁 Audio/

**用途**：音频资源

建议结构：

```
Audio/
├─ BGM/
├─ SFX/
```

**所有权**：🎨 美术

---

### 📁 AutoLoadNode/

**用途**：全局单例节点

* GameManager
* AudioManager
* SaveManager
* EventBus

**所有权**：👨‍💻 程序

❗美术禁止修改

---

### 📁 Components/

**用途**：可复用功能组件（逻辑层）

示例：

```
Components/
├─ HealthComponent.gd
├─ MoveComponent.gd
├─ HurtBox.tscn
```

规则：

* 只放“功能组件”，不放完整角色
* 可被多个节点复用

**所有权**：👨‍💻 程序

---

### 📁 Nodes/

**用途**：可复用的完整节点 / 预制体（Prefab）

建议结构：

```
Nodes/
├─ Characters/
│  ├─ Player.tscn
│  ├─ Enemy_Slime.tscn
├─ Props/
│  ├─ Door.tscn
│  ├─ Chest.tscn
```

规则：

* 程序负责结构 + 脚本
* 美术只通过 Inspector 调参 / 换资源
* 禁止直接改脚本逻辑

**所有权**：👨‍💻 程序（🎨 可使用、可调参）

---

### 📁 Maps/

**用途**：关卡 / 场景搭建

建议结构：

```
Maps/
├─ Levels/
│  ├─ Level_01.tscn
│  ├─ Level_02.tscn
├─ Test/
│  ├─ Test_AI.tscn
```

规则：

* 只实例化 Nodes 中的 prefab
* 不在 Map 中写游戏逻辑

**所有权**：🎨 美术

---

### 📁 Resources/

**用途**：数据资源（`.tres / .res`）

示例：

```
Resources/
├─ EnemyData/
├─ ItemData/
```

**所有权**：👨‍💻 程序

---

### 📁 Shader/

**用途**：Shader 文件

规则：

* 程序编写
* 暴露参数给美术调整

**所有权**：👨‍💻 程序

---

### 📁 UI/

**用途**：UI 场景

建议结构：

```
UI/
├─ Screens/
│  ├─ MainMenu.tscn
│  ├─ PauseMenu.tscn
├─ Widgets/
│  ├─ HPBar.tscn
```

规则：

* 避免多人同时改同一 UI 场景

**所有权**：👨‍💻 / 🎨 协商

---

## 三、Prefab / 场景使用规范

### ✅ 必须使用“场景实例化”

* 关卡中 **只实例化 Nodes 下的场景**
* 禁止复制节点结构

---

### ✅ 推荐使用“继承场景”

当需要美术微调外观时：

```
Enemy_Base.tscn      ← 程序
Enemy_Forest.tscn    ← 美术（继承）
```

Godot 操作：

> 右键 → New Inherited Scene

---

## 四、脚本与参数交互规范

### 程序必须提供：

```gdscript
@export var hp: int = 100
@export var speed: float = 200.0
@export var sprite: Texture2D
```

### 美术只允许：

* 调整 `@export` 参数
* 替换资源
* 调整节点 Transform

❌ 禁止：

* 修改 `.gd`
* 重构节点结构

---

## 五、Git 使用规范（必须遵守）

1. 提交前先 `pull`
2. 保证一个 commit 只干一件事
3. 提交信息示例：

   * `feat: add slime enemy`
   * `art: build level 01`
4. 遇到 `.tscn` 冲突，**优先回退重来，不手动改文本**

---

## 六、冲突处理原则

* 冲突文件是 **场景文件** → 删除本地修改，重新拉
* 冲突文件是 **脚本** → 程序解决

---

## 七、最终目标

> * 程序：安心写系统
> * 美术：安心摆场景
> * Git：不炸

---

📌 本规范一旦确认，**整个项目周期内不随意更改**
