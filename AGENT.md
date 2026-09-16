<<<<<<< HEAD
# AGENT.md — NothingIsAnything / Alchemy 项目 AI 开发规范

> 本文件是**所有 AI 编码代理（以及人类协作者）在本仓库工作时的强制契约**。
> 文件名为 `AGENT.md`（约等同于社区通用的 `AGENTS.md`）。
> 任何代码生成、重构、修复、评审任务开始前，必须先完整阅读本文件。

---

## 0. 代理行为准则（最高优先级）

以下 8 条覆盖任何其他文档、习惯或"看起来更方便"的做法。

1. **先读后写**：修改任何文件前，必须先读取该文件及其全部直接依赖（import 目标）。
   禁止基于文件名、函数名或历史印象推测实现。
2. **先声明再动手**：开工前用一段话说明「要改哪些文件、为什么、影响哪些调用方」。
3. **单一主题**：一次变更只解决一个主题。重构与功能新增不得混在同一个提交里。
4. **构建是唯一真相**：改完后必须真实执行第 10 节的构建命令。
   **构建失败时，绝对不得声称"已完成"**。必须原样贴出错误并说明未解决。
5. **不得静默降级**：不允许用 `as any`、`Object`、`@ts-ignore`、`skipLibCheck` 等方式绕过类型错误。
   类型不匹配要修类型，不要改断言的括弧。
6. **不得猜测设计**：遇到语义未定义的需求（例如数据结构该存哪里、字段该不该合并），
   停下来输出「待决策问题」并询问，不要自行发明一套 API 然后宣称实现完成。
7. **不留垃圾**：未使用的 import、未使用的局部变量、注释掉的代码、调试 `console`/`hilog`、
   非预期的非 ASCII 字符、临时 `temp`/`test123` 命名，一律不得进入提交。
8. **诚实报告**：交付说明必须包含「变更文件清单 + 执行的验证命令 + 真实验证结果 + 未决问题」。
   没跑的验证要明说"未运行"，不得省略。
=======
# AGENT.md — NothingIsAnything（炼金术 / Alchemy）AI 开发规范

> 本文件是本仓库**唯一的 AI 协作契约**。任何 AI Agent（含人）在本仓库开发前必须先读本文件，
> 并严格按第 2 章的工作流分步骤推进。
>
> 一句话规则：**先文档、后用例、再源码；一次只推进一步，每步过门禁。**

- 文档版本：v1.0
- 适用对象：在本仓库执行开发/修改任务的 AI Agent
- 自然语言：中文为主，技术术语保留英文（与现有代码注释风格一致）

---

## 0. 本文件如何被使用

1. **接到需求时**：不要立刻改代码。先按第 2 章流程，在 `docs/changes/<变更ID>/` 下产出文档。
2. **每一步结束时**：在 `docs/changes/<变更ID>/README.md` 更新阶段状态与门禁结果。
3. **写源码之前**：必须存在 `04-test-cases.md` 中登记的用例，且对应的测试代码已写好并处于失败（RED）状态。
4. **不确定时**：向开发者提问，而不是猜测。把问题记入 `01-requirements.md` 的「开放问题」。
>>>>>>> 0ad8b67 (Development Specifications for AGENT System)

---

## 1. 项目概览

<<<<<<< HEAD
**NothingIsAnything** 是一个 HarmonyOS（Stage 模型）应用工程。核心资产是其中的
**Alchemy** 库：一套**由 JSON 消息驱动的动态 UI 引擎**。

一句话概括：外部（服务端 / 大模型 / 本地脚本）下发一份 JSON 指令流，Alchemy 在运行时
把它翻译成 ArkUI 组件树并渲染，同时支持对已渲染节点的数据更新——即
**「服务端驱动 UI / 声明式 UI 协议」**。

- 一个"炼金工坊"隐喻贯穿命名：`Furnace`（熔炉＝页面根容器）、`Rod`（炼金杖＝消息入口）、
  `Potion`（药剂＝一条指令）、`Alchemical*`（炼金组件）。
- 当前进度：**组件创建链路（UPDATE_COMPONENT）可用；数据更新链路（UPDATE_DATA）设计进行中且构建失败**
  （见第 15 节）。

---

## 2. 技术栈与运行环境

| 项 | 值 |
| --- | --- |
| 平台 | HarmonyOS（Stage 模型），`runtimeOS: "HarmonyOS"` |
| 语言 / UI | ArkTS / ArkUI，**状态管理 V2**（`@ComponentV2` / `@ObservedV2`） |
| SDK 版本 | `targetSdkVersion` / `compatibleSdkVersion` = `6.1.0(23)` |
| 构建系统 | hvigor（本机实测 `6.23.5`），`modelVersion 6.1.0` |
| 包管理 | ohpm（`oh-package.json5`），依赖 `@ohos/hypium` 1.0.25、`@ohos/hamock` 1.0.0（dev） |
| 应用包名 | `com.alchemy.nothingisanything` |
| 目标设备 | `phone`（entry） |

> **重要**：本仓库**没有提交 `hvigorw` / `hvigor/hvigor-wrapper.js` 包装脚本**。
> 命令行构建必须使用 DevEco Studio 自带的 hvigor（见第 10 节）。
> *建议改进项*：补上 wrapper 以保证构建可复现（属独立任务，需单独提交）。

---

## 3. 仓库结构与模块职责

```
NothingIsAnything/
├── AppScope/                        应用级配置与资源（app.json5、图标）
├── build-profile.json5              工程级构建配置：products + modules 清单
├── code-linter.json5                Code Linter 规则（performance + typescript-eslint + security）
├── hvigorfile.ts                    工程级 hvigor 任务（appTasks）
├── oh-package.json5                 根依赖
├── entry/                           【HAP】可运行宿主应用（演示外壳）
│   ├── src/main/ets/entryability/   UIAbility 生命周期
│   ├── src/main/ets/pages/Index.ets 演示页：读取 rawfile JSON → 定时喂给 AlchemicalRod
│   ├── src/main/resources/rawfile/alchemy_message_demo.json   指令流样例
│   └── src/{test,ohosTest}/         Hypium 测试
└── Alchemy/                         【HAR】核心引擎库（对外包名 @gxxxxt/alchemy）
    ├── Index.ets                    库的公开出口（唯一 export 面）
    ├── src/main/ets/interface/      ★ 对外契约层（稳定 API，改这里要极其谨慎）
    │   ├── Alchemy.ets              Potion / PotionType / ComponentDescriptor / DataDescriptor
    │   ├── AlchemicalRod.ets        AlchemicalRod 接口 + AlchemicalRodCreator 工厂 + Options
    │   └── AlchemicalFurnace.ets    对外 @ComponentV2 根组件
    ├── src/main/ets/engine/
    │   ├── core/                    实现层
    │   │   ├── AlchemicalRod.ets        AlchemicalRodImpl：消息 → 节点树
    │   │   └── AlchemicalFurnace.ets    AlchemicalFurnaceImpl：节点树 → 渲染
    │   ├── components/              AlchemicalNode + 每个组件一个文件 + 两张注册表
    │   ├── common/AlchemicalUtils.ets   消息解析、属性赋值
    │   ├── type/AlchemicalType.ets      MessageToInstruction（线上报文结构）
    │   └── datamodel/AlchemicalData.ets 数据层（⚠️ 未完成、未被引用，见第 15 节）
    └── src/main/resources/rawfile/v1.0/
        ├── common.json              JSON Schema 公共定义
        └── AlchemicalComponents/*.json   每个组件的 JSON Schema
```

**分层约定**（以现有代码为准，双向依赖是既定设计，不要"顺手纠正"）：

- `interface/` = **对外契约 + 门面（facade）**：定义 `AlchemicalRod` / `AlchemicalFurnace` 等公开接口，
  并 import `engine/core/*Impl` 完成装配（`AlchemicalRodCreator` 返回 `AlchemicalRodImpl`）。
- `engine/` = **实现**：可 import `interface/` 中的契约类型（枚举、Descriptor、接口）。
- **契约类型只能在 `interface/Alchemy.ets` 单点定义**。`engine/` 内不得另行定义同义的结构
  （例如再写一个 `ComponentDescriptor`）；`engine/type/AlchemicalType.ets` 只负责**线上报文结构**。
- 对外可见面由 `Alchemy/Index.ets` **唯一**决定。新增对外类型必须在此 export，
  否则 `entry/` 无法使用（`entry/` 现仅 import `@gxxxxt/alchemy`，禁绝深路径 import）。

---

## 4. 核心架构：一次炼金反应的完整链路

