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
 * 炼金图片 — 封装 ArkUI Image 组件。
 *
 * 支持设置图片资源路径，通过 {@link setSrc} 动态更新。
 */
export class AlchemicalImage extends AlchemicalComponent {
  private src: string = '';

  constructor(uiContext: UIContext) {
    super(uiContext);
    let image: typeNode.Image = typeNode.createNode(this.uiContext, 'Image');
    image.initialize(this.src);
    this.node = image;
  }

  /** 设置图片资源路径。 */
  setSrc(src: string): void {
    this.src = src;
    (this.node as typeNode.Image).initialize(src);
  }
}
