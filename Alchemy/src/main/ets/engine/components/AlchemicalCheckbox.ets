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
 * 炼金复选框 — 封装 ArkUI Checkbox 组件。
 *
 * 支持设置选中状态，通过 {@link setChecked} 动态切换。
 */
export class AlchemicalCheckbox extends AlchemicalComponent {
  private checked: boolean = false;

  constructor(uiContext: UIContext) {
    super(uiContext);
    let checkbox: typeNode.Checkbox = typeNode.createNode(this.uiContext, 'Checkbox');
    checkbox.initialize(this.checked);
    this.node = checkbox;
  }

  /** 设置复选框选中状态。 */
  setChecked(checked: boolean): void {
    this.checked = checked;
    (this.node as typeNode.Checkbox).initialize(checked);
  }
}
