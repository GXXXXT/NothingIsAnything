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

---

## 1. 项目概览

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

```jsonc
[
  {
    "version": "1.0",
    "UPDATE_COMPONENT": {
      "id": "contentText",          // 必填，全局唯一，ASCII
      "componentType": "Text",      // 必填，必须是注册表中的 key
      "child": ["a", "b"],          // 可选，仅容器组件；值是他处定义的 id 列表，禁止内联子组件
      "params": { "text": "你好" }   // 组件初始化参数
    }
  },
  {
    "version": "1.0",
    "UPDATE_DATA": {
      "id": "contentText",
      "value": { }                  // 语义未定，见第 15 节
    }
  }
]
```

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
