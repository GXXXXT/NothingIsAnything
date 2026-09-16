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
import { AlchemicalNode, BasicAlchemyAttribute } from '../main/ets/engine/components/AlchemicalNode';

interface NodeAttrParams {
  width: string;
  height: string;
}

/**
 * TC-NODE-*：节点树（AlchemicalNode）与属性基类（BasicAlchemyAttribute）。
 * 覆盖 B4/B5 两个 params 分支。
 */
export default function alchemicalNodeTest() {
  describe('alchemicalNodeTest', () => {

    it('TC_NODE_001_createRoot_returns_root_blank_node', 0, () => {
      const root: AlchemicalNode = AlchemicalNode.createRoot();
      expect(root.id).assertEqual('root');
      expect(root.type).assertEqual('Blank');
      expect(root.getChildren().length).assertEqual(0);
    });

    it('TC_NODE_002_addChild_registers_child', 0, () => {
      const parent: AlchemicalNode = new AlchemicalNode('parent', 'Column');
      const child: AlchemicalNode = new AlchemicalNode('child', 'Text');

      const added: boolean = parent.addChild(child);

      expect(added).assertTrue();
      expect(parent.getChildren().length).assertEqual(1);
      expect(parent.getChildren()[0].id).assertEqual('child');
    });

    it('TC_NODE_003_removeChild_returns_true_when_child_present', 0, () => {
      const parent: AlchemicalNode = new AlchemicalNode('parent', 'Column');
      const child: AlchemicalNode = new AlchemicalNode('child', 'Text');
      parent.addChild(child);

      expect(parent.removeChild(child)).assertTrue();
      expect(parent.getChildren().length).assertEqual(0);
    });

    it('TC_NODE_004_removeChild_returns_false_when_child_absent', 0, () => {
      const parent: AlchemicalNode = new AlchemicalNode('parent', 'Column');
      const stranger: AlchemicalNode = new AlchemicalNode('stranger', 'Text');

      expect(parent.removeChild(stranger)).assertFalse();
    });

    it('TC_NODE_005_addChild_with_same_id_overwrites_previous', 0, () => {
      const parent: AlchemicalNode = new AlchemicalNode('parent', 'Column');
      parent.addChild(new AlchemicalNode('dup', 'Text'));
      parent.addChild(new AlchemicalNode('dup', 'Button'));

      expect(parent.getChildren().length).assertEqual(1);
      expect(parent.getChildren()[0].type).assertEqual('Button');
    });

    it('TC_NODE_006_basic_attribute_keeps_defaults', 0, () => {
      const attr: BasicAlchemyAttribute = new BasicAlchemyAttribute();
      expect(attr.width).assertEqual('auto');
      expect(attr.height).assertEqual('auto');
    });

    it('TC_NODE_007_basic_attribute_applies_params', 0, () => {
      const params: NodeAttrParams = { width: '100%', height: '50vp' };
      const attr: BasicAlchemyAttribute = new BasicAlchemyAttribute(params);

      expect(attr.width).assertEqual('100%');
      expect(attr.height).assertEqual('50vp');
    });

    it('TC_NODE_008_basic_attribute_with_undefined_params_keeps_defaults', 0, () => {
      const attr: BasicAlchemyAttribute = new BasicAlchemyAttribute(undefined);
      expect(attr.width).assertEqual('auto');
      expect(attr.height).assertEqual('auto');
    });

    it('TC_NODE_009_node_accepts_explicit_attribute', 0, () => {
      const params: NodeAttrParams = { width: '10vp', height: '10vp' };
      const attr: BasicAlchemyAttribute = new BasicAlchemyAttribute(params);
      const node: AlchemicalNode = new AlchemicalNode('n1', 'Text', attr);

      expect(node.attr.width).assertEqual('10vp');
      expect(node.id).assertEqual('n1');
      expect(node.type).assertEqual('Text');
    });
  });
}
