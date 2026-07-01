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

import { AlchemicalComponent } from './AlchemicalComponent';
import { AlchemicalNode } from './AlchemicalNode';
import { MutableBinding } from '@kit.ArkUI';

@Builder
export function gridComponentBuilder(componentNode: MutableBinding<AlchemicalNode>): void {
  AlchemicalGrid({
    componentNode: componentNode.value
  })
}

@ComponentV2
export struct AlchemicalGrid {
  @Require @Param componentNode: AlchemicalNode;

  build() {
    Grid() {
      ForEach(this.componentNode.getChildren(), (child: AlchemicalNode) => {
        GridItem() {
          AlchemicalComponent({
            componentNode: child,
            componentBuilder: AlchemicalComponent.componentMap.get(child.type)
          })
        }
      })
    }
    .width(this.componentNode.attr.width)
    .height(this.componentNode.attr.height)
  }
}
