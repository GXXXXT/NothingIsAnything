# 04 · 测试用例 · 引擎逻辑分支覆盖

| 项 | 内容 |
| --- | --- |
| 变更 ID | `REQ-20260915-engine-branch-coverage` |
| 关联测试方案 | `03-test-plan.md` |
| 状态 | verified |

> 格式说明：本变更用例共 44 条，为避免逐条空表带来的阅读负担，采用「按套件分组的紧凑表格 +
> 关键用例展开块」的形式。每条用例仍具备 **编号 / 前置 / 步骤 / 预期 / 自动化落点 / 状态** 六要素。

---

## 1. 用例明细

### 1.1 套件 `alchemicalUtilsTest`（`AlchemicalUtils.test.ets`）

| 编号 | 标题 | 类型 | 前置 | 步骤 | 预期 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| TC-UTIL-001 | 空数组报文返回空列表 | 边界 | 报文 `[]` | 调用 `parseMessage` | 长度 0 | GREEN |
| TC-UTIL-002 | 解析 UPDATE_COMPONENT | 正常 | 报文含该键 | 调用 `parseMessage` | type=UPDATE_COMPONENT，id/componentType 正确 | GREEN |
| TC-UTIL-003 | 解析 UPDATE_DATA | 正常 | 报文含该键 | 调用 `parseMessage` | type=UPDATE_DATA，id 正确 | GREEN |
| TC-UTIL-004 | 未知指令键被跳过 | 异常 | 报文仅含 `UNKNOWN_OP` | 调用 `parseMessage` | 长度 0 | GREEN |
| TC-UTIL-005 | 非法 JSON 抛异常 | 异常 | 报文 `{not-a-json` | try/catch 调用 | 捕获到异常（刻画现状） | GREEN |
| TC-UTIL-006 | 顺序保持 + 未知键剔除 | 边界 | 混合报文 | 调用 `parseMessage` | 长度 2，顺序为 COMPONENT→DATA | GREEN |
| TC-UTIL-007 | assign 覆盖已有字段 | 正常 | 空 Attribute + 有键 source | 调用 `assign` | width/height 被写入 | GREEN |
| TC-UTIL-008 | assign 空对象不改目标 | 边界 | 空 Attribute + 空 source | 调用 `assign` | 保持 `auto`/`auto` | GREEN |

### 1.2 套件 `alchemicalNodeTest`（`AlchemicalNode.test.ets`）

| 编号 | 标题 | 类型 | 步骤 | 预期 | 状态 |
| --- | --- | --- | --- | --- | --- |
| TC-NODE-001 | createRoot | 正常 | `AlchemicalNode.createRoot()` | id=`root`，type=`Blank`，0 子节点 | GREEN |
| TC-NODE-002 | addChild 注册子节点 | 正常 | `addChild(child)` | 返回 true，子节点数 1，id 正确 | GREEN |
| TC-NODE-003 | removeChild 命中 | 正常 | add 后 remove | 返回 true，子节点数 0 | GREEN |
| TC-NODE-004 | removeChild 未命中 | 边界 | remove 陌生节点 | 返回 false | GREEN |
| TC-NODE-005 | 同 id addChild 覆盖 | 边界 | 两次 add 同 id | 子节点数 1，type 为后者 | GREEN |
| TC-NODE-006 | 基类 Attribute 缺省 | 正常 | `new BasicAlchemyAttribute()` | width/height = `auto` | GREEN |
| TC-NODE-007 | 基类 Attribute 注入 | 正常 | 传入 typed params | 字段被覆盖 | GREEN |
| TC-NODE-008 | params 为 undefined | 边界 | `new BasicAlchemyAttribute(undefined)` | 保持缺省，不抛异常 | GREEN |
| TC-NODE-009 | 构造传自定义 attr | 正常 | `new AlchemicalNode(id,type,attr)` | attr 引用生效 | GREEN |

### 1.3 套件 `alchemicalAttributesTest`（`AlchemicalAttributes.test.ets`）

| 编号 | 组件 | 场景 | 断言要点 | 状态 |
| --- | --- | --- | --- | --- |
| TC-ATTR-001 | Text | 注入 | text/fontSize/color 生效 | GREEN |
| TC-ATTR-002 | Text | 缺省 | `''` / 16 / `#000000` | GREEN |
| TC-ATTR-003 | Button | 注入 | label 生效 | GREEN |
| TC-ATTR-004 | Button | 缺省 | label = `''` | GREEN |
| TC-ATTR-005 | Image | 注入 | src 生效 | GREEN |
| TC-ATTR-006 | Image | 缺省 | src = `''` | GREEN |
| TC-ATTR-007 | Checkbox | 注入 | name/group/checked 生效 | GREEN |
| TC-ATTR-008 | Checkbox | 缺省 | `''` / `''` / false | GREEN |
| TC-ATTR-009 | Slider | 注入 | value/min/max/step 生效 | GREEN |
| TC-ATTR-010 | Slider | 缺省 | 0 / 0 / 100 / 1 | GREEN |
| TC-ATTR-011 | TextInput | 注入 | text/placeholder 生效 | GREEN |
| TC-ATTR-012 | TextInput | 缺省 | `''` / `''` | GREEN |

