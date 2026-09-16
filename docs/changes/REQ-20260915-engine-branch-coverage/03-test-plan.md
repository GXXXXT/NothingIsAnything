# 03 · 测试方案 · 引擎逻辑分支覆盖

| 项 | 内容 |
| --- | --- |
| 变更 ID | `REQ-20260915-engine-branch-coverage` |
| 关联需求 | `01-requirements.md` |
| 关联方案 | `02-design.md` |
| 状态 | approved |

---

## 1. 测试范围

**测什么**

- `engine/common/AlchemicalUtils.ets`：`parseMessage` 指令判定分支、`assign` 反射赋值。
- `engine/components/AlchemicalNode.ets`：`AlchemicalNode` 构造/child 增删、`BasicAlchemyAttribute` 的 params 分支。
- 6 个组件 Attribute（`Text`/`Button`/`Image`/`Checkbox`/`Slider`/`TextInput`）的 params 注入与缺省值分支。
- `engine/core/AlchemicalRod.ets`：`onReceive` 指令分发 switch、`updateComponents` 的 3 条提前返回分支、新增的 registry 空值分支。
- `engine/components/AlchemicalComponent.ets` 的**静态注册表**（`componentMap` / `componentAttributeMap`）。
- `interface/AlchemicalRod.ets`：`AlchemicalRodCreator.forgeAlchemicalRod` 工厂。
- `engine/datamodel/AlchemicalData.ets`：空实现的刻画。

**不测什么（明确排除）**

- 所有 `@ComponentV2` struct 的 `build()` 渲染逻辑与 UI 外观（本地无 UI 运行时，需设备侧 ohosTest，属 D-4）。
- `@Builder` 函数体（依赖 UI 运行时；其注册关系通过注册表存在性间接验证）。
- 真实网络/资源加载路径（`Index.ets` 读 rawfile 的演示逻辑）。

## 2. 测试分层与运行方式

| 层级 | 落点目录 | 覆盖目标 | 运行方式 | 是否纳入本次 |
| --- | --- | --- | --- | --- |
| L-Unit 本地单元 | `Alchemy/src/test/` | 全部引擎逻辑分支 | `tools/run-unit-tests.sh`（内部调 hvigor `test` 任务） | ✅ 是 |
| L-Int 设备集成 | `Alchemy/src/ohosTest/` | UI 渲染与端到端 | 需设备/模拟器 | ❌ 否（D-4） |
| L-Schema 协议契约 | 建议落 L-Unit | 注册表 ↔ 规则 JSON 一致性 | — | ❌ 否（D-2） |
| L-Manual 人工 | — | 视觉 | — | ❌ 否 |

> 本地单元测试经探针实测**可加载** `@ObservedV2` 类与 `@kit.ArkUI` 依赖（见 `01-requirements.md` §10 Q-1），因此逻辑层可以完整下沉到 L-Unit。

## 3. 环境与前置条件

```bash
export DEVECO_SDK_HOME="/Applications/DevEco-Studio.app/Contents/sdk"   # 必须用 DevEco 自带完整 SDK
export JAVA_HOME="/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:/Applications/DevEco-Studio.app/Contents/tools/node/bin:$PATH"
```

- 构建工具：hvigor `6.23.5`（DevEco 自带）。
- 是否需要设备：**否**（本地单元测试在宿主 `Darwin` 上执行）。
- 已知环境阻塞：无。前序 `SDK component missing` 已定位为 `DEVECO_SDK_HOME` 指向错误 SDK，改用 DevEco 自带 SDK 后解除。
- 测试数据准备：报文以**字符串常量**内联在测试文件中（本地测试无 `resourceManager`，无法读 rawfile，见 §7 盲区）。
- 状态隔离手段：每个用例内部**自建** `nodeList` / `AlchemicalNode` / Rod 实例；不使用跨用例共享的可变全局；不使用 `beforeEach` 重置全局（因为无需重置）。

## 4. 分支覆盖矩阵

