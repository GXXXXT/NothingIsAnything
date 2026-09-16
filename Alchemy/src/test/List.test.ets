import localUnitTest from './LocalUnit.test';
import alchemicalUtilsTest from './AlchemicalUtils.test';
import alchemicalNodeTest from './AlchemicalNode.test';
import alchemicalAttributesTest from './AlchemicalAttributes.test';
import alchemicalRegistryTest from './AlchemicalRegistry.test';
import alchemicalRodTest from './AlchemicalRod.test';

export default function testsuite() {
  localUnitTest();
  alchemicalUtilsTest();
  alchemicalNodeTest();
  alchemicalAttributesTest();
  alchemicalRegistryTest();
  alchemicalRodTest();
}
