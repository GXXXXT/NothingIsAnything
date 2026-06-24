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
 * 炼金列表 — 封装 ArkUI List 滚动列表容器。
 *
 * 支持垂直/水平滚动，子节点作为列表项依次排列。
 */
export class AlchemicalList extends AlchemicalComponent {

  constructor(uiContext: UIContext) {
    super(uiContext);
    let list: typeNode.List = typeNode.createNode(this.uiContext, 'List');
    this.node = list;
  }
}