> 分母以实测 `coverageReport.json` 为准；下表为设计期锚定。

| # | 文件 | 决策点 | 覆盖用例 |
| --- | --- | --- | --- |
| B1 | `AlchemicalUtils` | `switch` → `UPDATE_DATA` | TC-UTIL-003 |
| B2 | `AlchemicalUtils` | `switch` → `UPDATE_COMPONENT` | TC-UTIL-002 |
| B3 | `AlchemicalUtils` | `switch` → 默认（未知键） | TC-UTIL-004 |
| B4 | `AlchemicalNode` | `BasicAlchemyAttribute` `if (!params)` 为真 | TC-NODE-008 |
| B5 | `AlchemicalNode` | `BasicAlchemyAttribute` `if (!params)` 为假 | TC-NODE-007 |
| B6/B7 | `AlchemicalText` | `if (!params)` 真 / 假 | TC-ATTR-002 / TC-ATTR-001 |
| B8/B9 | `AlchemicalButton` | `if (!params)` 真 / 假 | TC-ATTR-004 / TC-ATTR-003 |
| B10/B11 | `AlchemicalImage` | `if (!params)` 真 / 假 | TC-ATTR-006 / TC-ATTR-005 |
| B12/B13 | `AlchemicalCheckbox` | `if (!params)` 真 / 假 | TC-ATTR-008 / TC-ATTR-007 |
| B14/B15 | `AlchemicalSlider` | `if (!params)` 真 / 假 | TC-ATTR-010 / TC-ATTR-009 |
| B16/B17 | `AlchemicalTextInput` | `if (!params)` 真 / 假 | TC-ATTR-012 / TC-ATTR-011 |
| B18 | `AlchemicalRod` | `switch` → `UPDATE_COMPONENT` | TC-ROD-001 |
| B19 | `AlchemicalRod` | `switch` → `UPDATE_DATA` | TC-ROD-007 |
| B20 | `AlchemicalRod` | `switch` → 默认（**死分支**，见下） | — |
| B21/B22 | `AlchemicalRod` | `if (!registry)` 真 / 假（seam 新增） | TC-ROD-005 / TC-ROD-001 |
| B23/B24 | `AlchemicalRod` | `if (!loopRoot)` 真 / 假 | TC-ROD-002 / TC-ROD-001 |
| B25/B26 | `AlchemicalRod` | `if (!attribute)` 真 / 假 | TC-ROD-003 / TC-ROD-001 |
| B27/B28 | `AlchemicalRod` | `if (!value.child)` 真 / 假 | TC-ROD-001 / TC-ROD-004 |
| — | `AlchemicalFurnace`/`AlchemicalComponent`/各容器 | struct `build()`、`@Builder` | ❌ 需设备（不纳入分母口径） |

**B20 死分支论证**：`AlchemicalRodImpl.onReceive` 的 `switch` 只对 `parseMessage` 的产物分支，而 `parseMessage` 仅可能产出 `UPDATE_DATA` / `UPDATE_COMPONENT` 两种 `AlchemicalPotionType`。因此 `default` 分支在现有代码结构下**不可达**，无法构造合法输入覆盖。已登记为 D-1；若删除该 `default` 或未来新增 Potion 类型则消除。

## 5. 用例清单

