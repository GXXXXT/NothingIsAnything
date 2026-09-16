#!/usr/bin/env node
/**
 * 汇总 hvigor 单元测试产出的 coverageReport.json，打印整体与「逻辑层」两组覆盖率。
 *
 * 用法: node tools/coverage-summary.js <coverageReport.json>
 *
 * 「逻辑层」= 可在本地单元测试中执行的纯逻辑文件（见
 * docs/changes/REQ-20260915-engine-branch-coverage/03-test-plan.md）。
 * UI struct 的 build() 需要设备侧 ohosTest，不计入逻辑层口径。
 */
'use strict';

const fs = require('fs');

/** 逻辑层文件（相对 Alchemy/src/main/ets 的路径后缀）。 */
const LOGIC_LAYER = [
  'engine/common/AlchemicalUtils.ets',
  'engine/components/AlchemicalNode.ets',
  'engine/components/AlchemicalText.ets',
  'engine/components/AlchemicalButton.ets',
  'engine/components/AlchemicalImage.ets',
  'engine/components/AlchemicalCheckbox.ets',
  'engine/components/AlchemicalSlider.ets',
  'engine/components/AlchemicalTextInput.ets',
  'engine/core/AlchemicalRod.ets'
];

function pct(covered, total) {
  if (total === 0) return '100.0';
  return ((covered / total) * 100).toFixed(1);
}

function fmt(s) {
  return `${s.covered}/${s.total} (${pct(s.covered, s.total)}%)`.padEnd(18);
}

function main() {
  const reportPath = process.argv[2];
  if (!reportPath || !fs.existsSync(reportPath)) {
    console.error(`未找到覆盖率报告: ${reportPath}`);
    process.exit(1);
  }

  const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
  const files = report.files || [];

  const isLogic = (p) => LOGIC_LAYER.some((suffix) => p.endsWith(suffix));

  const acc = (list) => list.reduce(
    (a, f) => ({
      lines: { covered: a.lines.covered + f.summary.lines.covered, total: a.lines.total + f.summary.lines.total },
      functions: { covered: a.functions.covered + f.summary.functions.covered, total: a.functions.total + f.summary.functions.total },
      branches: { covered: a.branches.covered + f.summary.branches.covered, total: a.branches.total + f.summary.branches.total }
    }),
    { lines: { covered: 0, total: 0 }, functions: { covered: 0, total: 0 }, branches: { covered: 0, total: 0 } }
  );

  const logic = acc(files.filter((f) => isLogic(f.path)));

  console.log('');
  console.log('================ 覆盖率摘要 ================');
  console.log('指标       逻辑层             整体');
  console.log(`行         ${fmt(logic.lines)} ${fmt(report.summary.lines)}`);
  console.log(`函数       ${fmt(logic.functions)} ${fmt(report.summary.functions)}`);
  console.log(`分支       ${fmt(logic.branches)} ${fmt(report.summary.branches)}`);
  console.log('');

  const withBranches = files
    .filter((f) => f.summary.branches.total > 0 || isLogic(f.path))
    .map((f) => ({
      file: (f.path.split('/ets/')[1] || f.path).replace('engine/', ''),
      br: f.summary.branches,
      ln: f.summary.lines,
      logic: isLogic(f.path)
    }))
    .sort((a, b) => (b.br.total - b.br.covered) - (a.br.total - a.br.covered) || b.br.total - a.br.total);

  if (withBranches.length > 0) {
    console.log('含分支的文件:');
    console.log('  ' + 'file'.padEnd(44) + 'branches'.padEnd(18) + 'lines');
    for (const row of withBranches) {
      const flag = row.logic ? ' ' : '*';
      console.log(
        flag + ' ' + row.file.padEnd(44) + fmt(row.br) + fmt(row.ln)
      );
    }
    console.log('');
    console.log('  * = 含 UI struct，本地不可完全覆盖（其 build() 需设备侧 ohosTest）');
  }

  const missing = withBranches.filter((r) => r.logic && r.br.covered < r.br.total);
  if (missing.length > 0) {
    console.log('');
    console.log('逻辑层未覆盖分支:');
    for (const row of missing) {
      console.log(`  - ${row.file}: ${row.br.total - row.br.covered} 个未覆盖`);
    }
  }
}

main();
