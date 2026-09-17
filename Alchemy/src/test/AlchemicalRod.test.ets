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
import { AlchemicalNode, BasicAlchemyAttribute } from '../main/ets/engine/components/AlchemicalNode';
import { AlchemicalRodImpl } from '../main/ets/engine/core/AlchemicalRod';

const MSG_ROOT_COLUMN: string =
  '[{"version":"1.0","UPDATE_COMPONENT":{"id":"root","componentType":"Column","params":{}}}]';

const MSG_UNKNOWN_ID: string =
  '[{"version":"1.0","UPDATE_COMPONENT":{"id":"ghost","componentType":"Column","params":{}}}]';

const MSG_UNKNOWN_TYPE: string =
  '[{"version":"1.0","UPDATE_COMPONENT":{"id":"root","componentType":"NoSuchComponent","params":{}}}]';

const MSG_WITH_CHILDREN: string =
  '[{"version":"1.0","UPDATE_COMPONENT":{"id":"root","componentType":"Column",' +
  '"child":["c1","c2"],"params":{}}}]';

const MSG_UPDATE_DATA_ONLY: string =
  '[{"version":"1.0","UPDATE_DATA":{"id":"root","value":42}}]';

const MSG_MIXED_BATCH: string =
  '[{"version":"1.0","UPDATE_COMPONENT":{"id":"root","componentType":"Row","params":{}}},' +
  '{"version":"1.0","UPDATE_DATA":{"id":"root","value":1}}]';

function createRegistry(): Map<string, AlchemicalNode> {
  const registry: Map<string, AlchemicalNode> = new Map<string, AlchemicalNode>();
  registry.set('root', AlchemicalNode.createRoot());
  return registry;
}

function createRod(): AlchemicalRodImpl {
  return new AlchemicalRodImpl({} as UIContext);
}

function getRoot(registry: Map<string, AlchemicalNode>): AlchemicalNode {
  return registry.get('root') as AlchemicalNode;
}

/**
 * TC-ROD-*：AlchemicalRodImpl 的指令分发与节点树更新。
 * 覆盖 UPDATE_COMPONENT / UPDATE_DATA 分支、registry 空值保护、以及
 * loopRoot / attribute / child 的三条空值提前返回路径。
 */
export default function alchemicalRodTest() {
  describe('alchemicalRodTest', () => {

    it('TC_ROD_001_updates_type_and_attr_for_registered_id', 0, () => {
      const registry: Map<string, AlchemicalNode> = createRegistry();
      const rod: AlchemicalRodImpl = createRod();
      rod.registerNodeRegistry(registry);

      rod.onReceive(MSG_ROOT_COLUMN);

      const root: AlchemicalNode = getRoot(registry);
      expect(root.type).assertEqual('Column');
      expect(root.attr).not().assertUndefined();
      expect(root.getChildren().length).assertEqual(0);
    });

    it('TC_ROD_002_unknown_id_returns_early_without_mutation', 0, () => {
      const registry: Map<string, AlchemicalNode> = createRegistry();
      const rod: AlchemicalRodImpl = createRod();
      rod.registerNodeRegistry(registry);

      rod.onReceive(MSG_UNKNOWN_ID);

      expect(registry.size).assertEqual(1);
      expect(registry.has('ghost')).assertFalse();
      expect(getRoot(registry).type).assertEqual('Blank');
    });

    it('TC_ROD_003_unknown_component_type_changes_type_but_not_attr', 0, () => {
      // 刻画现状：type 在属性查表之前就已写入，因此未注册类型会留下
      // 「type 已改、attr 未改」的中间态。修复时应同步更新本用例。
      const registry: Map<string, AlchemicalNode> = createRegistry();
      const rod: AlchemicalRodImpl = createRod();
      rod.registerNodeRegistry(registry);

      const attrBefore: BasicAlchemyAttribute = getRoot(registry).attr;

      rod.onReceive(MSG_UNKNOWN_TYPE);

      const root: AlchemicalNode = getRoot(registry);
      expect(root.type).assertEqual('NoSuchComponent');
      expect(root.attr === attrBefore).assertTrue();
    });

    it('TC_ROD_004_creates_and_registers_child_placeholders', 0, () => {
      const registry: Map<string, AlchemicalNode> = createRegistry();
      const rod: AlchemicalRodImpl = createRod();
      rod.registerNodeRegistry(registry);

      rod.onReceive(MSG_WITH_CHILDREN);

      const root: AlchemicalNode = getRoot(registry);
      expect(root.getChildren().length).assertEqual(2);
      expect(registry.has('c1')).assertTrue();
      expect(registry.has('c2')).assertTrue();
      expect((registry.get('c1') as AlchemicalNode).type).assertEqual('Blank');
    });

    it('TC_ROD_005_missing_registry_is_ignored_without_crash', 0, () => {
      // seam 引入的安全保护：未注册任何 Furnace/注册表时静默忽略，
      // 而非早期实现中的 `!` 断言崩溃。
      const rod: AlchemicalRodImpl = createRod();

      let threw: boolean = false;
      try {
        rod.onReceive(MSG_ROOT_COLUMN);
      } catch (e) {
        threw = true;
      }
      expect(threw).assertFalse();
    });

    it('TC_ROD_006_resending_parent_rebuilds_child_objects', 0, () => {
      // 刻画现状：子节点以 id 为键存放在 Map 中，重复下发不会让数量增长，
      // 但会新建并替换子节点对象，丢弃子节点上已有的状态。
      const registry: Map<string, AlchemicalNode> = createRegistry();
      const rod: AlchemicalRodImpl = createRod();
      rod.registerNodeRegistry(registry);

      rod.onReceive(MSG_WITH_CHILDREN);
      const firstChild: AlchemicalNode = registry.get('c1') as AlchemicalNode;

      rod.onReceive(MSG_WITH_CHILDREN);
      const secondChild: AlchemicalNode = registry.get('c1') as AlchemicalNode;

      expect(getRoot(registry).getChildren().length).assertEqual(2);
      expect(secondChild === firstChild).assertFalse();
    });

    it('TC_ROD_007_update_data_does_not_touch_node_tree', 0, () => {
      // 刻画现状：UPDATE_DATA 目前是空实现，收到后静默丢弃。
      const registry: Map<string, AlchemicalNode> = createRegistry();
      const rod: AlchemicalRodImpl = createRod();
      rod.registerNodeRegistry(registry);

      let threw: boolean = false;
      try {
        rod.onReceive(MSG_UPDATE_DATA_ONLY);
      } catch (e) {
        threw = true;
      }

      expect(threw).assertFalse();
      expect(getRoot(registry).type).assertEqual('Blank');
      expect(registry.size).assertEqual(1);
    });

    it('TC_ROD_008_handles_mixed_batch_of_instructions', 0, () => {
      const registry: Map<string, AlchemicalNode> = createRegistry();
      const rod: AlchemicalRodImpl = createRod();
      rod.registerNodeRegistry(registry);

      rod.onReceive(MSG_MIXED_BATCH);

      expect(getRoot(registry).type).assertEqual('Row');
    });
  });
}
