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
import { FrameNode, NodeController } from '@ohos.arkui.node';

class AlchemicalNodeController extends NodeController {
  private rootNode: FrameNode | null = null;
  private nodeList: Map<FrameNode, FrameNode[]> | undefined = undefined;

  makeNode(uiContext: UIContext): FrameNode | null {
    this.rootNode = new FrameNode(uiContext);
    this.nodeList = new Map<FrameNode, FrameNode[]>();
    this.nodeList.set(this.rootNode, []);
    return this.rootNode;
  }

  assembleNode(): FrameNode | null {
    return this.rootNode;
  }
}

@Component
export struct AlchemicalFurnaceImpl {
  alchemicalRod: AlchemicalRodImpl | undefined;

  private alchemicalController: AlchemicalNodeController = new AlchemicalNodeController();

  build() {
    Column() {
      NodeContainer(this.alchemicalController)
        .width('100%')
        .height('100%');
    }
    .width('100%')
    .height('100%');
  }
}