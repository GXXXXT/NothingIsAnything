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
import { BasicAlchemyAttribute } from "../components/AlchemicalNode";
import { MessageToInstruction } from "../type/AlchemicalType";


export class AlchemicalUtils {
  /**
   * 解析外部消息字符串为 AlchemicalPotion[]。
   *
   * @param message 原始 JSON 字符串
   * @returns 解析后的 AlchemicalPotion 数组
   */
  static parseMessage(message: string): AlchemicalPotion[] {
    const parse: MessageToInstruction[] = JSON.parse(message);

    let potions: AlchemicalPotion[] = [];

    parse.forEach((msg: MessageToInstruction) => {
      const key = Object.keys(msg).find(k => k === 'UPDATE_DATA' || k === 'UPDATE_COMPONENT');

      switch (key) {
        case 'UPDATE_DATA':
          potions.push({
            type: AlchemicalPotionType.UPDATE_DATA,
            value: msg.UPDATE_DATA!
          });
          break;
        case 'UPDATE_COMPONENT':
          potions.push({
            type: AlchemicalPotionType.UPDATE_COMPONENT,
            value: msg.UPDATE_COMPONENT!
          });
          break;
        default:
          break;
      }
    })

    return potions;
  }

  static assign<T extends BasicAlchemyAttribute>(target: T, source: object): void {
    const sourceKeys = Object.keys(source);

    sourceKeys.forEach((key: string) => {
      Reflect.set(target, key, source[key]);
    });
  }
}