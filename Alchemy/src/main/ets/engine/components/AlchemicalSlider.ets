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

import { AlchemicalComponent } from "./AlchemicalComponent";
import { typeNode } from "@ohos.arkui.node";

/**
 * 炼金滑块 — 封装 ArkUI Slider 组件。
 *
 * 支持设置当前值、最小/最大值及步长，
 * 通过 {@link setValue}、{@link setMin}、{@link setMax}、{@link setStep} 动态更新。
 */
export class AlchemicalSlider extends AlchemicalComponent {
  private value: number = 0;
  private min: number = 0;
  private max: number = 100;
  private step: number = 1;

  constructor(uiContext: UIContext) {
    super(uiContext);
    let slider: typeNode.Slider = typeNode.createNode(this.uiContext, 'Slider');
    slider.initialize(this.value, this.min, this.max, this.step);
    this.node = slider;
  }

  /** 设置滑块当前值。 */
  setValue(value: number): void {
    this.value = value;
    (this.node as typeNode.Slider).initialize(this.value, this.min, this.max, this.step);
  }

  /** 设置滑块最小值。 */
  setMin(min: number): void {
    this.min = min;
    (this.node as typeNode.Slider).initialize(this.value, this.min, this.max, this.step);
  }

  /** 设置滑块最大值。 */
  setMax(max: number): void {
    this.max = max;
    (this.node as typeNode.Slider).initialize(this.value, this.min, this.max, this.step);
  }

  /** 设置滑块步长。 */
  setStep(step: number): void {
    this.step = step;
    (this.node as typeNode.Slider).initialize(this.value, this.min, this.max, this.step);
  }
}
