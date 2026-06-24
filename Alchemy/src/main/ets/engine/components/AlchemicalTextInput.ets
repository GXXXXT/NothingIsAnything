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
 * 炼金文本输入 — 封装 ArkUI TextInput 组件。
 *
 * 支持设置占位提示文本与输入内容，通过 {@link setPlaceholder}
 * 和 {@link setText} 动态更新。
 */
export class AlchemicalTextInput extends AlchemicalComponent {
  private placeholder: string = '';
  private textValue: string = '';

  constructor(uiContext: UIContext) {
    super(uiContext);
    let textInput: typeNode.TextInput = typeNode.createNode(this.uiContext, 'TextInput');
    textInput.initialize(this.placeholder, this.textValue);
    this.node = textInput;
  }

  /** 设置占位提示文本。 */
  setPlaceholder(placeholder: string): void {
    this.placeholder = placeholder;
    (this.node as typeNode.TextInput).initialize(this.placeholder, this.textValue);
  }

  /** 设置输入框文本内容。 */
  setText(textValue: string): void {
    this.textValue = textValue;
    (this.node as typeNode.TextInput).initialize(this.placeholder, this.textValue);
  }
}
