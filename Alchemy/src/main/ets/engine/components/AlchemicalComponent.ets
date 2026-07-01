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

import { blankComponentBuilder } from "./AlchemicalBlank";
import { AlchemyButtonAttribute, buttonComponentBuilder } from "./AlchemicalButton";
import { AlchemyCheckboxAttribute, checkboxComponentBuilder } from "./AlchemicalCheckbox";
import { columnComponentBuilder } from "./AlchemicalColumn";
import { dividerComponentBuilder } from "./AlchemicalDivider";
import { gridComponentBuilder } from "./AlchemicalGrid";
import { AlchemyImageAttribute, imageComponentBuilder } from "./AlchemicalImage";
import { listComponentBuilder } from "./AlchemicalList";
import { AlchemicalNode, BasicAlchemyAttribute } from "./AlchemicalNode";
import { rowComponentBuilder } from "./AlchemicalRow";
import { AlchemySliderAttribute, sliderComponentBuilder } from "./AlchemicalSlider";
import { AlchemyTextAttribute, textComponentBuilder } from "./AlchemicalText";
import { AlchemyTextInputAttribute, textInputComponentBuilder } from "./AlchemicalTextInput";
import { MutableBinding, UIUtils } from "@kit.ArkUI";

@ComponentV2
export struct AlchemicalComponent {
  @Require @Param componentNode: AlchemicalNode;
  @Require @Param componentBuilder: MutableBuilder<[MutableBinding<AlchemicalNode>]> = mutableBuilder(blankComponentBuilder);

  public static componentMap: Map<string, MutableBuilder<[MutableBinding<AlchemicalNode>]>> =
    new Map<string, MutableBuilder<[MutableBinding<AlchemicalNode>]>>([
    ['Blank', mutableBuilder(blankComponentBuilder)],
    ['Button', mutableBuilder(buttonComponentBuilder)],
    ['Checkbox', mutableBuilder(checkboxComponentBuilder)],
    ['Column', mutableBuilder(columnComponentBuilder)],
    ['Divider', mutableBuilder(dividerComponentBuilder)],
    ['Grid', mutableBuilder(gridComponentBuilder)],
    ['Image', mutableBuilder(imageComponentBuilder)],
    ['List', mutableBuilder(listComponentBuilder)],
    ['Row', mutableBuilder(rowComponentBuilder)],
    ['Slider', mutableBuilder(sliderComponentBuilder)],
    ['Text', mutableBuilder(textComponentBuilder)],
    ['TextInput', mutableBuilder(textInputComponentBuilder)]
  ])

  public static componentAttributeMap: Map<string, (params: object) => BasicAlchemyAttribute> =
    new Map<string, (params: object) => BasicAlchemyAttribute>([
      ['Blank', (params: object) => new BasicAlchemyAttribute(params)],
      ['Button', (params: object) => new AlchemyButtonAttribute(params)],
      ['Checkbox', (params: object) => new AlchemyCheckboxAttribute(params)],
      ['Column', (params: object) => new BasicAlchemyAttribute(params)],
      ['Divider', (params: object) => new BasicAlchemyAttribute(params)],
      ['Grid', (params: object) => new BasicAlchemyAttribute(params)],
      ['Image', (params: object) => new AlchemyImageAttribute(params)],
      ['List', (params: object) => new BasicAlchemyAttribute(params)],
      ['Row', (params: object) => new BasicAlchemyAttribute(params)],
      ['Slider', (params: object) => new AlchemySliderAttribute(params)],
      ['Text', (params: object) => new AlchemyTextAttribute(params)],
      ['TextInput', (params: object) => new AlchemyTextInputAttribute(params)]
    ])

  build() {
    this.componentBuilder.builder(UIUtils.makeBinding(() => this.componentNode))
  }
}
