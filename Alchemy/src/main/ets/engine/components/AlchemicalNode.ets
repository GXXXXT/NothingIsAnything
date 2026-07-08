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
import { AlchemicalUtils } from "../common/AlchemicalUtils";

@ObservedV2
export class BasicAlchemyAttribute {
  @Trace width: string = 'auto';
  @Trace height: string = 'auto';

  constructor(params: object | undefined = undefined) {
    if (!params) {
      return;
    }

    AlchemicalUtils.assign(this, params);
  }
}

@ObservedV2
export class AlchemicalNode {
  @Trace id: string;
  @Trace type: string;
  @Trace attr: BasicAlchemyAttribute;
  @Trace children: Map<string, AlchemicalNode>;

  constructor(id: string, type: string, attr: BasicAlchemyAttribute = new BasicAlchemyAttribute()) {
    this.id = id;
    this.type = type;
    this.attr = attr;
    this.children = new Map<string, AlchemicalNode>();
  }

  static createRoot(): AlchemicalNode {
    return new AlchemicalNode('root', 'Blank');
  }

  getChildren(): AlchemicalNode[] {
    const items: AlchemicalNode[] = [];
    this.children.forEach((item: AlchemicalNode) => {
      items.push(item);
    });
    return items;
  }

  addChild(child: AlchemicalNode): boolean {
    this.children.set(child.id, child);
    return true;
  }

  removeChild(child: AlchemicalNode): boolean {
    return this.children.delete(child.id);
  }
}