```
外部消息（JSON 字符串）
        │
        ▼
AlchemicalRod.onReceive(message)                     interface/AlchemicalRod.ets
        │                                            （实例由 AlchemicalRodCreator.forgeAlchemicalRod 创建）
        ▼
AlchemicalUtils.parseMessage(message)                engine/common/AlchemicalUtils.ets
        │   JSON.parse → MessageToInstruction[]
        │   逐条取 key（UPDATE_DATA | UPDATE_COMPONENT）
        ▼
   AlchemicalPotion[]  { type, value }
        │
        ▼
AlchemicalRodImpl.onReceive → 按 potion.type 分发      engine/core/AlchemicalRod.ets
        ├── UPDATE_COMPONENT → updateComponents(ComponentDescriptor)
        └── UPDATE_DATA      → updateDataModel(DataDescriptor)      ← 当前未完成
        │
        ▼
AlchemicalNode 树 + nodeList: Map<string, AlchemicalNode>   engine/components/AlchemicalNode.ets
        │   （@ObservedV2 + @Trace，可实现细粒度刷新）
        ▼
AlchemicalFurnaceImpl（@ComponentV2）                 engine/core/AlchemicalFurnace.ets
        │   aboutToAppear: nodeList.set('root', rootNode)
        │                   alchemicalRod.registerAlchemicalFurnaceImpl(this)
        │   build(): AlchemicalComponent(rootNode)
        ▼
AlchemicalComponent                                  engine/components/AlchemicalComponent.ets
        │   componentMap.get(node.type) → MutableBuilder
        │   builder(UIUtils.makeBinding(() => node))
        ▼
AlchemicalText / AlchemicalColumn / AlchemicalGrid / ...   读取 node.attr 渲染
        └── 容器组件（Column/Row/List/Grid）通过 ForEach + AlchemicalComponent 递归子节点
```

### 4.1 两张注册表（必须同步维护）

`AlchemicalComponent.ets` 中定义了两个 `static Map`，二者**必须成对存在**：

| 注册表 | 作用 | 缺失后果 |
| --- | --- | --- |
| `componentMap: Map<string, MutableBuilder<...>>` | `componentType` → 渲染 Builder | 节点渲染为空白 |
| `componentAttributeMap: Map<string, (params) => BasicAlchemyAttribute>` | `componentType` → 属性对象工厂 | `updateComponents` 静默 return，节点不更新 |

当前已注册的 `componentType`（PascalCase，与 ArkUI 组件名对齐）：
`Blank, Button, Checkbox, Column, Divider, Grid, Image, List, Row, Slider, Text, TextInput`。

### 4.2 协议的行为约束（当前实现）

- **父先于子**：`nodeList` 初始只有 `'root'`。一个 id 只有在被其父节点的 `child` 列表引入后才可寻址。
  因此指令流**必须按「父 → 子」顺序**下发（`alchemy_message_demo.json` 与 `Index.ets` 的
  200ms 定时投递正是为此）。乱序下发会被**静默忽略**。
- **无删除语义**：`AlchemicalNode.removeChild` 已实现但无任何调用方；协议目前没有 `REMOVE` 指令。
- **`updateComponents` 是 upsert-like**：对已存在 id 重复下发会覆盖 `type`/`attr` 并重复 `addChild`
  （同 id 在 `Map` 中幂等），但**不支持重新挂载父节点**，跨父迁移会同时残留在两个父的 children 中。
- **静默失败**：`nodeList` 查不到 id 时直接 `return`，无日志。这是当前最常见的调试黑洞。

> **待决策**：是否引入 `REMOVE_COMPONENT`、是否让未知 id 报错/打日志（见第 15 节）。

---

## 5. 消息协议规范

### 5.1 线上报文结构（`engine/type/AlchemicalType.ets`）
=======
### 1.1 一句话定位

**NothingIsAnything / Alchemy 是一个 HarmonyOS（ArkTS + ArkUI 声明式 V2）的「服务端驱动 UI」渲染引擎**：
外部（服务端/本地 JSON）下发一串**炼金药剂消息**，引擎把它解析为**节点树**，并动态渲染为真实 ArkUI 组件。

命名隐喻贯穿全局，读代码时请对照理解：

| 隐喻名 | 实际职责 |
| --- | --- |
| **AlchemicalRod（炼金杖）** | 消息接收器 / 外部唯一入口，`onReceive(message: string)` |
| **AlchemicalFurnace（炼金熔炉）** | 顶层容器组件，持有 root 节点树并负责渲染 |
| **AlchemicalNode（炼金节点）** | 组件树上的一个节点（id / type / attr / children） |
| **AlchemicalComponent（炼金组件）** | 递归渲染单元，按 `type` 查表分发到具体 builder |
| **AlchemicalPotion（药剂）** | 一次变更指令（`UPDATE_COMPONENT` 或 `UPDATE_DATA`） |
| **AlchemicalAttribute（属性）** | 节点的可观察属性对象（`@ObservedV2` + `@Trace`） |

### 1.2 技术栈与运行环境

| 项 | 值 |
| --- | --- |
| 语言 / UI 框架 | ArkTS / ArkUI 声明式开发范式 **V2**（`@ComponentV2`、`@ObservedV2`、`@Trace`、`@Local`、`@Param`、`@Require`） |
| 运行时 | HarmonyOS，Stage 模型 |
| SDK | `compatibleSdkVersion` / `targetSdkVersion` = `6.1.0(23)` |
| 包管理 | ohpm（`oh-package.json5`），测试依赖 `@ohos/hypium@1.0.25`、`@ohos/hamock@1.0.0` |
| 构建 | hvigor（`hvigor-config.json5` modelVersion `6.1.0`） |
| 测试框架 | Hypium（`describe` / `it` / `expect`） |
| 代码检查 | DevEco CodeLinter（规则见 `code-linter.json5`：`plugin:@performance/recommended` + `plugin:@typescript-eslint/recommended`） |
| 工程结构 | 1 个 entry（HAP） + 1 个 Alchemy（HAR 共享库） |
| bundleName | `com.alchemy.nothingisanything` |

### 1.3 目录结构与职责边界

```
NothingIsAnything/
├── AGENT.md                      # ← 本文件：AI 开发规范
├── docs/                         # ← 流程产物：模板 / 每个变更的文档目录
│   ├── README.md
│   ├── templates/                # 5 份空白模板
│   └── changes/                  # 每个需求的变更目录 REQ-<日期>-<slug>/
├── AppScope/app.json5            # 应用级配置
├── build-profile.json5           # 产品/模块/构建模式定义
├── code-linter.json5             # CodeLinter 规则
├── oh-package.json5              # 根依赖（hypium / hamock）
│
├── Alchemy/                      # ★ 引擎本体（HAR，包名 @gxxxxt/alchemy）
│   ├── Index.ets                 # ★ HAR 唯一对外出口（见 1.6 导出契约）
│   └── src/
│       ├── main/ets/
│       │   ├── interface/        # 【对外契约层】稳定 API，外部只依赖这层
│       │   │   ├── Alchemy.ets            #   AlchemicalPotionType / ComponentDescriptor / DataDescriptor / AlchemicalPotion
│       │   │   ├── AlchemicalRod.ets      #   AlchemicalRodOptions / AlchemicalRod / AlchemicalRodCreator
│       │   │   └── AlchemicalFurnace.ets  #   对外暴露的 @ComponentV2 struct
│       │   └── engine/           # 【内部实现层】外部不得直接 import
│       │       ├── core/         #   AlchemicalRodImpl（消息分发）/ AlchemicalFurnaceImpl（渲染根）
│       │       ├── components/   #   AlchemicalNode + 每个组件的 Attribute/Builder/Struct
│       │       ├── common/       #   AlchemicalUtils（消息解析、属性赋值）
│       │       ├── type/         #   MessageToInstruction（线上报文结构）
│       │       └── datamodel/    #   AlchemicalData（数据模型，当前为空实现）
│       ├── main/resources/rawfile/v1.0/   # ★ 协议 JSON Schema 规则（AI 生成 UI 的约束源）
│       │   ├── common.json
│       │   └── AlchemicalComponents/*.json
│       ├── test/                 # 本地单元测试（LocalUnit.test.ets）
│       └── ohosTest/             # 设备侧集成测试
│
└── entry/                        # 演示/宿主应用（HAP）
    └── src/main/
        ├── ets/pages/Index.ets   # 演示页：读 rawfile 模拟流式下发消息
        └── resources/rawfile/alchemy_message_demo.json  # ★ 协议样例报文
```

**分层铁律**

- `interface/` 是对外契约，**只能**通过 `Alchemy/Index.ets` 导出；修改签名 = 破坏性变更，必须走「协议变更清单」（5.4）。
- `engine/` 是实现细节，**禁止**从 `entry` 或其他模块直接 import `engine/**`。
- `entry/` 只做「宿主 + 演示」，**禁止**把引擎逻辑写进 entry。

### 1.4 核心架构与数据流

```
外部消息(JSON 字符串)
        │
        ▼
AlchemicalRod.onReceive(message)                     ← interface/AlchemicalRod.ets
        │
        ▼
AlchemicalRodImpl.onReceive()                        ← engine/core/AlchemicalRod.ets
        │  ① AlchemicalUtils.parseMessage()  →  AlchemicalPotion[]
        │     报文 {version, UPDATE_COMPONENT?|UPDATE_DATA?} → 按 key 判定 type
        ▼
   ┌────────────────────────┬─────────────────────────┐
   │ UPDATE_COMPONENT       │ UPDATE_DATA             │
   │ updateComponents()     │ updateDataModel()       │
   │  · 从 nodeList 找节点   │  · ⚠ 当前为空实现        │
   │  · 设 type / attr       │                         │
   │  · 新增 child 占位节点   │                         │
   └────────────────────────┴─────────────────────────┘
        │
        ▼
AlchemicalFurnaceImpl (@ComponentV2)                 ← engine/core/AlchemicalFurnace.ets
   rootNode + nodeList: Map<string, AlchemicalNode>
   aboutToAppear(): 注册自身到 Rod（registerAlchemicalFurnaceImpl）
        │
        ▼
AlchemicalComponent 递归渲染                          ← engine/components/AlchemicalComponent.ets
   查 componentMap 得到 builder → 调用 builder(UIUtils.makeBinding(...))
        │
        ▼
具体组件 struct（AlchemicalText / Button / Column / Row / List / Grid / ...）
   容器组件对 getChildren() 做 ForEach，递归回到 AlchemicalComponent
```

