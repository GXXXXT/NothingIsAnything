# 02 · 开发方案 · 引擎逻辑分支覆盖

| 项 | 内容 |
| --- | --- |
| 变更 ID | `REQ-20260915-engine-branch-coverage` |
| 关联需求 | `01-requirements.md` |
| 状态 | approved |

---

## 1. 方案概述与关键取舍

**整体做法**：以「刻画性测试（characterization test）」为主，为引擎逻辑层逐分支建立用例，锁定**当前**行为；不改变任何功能语义。

**唯一的生产代码改动**：`AlchemicalRodImpl` 缺少测试接缝，必须补一个最小注入点。

### 1.1 为什么必须改生产代码（问题陈述）

`AlchemicalRodImpl.updateComponents()` 的全部逻辑都建立在 `this.alchemicalFurnace!.nodeList` 之上：

```ts
const loopRoot: AlchemicalNode | undefined = this.alchemicalFurnace!.nodeList.get(value.id);
```

要在测试里驱动这段逻辑，必须提供一个带 `nodeList` 的对象。但实测证明**两条路都走不通**：

| 尝试 | 结果 |
| --- | --- |
| `{ nodeList: map } as AlchemicalFurnaceImpl` | ❌ 编译失败 `arkts-no-untyped-obj-literals`（struct 不接受对象字面量） |
| `{} as AlchemicalFurnaceImpl` 再赋值字段 | ❌ 同上，空字面量同样被拒 |
| `new AlchemicalFurnaceImpl()` | ❌ ArkUI struct 不能 `new`，且 `build()` 需 UI 运行时 |

结论：`AlchemicalRod.ets` 的 9 个分支中有 6 个在**当前代码结构下不可测**。需要引入依赖倒置的接缝。

### 1.2 选定方案：新增节点注册表注入点

在 `AlchemicalRodImpl` 上把「取节点表」这一依赖显式化，UI 路径行为保持不变。

```ts
// Before
export class AlchemicalRodImpl implements AlchemicalRod {
  uiContext: UIContext;
  private alchemicalFurnace: AlchemicalFurnaceImpl | undefined = undefined;

  constructor(uiContext: UIContext) { this.uiContext = uiContext; }

  registerAlchemicalFurnaceImpl(furnace: AlchemicalFurnaceImpl): void {
    this.alchemicalFurnace = furnace;
  }

  private updateComponents(value: ComponentDescriptor): void {
    const loopRoot: AlchemicalNode | undefined = this.alchemicalFurnace!.nodeList.get(value.id);
    ...
  }
}
```

```ts
// After（实际落地版本）
export class AlchemicalRodImpl implements AlchemicalRod {
  uiContext: UIContext;
  private nodeRegistry: Map<string, AlchemicalNode> | undefined = undefined;

  constructor(uiContext: UIContext) { this.uiContext = uiContext; }

  registerAlchemicalFurnaceImpl(furnace: AlchemicalFurnaceImpl): void {
    // UI 路径：从熔炉中提取节点表，作为默认注册表。
    this.registerNodeRegistry(furnace.nodeList);
  }

  /** 注入节点注册表。供单元测试与非 UI 场景使用。 */
  registerNodeRegistry(registry: Map<string, AlchemicalNode>): void {
    this.nodeRegistry = registry;
  }

  private updateComponents(value: ComponentDescriptor): void {
    const registry: Map<string, AlchemicalNode> | undefined = this.nodeRegistry;
    if (!registry) {
      return;
    }
    const loopRoot: AlchemicalNode | undefined = registry.get(value.id);
    if (!loopRoot) {
      return;
    }
    loopRoot.type = value.componentType;
    ...
    value.child.forEach((child: string) => {
      const blank: AlchemicalNode = new AlchemicalNode(child, 'Blank');
      loopRoot.addChild(blank);
      registry.set(child, blank);      // 原为 this.alchemicalFurnace?.nodeList.set(...)
    })
  }
}
```

> **设计取舍说明**：初稿曾采用「懒解析 + `??` / `?.`」写法（保留 `alchemicalFurnace` 字段，
> 用时再回退读取）。实作时改为**在注册时一次性提取 `furnace.nodeList`**，原因：
> ① `nodeList` 在 `AlchemicalFurnaceImpl` 中只被 `.set()` 变更、**从不整体重新赋值**，
>    因此一次性提取与每次读取指向同一对象，语义等价；
> ② 懒解析写法会额外引入 4 个分支（`??` × 2 + `?.` × 2），其中「`alchemicalFurnace` 已定义」
>    一路**在测试中不可达**（struct 无法构造），反而降低了分支覆盖率；
> ③ 一次性提取只新增 2 个分支，且都可覆盖。
> 该取舍同时消除了 `alchemicalFurnace` 字段本身。

