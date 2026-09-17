# 05 · 任务拆解与推进记录 · 引擎逻辑分支覆盖

| 项 | 内容 |
| --- | --- |
| 变更 ID | `REQ-20260915-engine-branch-coverage` |
| 关联方案 | `02-design.md` |
| 状态 | verified |

---

## 1. RED 阶段步骤

| 步骤 | 描述 | 涉及文件 | 验证方式 | 状态 |
| --- | --- | --- | --- | --- |
| R0 | 环境探针：确认本地单元测试可加载 `@ObservedV2` / `@kit.ArkUI` 依赖，并确认 struct 不可伪造 | `Alchemy/src/test/Probe.test.ets`（临时） | `Tests run: 6, Pass: 6`；伪造 struct 编译失败 | ✅ |
| R1 | 全部用例登记进 `04-test-cases.md` | `04-test-cases.md` | 追踪矩阵无空行 | ✅ |
| R2 | 编写 4 个不依赖 seam 的套件 | `AlchemicalUtils/Node/Attributes/Registry.test.ets` | 编译通过并在 `List.test.ets` 注册 | ✅ |
| R3 | 在**未改动源码**下运行，确认刻画性用例全绿 | — | `Tests run: 36, Pass: 36`；分支 17/26 | ✅ |
| R4 | 编写 Rod 套件并注册，确认 **RED** | `AlchemicalRod.test.ets` | 编译错误 `registerNodeRegistry does not exist` | ✅ |

## 2. GREEN 阶段步骤

| 步骤 | 描述 | 涉及文件 | 依赖 | 验证方式 | 状态 |
| --- | --- | --- | --- | --- | --- |
| T1 | 落地 seam：`nodeRegistry` 字段 + `registerNodeRegistry` | `engine/core/AlchemicalRod.ets` | R4 | 编译通过 | ✅ |
| T2 | 改造 `registerAlchemicalFurnaceImpl` 转发 `furnace.nodeList` | 同上 | T1 | 编译通过 | ✅ |
| T3 | `updateComponents` 改用 registry + 空值保护，移除 `!`；child 注册改走 `registry` | 同上 | T2 | Rod 套件转绿 | ✅ |
| T4 | 跑绿全部用例 | — | T3 | `Tests run: 44, Pass: 44` | ✅ |
| T5 | 实测覆盖率，确认仅剩已论证的死分支 | — | T4 | 分支 27/28；未覆盖项定位到 `AlchemicalRod.ets:46 default` | ✅ |

> **越界记录**：T3 第一次改完后仍编译失败（`alchemicalFurnace does not exist` 于 93 行），
> 原因是 `child` 注册也引用了旧字段。补改后通过。该处属 `02-design.md` §3.2 已列文件范围内，
> 无需变更方案。

## 3. 收尾步骤

| 步骤 | 描述 | 验证方式 | 状态 |
| --- | --- | --- | --- |
| C1 | 回归 `assembleHap`（验证 seam 未破坏 UI 编译链路） | `BUILD SUCCESSFUL`，退出码 0 | ✅ |
| C2 | 回归 CodeLinter | `Errors: 0; Warns: 4`，与变更前一致 | ✅ |
| C3 | 修正 `AGENT.md` 中被实测推翻的结论（问题 #4、问题 #5、问题 #10） | 人工核对 §1.9 | ✅ |
| C4 | 更新 `AGENT.md` §6.1/§6.2：改为**已验证**的 SDK/JDK 路径与命令 | 命令实测通过 | ✅ |
| C5 | 新增 `AGENT.md` §4.3 ArkTS 测试约束、§4.5 覆盖率门槛、§5.6 可测试性 seam 规范 | 人工核对 | ✅ |
| C6 | 删除临时探针文件 | `Probe.test.ets` 不存在 | ✅ |
| C7 | 回填全部文档状态为 `verified` | 人工核对 | ✅ |
| C8 | 登记新技术债（问题 #11、#12） | `AGENT.md` §1.9 | ✅ |

## 4. 执行日志

| 时间 | 步骤 | 动作 | 结果 |
| --- | --- | --- | --- |
| 2026-09-15 | 探针 | 定位 `SDK component missing` 根因 | `DEVECO_SDK_HOME` 改指 DevEco 自带 SDK；补 `JAVA_HOME` |
| 2026-09-15 | 探针 | 验证测试可加载引擎逻辑 | 6/6 通过；`{} as UIContext` 可行 |
| 2026-09-15 | 探针 | 尝试伪造 `AlchemicalFurnaceImpl` | ❌ 两次编译失败（对象字面量禁止用于 struct）→ 决定引入 seam |
| 2026-09-15 | R3 | 4 套件跑原始代码 | 36/36 通过；分支 17/26 (65.4%) |
| 2026-09-15 | R4 | 加入 Rod 套件 | ❌ RED：`registerNodeRegistry does not exist` ×5 |
| 2026-09-15 | T3 | 首轮 seam 改造 | ❌ 残留 `alchemicalFurnace` 引用（第 93 行） |
| 2026-09-15 | T3' | 补改 child 注册 | ✅ 编译通过 |
| 2026-09-15 | T4/T5 | 全量跑测 + 覆盖率 | ✅ 44/44；分支 27/28 (96.4%) |
| 2026-09-15 | C1/C2 | 构建 + lint 回归 | ✅ 均通过，lint 无新增 |

## 5. 阻塞记录

| 时间 | 步骤 | 阻塞原因 | 期望验证 | 解除条件 | 状态 |
| --- | --- | --- | --- | --- | --- |
| 2026-09-15 | 环境 | `hvigorw assembleHap` 报 `SDK component missing` | 能否 CLI 构建 | 改用 DevEco 自带 SDK `/Applications/DevEco-Studio.app/Contents/sdk` | ✅ 已解除 |
| 2026-09-15 | 环境 | `PackageHap` 报 `Unable to locate a Java Runtime` | 能否产出 HAP | 设置 `JAVA_HOME` 为 DevEco 自带 JBR | ✅ 已解除 |
| — | — | **最终无遗留阻塞** | — | — | — |

## 6. 变更记录

| 日期 | 修改人 | 说明 |
| --- | --- | --- |
| 2026-09-15 | AI Agent | 初稿并完成全部步骤；含 3 次失败记录与 2 次环境阻塞解除 |