**关键机制说明**

- **响应式**：`AlchemicalNode` 与 `BasicAlchemyAttribute` 都是 `@ObservedV2`，字段用 `@Trace` 标注，
  因此 `AlchemicalRodImpl` 在普通类中直接改 `node.type` / `node.attr` 即可驱动 UI 刷新。
- **双向桥接**：Rod 是普通类（非组件），无法直接拿 UI 状态；因此由 Furnace 在 `aboutToAppear` 时
  把自身注册给 Rod（`registerAlchemicalFurnaceImpl`），形成「Rod 改节点 → Furnace 重渲染」链路。

### 1.5 消息协议（线上契约）

**报文形态**：JSON **数组**，每个元素是一条指令。
>>>>>>> 0ad8b67 (Development Specifications for AGENT System)

```jsonc
[
  {
<<<<<<< HEAD
    "version": "1.0",
    "UPDATE_COMPONENT": {
      "id": "contentText",          // 必填，全局唯一，ASCII
      "componentType": "Text",      // 必填，必须是注册表中的 key
      "child": ["a", "b"],          // 可选，仅容器组件；值是他处定义的 id 列表，禁止内联子组件
      "params": { "text": "你好" }   // 组件初始化参数
=======
    "version": "1.0",                         // 必填
    "UPDATE_COMPONENT": {                     // 与 UPDATE_DATA 二选一
      "id": "contentText",                    // 节点唯一 id（root 为根）
      "componentType": "Text",                // 必须是已注册的组件类型
      "child": ["childA", "childB"],          // 可选；只放 id，禁止内联子组件定义
      "params": { "text": "你好", "width": "100%" }
>>>>>>> 0ad8b67 (Development Specifications for AGENT System)
    }
  },
  {
    "version": "1.0",
<<<<<<< HEAD
    "UPDATE_DATA": {
      "id": "contentText",
      "value": { }                  // 语义未定，见第 15 节
    }
=======
    "UPDATE_DATA": { "id": "progressSlider", "value": 50 }   // ⚠ 见已知问题 #3
>>>>>>> 0ad8b67 (Development Specifications for AGENT System)
  }
]
```

<<<<<<< HEAD
顶层是**数组**，每个元素携带 `version` 与**恰好一个** `UPDATE_*` 键。
`AlchemicalUtils.parseMessage` 用 `Object.keys(...).find()` 取第一个匹配键，因此：
**一条报文里不得同时出现 `UPDATE_DATA` 和 `UPDATE_COMPONENT`**（第二个会被丢弃）。

### 5.2 规则

1. `version` 目前未被消费。引入不兼容协议变更时**必须**先启用版本校验，不得默默改语义。
2. `componentType` 必须是 `componentMap` 与 `componentAttributeMap` 中都存在的 key，大小写敏感。
3. `params` 的字段名必须与对应 `Alchemy*Attribute` 类的**声明字段名和类型**一致。
4. `id` 必须 ASCII、稳定、唯一。建议 `<语义><序号>`（`submitButton`、`gridItem1`）。
5. **禁止内联子树**。子组件一律先独立定义，再由父级 `child` 引用（沿用现有 schema 说明）。

---

## 6. 标准流程：新增一个 Alchemical 组件

新增组件必须**同时**完成以下 6 步，缺一不可视为未完成。

以新增 `Progress` 为例：

**① 新建 `Alchemy/src/main/ets/engine/components/AlchemicalProgress.ets`**

遵循现有文件模板（`AlchemicalSlider.ets` 是最完整的参考）：

```ts
/* Apache-2.0 许可证头，见第 7.1 节 —— 必须原样复制 */

import { AlchemicalNode, BasicAlchemyAttribute } from './AlchemicalNode';
import { MutableBinding } from '@kit.ArkUI';
import { AlchemicalUtils } from '../common/AlchemicalUtils';

@ObservedV2
export class AlchemyProgressAttribute extends BasicAlchemyAttribute {
  @Trace value: number = 0;          // 仅用 @Trace 标注需要参与刷新的字段

  constructor(params: object | undefined = undefined) {
    super(params);                   // 注意：super 已赋值一次
    if (!params) {
      return;
    }
    AlchemicalUtils.assign(this, params);
  }
}

@Builder
export function progressComponentBuilder(componentNode: MutableBinding<AlchemicalNode>): void {
  AlchemicalProgress({ componentNode: componentNode.value });
}

@ComponentV2
export struct AlchemicalProgress {
  @Require @Param componentNode: AlchemicalNode;

  build() {
    Progress({ value: (this.componentNode.attr as AlchemyProgressAttribute).value })
      .width(this.componentNode.attr.width)
      .height(this.componentNode.attr.height)
  }
}
```

**② 在 `AlchemicalComponent.ets` 注册到两张表**（import + `componentMap` + `componentAttributeMap`）。

**③ 新建 JSON Schema `Alchemy/src/main/resources/rawfile/v1.0/AlchemicalComponents/AlchemicalProgress.json`**
（结构规范见第 9 节）。

**④ 若为容器组件**：import `AlchemicalComponent`，用 `ForEach(this.componentNode.getChildren(), ...)`
递归渲染子节点，并**必须提供 keyGenerator**（见第 12 节）。

**⑤ 在 `entry/src/main/resources/rawfile/alchemy_message_demo.json` 增加一条可观测的样例指令**。

**⑥ 执行第 10 节构建，直到通过**。

> 属性类命名沿用现存写法 `Alchemy<Name>Attribute`（注意历史上是 `Alchemy` 而非 `Alchemical`）。
> 该不一致属已知外观问题，**不要顺手全仓重命名**；如需统一，另开独立提交并同步所有引用。

---

## 7. 编码规范

### 7.1 许可证头（强制）

`Alchemy/` 下**每个新建 `.ets` 文件**必须原样包含以下头部（年份、署名保持不变）：

```ts
/*
 * Copyright 2026 GXXXXT
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
```

（`entry/` 下既有文件并不统一，新建 `interface/`、`engine/` 文件一律带头部。）

### 7.2 命名

| 类别 | 约定 | 示例 |
| --- | --- | --- |
| 对外接口 / 类型 | `Alchemical*` / PascalCase | `AlchemicalRod`, `AlchemicalPotion` |
| 实现类 | `Alchemical*Impl` | `AlchemicalRodImpl` |
| 属性类 | `Alchemy*Attribute` | `AlchemyTextAttribute` |
| Builder 函数 | `<lowerCamel>ComponentBuilder` | `sliderComponentBuilder` |
| 组件文件 | `Alchemical<Name>.ets` | `AlchemicalTextInput.ets` |
| `componentType` | PascalCase，与 ArkUI 组件同名 | `"TextInput"` |

### 7.3 ArkTS / ArkUI 状态管理 V2

- 可观察数据模型用 `@ObservedV2` class + `@Trace` 字段；**只有需要驱动 UI 刷新的字段才加 `@Trace`**。
- UI 组件用 `@ComponentV2` struct + `@Param`（入参）/ `@Local`（自持状态）。
- 传给 `@Builder` 的响应式对象使用 `MutableBinding<T>` + `UIUtils.makeBinding(() => value)`，
  这是当前把可观察节点送进 Builder 的既定方式，不要改成普通参数传递。
- **禁止对 `static` 成员使用 `@Trace` / `@Local` / `@Param`**（V2 装饰器作用于实例字段）。
- `@Require @Param` 用于必填参数；调用方漏传应在编译期失败，不要用可选类型掩盖。

### 7.4 类型与健壮性

- 禁止 `any`、`unknown` 兜底、`as any`。跨边界类型不匹配时，修正类型定义或显式解析。
- 索引访问与反射赋值（`Reflect.set`）会绕过编译期检查。`AlchemicalUtils.assign` 属于此类，
  调用前必须保证 `params` 已被 schema 校验，且**键名白名单受限**（防 `__proto__`/`constructor` 污染）。
- 可能抛异常的 API（`getRawFileContentSync`、`JSON.parse` 等）必须用 `try/catch` 包裹或显式处理。
  编译器会给出 `Function may throw exceptions` 警告，**不要把警告当噪声忽略**。
- `JSON.parse` 的结果必须视为不可信输入：先校验 `id` / `componentType` / `params` 结构，
  再进入引擎。**不得**把未校验对象直接喂给 `assign` 或注册表查询。

### 7.5 注释

- **注释、字符串字面量、JSON `description` 可以使用中文**；这是本项目既定风格。
- **标识符、关键字、代码语句必须是 ASCII**。出现中文标识符一律视为事故（见第 12 节）。
- 公开的 `interface` / `class` / `enum` / 关键方法使用 TSDoc（`/** ... */`），说明职责与用法。

### 7.6 导入

- 使用相对路径导入模块内文件，保持与现有文件一致的写法（不带 `.ets` 后缀）。
- 只导入真正使用的符号；**删除未使用 import**。禁止 `import * as`。

---

## 8. 属性类（Attribute）规范

