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
import { ComponentNode, RenderTree } from '../components/AlchemicalComponent'

@Component
export struct AlchemicalFurnaceImpl {
  @Require alchemicalRod: AlchemicalRodImpl | undefined = undefined;
  private nodeMap: Map<string, ComponentNode> = new Map();
  @Local rootNodes: ComponentNode[] = [];

  aboutToAppear(): void {
    if (this.alchemicalRod) {
      this.alchemicalRod.bindFurnace(this);
    }
  }

  build() {
    Column() {
      ForEach(this.rootNodes, (node: ComponentNode) => {
        RenderTree(node)
      }, (node: ComponentNode) => node.id)
    }
    .width('100%')
    .height('100%')
  }

  // ── Public API for AlchemicalRodImpl ──────────────────────────

  getNode(id: string): ComponentNode | undefined {
    return this.nodeMap.get(id);
  }

  addRootNode(node: ComponentNode): void {
    this.nodeMap.set(node.id, node);
    this.rootNodes = [...this.rootNodes, node];
  }

  addChildNode(parentId: string, node: ComponentNode): boolean {
    const parent = this.nodeMap.get(parentId);
    if (!parent) return false;
    this.nodeMap.set(node.id, node);
    parent.children = [...parent.children, node];
    return true;
  }

  updateNodeProps(id: string, props: Record<string, Object>): void {
    const node = this.nodeMap.get(id);
    if (node) {
      node.props = { ...node.props, ...props };
    }
  }
}
