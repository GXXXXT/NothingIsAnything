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
import { AlchemyTextAttribute } from '../main/ets/engine/components/AlchemicalText';
import { AlchemyButtonAttribute } from '../main/ets/engine/components/AlchemicalButton';
import { AlchemyImageAttribute } from '../main/ets/engine/components/AlchemicalImage';
import { AlchemyCheckboxAttribute } from '../main/ets/engine/components/AlchemicalCheckbox';
import { AlchemySliderAttribute } from '../main/ets/engine/components/AlchemicalSlider';
import { AlchemyTextInputAttribute } from '../main/ets/engine/components/AlchemicalTextInput';

interface TextParams {
  text: string;
  fontSize: number;
  color: string;
}

interface ButtonParams {
  label: string;
}

interface ImageParams {
  src: string;
}

interface CheckboxParams {
  name: string;
  group: string;
  checked: boolean;
}

interface SliderParams {
  value: number;
  min: number;
  max: number;
  step: number;
}

interface TextInputParams {
  text: string;
  placeholder: string;
}

/**
 * TC-ATTR-*：6 个组件 Attribute 的 params 注入与缺省值。
 * 每个 Attribute 的 `if (!params)` 两个分支各覆盖一次（B6–B17）。
 */
export default function alchemicalAttributesTest() {
  describe('alchemicalAttributesTest', () => {

    // ---------- Text ----------

    it('TC_ATTR_001_text_attribute_applies_params', 0, () => {
      const params: TextParams = { text: '炼金术士', fontSize: 22, color: '#FF0000' };
      const attr: AlchemyTextAttribute = new AlchemyTextAttribute(params);

      expect(attr.text).assertEqual('炼金术士');
      expect(attr.fontSize).assertEqual(22);
      expect(attr.color).assertEqual('#FF0000');
    });

    it('TC_ATTR_002_text_attribute_keeps_defaults', 0, () => {
      const attr: AlchemyTextAttribute = new AlchemyTextAttribute(undefined);

      expect(attr.text).assertEqual('');
      expect(attr.fontSize).assertEqual(16);
      expect(attr.color).assertEqual('#000000');
    });

    // ---------- Button ----------

    it('TC_ATTR_003_button_attribute_applies_params', 0, () => {
      const params: ButtonParams = { label: '开始炼制' };
      const attr: AlchemyButtonAttribute = new AlchemyButtonAttribute(params);

      expect(attr.label).assertEqual('开始炼制');
    });

    it('TC_ATTR_004_button_attribute_keeps_defaults', 0, () => {
      const attr: AlchemyButtonAttribute = new AlchemyButtonAttribute(undefined);
      expect(attr.label).assertEqual('');
    });

    // ---------- Image ----------

    it('TC_ATTR_005_image_attribute_applies_params', 0, () => {
      const params: ImageParams = { src: 'https://example.com/a.png' };
      const attr: AlchemyImageAttribute = new AlchemyImageAttribute(params);

      expect(attr.src).assertEqual('https://example.com/a.png');
    });

    it('TC_ATTR_006_image_attribute_keeps_defaults', 0, () => {
      const attr: AlchemyImageAttribute = new AlchemyImageAttribute(undefined);
      expect(attr.src).assertEqual('');
    });

    // ---------- Checkbox ----------

    it('TC_ATTR_007_checkbox_attribute_applies_params', 0, () => {
      const params: CheckboxParams = { name: 'agreement', group: 'settings', checked: true };
      const attr: AlchemyCheckboxAttribute = new AlchemyCheckboxAttribute(params);

      expect(attr.name).assertEqual('agreement');
      expect(attr.group).assertEqual('settings');
      expect(attr.checked).assertTrue();
    });

    it('TC_ATTR_008_checkbox_attribute_keeps_defaults', 0, () => {
      const attr: AlchemyCheckboxAttribute = new AlchemyCheckboxAttribute(undefined);

      expect(attr.name).assertEqual('');
      expect(attr.group).assertEqual('');
      expect(attr.checked).assertFalse();
    });

    // ---------- Slider ----------

    it('TC_ATTR_009_slider_attribute_applies_params', 0, () => {
      const params: SliderParams = { value: 30, min: 10, max: 90, step: 5 };
      const attr: AlchemySliderAttribute = new AlchemySliderAttribute(params);

      expect(attr.value).assertEqual(30);
      expect(attr.min).assertEqual(10);
      expect(attr.max).assertEqual(90);
      expect(attr.step).assertEqual(5);
    });

    it('TC_ATTR_010_slider_attribute_keeps_defaults', 0, () => {
      const attr: AlchemySliderAttribute = new AlchemySliderAttribute(undefined);

      expect(attr.value).assertEqual(0);
      expect(attr.min).assertEqual(0);
      expect(attr.max).assertEqual(100);
      expect(attr.step).assertEqual(1);
    });

    // ---------- TextInput ----------

    it('TC_ATTR_011_text_input_attribute_applies_params', 0, () => {
      const params: TextInputParams = { text: '咒语', placeholder: '请输入' };
      const attr: AlchemyTextInputAttribute = new AlchemyTextInputAttribute(params);

      expect(attr.text).assertEqual('咒语');
      expect(attr.placeholder).assertEqual('请输入');
    });

    it('TC_ATTR_012_text_input_attribute_keeps_defaults', 0, () => {
      const attr: AlchemyTextInputAttribute = new AlchemyTextInputAttribute(undefined);

      expect(attr.text).assertEqual('');
      expect(attr.placeholder).assertEqual('');
    });
  });
}