- 每个组件一个独立文件，内含「`Alchemy<Name>Attribute` 类 + Builder 函数 + `Alchemical*` struct」。
- 属性类 **必须继承 `BasicAlchemyAttribute`**（它提供 `width` / `height` 并处理 `params` 赋值）。
- 属性字段 **必须给定明确的默认值**，不得出现 `undefined` 初始值。
- 属性字段的**类型必须与 JSON Schema 声明一致**，且与 demo 报文实际取值一致。
  典型反例：`BasicAlchemyAttribute.width: string`，而 demo 中 `"width": 200` 是 number。
  **不要制造这种类型谎言**；需要数值尺寸时用 `number | string` 联合类型并显式转换。
- 渲染 struct 中读取属性时使用 `this.componentNode.attr as Alchemy<Name>Attribute` 的既有模式。
- 新增属性字段时，同步更新该组件的 JSON Schema 与至少一条样例指令。

---

## 9. JSON Schema 规范

`AlchemicalComponents/*.json` 必须在结构上**合法**且**彼此一致**。以 `AlchemicalColumn.json`
的正确写法为准：

```json
{
  "type": "object",
  "properties": {
    "id": { "$ref": "../common.json#/$defs/ComponentId" },
    "componentType": { "const": "Column" },
    "child": {
      "type": "array",
      "items": { "type": "string" },
      "description": "The ID lists of the child component. Do NOT define the child component inline."
    },
    "params": {
      "type": "object",
      "properties": { },
      "required": [ ]
    }
  },
  "required": ["id", "componentType"]
}
```

**必须遵守**：

1. `params` 有字段时**必须**写成 `{ "type": "object", "properties": {...} }`，
   不得把字段定义直接平铺在 `params` 下。
2. `child` 是**字符串数组**：`"type": "array", "items": { "type": "string" }`。
   （历史上写成 `"type": "object"` 是错的。）
3. `required` 只列**同级**字段名。禁止 `"params.text"` 这种点号路径——
   应在 `params` 内部用嵌套 `required: ["text"]` 表达。
4. `componentType` 的 `const` 必须与两张注册表的 key 完全一致。
5. `params` 字段的类型/名称必须与对应 Attribute 类字段一致。

---

## 10. 构建与验证（唯一可信的完成判据）

本机无全局 `hvigorw` / `ohpm`，使用 DevEco Studio 自带工具链：

```bash
# 1) 准备环境（每次新 shell 都要执行）
export DEVECO_SDK_HOME="/Applications/DevEco-Studio.app/Contents/sdk"
export PATH="/Applications/DevEco-Studio.app/Contents/tools/node/bin:$PATH"
HVIGORW="/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw"

# 2) 安装/同步依赖（改过 oh-package.json5 后执行）
/Applications/DevEco-Studio.app/Contents/tools/ohpm/bin/ohpm install --all

# 3) ★ 主验证命令：编译 entry(debug)，同时会编译 Alchemy 依赖
cd /Volumes/MacExtHD/Code/NothingIsAnything
"$HVIGORW" assembleHap --mode module -p product=default -p buildMode=debug --no-daemon

# 4) 仅验证 Alchemy HAR
"$HVIGORW" assembleHar --mode module -p product=default -p buildMode=debug --no-daemon

# 5) 清理
"$HVIGORW" clean --no-daemon
```

**判据**：命令输出中必须出现 `BUILD SUCCESSFUL`，且**不得**出现任何
`ArkTS Compiler Error` / `ERROR: Failed :...@CompileArkTS`。

- 只跑第 3 条即可覆盖库代码；若只改 Alchemy 且想更快，可用第 4 条。
- `code-linter.json5` 的规则目前只能通过 DevEco Studio 的 **Code Linter** 界面执行
  （工具链未提供独立 CLI）。涉及安全规则（`@security/*`）的改动必须在 IDE 中跑一遍 Linter。
- **注意**：`@CompileArkTS` 只编译依赖可达的文件。**未被任何文件 import 的 `.ets` 文件不会被编译，
  其中的语法错误不会暴露**。新增文件后必须真正接线（import）或用构建确认其可达性。

---

## 11. 测试规范

- 框架：Hypium（`@ohos/hypium`）。
- 单元测试：`<module>/src/test/`（`LocalUnit.test.ets` + `List.test.ets` 聚合）。
  新增套件后必须挂到 `List.test.ets` 的 `testsuite()` 中，否则不会执行。
- 仪器测试：`<module>/src/ohosTest/`。
- 被测逻辑应尽量下沉到**纯逻辑层**（`AlchemicalUtils.parseMessage`、`AlchemicalNode` 树操作、
  属性赋值），这类代码无需 UI 环境即可单测。
- 每个新协议特性（新 `UPDATE_*` 指令、新解析分支）**至少一条**正向 + 一条异常输入用例。
- 测试代码不要求 Apache 许可证头（`code-linter.json5` 已忽略 `src/test`、`src/ohosTest`、`src/mock`）。

---

## 12. 禁止事项（反模式清单）

以下每一条都对应本仓库**真实发生过**的缺陷，务必逐条自查。

| # | 禁止 | 原因 / 真实事故 |
| --- | --- | --- |
| 1 | **复制粘贴方法后不修改语义** | `AlchemicalRodImpl.updateDataModel` 是 `updateComponents` 的整段复制，仍引用 `DataDescriptor` 上不存在的 `componentType`/`params`/`child`，直接导致构建失败。复制后必须逐行核对方法名与实现是否自洽。 |
| 2 | **在代码语句中出现非预期中文/全角字符** | `engine/datamodel/AlchemicalData.ets` 中混入孤立中文（`寒假姐`），属输入法残留。该类文件一旦被 import 即刻编译失败。 |
| 3 | **留下未使用的变量 / import / 死代码** | `AlchemicalData.updateDataModel` 中 `const parse = JSON.parse(value)` 从未使用；提交 `eb62b6e` 曾清理 `AlchemicalRod.ets` 中未使用的 `AlchemyButtonAttribute` / `AlchemyTextAttribute` 导入；`AlchemicalNode.removeChild` 至今无调用方。 |
| 4 | **把 `@Trace` 用在 `static` 成员上** | `AlchemicalData.dataModel` 的写法不符合 V2 语义，无法驱动刷新。 |
| 5 | **用 `sed`/正则批量替换跨文件符号** | `.claude/settings.local.json` 中残留的 sed 记录显示曾用整批替换改 import。批量替换会误伤同名符号；改用精确的逐文件编辑。 |
| 6 | **新增组件只改一张注册表** | 只加 `componentMap` 不加 `componentAttributeMap` → 节点渲染出来但永远不更新；反之则静默无反应。 |
| 7 | **`ForEach` 不提供 keyGenerator** | `AlchemicalColumn/Row/List/Grid` 目前均缺失。`Map` 派生的数组在增删时可能复用错误节点；容器组件请补 `(item) => item.id`。 |
| 8 | **静默 `return`、不写日志** | id 未命中 `nodeList` 时无任何反馈，是当前主要调试障碍。新增失败分支必须 `hilog` 记录 id 与原因。 |
| 9 | **跳过构建就宣布完成** | 违反第 0.4 条。 |
| 10 | **改动 `interface/` 却不检查调用方** | `DataDescriptor` 的字段变更（工作区未提交）已使 `engine/` 编译失败，属典型契约漂移。 |

### 提交前自查命令

> 本机**未安装 `rg`（ripgrep）**，且 macOS 自带的是 BSD `grep`（**不支持 `-P`**）。
> 请使用下面已在 macOS 上实测通过的命令（注意排除 `build/` 产物目录）。

```bash
cd /Volumes/MacExtHD/Code/NothingIsAnything

# a) ★ 找出「非注释行」中出现的非预期中文。
#    注释内的中文合法；若命中的是字符串字面量内的中文亦属合法，但必须逐条人工确认。
grep -rn '[一-龥]' --include='*.ets' Alchemy entry 2>/dev/null \
  | grep -v '/build/' \
  | grep -vE ':[0-9]+:[[:space:]]*(\*|//|/\*)' || echo "OK: 无非注释中文"

# b) 找出未被任何文件引用的 .ets（不可达文件不会参与编译，错误会被隐藏）
grep -rn "AlchemicalData" --include='*.ets' Alchemy entry 2>/dev/null \
  | grep -v '/build/' | grep -v 'AlchemicalData\.ets' || echo "AlchemicalData 未被引用"

# c) 确认两张注册表的 key 集合一致（下面前 12 行是 componentMap，后 12 行是 componentAttributeMap）
grep -nE "^\s*\['" Alchemy/src/main/ets/engine/components/AlchemicalComponent.ets

# d) 查看待提交改动
git status --short && git diff --stat
```

---

## 13. 提交规范

- **信息格式**：`<动词开头的英文短句>`（首字母大写，不用句点），例如
  `Added data update capability`、`Adjust and implement the architecture`。
- **必须携带 DCO 签名行**（本仓库历史惯例）：

  ```
  <Subject line>

  Signed-off-by: Name <email>
  ```

  使用 `git commit -s` 自动生成。
- 一个提交一个主题；重构与行为变更分开。
- 不得提交 `build/`、`.hvigor/`、`oh_modules/`、IDE 本地设置等产物。
- *建议改进项*：将 `.claude/` 加入 `.gitignore`（当前未被忽略，会污染提交）。

---

## 14. 完成定义（Definition of Done）

AI 代理宣布任务完成前，必须逐项确认：