| 用例编号 | 标题 | 层级 | 对应 AC | 自动化落点 | 类型 |
| --- | --- | --- | --- | --- | --- |
| TC-UTIL-001 | 空数组报文返回空列表 | L-Unit | AC-1 | `AlchemicalUtils.test.ets` | 边界 |
| TC-UTIL-002 | 解析 UPDATE_COMPONENT 指令 | L-Unit | AC-1 | 同上 | 正常 |
| TC-UTIL-003 | 解析 UPDATE_DATA 指令 | L-Unit | AC-1 | 同上 | 正常 |
| TC-UTIL-004 | 未知指令键被跳过 | L-Unit | AC-1 | 同上 | 异常 |
| TC-UTIL-005 | 非法 JSON 抛异常（刻画现状） | L-Unit | AC-1 | 同上 | 异常 |
| TC-UTIL-006 | 混合报文顺序保持且未知键被剔除 | L-Unit | AC-1 | 同上 | 边界 |
| TC-UTIL-007 | assign 覆盖已有字段 | L-Unit | AC-2 | 同上 | 正常 |
| TC-UTIL-008 | assign 空对象不改变目标 | L-Unit | AC-2 | 同上 | 边界 |
| TC-NODE-001 | createRoot 返回 root/Blank 且无子节点 | L-Unit | AC-3 | `AlchemicalNode.test.ets` | 正常 |
| TC-NODE-002 | addChild 后子节点可枚举 | L-Unit | AC-3 | 同上 | 正常 |
| TC-NODE-003 | removeChild 成功返回 true | L-Unit | AC-3 | 同上 | 正常 |
| TC-NODE-004 | removeChild 不存在返回 false | L-Unit | AC-3 | 同上 | 边界 |
| TC-NODE-005 | 同 id addChild 覆盖（Map 语义） | L-Unit | AC-3 | 同上 | 边界 |
| TC-NODE-006 | BasicAlchemyAttribute 默认值 | L-Unit | AC-4 | 同上 | 正常 |
| TC-NODE-007 | BasicAlchemyAttribute 注入 params | L-Unit | AC-4 | 同上 | 正常 |
| TC-NODE-008 | BasicAlchemyAttribute params 为 undefined | L-Unit | AC-4 | 同上 | 边界 |
| TC-NODE-009 | AlchemicalNode 构造可传入自定义 attr | L-Unit | AC-3 | 同上 | 正常 |
| TC-ATTR-001..012 | 6 个组件 Attribute 的注入与缺省 | L-Unit | AC-4 | `AlchemicalAttributes.test.ets` | 正常/边界 |
| TC-ROD-001 | 已注册 id+类型、无 child：更新 type/attr | L-Unit | AC-5 | `AlchemicalRod.test.ets` | 正常 |
| TC-ROD-002 | 未注册 id：提前返回 | L-Unit | AC-5 | 同上 | 边界 |
| TC-ROD-003 | 未注册 componentType：type 已改、attr 未改 | L-Unit | AC-5 | 同上 | 异常 |
| TC-ROD-004 | 含 child：创建并注册占位子节点 | L-Unit | AC-5 | 同上 | 正常 |
| TC-ROD-005 | 未注册 registry：安全忽略不崩溃 | L-Unit | AC-5 | 同上 | 异常 |
| TC-ROD-006 | 重复下发父节点指令：数量不增长但子对象被替换（刻画缺陷 #4） | L-Unit | AC-5 | 同上 | 边界 |
| TC-ROD-007 | UPDATE_DATA 不抛异常且不改节点树 | L-Unit | AC-5 | 同上 | 边界 |
| TC-ROD-008 | 混合批量指令端到端 | L-Unit | AC-5 | 同上 | 正常 |
| TC-REG-001 | componentMap 含 12 种类型 | L-Unit | AC-6 | `AlchemicalRegistry.test.ets` | 正常 |
| TC-REG-002 | 两张注册表键集合一致 | L-Unit | AC-6 | 同上 | 正常 |
| TC-REG-003 | 每个 Attribute 工厂可无参实例化 | L-Unit | AC-6 | 同上 | 正常 |
| TC-REG-004 | 每个 Attribute 工厂可接受 params 注入 | L-Unit | AC-6 | 同上 | 正常 |
| TC-FACTORY-001 | forgeAlchemicalRod 返回可用实例 | L-Unit | AC-7 | 同上 | 正常 |
| TC-DATA-001 | AlchemicalData.updateDataModel 不抛异常 | L-Unit | AC-8 | 同上 | 边界 |

## 6. 通过标准（Exit Criteria）

