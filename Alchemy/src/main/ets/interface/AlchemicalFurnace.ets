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

import { AlchemicalFurnaceImpl } from '../engine/core/AlchemicalFurnace'
import { AlchemicalRodImpl } from '../engine/core/AlchemicalRod';
import { AlchemicalRod } from './AlchemicalRod'

/**
 * 炼金熔炉 — 整个炼金系统的顶层容器组件。
 *
 * 熔炉接收一根 {@link AlchemicalRod | 炼金杖}，内部委托给
 * {@link AlchemicalFurnaceImpl} 完成节点树的构建与渲染。
 * 将自身尺寸撑满父容器（100% × 100%）。
 *
 * @usage
 * // 在页面中使用
 * AlchemicalFurnace({ alchemicalRod: AlchemicalRodCreator.forgeAlchemicalRod({ uiContext: this.uiContext }) })
 */
@Component
export struct AlchemicalFurnace {
  /** 炼金杖实例，提供与外部消息的桥梁。 */
  @Require alchemicalRod: AlchemicalRod | undefined;

  build() {
    AlchemicalFurnaceImpl({ alchemicalRod: this.alchemicalRod as AlchemicalRodImpl })
      .width('100%')
      .height('100%')
  }
}