- [ ] 变更范围与开工声明一致，无越界改动
- [ ] 未使用 import / 变量 / 死代码已清除
- [ ] 无中文标识符、无输入法残留、无调试输出
- [ ] 新增/修改的 `.ets` 均带许可证头（`Alchemy/` 下）
- [ ] 若新增组件：两张注册表 + JSON Schema + demo 样例 + 测试**全部**到位
- [ ] 若改协议：`interface/` 契约与所有调用方已同步更新
- [ ] 若改 schema：结构合法（第 9 节五条硬规则）
- [ ] 已执行第 10 节构建命令，输出含 `BUILD SUCCESSFUL` 且无 `ArkTS Compiler Error`
- [ ] 新增测试已挂到 `List.test.ets`
- [ ] 交付说明写明：变更文件清单 / 验证命令 / 真实验证结果 / 未决问题

---

## 15. 已知问题与待决策（当前工作区状态）

> 状态快照：`dev` 分支，工作区**有未提交改动**（`interface/Alchemy.ets` 已修改、
> `engine/datamodel/` 未纳入版本控制）。**当前构建失败。**

### 15.1 阻塞性缺陷（必须先修）

1. **构建失败 — `ArkTS Compiler Error`（编译器汇总 `ERROR:6 WARN:1`，明确列出 5 处）**
   位置：`Alchemy/src/main/ets/engine/core/AlchemicalRod.ets:88,90,97,101`
   原因：`updateDataModel(value: DataDescriptor)` 引用了 `DataDescriptor` 上不存在的
   `componentType` / `params` / `child`。`interface/Alchemy.ets` 已将 `DataDescriptor`
   改为 `{ id: string; value: object }`，但实现层未同步。
   → 属第 12 节第 1 条与第 10 条反模式，**需要设计决策，不应机械修补**。

2. **`engine/datamodel/AlchemicalData.ets` 不可编译**
   - 混入孤立中文残留（第 12 节第 2 条）；
   - `updateDataModel` 有未使用变量、无实现；
   - `@Trace private static dataModel` 装饰器用法不合法；
   - 该文件**未被任何文件 import**，因此错误被构建"隐藏"了。
   → 该目录未纳入 git（`?? Alchemy/src/main/ets/engine/datamodel/`）。

### 15.2 待决策（需项目负责人确认，AI 不得自行发明）

1. **`UPDATE_DATA` 的语义**：`value` 是「按 id 局部覆盖某节点属性对象的若干字段」，
   还是「写入一份独立于 UI 树的数据仓库（由属性做响应式绑定）」？
   两种设计的引擎改动量差异很大，先定语义再写代码。
2. **数据层归属**：`AlchemicalData` 的 `Map<string, AlchemicalData[]>` 静态仓库是否是最终方案？
   是否应改为实例化并挂到 `AlchemicalFurnaceImpl`（便于多实例、便于测试与释放）？
3. **失败策略**：未知 id / 未注册 `componentType` 应该「打日志并忽略」「抛异常」还是
   「创建占位节点」？建议至少 `hilog` + 可配置的严格模式。
4. **删除与重排**：是否需要 `REMOVE_COMPONENT` / `MOVE_COMPONENT`？
   `AlchemicalNode.removeChild` 目前是死代码。
5. **协议版本校验**：`version` 字段是否启用（第 5.2 节第 1 条）？
6. **JSON Schema 校验时机**：在 `parseMessage` 入口做一次全量校验，
   还是仅在开发/调试构建中校验？关系到安全（第 7.4 节）与性能的取舍。

### 15.3 非阻塞改进项

- 组件 JSON Schema 存在多处结构错误（`params` 未包裹、`child` 类型错、`required` 用点号路径），
  集中在 `AlchemicalText/Button/Checkbox/Image/Slider/TextInput`。
- `BasicAlchemyAttribute.width/height` 声明为 `string`，但 demo 传入 number。
- `AlchemicalColumn/Row/List/Grid` 的 `ForEach` 缺少 keyGenerator。
- 仓库缺少 `hvigorw` wrapper，命令行构建依赖本机 DevEco Studio 路径。
- `.claude/settings.local.json` 含过期 sed 权限记录；`.claude/` 未被 `.gitignore` 忽略。
- `entry/src/test`、`src/ohosTest` 仅有脚手架用例，无真实断言覆盖引擎。
- `AlchemicalRodImpl.updateDataModel` 中 `this.alchemicalFurnace!` 使用非空断言，
  若 `onReceive` 早于 `aboutToAppear` 调用会空指针。

---

## 16. 常见任务速查

| 任务 | 关键动作 |
| --- | --- |
| 新增可渲染组件 | 第 6 节 6 步（组件文件 + 两张注册表 + schema + demo + 构建） |
| 新增协议指令 | 改 `interface/Alchemy.ets` 枚举与 Descriptor → `AlchemicalType.ets` → `AlchemicalUtils.parseMessage` → `AlchemicalRodImpl` 分发 → schema/测试 → 构建 |
| 排查"节点不更新" | 依次查：id 是否在 `nodeList`（父是否先下发）→ `componentType` 是否在两张表 → `params` 字段名是否匹配 Attribute → 属性是否加了 `@Trace` |
| 排查"编译报错但文件看着没错" | 确认文件是否被 import（不可达文件不参与编译） |
| 修改对外 API | 从 `Alchemy/Index.ets` 出口开始，逐一检查 `entry/` 与 `engine/` 调用方 |
| 验证改动 | 第 10 节 `assembleHap`，要求 `BUILD SUCCESSFUL` |

---

**本规范由项目现状反推制定，会随架构演进更新。**
**修改本文件需与代码变更同一提交，并说明理由。**
**若规范与代码冲突，视为代码存在待修缺陷，而不是规范可以忽略。**
=======
**类型定义位置**（改动必须同步）

| 概念 | 文件 |
| --- | --- |
| `AlchemicalPotionType` / `ComponentDescriptor` / `DataDescriptor` / `AlchemicalPotion` | `Alchemy/src/main/ets/interface/Alchemy.ets` |
| `MessageToInstruction`（报文结构） | `Alchemy/src/main/ets/engine/type/AlchemicalType.ets` |
| 协议 JSON Schema 规则 | `Alchemy/src/main/resources/rawfile/v1.0/**` |
| 样例报文 | `entry/src/main/resources/rawfile/alchemy_message_demo.json` |

### 1.6 对外导出契约（`Alchemy/Index.ets`）

当前**仅**导出三项，新增对外 API 必须显式在此登记：

```ts
export { AlchemicalFurnace } from './src/main/ets/interface/AlchemicalFurnace'
export { AlchemicalRod, AlchemicalRodCreator } from './src/main/ets/interface/AlchemicalRod'
```

### 1.7 组件注册机制（★ 多处联动，最易漏）

新增/修改一个组件类型 `X` 时，**必须同步以下位置**，缺一处即产生「静默失效」（不报错但渲染错乱）：

| # | 位置 | 作用 | 漏改后果 |
| --- | --- | --- | --- |
| 1 | `AlchemicalComponent.componentMap` | `type` → Builder 函数 | 命中不到，回落到 Blank 空白 |
| 2 | `AlchemicalComponent.componentAttributeMap` | `type` → Attribute 工厂 | 属性丢失 / 类型断言崩溃 |
| 3 | `Alchemy/src/main/resources/rawfile/v1.0/AlchemicalComponents/AlchemicalX.json` | 协议规则（约束下发方） | 生成端缺约束，产物不可控 |
| 4 | `docs/` 内的协议说明（如涉及对外） | 人读文档 | 契约失真 |

**现有 12 种已注册组件类型**（`componentMap` / `componentAttributeMap` 各 12 项）：
`Blank`、`Button`、`Checkbox`、`Column`、`Divider`、`Grid`、`Image`、`List`、`Row`、`Slider`、`Text`、`TextInput`。

**注意**：协议规则目录 `rawfile/v1.0/AlchemicalComponents/` 下只有 **11** 个 JSON —— `Blank` 没有规则文件。
这是「注册表 ↔ 规则」漂移的一个实例，新增组件时不要复刻这个疏漏。

### 1.8 当前实现状态

| 能力 | 状态 | 证据 |
| --- | --- | --- |
| 消息解析（JSON → Potion） | ✅ 已实现 | `AlchemicalUtils.parseMessage` |
| `UPDATE_COMPONENT` 建树 | 🟡 部分实现 | 可创建节点、设 type/attr、挂 child 占位；**不支持属性二次更新、不支持移除节点** |
| `UPDATE_DATA` 数据更新 | ❌ 未实现 | `AlchemicalRodImpl.updateDataModel()` 与 `AlchemicalData.updateDataModel()` 均为空方法体 |
| 递归渲染（Column/Row/List/Grid 容器） | ✅ 已实现 | 各容器 `ForEach(getChildren())` |
| 组件规则 JSON Schema | 🟡 部分实现 | 仅 11 个组件文件 + `common.json`；`params` 写法不规范（见 #6） |
| 真实测试覆盖 | ✅ 逻辑层已覆盖 | 44 条 L-Unit 用例，逻辑层可达分支 27/27（见 §4.2 基线） |
| README / 开发者文档 | ❌ 无 | 本文件即为首份规范 |

### 1.9 已知问题与技术债（开发时请顺带留意，不要无声扩大）

> 这些是**已确认存在**的问题。修复它们需要单独立项走完整流程，**不要**在无关需求里顺手改。

