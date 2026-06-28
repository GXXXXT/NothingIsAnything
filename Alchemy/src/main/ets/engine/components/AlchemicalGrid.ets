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

import { AlchemicalComponent } from "./AlchemicalComponent";
import { typeNode } from "@ohos.arkui.node";

/**
 * 炼金网格 — 封装 ArkUI Grid 网格容器。
 *
 * 子节点按行列网格排列，适用于宫格布局等场景。
 */
export class AlchemicalGrid extends AlchemicalComponent {

  constructor(uiContext: UIContext) {
    super(uiContext);
    let grid: typeNode.Grid = typeNode.createNode(this.uiContext, 'Grid');
    this.node = grid;
  }

  override buildRule(): void {
    this.loadRule('v1.0/AlchemicalComponents/AlchemicalGrid.json');
  }
}
