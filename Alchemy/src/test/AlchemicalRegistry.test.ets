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
import { UIContext } from '@kit.ArkUI';
import { AlchemicalComponent } from '../main/ets/engine/components/AlchemicalComponent';
import { BasicAlchemyAttribute } from '../main/ets/engine/components/AlchemicalNode';
import {
  AlchemicalRod,
  AlchemicalRodCreator,
  AlchemicalRodOptions
} from '../main/ets/interface/AlchemicalRod';
import { AlchemicalData } from '../main/ets/engine/datamodel/AlchemicalData';

/** 注册表中应有的组件类型全集（与 AGENT.md §1.7 一致）。 */
const EXPECTED_TYPES: string[] = [
  'Blank', 'Button', 'Checkbox', 'Column', 'Divider', 'Grid',
  'Image', 'List', 'Row', 'Slider', 'Text', 'TextInput'
];

interface EmptyParams {
}

interface WidthOnlyParams {
  width: string;
}

/**
 * TC-REG-* / TC-FACTORY-* / TC-DATA-*：
 * 组件注册表完整性、对外工厂与数据模型刻画。
 */
export default function alchemicalRegistryTest() {
  describe('alchemicalRegistryTest', () => {

    it('TC_REG_001_component_map_contains_all_expected_types', 0, () => {
      expect(AlchemicalComponent.componentMap.size).assertEqual(EXPECTED_TYPES.length);
      EXPECTED_TYPES.forEach((typeName: string) => {
        expect(AlchemicalComponent.componentMap.has(typeName)).assertTrue();
      });
    });

    it('TC_REG_002_attribute_map_covers_same_type_set', 0, () => {
      expect(AlchemicalComponent.componentAttributeMap.size).assertEqual(EXPECTED_TYPES.length);
      EXPECTED_TYPES.forEach((typeName: string) => {
        expect(AlchemicalComponent.componentAttributeMap.has(typeName)).assertTrue();
      });
    });

    it('TC_REG_003_every_attribute_factory_builds_with_empty_params', 0, () => {
      const empty: EmptyParams = {};
      EXPECTED_TYPES.forEach((typeName: string) => {
        const factory: ((params: object) => BasicAlchemyAttribute) | undefined =
          AlchemicalComponent.componentAttributeMap.get(typeName);
        expect(factory !== undefined).assertTrue();
        if (factory !== undefined) {
          const attr: BasicAlchemyAttribute = factory(empty);
          expect(attr !== undefined).assertTrue();
          expect(attr.width).assertEqual('auto');
        }
      });
    });

    it('TC_REG_004_every_attribute_factory_applies_params', 0, () => {
      const params: WidthOnlyParams = { width: '12vp' };
      EXPECTED_TYPES.forEach((typeName: string) => {
        const factory: ((params: object) => BasicAlchemyAttribute) | undefined =
          AlchemicalComponent.componentAttributeMap.get(typeName);
        if (factory !== undefined) {
          const attr: BasicAlchemyAttribute = factory(params);
          expect(attr.width).assertEqual('12vp');
        }
      });
    });

    it('TC_FACTORY_001_forge_returns_usable_rod', 0, () => {
      const options: AlchemicalRodOptions = { uiContext: {} as UIContext };
      const rod: AlchemicalRod = AlchemicalRodCreator.forgeAlchemicalRod(options);

      expect(rod !== undefined).assertTrue();

      let threw: boolean = false;
      try {
        rod.onReceive('[]');
      } catch (e) {
        threw = true;
      }
      expect(threw).assertFalse();
    });

    it('TC_DATA_001_update_data_model_does_not_throw', 0, () => {
      // 刻画现状：AlchemicalData.updateDataModel 目前为空实现。
      // 实现 UPDATE_DATA 时必须同步更新本用例。
      let threw: boolean = false;
      try {
        AlchemicalData.updateDataModel('{}');
      } catch (e) {
        threw = true;
      }
      expect(threw).assertFalse();
    });
  });
}
