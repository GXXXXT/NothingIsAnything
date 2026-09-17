# docs/ — 变更文档与工作流产物

本目录存放**每个需求的流程产物**。规范正文见仓库根目录 [`AGENT.md`](../AGENT.md)。

## 工作流速查

| 阶段 | 产物 | 模板 | 门禁 |
| --- | --- | --- | --- |
| S0 立项与澄清 | `README.md`（状态看板） | 直接新建 | G0 |
| S1 需求文档 | `01-requirements.md` | [`templates/01-requirements.md`](templates/01-requirements.md) | G1 |
| S2 开发方案 | `02-design.md` | [`templates/02-design.md`](templates/02-design.md) | G2 |
| S3 测试方案 | `03-test-plan.md` | [`templates/03-test-plan.md`](templates/03-test-plan.md) | G3 |
| S4 测试用例 + 测试代码（RED） | `04-test-cases.md` + `*.test.ets` | [`templates/04-test-cases.md`](templates/04-test-cases.md) | G4 |
| S5 源码实现（GREEN） | `05-task-breakdown.md` + 源码 | [`templates/05-task-breakdown.md`](templates/05-task-breakdown.md) | G5 |
| S6 回归与收尾 | 全部文档回填 | — | G6 |

## 新建一个变更

```bash
# 变更 ID 规则：REQ-<YYYYMMDD>-<kebab-slug>
ID=REQ-20260915-slider-data-update
mkdir -p "docs/changes/$ID"
for f in 01-requirements 02-design 03-test-plan 04-test-cases 05-task-breakdown; do
  cp "docs/templates/$f.md" "docs/changes/$ID/$f.md"
done
```

然后为 `docs/changes/$ID/README.md` 建立状态看板（结构见下）。

## 变更目录结构

```
docs/changes/REQ-<YYYYMMDD>-<slug>/
├── README.md               # 状态看板：阶段 / 门禁结果 / 下一步 / 未决阻塞
├── 01-requirements.md
├── 02-design.md
├── 03-test-plan.md
├── 04-test-cases.md
└── 05-task-breakdown.md
```

## 状态看板（`README.md`）最小结构

```markdown
# REQ-20260915-slider-data-update

- 变更级别：L2 / L3
- 原始需求：<开发者原话，原样粘贴>
- 当前阶段：S2 开发方案
- 当前状态：implementing

## 门禁记录

| 阶段 | 门禁 | 结果 | 时间 | 备注 |
| --- | --- | --- | --- | --- |
| S0 | G0 | ✅ 通过 | 2026-09-15 | 歧义点已澄清 |
| S1 | G1 | ✅ 通过 | 2026-09-15 | FR-1..3 均可测试 |
| S2 | G2 | ⏳ 进行中 | — | 待补异常分析 |

## 下一步

- 完成 02-design.md 的异常与边界章节，然后进入 S3。

## 阻塞 / 未决

- 无
```

## 状态流转

`draft → review → approved → implementing → verified → archived`

每份文档头部都有「状态」字段，阶段推进时同步更新。