### 1.4 套件 `alchemicalRegistryTest`（`AlchemicalRegistry.test.ets`）

| 编号 | 标题 | 步骤 | 预期 | 状态 |
| --- | --- | --- | --- | --- |
| TC-REG-001 | componentMap 含 12 类型 | size 与逐个 `has` | 12/12 存在 | GREEN |
| TC-REG-002 | attributeMap 键集一致 | size 与逐个 `has` | 12/12 存在且 size 相同 | GREEN |
| TC-REG-003 | 每个 Attribute 工厂可实例化 | 空 params 调用 12 个工厂 | 返回非空且 width=`auto` | GREEN |
| TC-REG-004 | 每个工厂可注入 params | 传 `{width:'12vp'}` | 12 个全部得到 `12vp` | GREEN |
| TC-FACTORY-001 | forgeAlchemicalRod 可用 | `{} as UIContext` 建实例并 `onReceive('[]')` | 非空且不抛异常 | GREEN |
| TC-DATA-001 | updateDataModel 不抛异常 | 调用静态方法 | 不抛异常（刻画空实现） | GREEN |

### 1.5 套件 `alchemicalRodTest`（`AlchemicalRod.test.ets`）

> 本套件覆盖分支最密集的 `AlchemicalRodImpl`，以下逐条展开。

#### TC-ROD-001 · 已注册 id + 已注册类型 + 无 child

| 项 | 内容 |
| --- | --- |
| 层级 / 类型 | L-Unit / 正常 |
| 对应 AC | AC-5 |
| 落点 | `AlchemicalRod.test.ets` → `alchemicalRodTest` |
| 状态 | GREEN |

**前置**：`registry = Map{'root' → AlchemicalNode.createRoot()}`
**步骤**：`rod.registerNodeRegistry(registry)` → `rod.onReceive(MSG_ROOT_COLUMN)`
**预期**：`root.type === 'Column'`；`root.attr` 非空；子节点数 0
**覆盖分支**：`UPDATE_COMPONENT` 命中；`if(!registry)` 假；`if(!loopRoot)` 假；`if(!attribute)` 假；`if(!value.child)` 真

#### TC-ROD-002 · 未注册 id 提前返回

**前置**：registry 仅含 `root`
**步骤**：`onReceive` 一条 `id = 'ghost'` 的指令
**预期**：`registry.size === 1`；`has('ghost') === false`；`root.type` 仍为 `Blank`
**覆盖分支**：`if(!loopRoot)` 真
**意义**：证明未知 id 不会污染节点表，且**不会**误改已有节点

#### TC-ROD-003 · 未注册 componentType（刻画现状）

**步骤**：`onReceive` 一条 `componentType = 'NoSuchComponent'` 的指令
**预期**：`root.type === 'NoSuchComponent'`（**type 已被写入**）且 `root.attr` 与调用前**同一引用**（**attr 未变**）
**覆盖分支**：`if(!attribute)` 真
**意义**：锁定「type 先于属性查表写入」造成的中间态。若未来修复为「查表失败则不写 type」，**必须同步更新本用例**，否则会被误判为回归。

#### TC-ROD-004 · 含 child 时创建并注册占位子节点

**步骤**：`onReceive` 一条带 `child:['c1','c2']` 的指令
**预期**：root 子节点数 2；`registry.has('c1')`、`has('c2')` 为真；子节点 type 为 `Blank`
**覆盖分支**：`if(!value.child)` 假

#### TC-ROD-005 · 未注册注册表时安全忽略

**前置**：**不**调用任何注册方法
**步骤**：`onReceive(MSG_ROOT_COLUMN)`
**预期**：不抛异常
**覆盖分支**：`if(!registry)` 真
**意义**：验证 seam 引入的安全保护，取代旧实现的 `!` 断言崩溃（AGENT.md 问题 #5）

#### TC-ROD-006 · 重复下发父节点指令会重建子节点对象

**步骤**：连续两次 `onReceive(MSG_WITH_CHILDREN)`，比较两次的 `registry.get('c1')`
**预期**：子节点数仍为 2（Map 按 id 去重，**不增长**）；但两次取到的 `c1` **不是同一对象**
**意义**：这是 AGENT.md 问题 #4 的**实测结论**——原先描述为「子节点累积」是**错误**的，
  真实缺陷是「子节点对象被替换、已有状态丢失」。本用例用于锁定真实行为。

#### TC-ROD-007 · UPDATE_DATA 不触碰节点树（刻画空实现）

**步骤**：`onReceive(MSG_UPDATE_DATA_ONLY)`
**预期**：不抛异常；`root.type` 仍为 `Blank`；`registry.size === 1`
**覆盖分支**：`UPDATE_DATA` 命中
**意义**：锁定 `UPDATE_DATA` 当前被静默丢弃的现状（AGENT.md 问题 #1）。实现该能力时**必须同步更新本用例**。

