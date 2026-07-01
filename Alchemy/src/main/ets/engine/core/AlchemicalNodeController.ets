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

import { FrameNode, NodeController } from '@ohos.arkui.node';
import { AlchemicalComponent, ComponentFactory } from '../components/Components';

/**
 * 熔炉节点控制器 — 管理动态节点树的根节点，
 * 并提供子节点挂载 / 卸载 / 组件查询方法。
 */
export class AlchemicalNodeController extends NodeController {
  private uiContext: UIContext;
  private componentManager: Map<string, AlchemicalComponent>;

  constructor(uiContext: UIContext) {
    super();
    this.uiContext = uiContext;
    this.componentManager = new Map<string, AlchemicalComponent>();
  }

  makeNode(): FrameNode | null {
    let root = ComponentFactory.create('Column', this.uiContext);
    if (!root) {
      return null;
    }
    this.componentManager.set('root', root);
    return root.getNode();
  }

  /**
   * 创建组件并挂载到父节点。
   *
   * @param parent 父节点 id，必须在 componentManager 中已注册
   * @param child  新组件的 id
   * @param type   组件类型，对应 ComponentFactory 中的 key
   * @returns 创建并挂载成功返回 true
   */
  addNode(parent: string, child: string, type: string): boolean {
    let parentNode = this.componentManager.get(parent);
    if (!parentNode) {
      return false;
    }

    let component = ComponentFactory.create(type, this.uiContext);
    if (!component) {
      return false;
    }

    let childNode = component.getNode();
    if (!childNode) {
      return false;
    }

    parentNode.getNode()!.appendChild(childNode);
    this.componentManager.set(child, component);
    return true;
  }

  /**
   * 按 id 获取已注册的组件实例。
   */
  getComponent(name: string): AlchemicalComponent | undefined {
    return this.componentManager.get(name);
  }
}