| 项 | 阈值 |
| --- | --- |
| 本次新增用例 | 100% 通过 |
| 逻辑层**分支覆盖** | 除 B20（已论证死分支）外全部覆盖 |
| 既有用例 | 无回归（`localUnitTest` 样板仍绿） |
| CodeLinter | 无新增 error |
| `assembleHap` | 通过（验证 seam 未破坏 UI 编译产物） |
| 无法执行的验证 | 无（本次环境已解除阻塞） |

## 6.1 实测结果（2026-09-15）

命令：`tools/run-unit-tests.sh`（内部为 `hvigorw --mode module -p module=Alchemy@default -p product=default test`）
退出码：`0`

| 项 | 基线（变更前） | 实测（变更后） |
| --- | --- | --- |
| 用例数 / 通过 | 1 / 1（样板，不触及引擎） | **44 / 44** |
| 逻辑层 行覆盖 | 0/160 (0%) | **109/165 (66.1%)** |
| 逻辑层 函数覆盖 | 0/49 (0%) | **25/50 (50.0%)** |
| 逻辑层 **分支覆盖** | 0/26 (0%) | **27/28 (96.4%)** |
| 整体 分支覆盖 | 0/26 (0%) | **27/28 (96.4%)** |
| 回归 `assembleHap` | ✅ | ✅ `BUILD SUCCESSFUL` |
| 回归 CodeLinter | 0 error / 4 warn | **0 error / 4 warn**（无新增） |

**分支口径结论**

- 全项目 28 个分支中，**27 个已覆盖**；
- 唯一未覆盖的是 `AlchemicalRod.ets:46` 的 `default:`（实测 `trueCount = 0, falseCount = 10`），
  即 §4 中已论证的**不可达分支 B20**；
- 因此 **可达分支覆盖 = 27/27 = 100%**。

**未覆盖函数的构成（逻辑层 25/50）**

| 类别 | 数量 | 原因 |
| --- | --- | --- |
| `@Builder` 组件函数（`xComponentBuilder`） | 6 | 需 ArkUI UI 运行时 |
| `@ComponentV2` struct 内部（`initialRender` / `anonymous_*`） | 18 | 需 ArkUI UI 运行时 |
| `AlchemicalRodImpl.registerAlchemicalFurnaceImpl` | 1 | 参数为 struct，测试无法构造（记录为 AGENT.md 问题 #12） |
| 合计 | 25 | 全部为「本地不可达」，非遗漏 |

> 注：逻辑层分母在本次变更中由 160 行 / 49 函数 / 26 分支增长为 165 行 / 50 函数 / 28 分支，
> 增量来自 seam 改造本身（新增 `registerNodeRegistry` 与 registry 空值保护）。

## 7. 回归范围

| 受影响能力 | 回归用例 | 原因 |
| --- | --- | --- |
| UI 渲染链路 | `assembleHap` 编译通过 | seam 改动 `AlchemicalRodImpl`，被 Furnace 调用 |
| 消息解析 | TC-UTIL-001..006 | 未改动，但为守护基线 |
| 既有样板用例 | `localUnitTest` | 确认未破坏测试注册机制 |

## 8. 风险与限制

| 项 | 说明 |
| --- | --- |
| 测试盲区 | ① UI struct 渲染（需设备）；② rawfile 规则 JSON 与注册表一致性（本地无 `resourceManager`）；③ `entry` 演示页读 rawfile 路径 |
| 环境限制 | 需 DevEco 自带 SDK + JBR；路径在非 DevEco 环境需通过环境变量覆盖 |
| 未自动化项 | 无（本次范围） |
| 断言锁死缺陷 | TC-ROD-003/006、TC-UTIL-005、TC-DATA-001 刻画**当前缺陷行为**，修复对应缺陷时**必须同步更新**这些用例，否则会被误判为回归 |

## 9. 变更记录

| 日期 | 修改人 | 说明 |
| --- | --- | --- |
| 2026-09-15 | AI Agent | 初稿；含 B20 死分支论证与断言锁死缺陷的风险提示 |
