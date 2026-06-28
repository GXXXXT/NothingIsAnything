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

export class AlchemicalText extends AlchemicalComponent {
  private textValue: string = ''

  constructor(uiContext: UIContext) {
    super(uiContext);
    let text: typeNode.Text = typeNode.createNode(this.uiContext, 'Text');
    text.initialize(this.textValue);
    this.node = text;
  }

  override buildRule(): void {
    this.loadRule('v1.0/AlchemicalComponents/AlchemicalText.json');
  }

  setText(textValue: string): void {
    this.textValue = textValue;
    (this.node as typeNode.Text).initialize(textValue);
  }
}