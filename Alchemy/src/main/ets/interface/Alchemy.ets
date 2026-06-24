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

/**
 * 炼金药剂类型 — 描述一次炼金反应的目标类别。
 *
 * - UPDATE_DATA: 仅驱动数据层变更，不直接操作节点树。
 * - UPDATE_COMPONENT: 触发组件树的创建、更新或销毁。
 */
export enum AlchemicalPotionType {
  /** 更新数据（状态 / 属性），不涉及组件树操作。 */
  UPDATE_DATA = 0,

  /** 更新组件（创建 / 修改 / 移除节点）。 */
  UPDATE_COMPONENT = 1
}

/**
 * 炼金药剂 — 一次炼金反应的最小描述单元。
 *
 * 每条药剂携带一个 {@link AlchemicalPotionType} 类型标记
 * 以及对应的 value 载荷，由 {@link AlchemicalRod} 接收并
 * 分发给对应的处理器。
 */
export interface AlchemicalPotion {
  /** 本次反应的目标类别（数据 or 组件）。 */
  type: AlchemicalPotionType;

  /** 反应所需的具体载荷，结构由 type 决定。 */
  value: object;
}