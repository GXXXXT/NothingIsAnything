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
import { AlchemicalPotion, AlchemicalPotionType, ComponentDescriptor, DataDescriptor } from '../../interface/Alchemy';
import { AlchemicalUtils } from '../common/AlchemicalUtils';
import { AlchemicalComponent } from '../components/AlchemicalComponent';
import { AlchemicalNode, BasicAlchemyAttribute } from '../components/AlchemicalNode';
import { AlchemicalFurnaceImpl } from './AlchemicalFurnace';

/**
 * AlchemicalRodImpl — 接收外部消息，直接构建 AlchemicalNode 树。
 */
export class AlchemicalRodImpl implements AlchemicalRod {
  uiContext: UIContext;

  private alchemicalFurnace: AlchemicalFurnaceImpl | undefined = undefined;

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  onReceive(message: string): void {
    let potions: AlchemicalPotion[] = AlchemicalUtils.parseMessage(message);

    potions.forEach((potion: AlchemicalPotion) => {
      switch (potion.type) {
        case AlchemicalPotionType.UPDATE_COMPONENT:
          this.updateComponents(potion.value as ComponentDescriptor);
          break;
        case AlchemicalPotionType.UPDATE_DATA:
          this.updateDataModel(potion.value as DataDescriptor);
          break;
        default:
          break;
      }
    })
  }

  registerAlchemicalFurnaceImpl(furnace: AlchemicalFurnaceImpl): void {
    this.alchemicalFurnace = furnace;
  }

  private updateComponents(value: ComponentDescriptor): void {
    const loopRoot: AlchemicalNode | undefined = this.alchemicalFurnace!.nodeList.get(value.id);
    if (!loopRoot) {
      return;
    }

    loopRoot.type = value.componentType;
    const attribute: BasicAlchemyAttribute | undefined =
      AlchemicalComponent.componentAttributeMap.get(value.componentType)?.(value.params);
    if (!attribute) {
      return;
    }

    loopRoot.attr = attribute;

    if (!value.child) {
      return;
    }

    value.child.forEach((child: string) => {
      const blank: AlchemicalNode = new AlchemicalNode(child, 'Blank');
      loopRoot.addChild(blank);
      this.alchemicalFurnace?.nodeList.set(child, blank);
    })
  }

  private updateDataModel(value: DataDescriptor): void {
    const loopRoot: AlchemicalNode | undefined = this.alchemicalFurnace!.nodeList.get(value.id);
    if (!loopRoot) {
      return;
    }

    loopRoot.type = value.componentType;
    const attribute: BasicAlchemyAttribute | undefined =
      AlchemicalComponent.componentAttributeMap.get(value.componentType)?.(value.params);
    if (!attribute) {
      return;
    }

    loopRoot.attr = attribute;

    if (!value.child) {
      return;
    }

    value.child.forEach((child: string) => {
      const blank: AlchemicalNode = new AlchemicalNode(child, 'Blank');
      loopRoot.addChild(blank);
      this.alchemicalFurnace?.nodeList.set(child, blank);
    })
  }
}