**行为等价性论证**

| 场景 | Before | After | 是否等价 |
| --- | --- | --- | --- |
| UI 正常路径（Furnace 在 `aboutToAppear` 注册） | 保存 furnace 引用，用时读 `furnace.nodeList` | 注册时提取 `furnace.nodeList` 存入 `nodeRegistry` | ✅ 等价（`nodeList` 从不整体重新赋值，引用恒定） |
| UI 路径但根节点 id 不存在 | `get` 返回 undefined → 提前 return | 同 | ✅ 等价 |
| UI 路径带 `child` | `this.alchemicalFurnace?.nodeList.set(child, blank)` | `registry.set(child, blank)`，二者为同一 Map | ✅ 等价 |
| 未注册 Furnace 且收到 `UPDATE_COMPONENT` | `!` 断言 → **TypeError 崩溃** | 提前 return（静默忽略） | ⚠️ **有意变更**：由崩溃改为安全忽略，消除 AGENT.md §1.9 问题 #5 |
| 未注册 Furnace 且收到 `UPDATE_DATA` | 空实现，无影响 | 同 | ✅ 等价 |

> 该行为变更属**本次必需**：seam 替换掉了 `!` 断言，因此顺带把「崩溃」变成「安全忽略」。
> 它严格优于原行为，且不影响 `entry` 演示路径（演示中 Furnace 必定先注册）。已在 `03-test-plan.md` 登记为回归项。

### 1.3 备选方案与放弃原因

| 备选方案 | 放弃原因 |
| --- | --- |
| 让 `AlchemicalRodImpl` 依赖新 `interface AlchemicalFurnaceHost`，由 struct 实现 | 改动面更大（碰 `engine/core/AlchemicalFurnace.ets` 的 struct 声明），且 `@Local` 字段是否满足结构类型存在不确定性，风险高于收益 |
| 让测试间接通过 `AlchemicalFurnaceImpl` 真实实例 | struct 无法在无 UI 运行时下实例化，不可行 |
| 放弃覆盖 `updateComponents`，只测 `parseMessage` | 分支覆盖目标（NFR-1）无法达成，且 `updateComponents` 正是缺陷最集中处 |
| 用 `Object.create(AlchemicalFurnaceImpl.prototype)` 绕过类型系统 | 依赖编译产物内部结构，脆弱且不可读，拒绝 |

## 2. 架构影响

- 影响层：仅 `engine/core/AlchemicalRod.ets`。
- **不改变**数据流方向（对照 AGENT.md §1.4）：消息仍走 `parseMessage → onReceive → updateComponents → 节点树`。
- 不新增/删除组件类型。
- 不影响 `interface/` 对外契约：`AlchemicalRod` 接口不变，`Alchemy/Index.ets` 导出不变。
- `registerNodeRegistry` 是**新增的公开方法**，但不在 `Index.ets` 导出范围内，故不构成对外契约。

## 3. 文件级改动清单

### 3.1 新增

| 文件路径 | 用途 |
| --- | --- |
| `docs/changes/REQ-20260915-engine-branch-coverage/**` | 本次变更的 5 份流程文档 |
| `Alchemy/src/test/AlchemicalUtils.test.ets` | FR-1 / FR-2：消息解析与属性赋值 |
| `Alchemy/src/test/AlchemicalNode.test.ets` | FR-3 / FR-4 一部分：节点树与基类 Attribute |
| `Alchemy/src/test/AlchemicalAttributes.test.ets` | FR-4：6 个组件 Attribute 的注入与缺省 |
| `Alchemy/src/test/AlchemicalRod.test.ets` | FR-5：指令分发与提前返回路径 |
| `Alchemy/src/test/AlchemicalRegistry.test.ets` | FR-6 / FR-7 / FR-8：注册表、工厂、数据模型 |
| `tools/run-unit-tests.sh` | FR-9：一条命令跑测（固化 SDK/JDK 环境变量） |

### 3.2 修改

| 文件路径 | 改动要点 | 对应 FR |
| --- | --- | --- |
| `Alchemy/src/main/ets/engine/core/AlchemicalRod.ets` | 新增 `registerNodeRegistry`，`registerAlchemicalFurnaceImpl` 改为转发 `furnace.nodeList`，`updateComponents` 增加 registry 空值保护并移除 `!` 断言 | FR-5（可测性） |
| `Alchemy/src/test/List.test.ets` | 注册 5 个新测试套件 | FR-1..FR-8 |
| `AGENT.md` | §6.2 更新为**已验证可用**的构建/测试命令与覆盖率获取方式 | FR-9 |

### 3.3 删除

