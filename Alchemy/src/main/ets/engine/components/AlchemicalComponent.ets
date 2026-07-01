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
import { NodeBuilder } from '../type/AlchemicalType';

// 导入全部组件文件，触发各模块的 AlchemicalComponent.register 自注册
import './AlchemicalText'
import './AlchemicalButton'
import './AlchemicalImage'
import './AlchemicalDivider'
import './AlchemicalCheckbox'
import './AlchemicalTextInput'
import './AlchemicalSlider'
import './AlchemicalColumn'
import './AlchemicalRow'
import './AlchemicalList'
import './AlchemicalGrid'

/**
 * 组件树节点 — @ObservedV2 + @Trace 实现深度状态追踪。
 *
 * props 或 children 变更时 ArkUI V2 自动触发 ForEach / @Builder 精确重渲染。
 */
@ObservedV2
export class ComponentNode {
  @Trace id: string;
  @Trace type: string;
  @Trace props: Record<string, Object>;
  @Trace children: ComponentNode[];

  constructor(id: string, type: string, props: Record<string, Object> = {}) {
    this.id = id;
    this.type = type;
    this.props = props;
    this.children = [];
  }
}

/** WrappedBuilder 注册表 + 递归渲染 — 组件 @Builder 查找、注册与树遍历。 */
export class AlchemicalComponent {
  private static readonly builders = new Map<string, NodeBuilder>();

  /** 注册组件 @Builder（各组件文件模块加载时调用）。 */
  static register(type: string, b: NodeBuilder): void {
    AlchemicalComponent.builders.set(type, b);
  }

  /** 按类型名获取已注册的 WrappedBuilder。 */
  static get(type: string): NodeBuilder | undefined {
    return AlchemicalComponent.builders.get(type);
  }

  /**
   * 递归渲染组件树 — 容器 builder 内 ForEach 调用此方法深度遍历子节点。
   */
  @Builder
  static RenderTree(node: ComponentNode) {
    const b = AlchemicalComponent.get(node.type);
    if (b) {
      b.builder(node);
    }
  }
}
