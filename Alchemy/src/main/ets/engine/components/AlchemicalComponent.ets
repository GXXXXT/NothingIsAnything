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

import { FrameNode } from '@ohos.arkui.node';

/**
 * 炼金组件基类 — 所有可视化组件继承于此。
 * 子类必须实现 createNode()，返回一个 ArkUI FrameNode，
 * 然后通过 getNode() 惰性获取，最后交由 AlchemicalFurnace 的
 * NodeController.appendChild() 挂载到节点树中。
 */
export abstract class AlchemicalComponent {
  protected uiContext: UIContext;
  protected node: FrameNode | null = null;

  // protected commonAttribute: Map<string, () => void> =

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  /**
   * 获取该组件对应的 FrameNode — 惰性创建，首次调用才会构造。
   */
  getNode(): FrameNode | null {
    return this.node;
  }

  /**
   * 更新组件状态。子类可重写以刷新节点属性（文字、颜色等）。
   * @param params 任意结构的数据
   */
  update(params?: object): void {
    // 子类按需重写
  }

  /**
   * 销毁时释放节点引用。
   */
  dispose(): void {
    this.node = null;
  }
}