| # | 问题 | 位置 | 影响 |
| --- | --- | --- | --- |
| 1 | `UPDATE_DATA` 全链路未实现 | `AlchemicalRod.updateDataModel` / `AlchemicalData.updateDataModel` | demo 里最后 3 条数据指令被静默丢弃 |
| 2 | `@Trace private static` 语义可疑 | `engine/datamodel/AlchemicalData.ets` | 静态成员 + V2 状态装饰器组合需核实，可能完全无效 |
| 3 | 协议与样例不一致 | `DataDescriptor = {id, value}` vs demo 中 `UPDATE_DATA: {id, text}` | 契约二义，先定协议再实现 |
| 4 | 重复下发父节点指令会**重建子节点对象** | `AlchemicalRodImpl.updateComponents` 对每个 child 新建 `AlchemicalNode` 并覆盖 Map 条目 | 子节点数量不增长（Map 按 id 去重），但**子节点已有状态被丢弃**；实测见 `TC_ROD_006` |
| 5 | ~~强非空断言 `this.alchemicalFurnace!`~~ | ~~`AlchemicalRodImpl.updateComponents`~~ | ✅ **已修复**（`REQ-20260915-engine-branch-coverage` 的 seam 改造：改为 `nodeRegistry` 空值保护，未注册时安全忽略而非崩溃） |
| 6 | 规则 JSON 的 `child` 类型写成 `"object"` | `rawfile/v1.0/AlchemicalComponents/*.json` | 应为 `array`，Schema 失效 |
| 7 | ForEach 缺 keyGenerator | Column / Grid / List / Row（CodeLinter 4 warn） | 列表复用性能劣化 |
| 8 | `componentMap.get()` 可能为 `undefined` | 各容器 `AlchemicalComponent(...)` 调用处 | 未注册类型依赖默认值兜底，无显式校验 |
| 9 | 无协议一致性自动化校验 | 全局 | 代码注册表与规则 JSON 漂移无人发现 |
| 10 | ~~零真实测试覆盖~~ | ~~`Alchemy/src/test`、`entry/src/test`~~ | ✅ **已修复**（`REQ-20260915-engine-branch-coverage`：44 条用例，逻辑层可达分支 27/27） |
| 11 | UI struct 层完全无测试 | 全部 `@ComponentV2` 的 `build()` / `@Builder` | 渲染回归无保护，需设备侧 ohosTest |
| 12 | `registerAlchemicalFurnaceImpl` 无法被单元测试覆盖 | `AlchemicalRodImpl`（参数为 struct，测试无法构造） | 该 2 行委托逻辑仅由 UI 路径与 `assembleHap` 保护 |

---

## 2. 角色与总体工作流

### 2.1 输入与输出

- **工作流输入**：**开发者的需求描述**（一句话到一段话均可，允许口语化、允许不完整）。
- **工作流输出**：一个完整的、可验证的、可追溯的变更，包含
  1. `docs/changes/<变更ID>/` 下 5 份文档；
  2. 先行编写的测试代码；
  3. 通过验证的源码改动；
  4. 一份更新后的阶段状态看板。

### 2.2 七阶段流程与门禁

```
开发者需求描述
      │
   ┌──▼─────────────────────────────────────────────┐
   │ S0 立项与澄清          → 门禁 G0              │  复述需求 / 消除歧义 / 建变更目录
   └──┬─────────────────────────────────────────────┘
   ┌──▼─────────────────────────────────────────────┐
   │ S1 需求文档            → 门禁 G1              │  FR / NFR / 验收标准 可验证
   └──┬─────────────────────────────────────────────┘
   ┌──▼─────────────────────────────────────────────┐
   │ S2 开发方案            → 门禁 G2              │  文件级改动清单 + 任务拆解
   └──┬─────────────────────────────────────────────┘
   ┌──▼─────────────────────────────────────────────┐
   │ S3 测试方案            → 门禁 G3              │  分层策略 + 用例清单 + 通过标准
   └──┬─────────────────────────────────────────────┘
   ┌──▼─────────────────────────────────────────────┐
   │ S4 测试用例 + 测试代码  → 门禁 G4  【RED】     │  用例已登记且测试真实失败
   └──┬─────────────────────────────────────────────┘
   ┌──▼─────────────────────────────────────────────┐
   │ S5 源码实现            → 门禁 G5  【GREEN】    │  测试转绿 + CodeLinter 无新增 error
   └──┬─────────────────────────────────────────────┘
   ┌──▼─────────────────────────────────────────────┐
   │ S6 回归与收尾          → 门禁 G6              │  全量回归 + 文档回填 + 提交
   └──┬─────────────────────────────────────────────┘
      ▼
   可交付变更
```

### 2.3 门禁与产物矩阵

| 阶段 | 产物（`docs/changes/<变更ID>/`） | 门禁判据（全部满足才可进入下一阶段） |
| --- | --- | --- |
| **S0** 立项与澄清 | `README.md`（状态看板） | 需求已用一句话复述；歧义点已向开发者提问并得到答复（或明确标注为假设）；变更目录已创建 |
| **S1** 需求文档 | `01-requirements.md` | 每条 FR 可测试；每条 NFR 有量化指标；「非目标」已写明；验收标准 AC 与 FR 一一对应 |
| **S2** 开发方案 | `02-design.md` | 有**文件级**改动清单（新增/修改/删除）；有接口签名；有异常与兼容性分析；已拆解为可独立验证的步骤 |
| **S3** 测试方案 | `03-test-plan.md` | 明确测试层级与运行方式；用例清单覆盖全部 FR 与关键边界；写明通过标准与回归范围 |
| **S4** 测试用例 | `04-test-cases.md` + 测试代码 | 用例编号唯一且与 AC 双向可追溯；**测试代码已写完并运行/尝试运行，处于失败状态** |
| **S5** 源码实现 | `05-task-breakdown.md`（勾选进度）+ 源码 | 目标用例全部转绿（或按 §6.3 记录无法运行的原因）；CodeLinter 无**新增** error；无越界改动 |
| **S6** 回归与收尾 | 全部文档回填状态 | 全量测试无回归；文档状态置为 `verified`；追踪矩阵无空行；提交信息合规 |

### 2.4 分步骤推进规则（强制）

1. **一次只推进一步**：一个回合只完成一个阶段（S0…S6 之一），不要跨阶段产出。
2. **每步必须留痕**：在 `README.md` 看板更新「当前阶段 / 门禁结果 / 下一步」。
3. **门禁不过不前进**：门禁未通过时，要么补齐本阶段产物，要么回到上一阶段修正，**禁止**「先写代码回头补文档」。
4. **任务拆解要可独立验证**：`02-design.md` 中的每个步骤必须自带验证方式（跑哪条用例、看什么现象）。
5. **小步提交**：每个任务步骤对应一次原子提交（见第 7 章）。
6. **越界即停**：实现过程中若发现需要改动 `02-design.md` 未列出的文件，**先停下更新方案**，再继续。
7. **不允许静默扩大范围**：发现 1.9 节的技术债时，记录到 `01-requirements.md` 的「衍生问题」，
   不在本次需求内顺手修改（除非开发者明确同意纳入范围）。

### 2.5 需求分级（决定流程深度）

| 级别 | 判据 | 流程要求 |
| --- | --- | --- |
| **L1 微改** | 注释、文案、样式常量、单文件无逻辑改动 | 可跳过 S1/S2/S3，但必须：写/改测试用例、S5 后跑 CodeLinter；在 `README.md` 记录 |
| **L2 常规** | 单模块功能增删、新增一个组件、修一个 bug | 全流程 S0–S6 |
| **L3 重大** | 协议变更、`interface/` 签名变更、架构调整、跨模块改动 | 全流程 + 必须产出「协议变更清单」5.4 + 兼容性与迁移方案 + 开发者显式确认 G1/G2 |

> 级别由 AI 判定并在 `README.md` 中声明；若判定为 L3，必须在 S1 结束前请开发者确认。

---

## 3. 阶段细则

### S0 立项与澄清

- **动作**：把需求描述翻译成「目标 + 期望行为 + 边界」，找出所有歧义点。
- **必须提问的情形**：需求未说明默认值 / 涉及协议字段语义 / 涉及破坏性变更 / 有多种合理实现且代价差异大。
- **禁止**：在歧义未澄清时自行假设并直接进入实现。
- **产出**：`docs/changes/<变更ID>/README.md`，含变更 ID、级别、原始需求原文、当前阶段、状态看板。

**变更 ID 规则**：`REQ-<YYYYMMDD>-<kebab-slug>`，例如 `REQ-20260915-slider-data-update`。

### S1 需求文档 → `01-requirements.md`

使用 `docs/templates/01-requirements.md`。必须包含：

- 背景与问题、目标、**非目标（明确不做什么）**；
- 用户故事；
- **功能需求 FR-n**（每条必须可观测、可测试）；
- **非功能需求 NFR-n**（性能、兼容性、可维护性，带量化指标）；
- **验收标准 AC-n**（与 FR 对应，是测试用例的唯一来源）；
- 衍生问题（本次不做但要记录）；
- 开放问题（未决项 + 默认假设）。

**门禁 G1**：任一条 FR 无法写出「如何验证」，则需求文档不合格。

### S2 开发方案 → `02-design.md`

使用 `docs/templates/02-design.md`。必须包含：

- 方案概述与关键取舍（为什么这样做，备选方案为何不选）；
- **文件级改动清单**：`新增 / 修改 / 删除`，每项一句话说明；
- **接口签名变更**：涉及 `interface/**` 或协议时必须给出前后对比；
- 数据结构与状态流（节点树如何变化、`@Trace` 字段如何驱动刷新）；
- 异常与边界处理（空值、未注册类型、重复消息、乱序消息）；
- 兼容性与回滚方案；
- **任务拆解**：形成 `05-task-breakdown.md` 的初始步骤表。

