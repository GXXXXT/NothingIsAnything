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
import { ComponentNode } from '../components/AlchemicalComponent';
import { AlchemicalPotion, AlchemicalPotionType } from '../../interface/Alchemy';
import { parseMessage, parseComponentPotion, ComponentDescriptor } from '../common/AlchemicalUtils';

/**
 * AlchemicalRodImpl — 接收外部消息，直接构建 ComponentNode 树。
 *
 * 通过 @ObservedV2 + @Trace，节点树变更自动触发 ForEach 重渲染，
 * 不再依赖 NodeContainer / NodeController 体系。
 */
export class AlchemicalRodImpl implements AlchemicalRod {
  uiContext: UIContext;
  private furnace: AlchemicalFurnaceImpl | null = null;

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  bindFurnace(furnace: AlchemicalFurnaceImpl): void {
    this.furnace = furnace;
  }

  onReceive(message: string): void {
    const furnace = this.furnace;
    if (!furnace) {
      console.error('[AlchemicalRodImpl] Furnace not bound');
      return;
    }

    const potions = parseMessage(message);
    const descriptors: ComponentDescriptor[] = [];
    const parentMap = new Map<string, string>();

    // 第一趟：收集组件描述与父子关系
    for (let potion of potions) {
      if (potion.type !== AlchemicalPotionType.UPDATE_COMPONENT) {
        continue;
      }
      const desc = parseComponentPotion(potion);
      if (!desc) continue;
      descriptors.push(desc);
      for (let childId of desc.childIds) {
        parentMap.set(childId, desc.id);
      }
    }

    // 第二趟：创建或更新节点
    for (let desc of descriptors) {
      let node = furnace.getNode(desc.id);

      if (node) {
        // 已存在 → @Trace props 变更触发精确重渲染
        node.props = { ...node.props, ...desc.params };
      } else {
        // 新节点 → 创建并挂载，@Trace children 变更触发 ForEach
        const newNode = new ComponentNode(desc.id, desc.componentType, desc.params);

        if (desc.id === 'root') {
          furnace.addRootNode(newNode);
        } else {
          const parentId = parentMap.get(desc.id);
          if (parentId) {
            furnace.addChildNode(parentId, newNode);
          } else {
            console.error(`[AlchemicalRodImpl] No parent found for: ${desc.id}`);
          }
        }
      }
    }
  }
}
