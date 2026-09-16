# 01 · 需求文档 · 引擎逻辑分支覆盖

| 项 | 内容 |
| --- | --- |
| 变更 ID | `REQ-20260915-engine-branch-coverage` |
| 变更级别 | L2 |
| 关联需求原文 | 「当前已实现的部分没有对应测试用例覆盖，补充，保证功能分支覆盖率」 |
| 状态 | approved |

---

## 1. 背景与问题

`Alchemy` 引擎已实现消息解析、组件树构建与递归渲染，但测试资产为零真实覆盖：

- `Alchemy/src/test/List.test.ets` 只注册了脚手架样板 `LocalUnit.test.ets`（`assertContain`）。
- 该样板**不 import 任何引擎源码**，因此对引擎的覆盖率恒为 0。

实测基线（`hvigorw ... test` 自动产出的 `coverageReport.json`）：

| 指标 | 覆盖 / 总数 | 百分比 |
| --- | --- | --- |
| Lines | 0 / 254 | 0% |
| Functions | 0 / 117 | 0% |
| **Branches** | **0 / 26** | **0%** |

后果：任何对引擎的改动都没有回归保护（对应 AGENT.md §1.9 问题 #10）。

## 2. 目标

- G-1：把引擎**逻辑层**的分支覆盖率从 0% 提升到尽可能接近 100%，并对无法覆盖的分支给出可验证的论证。
- G-2：测试能在本机真实执行，产出可复现的覆盖率数字（不允许"看起来覆盖了"）。
- G-3：测试成为后续改动的回归网，使 AGENT.md 中「先写用例再动源码」可执行。

## 3. 非目标（明确不做）

- NG-1：**不测** `@ComponentV2` struct 的 `build()` 渲染结果与 UI 外观。本地单元测试无 UI 运行时，需设备侧 ohosTest，属另一变更。
- NG-2：**不修** AGENT.md §1.9 中的功能缺陷（如 `UPDATE_DATA` 未实现）。本次只**刻画现状**，不改变功能语义。
- NG-3：不追求把 254 行全部覆盖——UI struct 行不在本地可达范围内（见 §6 NFR-2）。
- NG-4：不引入新的测试框架或第三方依赖（只用已有 `@ohos/hypium`）。

## 4. 用户故事

| 编号 | 角色 | 我希望 | 以便 |
| --- | --- | --- | --- |
| US-1 | 引擎开发者 | 改 `parseMessage` / 节点树 / Rod 分发时立刻知道是否破坏既有行为 | 敢于重构 |
| US-2 | AI Agent | 有可运行的回归命令与覆盖率门槛 | 在 S5 门禁上有客观判据 |
| US-3 | 项目维护者 | 看见"哪些分支没人测"的清单 | 排优先级 |

## 5. 功能需求（FR）

> 注：本变更为测试补齐，"功能"指**测试能力**。

| 编号 | 需求描述 | 优先级 |
| --- | --- | --- |
| FR-1 | 为消息解析 `AlchemicalUtils.parseMessage` 的两个指令分支与未知键分支建立用例 | P0 |
| FR-2 | 为 `AlchemicalUtils.assign` 的有键/无键行为建立用例 | P0 |
| FR-3 | 为 `AlchemicalNode` 的构造、child 增删、`createRoot`、默认 attr 建立用例 | P0 |
| FR-4 | 为 6 个带独立 Attribute 的组件（Text/Button/Image/Checkbox/Slider/TextInput）的 params 注入与缺省值建立用例 | P0 |
| FR-5 | 为 `AlchemicalRodImpl.onReceive` 的指令分发与 `updateComponents` 的 3 条提前返回路径建立用例 | P0 |
| FR-6 | 为组件注册表 `componentMap` / `componentAttributeMap` 的完整性与一致性建立用例（12 种类型） | P0 |
| FR-7 | 为 `AlchemicalRodCreator.forgeAlchemicalRod` 工厂建立用例 | P1 |
| FR-8 | 为 `AlchemicalData.updateDataModel`（当前空实现）建立刻画用例，锁定"调用不抛异常且不改变状态"的现状 | P1 |
| FR-9 | 提供一条可在本机复现的测试执行命令，并产出 `coverageReport.json` | P0 |

## 6. 非功能需求（NFR）

| 编号 | 类别 | 指标 | 测量方式 |
| --- | --- | --- | --- |
| NFR-1 | 覆盖率 | 逻辑层**分支覆盖 100%**（26/26，死分支需论证） | `coverageReport.json` → `summary.branches` |
| NFR-2 | 覆盖率 | 明确区分"本地可达"与"需设备"两类，UI struct 行不计入本次分母 | 按文件清单人工核对 |
| NFR-3 | 可执行性 | 全部用例在本机 `hvigorw test` 下真实通过，退出码 0 | 命令输出 + `test_result.txt` |
| NFR-4 | 隔离性 | 用例之间无状态污染（每个用例自建节点树/注册表） | 代码审查：无共享可变全局 |
| NFR-5 | 零回归 | 测试改动不改变任何运行时行为（seam 重构除外，需论证等价） | `assembleHap` 通过 + 全量用例绿 |
| NFR-6 | 可维护性 | 新增测试文件在 `List.test.ets` 注册；命名可读 | 代码审查 |