**门禁 G2**：任一步骤无法独立验证，则方案不合格。

### S3 测试方案 → `03-test-plan.md`

使用 `docs/templates/03-test-plan.md`。必须包含：

- 测试范围（测什么 / 不测什么）；
- **测试分层**（见 4.2）；
- 环境与前置条件；
- **用例清单**（编号、标题、层级、自动化落点、对应 AC）；
- 通过标准（哪些用例必须全绿、CodeLinter 的 error 阈值）；
- 回归范围（本次改动可能影响到的既有能力）。

**门禁 G3**：用例清单未能覆盖全部 FR 与关键边界（空值/重复/乱序/未注册类型），则方案不合格。

### S4 测试用例 + 测试代码（RED）

使用 `docs/templates/04-test-cases.md`。**这是「测试先行」的落地点。**

- 先把每条用例写成表格行：编号、前置条件、步骤、预期结果、自动化位置、状态；
- **然后立刻写测试代码**（Hypium），覆盖本轮所有可自动化的用例；
- 运行测试（或按 §6.3 说明为何无法运行），确认处于**失败**状态；
- 在文档中登记实际运行结果（命令 + 输出摘要 + 退出码）。

**门禁 G4**：测试代码不可运行且未说明原因 → 不通过；测试代码直接通过（未实现就绿）→ 说明用例无效，重写。

### S5 源码实现（GREEN）

- 严格按 `05-task-breakdown.md` 的步骤推进，一次一步；
- 每完成一步：跑该步对应的测试 → 更新任务表状态 → 提交；
- **最小改动原则**：只改方案里列出的文件，只解决当前用例覆盖的问题；
- 全部用例转绿后，运行 CodeLinter 并确认**无新增 error**。

**门禁 G5**：用例未全绿，或 CodeLinter 新增 error → 不通过。

### S6 回归与收尾

- 跑全量测试（含既有用例），确认无回归；
- 回填所有文档状态：`draft → approved → implementing → verified → archived`；
- 校验追踪矩阵（AC ↔ FR ↔ 用例 ↔ 代码文件）无空行；
- 按第 7 章规范提交；
- 若产生新的技术债，登记到 `01-requirements.md` 的「衍生问题」并同步更新本文件 1.9 节。

**门禁 G6**：存在未回填的文档状态或未追踪的 AC → 不通过。

---

## 4. 测试先行（Test-First）强制规则

### 4.1 RED → GREEN 循环（不可跳过 RED）

```
写用例文档 → 写测试代码 → 运行确认【RED】 → 写实现 → 运行确认【GREEN】 → 重构（保持 GREEN）
                              ↑
                    严禁跳过此步直接写实现
```

- **红线**：**任何源码文件的修改，都必须能指向至少一条已登记的用例。**
- 若某个改动确实无法被自动化测试覆盖（如纯视觉效果），必须在 `04-test-cases.md` 中标注为
  `manual`，写明人工验证步骤与预期现象，并在 S6 记录人工验证结论。

### 4.2 测试分层

| 层级 | 位置 | 测什么 | 运行方式 |
| --- | --- | --- | --- |
| **L-Unit 本地单元测试** | `Alchemy/src/test/`、`entry/src/test/` | 纯逻辑：消息解析、属性赋值、节点树增删、协议校验 | `tools/run-unit-tests.sh`（推荐）；原始命令见 §6.2 |
| **L-Int 设备集成测试** | `Alchemy/src/ohosTest/`、`entry/src/ohosTest/` | 组件渲染、`onReceive` 端到端、UI 自动化（`@ohos.UiTest`） | 连接设备/模拟器运行 ohosTest |
| **L-Schema 协议契约校验** | 建议新增（见问题 #9） | 代码注册表 ↔ 规则 JSON ↔ 样例报文 三者一致 | 建议以 L-Unit 实现 |

**优先级**：优先把逻辑下沉到 L-Unit（无设备依赖、反馈快）。**默认要求：引擎逻辑必须有 L-Unit 覆盖。**

**当前基线**（`REQ-20260915-engine-branch-coverage`）：逻辑层可达分支 **27/27 = 100%**，行 109/165，函数 25/50。
未覆盖的函数全部是 UI 运行时依赖（`@Builder` / struct `build()`）与无法构造的 struct 参数。
**新增代码不得降低该基线。**

### 4.3 Hypium 约定

- 测试文件命名：`<被测对象>.test.ets`；测试套件用 `describe('<模块名>')`；
- 用例名必须**描述行为与预期**，禁止 `test1`、`assertContain` 之类无信息名；
  正确示例：`it('parseMessage_should_return_empty_when_json_is_empty_array', 0, () => {...})`；
- 每个用例只断言一个行为；断言要精确（`assertEqual` / `assertDeepEquals` / `assertTrue`），
  避免只断言「不抛异常」；
- 前置/清理放 `beforeEach` / `afterEach`，确保用例间无状态污染；
- 新增测试套件必须在同目录 `List.test.ets` 中注册。

**ArkTS 对测试代码的额外约束（已实测踩坑）**

- `arkts-no-untyped-obj-literals`：**禁止把裸对象字面量当参数传递**，测试里构造 `params` 必须
  先声明 `interface`：
  ```ts
  interface TextParams { text: string }        // ✅ 先声明
  const p: TextParams = { text: 'hi' };         // ✅ 合法
  new AlchemyTextAttribute({ text: 'hi' });     // ❌ 编译失败
  ```
- **struct 无法被伪造**：`AlchemicalFurnaceImpl` 这类 `@ComponentV2` struct 既不能 `new`，
  也不能用对象字面量 + `as` 断言（`{...} as XxxImpl` 与 `{} as XxxImpl` 均编译失败）。
  需要替身时，必须走**依赖注入 seam**（见 §5.6）。
- 用 `{} as UIContext` 这类**类**的断言是可行的（与 struct 不同）。
- `expect` 断言里不要写 `expect(fn).assertThrowError()` 这类不确定 API；用
  `try/catch + expect(threw).assertTrue()` 更稳。

### 4.5 覆盖率门槛（回归红线）

- 每个变更的 S5 门禁必须跑 `tools/run-unit-tests.sh` 并记录覆盖率数字；
- **新增/修改逻辑代码时，分支覆盖率不得低于变更前基线**；
- 若存在**不可达分支**（如枚举 switch 的 `default`），必须在测试方案中给出**不可达论证**，
  不得为了让数字好看而删除防御性代码。

### 4.4 不得伪造验证结果（红线）

- **未实际运行**的命令，不得写成「已验证通过」。
- 若环境不可用，必须如实记录：`验证状态：blocked（原因：…）`，并给出可复现该验证的命令与前置条件。
- 禁止以「看起来没问题」「逻辑上应该可以」替代运行结果。

---

## 5. 编码规范（本项目特有）

### 5.1 命名与文件布局

- 引擎内所有类型/组件统一 `Alchemical*` / `Alchemy*` 前缀，沿用现有隐喻词汇；
- 一个组件一个文件：`AlchemicalX.ets`，内含三件套
  1. `@ObservedV2 class AlchemyXAttribute extends BasicAlchemyAttribute`
  2. `@Builder function xComponentBuilder(componentNode: MutableBinding<AlchemicalNode>): void`
  3. `@ComponentV2 struct AlchemicalX`
- 注册表（`componentMap` / `componentAttributeMap`）按 **type 字母序**维护，便于人工查重。

### 5.2 ArkTS / ArkUI V2 约束

- 统一使用 **V2 状态装饰器**：`@ComponentV2`、`@ObservedV2`、`@Trace`、`@Local`、`@Param`、`@Require`；
  **禁止**混用 V1（`@Component`/`@State`/`@Observed`/`@ObjectLink`），除页面入口 `@Entry @Component` 例外。
- 状态字段必须显式 `@Trace`，否则在普通类中修改不会触发刷新。
- 构造函数中禁止直接调用耗时/异步逻辑；初始化放在 `aboutToAppear`。
- 禁止在 `build()` 内做副作用（网络、IO、修改状态）。
- 使用 `MutableBinding` + `UIUtils.makeBinding` 传递节点引用，保持现有模式。
- 属性赋值统一走 `AlchemicalUtils.assign`（反射赋值），保证扩展字段自动生效。

### 5.3 新增一个组件的完整清单

- [ ] 新建 `engine/components/AlchemicalX.ets`（Attribute + Builder + Struct 三件套）
- [ ] `componentMap` 注册 `'X' → mutableBuilder(xComponentBuilder)`
- [ ] `componentAttributeMap` 注册 `'X' → (params) => new AlchemyXAttribute(params)`
- [ ] 新建 `rawfile/v1.0/AlchemicalComponents/AlchemicalX.json` 协议规则（`child` 用 `array`，修正问题 #6 的写法）
- [ ] 若是对外能力，更新 `Alchemy/Index.ets` 与文档
- [ ] 写 L-Unit 用例：Attribute 默认值、params 覆盖、未注册类型兜底
- [ ] 在 `entry/src/main/resources/rawfile/alchemy_message_demo.json` 增加一条可复现的样例指令
- [ ] 跑 CodeLinter（新组件不得引入新增 error；ForEach 需带 keyGenerator）

### 5.4 协议变更清单（L3 必做）

任何对消息格式、`ComponentDescriptor`、`DataDescriptor`、`AlchemicalPotionType` 的改动，必须同时更新：

