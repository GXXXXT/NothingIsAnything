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

import { AlchemicalRod } from '../../interface/AlchemicalRod'
import { AlchemicalFurnaceImpl } from './AlchemicalFurnace';
import { AlchemicalPotion, AlchemicalPotionType } from '../../interface/Alchemy';
import { parseMessage, parseComponentPotion, ComponentDescriptor } from '../common/AlchemicalUtils';

/**
 * AlchemicalRodImpl — 接收外部消息，解析并驱动组件树构建。
 *
 * 流水线：
 * 1. {@link parseMessage} 解析 JSON → AlchemicalPotion[]
 * 2. 遍历 potions，逐条调用 {@link parseComponentPotion} 并构建 parentMap
 * 3. 遍历解析结果，通过 {@link AlchemicalNodeController.addNode} 创建挂载
 */
export class AlchemicalRodImpl implements AlchemicalRod {
  uiContext: UIContext;

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  onReceive(message: string): void {
    let controller = AlchemicalFurnaceImpl.alchemicalController;
    if (!controller) {
      console.error('[AlchemicalRodImpl] Controller not initialized');
      return;
    }

    let potions = parseMessage(message);
    let descriptors: ComponentDescriptor[] = [];
    let parentMap = new Map<string, string>();

    // 第一趟：解析每条药剂，构建父子映射
    for (let potion of potions) {
      if (potion.type !== AlchemicalPotionType.UPDATE_COMPONENT) {
        continue;
      }

      let desc = parseComponentPotion(potion);
      if (!desc) {
        continue;
      }
      descriptors.push(desc);

      for (let childId of desc.childIds) {
        parentMap.set(childId, desc.id);
      }
    }

    // 第二趟：创建组件并挂载
    for (let desc of descriptors) {
      if (desc.id === 'root') {
        let root = controller.getComponent('root');
        if (root) {
          root.update(desc.params);
        }
        continue;
      }

      let parentId = parentMap.get(desc.id);
      if (!parentId) {
        console.error(`[AlchemicalRodImpl] No parent found for: ${desc.id}`);
        continue;
      }

      if (controller.addNode(parentId, desc.id, desc.componentType)) {
        let component = controller.getComponent(desc.id);
        if (component) {
          component.update(desc.params);
        }
      }
    }
  }
}