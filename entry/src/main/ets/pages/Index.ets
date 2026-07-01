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

import {
  AlchemicalFurnace,
  AlchemicalRod,
  AlchemicalRodCreator
} from '@gxxxxt/alchemy'
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State alchemicalRod: AlchemicalRod = AlchemicalRodCreator.forgeAlchemicalRod({
    uiContext: this.getUIContext()
  });

  a(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const resourceMgr = context.resourceManager;
    const fileData: Uint8Array = resourceMgr.getRawFileContentSync('alchemy_message_demo.json');

    const textDecoderOptions: util.TextDecoderOptions = {
      fatal: false,
      ignoreBOM: true
    };
    const decodeToStringOptions: util.DecodeToStringOptions = {
      stream: false
    };
    const textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
    const strContent = textDecoder.decodeToString(fileData, decodeToStringOptions);

    this.alchemicalRod.onReceive(strContent);
  }

  build() {
    Column() {
      AlchemicalFurnace({ alchemicalRod: this.alchemicalRod })
        .width('100%')
        .height('80%')

      Button('Click')
        .onClick(() => {
          this.a();
        })
    }
  }
}