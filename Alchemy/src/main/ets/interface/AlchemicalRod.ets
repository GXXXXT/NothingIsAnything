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

import { AlchemicalRodImpl } from '../engine/core/AlchemicalRod'

/**
 * 炼金杖配置 — 创建 {@link AlchemicalRod} 实例所需的参数。
 */
export interface AlchemicalRodOptions {
  /** 目标页面的 UI 上下文，用于后续组件创建。 */
  uiContext: UIContext
}

/**
 * 炼金杖 — 消息接收器接口。
 *
 * 炼金杖是整个炼金系统的外部入口：外部调用方通过
 * {@link AlchemicalRodCreator.forgeAlchemicalRod} 创建杖实例，
 * 随后调用 {@link onReceive} 传入消息字符串，
 * 由 {@link AlchemicalRodImpl} 解析为 {@link AlchemicalPotion}[]，
 * 最终驱动 {@link AlchemicalFurnace} 完成组件渲染。
 */
export interface AlchemicalRod {
  /** 接收外部消息并启动炼金反应。 */
  onReceive(message: string): void;
}

/**
 * 炼金杖创建器 — {@link AlchemicalRod} 实例的静态工厂。
 *
 * 通过 {@link forgeAlchemicalRod} 方法传入
 * {@link AlchemicalRodOptions}（至少包含 uiContext），
 * 内部构造 {@link AlchemicalRodImpl} 实例并返回。
 */
export class AlchemicalRodCreator {
  /** 创建炼金杖实例。 */
  static forgeAlchemicalRod(options: AlchemicalRodOptions): AlchemicalRod {
    return new AlchemicalRodImpl(options.uiContext);
  }
}