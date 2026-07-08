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

import { AlchemicalRodImpl } from './AlchemicalRod'
import { AlchemicalComponent } from '../components/AlchemicalComponent'
import { AlchemicalNode } from '../components/AlchemicalNode';

@ComponentV2
export struct AlchemicalFurnaceImpl {
  @Require @Param private alchemicalRod: AlchemicalRodImpl | undefined = undefined;
  @Local rootNode: AlchemicalNode = AlchemicalNode.createRoot();
  @Local nodeList: Map<string, AlchemicalNode> = new Map<string, AlchemicalNode>();

  aboutToAppear(): void {
    this.nodeList.set('root', this.rootNode);
    this.alchemicalRod?.registerAlchemicalFurnaceImpl(this);
  }

  build() {
    AlchemicalComponent({
      componentNode: this.rootNode,
      componentBuilder: AlchemicalComponent.componentMap.get(this.rootNode.type)
    })
  }
}
