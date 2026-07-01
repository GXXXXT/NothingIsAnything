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

import { AlchemicalPotion, AlchemicalPotionType } from "../../interface/Alchemy";

/**
 * 解析外部消息字符串为 AlchemicalPotion[]。
 *
 * 消息格式为 JSON 数组，每项结构：
 * ```
 * {
 *   "version": "1.0",
 *   "UPDATE_COMPONENT": { "id": "...", "componentType": "...", ... }
 * }
 * // 或
 * {
 *   "version": "1.0",
 *   "UPDATE_DATA": { "id": "...", "value": ... }
 * }
 * ```
 *
 * @param message 原始 JSON 字符串
 * @returns 解析后的 AlchemicalPotion 数组
 */
export function parseMessage(message: string): AlchemicalPotion[] {
  let rawArray: object[] = JSON.parse(message) as object[];
  let potions: AlchemicalPotion[] = [];

  for (let item of rawArray) {
    let record = item as Record<string, Object>;

    if (!record || typeof record !== 'object') {
      continue;
    }

    if (record['UPDATE_COMPONENT'] !== undefined) {
      potions.push({
        type: AlchemicalPotionType.UPDATE_COMPONENT,
        value: record['UPDATE_COMPONENT'] as object
      });
    } else if (record['UPDATE_DATA'] !== undefined) {
      potions.push({
        type: AlchemicalPotionType.UPDATE_DATA,
        value: record['UPDATE_DATA'] as object
      });
    }
  }

  return potions;
}

/**
 * UPDATE_COMPONENT 药剂解析后的组件描述。
 */
export interface ComponentDescriptor {
  /** 组件唯一标识 */
  id: string;
  /** 组件类型，对应 AlchemicalComponent 中 builders 注册表的 key */
  componentType: string;
  /** 子节点 id 列表 */
  childIds: string[];
  /** 初始化参数 */
  params: object;
}

/**
 * 解析单条 UPDATE_COMPONENT 药剂。
 *
 * 将 potion.value 提取为结构化的 {@link ComponentDescriptor}。
 *
 * @param potion 单条 AlchemicalPotion（仅处理 UPDATE_COMPONENT）
 * @returns 解析后的组件描述，类型不匹配或字段缺失时返回 null
 */
export function parseComponentPotion(potion: AlchemicalPotion): ComponentDescriptor | null {
  if (potion.type !== AlchemicalPotionType.UPDATE_COMPONENT) {
    return null;
  }

  let value = potion.value as Record<string, Object>;
  let id = value['id'] as string;
  let componentType = value['componentType'] as string;

  if (!id || !componentType) {
    console.error('[parseComponentPotion] Missing id or componentType');
    return null;
  }

  return {
    id,
    componentType,
    childIds: (value['child'] as string[]) ?? [],
    params: (value['params'] as object) ?? {}
  };
}