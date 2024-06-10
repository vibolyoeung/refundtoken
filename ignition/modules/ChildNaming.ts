import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ChildNaming", (m) => {
  const childNaming = m.contract("ChildNaming", []);

  return { childNaming };
});