- [ ] `interface/Alchemy.ets`（类型定义）
- [ ] `engine/type/AlchemicalType.ets`（报文结构）
- [ ] `engine/common/AlchemicalUtils.ets`（解析逻辑）
- [ ] `rawfile/v1.0/**` 全部相关规则 JSON
- [ ] `entry/.../alchemy_message_demo.json`（样例）
- [ ] 版本号 `version` 字段策略（兼容旧版本 / 拒绝旧版本）
- [ ] `03-test-plan.md` 中的兼容性与回归用例
- [ ] 本文件 §1.5 协议章节

### 5.5 版权头与注释

- **每个 `.ets` 源文件必须保留现有 Apache-2.0 版权头**（`Copyright 2026 GXXXXT`），新增文件同样添加。
- 注释用中文，解释「为什么」而非「做什么」；对外 API 使用 `/** */` JSDoc 风格。
- 修改代码时不要删除既有有价值注释。

### 5.6 可测试性接缝（seam）

引擎里有若干「普通类直接依赖 UI struct」的耦合点（如 `AlchemicalRodImpl` 依赖
`AlchemicalFurnaceImpl`）。由于 **struct 无法在测试中构造或伪造**（§4.3），这类代码默认不可测。

**规则**：

1. 需要覆盖此类逻辑时，**允许**为生产代码引入**最小的依赖注入接缝**，但必须同时满足：
   - **行为等价**：逐场景论证等价性（UI 路径、异常路径、空值路径）；
   - **改动最小**：只碰必要的文件与方法，不做顺带重构；
   - **可回滚**：作为独立提交，便于 `git revert`；
   - **在 `02-design.md` 中登记**：写清为什么非改不可、否决了哪些备选方案。
2. 既有范例：`AlchemicalRodImpl.registerNodeRegistry(registry)` ——
   UI 路径由 `registerAlchemicalFurnaceImpl(furnace)` 转发 `furnace.nodeList`，
   测试路径直接注入自建 `Map`。同时消除了原 `!` 断言崩溃风险（问题 #5）。
3. **禁止**为了让代码可测而把 UI struct 拆成无意义的空壳，或引入测试专用分支
   （如 `if (isTest)`）—— 那是反模式，应改用注入。

---

## 6. 命令与验证清单

### 6.1 环境前置

```bash
# ★ 关键：必须使用 DevEco Studio 自带的完整 HarmonyOS SDK。
#   ~/Library/OpenHarmony/Sdk 缺 native 组件，会导致 "SDK component missing"。
export DEVECO_SDK_HOME="/Applications/DevEco-Studio.app/Contents/sdk"
# ★ 必须设置 JAVA_HOME，否则 PackageHap 报 "Unable to locate a Java Runtime"。
export JAVA_HOME="/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:/Applications/DevEco-Studio.app/Contents/tools/node/bin:$PATH"

DEVECO=/Applications/DevEco-Studio.app/Contents
HVIGOR=$DEVECO/tools/hvigor/bin/hvigorw
OHPM=$DEVECO/tools/ohpm/bin/ohpm
LINTER=$DEVECO/plugins/codelinter/run/index.js
```

### 6.2 命令表

> 「验证状态」为**本机实测**结果（2026-09-15）。执行前请自行复测。

| 用途 | 命令 | 验证状态 |
| --- | --- | --- |
| 安装依赖 | `$OHPM install` | 未实测 |
| 构建 HAP | `$HVIGOR --no-daemon assembleHap` | ✅ **实测通过**（`BUILD SUCCESSFUL`，需 §6.1 的 SDK + JAVA_HOME） |
| 构建 HAR（Alchemy） | `$HVIGOR --no-daemon --mode module -p module=Alchemy@default assembleHar` | 未实测 |
| **本地单元测试（L-Unit）** | `tools/run-unit-tests.sh` | ✅ **实测通过**：44/44 用例，自动产出覆盖率报告 |
| 本地单元测试（原始命令） | `$HVIGOR --no-daemon --mode module -p module=Alchemy@default -p product=default test` | ✅ 实测通过 |
| **覆盖率摘要** | `node tools/coverage-summary.js <模块>/.test/default/outputs/test/reports/coverageReport.json` | ✅ 实测通过 |
| **CodeLinter 代码检查** | `node "$LINTER" -c ./code-linter.json5 -f default -e error ./Alchemy/src/main/ets` | ✅ 实测：`Errors: 0; Warns: 4`（4 条均为 ForEach 缺 keyGenerator，见问题 #7） |
| 设备集成测试（L-Int） | 连接设备/模拟器后运行 `Alchemy/src/ohosTest` | 未实测（需设备） |

**产物路径**

| 产物 | 路径 |
| --- | --- |
| 覆盖率原始数据 | `<模块>/.test/default/outputs/test/reports/coverageReport.json` |
| 覆盖率 HTML | `<模块>/.test/default/outputs/test/reports/index.html` |
| 测试结果 | `<模块>/.test/default/intermediates/test/coverage_data/test_result.txt` |

**CodeLinter 说明**：`-e error` 表示仅 error 级别导致非零退出；warn 不阻塞但**必须记录**。
项目级规则见 `code-linter.json5`（`plugin:@performance/recommended` + `plugin:@typescript-eslint/recommended`）。

### 6.3 环境不可用时的处理（重要）

若某条验证命令在本机无法执行（缺 SDK 组件、无设备、无 JDK 等），AI **必须**：

1. 停止对构建/测试结果做任何断言；
2. 在变更文档中如实记录：
   ```
   验证状态：blocked
   阻塞原因：<具体错误原文>
   已执行：<命令原文>
   期望验证：<该命令能证明什么>
   待办：<解除条件与后续动作>
   ```
3. 继续完成**不依赖该命令**的验证（例如 CodeLinter 能跑就必须跑）；
4. 在最终交付说明中**显式列出未能验证的项**。

> 历史案例：曾因 `DEVECO_SDK_HOME` 指向 `~/Library/OpenHarmony/Sdk`（缺 `native`）导致全部构建命令失败。
> 定位后改用 DevEco 自带 SDK 即解除。遇到环境报错的正确做法是**先排查环境**，再决定是否记录 blocked。

---

## 7. 提交与交付规范

- **提交粒度**：一个任务步骤一次提交；测试代码与实现代码**分开提交**，以便看出 RED→GREEN 过程。
- **提交信息**（沿用仓库现有风格）：
  ```
  <简短英文祈使句标题>

  <可选正文：做了什么、为什么、对应变更ID REQ-xxxx>

  Signed-off-by: <name> <email>
  ```
- **提交前检查**：
  - [ ] 测试已运行且结果已记录
  - [ ] CodeLinter 无新增 error
  - [ ] `docs/changes/<变更ID>/` 文档状态已更新
  - [ ] 未提交 `build/`、`.hvigor/`、`.idea/`、`oh_modules/`（已在 `.gitignore`）
  - [ ] 未擅自删除既有版权头

---

## 8. 文档模板与目录约定

```
docs/
├── README.md                       # docs 使用说明与工作流速查
├── templates/
│   ├── 01-requirements.md          # 需求文档模板
│   ├── 02-design.md                # 开发方案模板
│   ├── 03-test-plan.md             # 测试方案模板
│   ├── 04-test-cases.md            # 测试用例模板（含追踪矩阵）
│   └── 05-task-breakdown.md        # 任务拆解模板（分步骤推进）
└── changes/
    └── REQ-<YYYYMMDD>-<slug>/      # 每个需求一个目录，从 templates 复制
        ├── README.md               # 状态看板（阶段/门禁/下一步）
        ├── 01-requirements.md
        ├── 02-design.md
        ├── 03-test-plan.md
        ├── 04-test-cases.md
        └── 05-task-breakdown.md
```

**文档状态流转**：`draft → review → approved → implementing → verified → archived`

---

## 9. 完成定义（Definition of Done）

一次变更只有**全部**满足以下条件才算完成：

- [ ] 5 份文档齐备，状态均为 `verified`
- [ ] 每条 FR 都有对应 AC，每条 AC 都有对应用例，每条用例都有对应代码或无代码的理由
- [ ] 测试先行过程可追溯（存在 RED 阶段记录）
- [ ] 目标用例全部通过，既有用例无回归
- [ ] CodeLinter 无新增 error
- [ ] 未修改方案外的文件（或已先更新方案）
- [ ] 技术债已登记（1.9 节 / 需求文档「衍生问题」）
- [ ] 提交信息合规，测试与实现分次提交
- [ ] 未能验证的项已在交付说明中显式列出

---

## 10. 红线（绝对禁止）

1. **禁止**未写测试先改源码。
2. **禁止**虚假声称构建/测试/lint 通过。
3. **禁止**跳过门禁跨阶段推进。
4. **禁止**在无关需求中顺手重构、扩大改动范围。
5. **禁止**从 `entry` 直接 import `engine/**`，禁止绕过 `Alchemy/Index.ets` 对外契约。
6. **禁止**混用 ArkUI V1 与 V2 状态装饰器。
7. **禁止**删除或篡改既有 Apache-2.0 版权头。
8. **禁止**在组件注册表与规则 JSON 之间制造漂移（新增组件必须四处同步）。
9. **禁止**在协议字段语义未确认时实现 `UPDATE_DATA` 之类有歧义的能力（先澄清，见问题 #3）。
>>>>>>> 0ad8b67 (Development Specifications for AGENT System)
