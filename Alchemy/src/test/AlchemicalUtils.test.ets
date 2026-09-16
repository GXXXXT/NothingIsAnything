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

import { describe, it, expect } from '@ohos/hypium';
import { AlchemicalUtils } from '../main/ets/engine/common/AlchemicalUtils';
import {
  AlchemicalPotion,
  AlchemicalPotionType,
  ComponentDescriptor,
  DataDescriptor
} from '../main/ets/interface/Alchemy';
import { BasicAlchemyAttribute } from '../main/ets/engine/components/AlchemicalNode';

// ArkTS 禁止无类型对象字面量（arkts-no-untyped-obj-literals），
// 因此所有作为参数传递的字面量都必须先有显式声明的 interface。
interface AssignSource {
  width: string;
  height: string;
}

interface EmptyParams {
}

const MSG_EMPTY: string = '[]';

const MSG_UPDATE_COMPONENT: string =
  '[{"version":"1.0","UPDATE_COMPONENT":{"id":"root","componentType":"Column","params":{}}}]';

const MSG_UPDATE_DATA: string =
  '[{"version":"1.0","UPDATE_DATA":{"id":"progressSlider","value":50}}]';

const MSG_UNKNOWN_KEY: string =
  '[{"version":"1.0","UNKNOWN_OP":{"id":"ghost"}}]';

const MSG_MIXED: string =
  '[{"version":"1.0","UPDATE_COMPONENT":{"id":"a","componentType":"Text","params":{"text":"hi"}}},' +
  '{"version":"1.0","UNKNOWN_OP":{"id":"ghost"}},' +
  '{"version":"1.0","UPDATE_DATA":{"id":"a","value":1}}]';

const MSG_INVALID: string = '{not-a-json';

/**
 * TC-UTIL-*：消息解析（AlchemicalUtils.parseMessage）与反射赋值（assign）。
 * 覆盖 B1/B2/B3 三个 switch 分支。
 */
export default function alchemicalUtilsTest() {
  describe('alchemicalUtilsTest', () => {

    it('TC_UTIL_001_parseMessage_empty_array_returns_empty_list', 0, () => {
      const potions: AlchemicalPotion[] = AlchemicalUtils.parseMessage(MSG_EMPTY);
      expect(potions.length).assertEqual(0);
    });

    it('TC_UTIL_002_parseMessage_resolves_UPDATE_COMPONENT', 0, () => {
      const potions: AlchemicalPotion[] = AlchemicalUtils.parseMessage(MSG_UPDATE_COMPONENT);
      expect(potions.length).assertEqual(1);
      expect(potions[0].type).assertEqual(AlchemicalPotionType.UPDATE_COMPONENT);

      const descriptor: ComponentDescriptor = potions[0].value as ComponentDescriptor;
      expect(descriptor.id).assertEqual('root');
      expect(descriptor.componentType).assertEqual('Column');
    });

    it('TC_UTIL_003_parseMessage_resolves_UPDATE_DATA', 0, () => {
      const potions: AlchemicalPotion[] = AlchemicalUtils.parseMessage(MSG_UPDATE_DATA);
      expect(potions.length).assertEqual(1);
      expect(potions[0].type).assertEqual(AlchemicalPotionType.UPDATE_DATA);

      const descriptor: DataDescriptor = potions[0].value as DataDescriptor;
      expect(descriptor.id).assertEqual('progressSlider');
    });

    it('TC_UTIL_004_parseMessage_skips_unknown_operation_key', 0, () => {
      const potions: AlchemicalPotion[] = AlchemicalUtils.parseMessage(MSG_UNKNOWN_KEY);
      expect(potions.length).assertEqual(0);
    });

    it('TC_UTIL_005_parseMessage_invalid_json_throws', 0, () => {
      // 刻画现状：parseMessage 未捕获 JSON.parse 异常。
      // 若未来改为容错解析，必须同步更新本用例。
      let threw: boolean = false;
      try {
        AlchemicalUtils.parseMessage(MSG_INVALID);
      } catch (e) {
        threw = true;
      }
      expect(threw).assertTrue();
    });

    it('TC_UTIL_006_parseMessage_keeps_order_and_drops_unknown_keys', 0, () => {
      const potions: AlchemicalPotion[] = AlchemicalUtils.parseMessage(MSG_MIXED);
      expect(potions.length).assertEqual(2);
      expect(potions[0].type).assertEqual(AlchemicalPotionType.UPDATE_COMPONENT);
      expect(potions[1].type).assertEqual(AlchemicalPotionType.UPDATE_DATA);
    });

    it('TC_UTIL_007_assign_overwrites_existing_fields', 0, () => {
      const target: BasicAlchemyAttribute = new BasicAlchemyAttribute();
      const source: AssignSource = { width: '50%', height: '20vp' };

      AlchemicalUtils.assign(target, source);

      expect(target.width).assertEqual('50%');
      expect(target.height).assertEqual('20vp');
    });

    it('TC_UTIL_008_assign_empty_source_keeps_target_defaults', 0, () => {
      const target: BasicAlchemyAttribute = new BasicAlchemyAttribute();
      const source: EmptyParams = {};

      AlchemicalUtils.assign(target, source);

      expect(target.width).assertEqual('auto');
      expect(target.height).assertEqual('auto');
    });
  });
}
