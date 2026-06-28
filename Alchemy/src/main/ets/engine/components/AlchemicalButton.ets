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
 * 炼金按钮 — 封装 ArkUI Button 组件。
 *
 * 支持设置按钮文本标签，通过 {@link setLabel} 动态更新。
 */
export class AlchemicalButton extends AlchemicalComponent {
  private label: string = '';

  constructor(uiContext: UIContext) {
    super(uiContext);
    let button: typeNode.Button = typeNode.createNode(this.uiContext, 'Button');
    button.initialize(this.label);
    this.node = button;
  }

  override buildRule(): void {
    this.loadRule('v1.0/AlchemicalComponents/AlchemicalButton.json');
  }

  /** 设置按钮文本标签。 */
  setLabel(label: string): void {
    this.label = label;
    (this.node as typeNode.Button).initialize(this.label);
  }
}