#### TC-ROD-008 · 混合批量指令

**步骤**：`onReceive` 一条同时含 `UPDATE_COMPONENT(Row)` 与 `UPDATE_DATA` 的批量报文
**预期**：`root.type === 'Row'`
**意义**：验证 `forEach` 顺序分发与两类指令共存

---

## 2. 追踪矩阵（AC ↔ FR ↔ 用例 ↔ 代码）

| FR | AC | 用例编号 | 自动化文件 | 实现文件 | 状态 |
| --- | --- | --- | --- | --- | --- |
| FR-1 | AC-1 | TC-UTIL-001..006 | `AlchemicalUtils.test.ets` | `engine/common/AlchemicalUtils.ets` | ✅ |
| FR-2 | AC-2 | TC-UTIL-007,008 | `AlchemicalUtils.test.ets` | 同上 | ✅ |
| FR-3 | AC-3 | TC-NODE-001..005,009 | `AlchemicalNode.test.ets` | `engine/components/AlchemicalNode.ets` | ✅ |
| FR-4 | AC-4 | TC-NODE-006..008, TC-ATTR-001..012 | `AlchemicalNode.test.ets`, `AlchemicalAttributes.test.ets` | `Alchemical{Node,Text,Button,Image,Checkbox,Slider,TextInput}.ets` | ✅ |
| FR-5 | AC-5 | TC-ROD-001..008 | `AlchemicalRod.test.ets` | `engine/core/AlchemicalRod.ets` | ✅ |
| FR-6 | AC-6 | TC-REG-001..004 | `AlchemicalRegistry.test.ets` | `engine/components/AlchemicalComponent.ets` | ✅ |
| FR-7 | AC-7 | TC-FACTORY-001 | `AlchemicalRegistry.test.ets` | `interface/AlchemicalRod.ets` | ✅ |
| FR-8 | AC-8 | TC-DATA-001 | `AlchemicalRegistry.test.ets` | `engine/datamodel/AlchemicalData.ets` | ✅ |
| FR-9 | AC-9 | —（工具本身） | `tools/run-unit-tests.sh`, `tools/coverage-summary.js` | — | ✅ |

## 3. 人工验证用例

无。本次范围内全部用例均已自动化。

## 4. RED / GREEN 证据记录

### 4.1 阶段一：4 个刻画性套件在**未改动源码**下运行

| 项 | 内容 |
| --- | --- |
| 执行时间 | 2026-09-15 |
| 命令 | `tools/run-unit-tests.sh` |
| 输出摘要 | `Tests run: 36, Failure: 0, Error: 0, Pass: 36` |
| 覆盖率 | 分支 17/26 (65.4%)；`core/AlchemicalRod.ets` 0/9 |
| 结论 | ✅ 36 条刻画性用例在原始代码上**全部通过**，证明它们是对既有行为的有效刻画，而非同义反复 |

> 该套件不含 `alchemicalRodTest`（其依赖尚不存在的 seam）。

### 4.2 阶段二：RED（加入 Rod 套件，seam 尚未实现）

| 项 | 内容 |
| --- | --- |
| 执行时间 | 2026-09-15 |
| 命令 | `tools/run-unit-tests.sh` |
| 输出摘要 | `hvigor ERROR: Failed :Alchemy:default@UnitTestArkTS` |
| 关键错误 | `Property 'registerNodeRegistry' does not exist on type 'AlchemicalRodImpl'`，命中 `AlchemicalRod.test.ets` 第 66/79/93/107/137 行 |
| 退出码 | 非 0（BUILD FAILED） |
| 结论 | ✅ **RED 成立**：测试先于实现编写，并因缺少 seam 而真实失败 |

### 4.3 阶段三：GREEN（实现 seam 后）

| 项 | 内容 |
| --- | --- |
| 执行时间 | 2026-09-15 |
| 命令 | `tools/run-unit-tests.sh` |
| 输出摘要 | `BUILD SUCCESSFUL`；`Tests run: 44, Failure: 0, Error: 0, Pass: 44` |
| 覆盖率 | 逻辑层分支 **27/28 (96.4%)**；可达分支 27/27 |
| 结论 | ✅ **GREEN 成立** |

### 4.4 回归验证

| 项 | 命令 | 结果 |
| --- | --- | --- |
| UI 编译链路 | `hvigorw --no-daemon assembleHap` | ✅ `BUILD SUCCESSFUL`，退出码 0 |
| 静态检查 | `node codelinter/run/index.js -c ./code-linter.json5 -e error ./Alchemy/src/main/ets` | ✅ `Errors: 0; Warns: 4`，与变更前**完全一致**（无新增） |

## 5. 用例变更记录

| 日期 | 用例编号 | 变更说明 |
| --- | --- | --- |
| 2026-09-15 | TC-ROD-006 | 由「子节点累积」修正为「子节点对象被替换」——实测推翻了原假设 |
| 2026-09-15 | TC-ROD-003 | 明确断言「type 已改 / attr 未改」的中间态 |