## 7. 验收标准（AC）

| AC | 对应 FR | 验收标准（Given / When / Then） |
| --- | --- | --- |
| AC-1 | FR-1 | Given 含 `UPDATE_COMPONENT` / `UPDATE_DATA` / 未知键 / 空数组的报文，When 调用 `parseMessage`，Then 分别得到正确 type 序列且未知键与空数组被跳过 |
| AC-2 | FR-2 | Given 有键/无键对象，When 调用 `assign`，Then 有键被写入目标、无键不抛异常 |
| AC-3 | FR-3 | Given 一个节点，When `addChild`/`removeChild`/`getChildren`/`createRoot`，Then 子节点集合与 id 正确、root 为 `Blank` |
| AC-4 | FR-4 | Given 完整 params 与 undefined，When 构造各 Attribute，Then 注入值与缺省值均正确 |
| AC-5 | FR-5 | Given 未注册 id、未注册 componentType、含 child 的指令，When `onReceive`，Then 分别提前返回／正常建树，且不抛异常 |
| AC-6 | FR-6 | Given 引擎注册表，When 枚举，Then 12 种类型齐备且每个都有可实例化的 Attribute 工厂 |
| AC-7 | FR-7 | Given `{} as UIContext`，When `forgeAlchemicalRod`，Then 返回带 `onReceive` 的实例 |
| AC-8 | FR-8 | Given `AlchemicalData`，When `updateDataModel`，Then 不抛异常（刻画现状） |
| AC-9 | FR-9 | Given 本机工具链，When 执行 `test` 任务，Then 退出码 0 且生成 `coverageReport.json` |

## 8. 本项目影响面自查

- [x] 是否涉及消息协议？ → 否（只读取现有协议结构）
- [x] 是否涉及 `Alchemy/Index.ets` 对外导出？ → 否
- [x] 是否新增/修改组件类型？ → 否
- [x] 是否触碰 AGENT.md §1.9 已知问题？ → 触碰 #5（`!` 非空断言）与 #10（零覆盖），其中 #5 因 seam 改造顺带消除，已记录
- [x] 是否涉及 ArkUI V1/V2 装饰器？ → 测试不新增装饰器；seam 不改变 V2 用法
- [x] 是否更新 demo 报文？ → 否

## 9. 衍生问题（本次不做，仅登记）

| 编号 | 问题 | 发现位置 | 建议处理时机 |
| --- | --- | --- | --- |
| D-1 | `AlchemicalRodImpl.onReceive` 的 `switch default` 分支不可达（`parseMessage` 只产出两种 type） | `engine/core/AlchemicalRod.ets` | 若未来新增 Potion 类型则自动可达；否则可移除 default |
| D-2 | 注册表（代码）↔ 规则 JSON（rawfile）无一致性自动校验；`Blank` 缺规则文件 | `rawfile/v1.0/` | 建议下一变更实现 L-Schema 测试 |
| D-3 | 规则 JSON 的 `child` 类型写成 `"object"`（应为 array） | 同上 | 协议变更时一并修 |
| D-4 | UI struct 层无任何测试 | 全部 `@ComponentV2` | 需设备侧 ohosTest 变更 |
| D-5 | `AlchemicalData` 的 `@Trace private static` 语义可疑 | `engine/datamodel/AlchemicalData.ets` | 实现 `UPDATE_DATA` 时核实 |

## 10. 开放问题与假设

| 编号 | 问题 | 状态 | 结论 / 默认假设 |
| --- | --- | --- | --- |
| Q-1 | 本地单元测试能否加载 `@ObservedV2` 与 `@kit.ArkUI` 依赖的文件？ | 已澄清 | **能**。已用探针实测：`AlchemicalNode`、`AlchemyTextAttribute`、`AlchemicalRodImpl` 均可加载并实例化 |
| Q-2 | 能否直接伪造 `AlchemicalFurnaceImpl` 注入 Rod？ | 已澄清 | **不能**。ArkTS 禁止对 struct 做对象字面量断言（`arkts-no-untyped-obj-literals`），故需最小 seam（见 02-design §1） |
| Q-3 | "功能分支覆盖率"是否包含 UI 渲染分支？ | 已澄清 | 不包含。本地无 UI 运行时，按 NFR-2 单独列出并排除 |

## 11. 变更记录

| 日期 | 修改人 | 说明 |
| --- | --- | --- |
| 2026-09-15 | AI Agent | 初稿；含环境阻塞解除与探针实测结论 |
