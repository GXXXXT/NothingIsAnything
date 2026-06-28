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
 * 炼金分割线 — 封装 ArkUI Divider 组件。
 *
 * 用于在布局中绘制水平或垂直分割线。
 */
export class AlchemicalDivider extends AlchemicalComponent {

  constructor(uiContext: UIContext) {
    super(uiContext);
    let divider: typeNode.Divider = typeNode.createNode(this.uiContext, 'Divider');
    this.node = divider;
  }

  override buildRule(): void {
    this.loadRule('v1.0/AlchemicalComponents/AlchemicalDivider.json');
  }
}
