import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("RefundToken", (m) => {
  const refundToken = m.contract("RefundToken", []);

  return { refundToken };
});
