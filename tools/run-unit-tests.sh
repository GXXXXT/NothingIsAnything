#!/usr/bin/env bash
#
# 运行 Alchemy 模块的本地单元测试（L-Unit），并打印覆盖率摘要。
#
# 用法:
#   tools/run-unit-tests.sh                 # 跑 Alchemy 模块
#   MODULE=entry tools/run-unit-tests.sh    # 跑 entry 模块
#
# 环境变量（都有默认值，可按本机情况覆盖）:
#   DEVECO_HOME       DevEco Studio 安装目录
#   DEVECO_SDK_HOME   HarmonyOS SDK 根目录（必须包含 native 组件）
#   JAVA_HOME         JDK/JBR 根目录
#
set -euo pipefail

DEVECO_HOME="${DEVECO_HOME:-/Applications/DevEco-Studio.app/Contents}"
export DEVECO_SDK_HOME="${DEVECO_SDK_HOME:-$DEVECO_HOME/sdk}"
export JAVA_HOME="${JAVA_HOME:-$DEVECO_HOME/jbr/Contents/Home}"
export PATH="$JAVA_HOME/bin:$DEVECO_HOME/tools/node/bin:$PATH"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULE="${MODULE:-Alchemy}"
HVIGORW="$DEVECO_HOME/tools/hvigor/bin/hvigorw"

if [[ ! -x "$HVIGORW" ]]; then
  echo "ERROR: 未找到 hvigorw: $HVIGORW" >&2
  echo "       请通过 DEVECO_HOME 指定 DevEco Studio 安装目录。" >&2
  exit 1
fi

cd "$PROJECT_ROOT"

echo "==> 运行 $MODULE 本地单元测试"
"$HVIGORW" --no-daemon --mode module \
  -p "module=$MODULE@default" -p product=default test "$@"

RESULT_FILE="$PROJECT_ROOT/$MODULE/.test/default/intermediates/test/coverage_data/test_result.txt"
if [[ -f "$RESULT_FILE" ]]; then
  echo
  echo "==> 测试结果 (${RESULT_FILE})"
  tail -3 "$RESULT_FILE"
fi

REPORT="$PROJECT_ROOT/$MODULE/.test/default/outputs/test/reports/coverageReport.json"
if [[ -f "$REPORT" ]]; then
  echo
  node "$PROJECT_ROOT/tools/coverage-summary.js" "$REPORT"
else
  echo "WARN: 未找到覆盖率报告 $REPORT" >&2
fi
