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

import { wrapBuilder } from '@kit.ArkUI';
import { ComponentNode, AlchemicalComponent } from './AlchemicalComponent';

@Builder
export function AlchemicalButtonBuilder(node: ComponentNode) {
  Button(node.props['text'] as string ?? '')
    .width(node.props['width'] as string ?? '100%')
    .height(node.props['height'] as string ?? '100%')
}

AlchemicalComponent.register('Button', wrapBuilder(AlchemicalButtonBuilder));
