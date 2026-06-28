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
 * 炼金横向布局 — 封装 ArkUI Row 容器组件。
 *
 * 子节点沿水平方向排列，可作为其他组件的父容器。
 */
export class AlchemicalRow extends AlchemicalComponent {

  constructor(uiContext: UIContext) {
    super(uiContext);
    let row: typeNode.Row = typeNode.createNode(this.uiContext, 'Row');
    this.node = row;
  }

  override buildRule(): void {
    this.loadRule('v1.0/AlchemicalComponents/AlchemicalRow.json');
  }
}
