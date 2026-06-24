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
import {
  AlchemicalColumn,
  AlchemicalRow,
  AlchemicalList,
  AlchemicalGrid,
  AlchemicalText,
  AlchemicalImage,
  AlchemicalDivider,
  AlchemicalButton,
  AlchemicalCheckbox,
  AlchemicalTextInput,
  AlchemicalSlider,
} from './Components';

type ComponentCreator = (uiContext: UIContext) => AlchemicalComponent;

/**
 * 组件工厂 — 根据类型字符串创建对应的炼金组件实例。
 *
 * 新增组件只需：
 * 1. 在 Components.ets 中 export
 * 2. 在此文件的 import 和 components 中各加一行
 */
export class ComponentFactory {
  private static readonly components = new Map<string, ComponentCreator>([
    // 容器类
    ['Column',    (ctx) => new AlchemicalColumn(ctx)],
    ['Row',       (ctx) => new AlchemicalRow(ctx)],
    ['List',      (ctx) => new AlchemicalList(ctx)],
    ['Grid',      (ctx) => new AlchemicalGrid(ctx)],
    // 展示类
    ['Text',      (ctx) => new AlchemicalText(ctx)],
    ['Image',     (ctx) => new AlchemicalImage(ctx)],
    ['Divider',   (ctx) => new AlchemicalDivider(ctx)],
    // 交互类
    ['Button',    (ctx) => new AlchemicalButton(ctx)],
    ['Checkbox',  (ctx) => new AlchemicalCheckbox(ctx)],
    ['TextInput', (ctx) => new AlchemicalTextInput(ctx)],
    ['Slider',    (ctx) => new AlchemicalSlider(ctx)],
  ]);

  /** 按类型名创建组件实例，未注册返回 undefined。 */
  static create<T extends AlchemicalComponent = AlchemicalComponent>(
    type: string,
    uiContext: UIContext
  ): T | undefined {
    const creator = ComponentFactory.components.get(type);
    return creator ? creator(uiContext) as T : undefined;
  }
}