| 文件路径 | 删除原因 |
| --- | --- |
| `Alchemy/src/test/Probe.test.ets` | 临时探针，结论已固化进 `01-requirements.md` §10，正式用例取代之 |

## 4. 接口与协议变更

### 4.1 对外接口

**无变更**。`Alchemy/Index.ets` 仍只导出 `AlchemicalFurnace`、`AlchemicalRod`、`AlchemicalRodCreator`。

### 4.2 消息协议

**无变更**。不改 `ComponentDescriptor` / `DataDescriptor` / 报文结构。

### 4.3 内部新增成员

```ts
// engine/core/AlchemicalRod.ets（内部实现层，非对外契约）
registerNodeRegistry(registry: Map<string, AlchemicalNode>): void
```

## 5. 数据结构与状态流

- 节点树结构不变：`AlchemicalNode`（`@ObservedV2` + `@Trace`）持有 `children: Map<string, AlchemicalNode>`。
- 新增一个 `nodeRegistry` 引用，仅作为**取值来源**，不参与状态观测（普通私有字段，非 `@Trace`）。
- 刷新触发点不变：仍是 `node.type` / `node.attr` 的 `@Trace` 字段被写入。

## 6. 异常与边界处理

| 场景 | 预期行为 | 处理位置 | 用例 |
| --- | --- | --- | --- |
| 空数组报文 `[]` | 返回空 potion 列表，不抛异常 | `parseMessage` | TC-UTIL-001 |
| 非法 JSON | **抛异常**（当前未捕获，刻画为现状） | `parseMessage` | TC-UTIL-005 |
| 未知指令键 | 跳过该条 | `parseMessage` default | TC-UTIL-004 |
| `id` 不在注册表 | 提前 return，不建树 | `updateComponents` | TC-ROD-002 |
| `componentType` 未注册 | 提前 return，不改节点 | `updateComponents` | TC-ROD-003 |
| 未注册 Furnace | 安全忽略（不再崩溃） | `resolveNodeRegistry` | TC-ROD-005 |
| `child` 为 undefined | 不改子节点 | `updateComponents` | TC-ROD-001 |
| 同 id 重复下发 | **当前**会为 child 新建节点对象并覆盖 Map 条目：数量不增长，但子节点已有状态被丢弃（缺陷 #4，刻画为现状） | `updateComponents` | TC-ROD-006 |
| `params` 为空对象 | 保留 Attribute 缺省值 | 各 Attribute 构造 | TC-ATTR-* |

## 7. 兼容性与回滚

- 向后兼容：`AlchemicalRod` 接口与 `Index.ets` 导出不变，`entry` 无需改动。
- 既有 demo：不受影响（Furnace 仍调用 `registerAlchemicalFurnaceImpl`）。
- 回滚方式：`git revert` 本变更的两个提交（seam 一个、测试一个）。

## 8. 任务拆解

明细见 `05-task-breakdown.md`。

| 步骤 | 描述 | 依赖 | 验证方式 |
| --- | --- | --- | --- |
| R1 | 登记全部用例到 `04-test-cases.md` | — | 追踪矩阵无空行 |
| R2 | 编写 5 个测试套件（此时 Rod 用例因缺 seam 无法编译/运行） | R1 | 记录 RED 证据 |
| T1 | 落地 seam 改造 | R2 | Rod 用例可编译 |
| T2 | 跑绿全部用例 | T1 | `test_result.txt` 全 Success |
| T3 | 实测分支覆盖率并补漏 | T2 | `coverageReport.json` |
| C1 | 回归 `assembleHap` | T3 | 退出码 0 |
| C2 | 回归 CodeLinter | T3 | 无新增 error |
| C3 | 回填文档 + 清理探针 | C1,C2 | 人工核对 |

## 9. 风险

| 风险 | 概率 | 影响 | 应对 |
| --- | --- | --- | --- |
| seam 改动影响 UI 渲染 | 低 | 高 | UI 路径逐行等价论证 + `assembleHap` 回归 |
| 测试断言锁死缺陷，未来修复时误判为回归 | 中 | 中 | 涉及缺陷的用例在注释与文档中显式标注「刻画现状，修复时应同步更新」 |
| 覆盖率分母含 UI struct 行，数字看起来偏低 | 高 | 低 | 按 NFR-2 分别报告「逻辑层」与「整体」两组数字 |
| 本机 SDK 路径硬编码进脚本 | 中 | 低 | 脚本支持环境变量覆盖，并在 AGENT.md 说明 |

## 10. 变更记录

| 日期 | 修改人 | 说明 |
| --- | --- | --- |
| 2026-09-15 | AI Agent | 初稿；含 seam 行为等价性论证与 4 个备选方案否决理由 |
