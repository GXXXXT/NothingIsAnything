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

import { AlchemicalNode } from './AlchemicalNode';
import { MutableBinding } from '@kit.ArkUI';

@Builder
export function blankComponentBuilder(componentNode: MutableBinding<AlchemicalNode>): void {
  AlchemicalBlank({
    componentNode: componentNode.value
  })
}

@Builder
export function childBuilder(): void {
  Blank()
}

@ComponentV2
export struct AlchemicalBlank {
  @Require @Param componentNode: AlchemicalNode;

  build() {
    Blank()
  }
}
