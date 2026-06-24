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

import { AlchemicalRod } from '../../interface/AlchemicalRod'
import { parseMessage } from '../common/AlchemicalUtils';
import { AlchemicalPotion } from '../../interface/Alchemy';

/**
 * AlchemicalRodImpl — 接收外部消息，解析为 AlchemicalPotion[]，
 * 并通过回调通知 AlchemicalFurnace 创建/更新组件。
 */
export class AlchemicalRodImpl implements AlchemicalRod {
  uiContext: UIContext;

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
    console.log(`[HJJ] AlchemicalRodImpl`)
  }

  onReceive(message: string): void {
    let potions: AlchemicalPotion[] = parseMessage(message);
  }
}