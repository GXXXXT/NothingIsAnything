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

import { AlchemicalNode, BasicAlchemyAttribute } from './AlchemicalNode';
import { MutableBinding } from '@kit.ArkUI';
import { AlchemicalUtils } from '../common/AlchemicalUtils';

@ObservedV2
export class AlchemyImageAttribute extends BasicAlchemyAttribute {
  @Trace src: string = '';

  constructor(params: object | undefined = undefined) {
    super(params);

    if (!params) {
      return;
    }

    AlchemicalUtils.assign(this, params);
  }
}

@Builder
export function imageComponentBuilder(componentNode: MutableBinding<AlchemicalNode>): void {
  AlchemicalImage({
    componentNode: componentNode.value
  })
}

@ComponentV2
export struct AlchemicalImage {
  @Require @Param componentNode: AlchemicalNode;

  build() {
    Image((this.componentNode.attr as AlchemyImageAttribute).src)
      .width(this.componentNode.attr.width)
      .height(this.componentNode.attr.height)
  }
}
