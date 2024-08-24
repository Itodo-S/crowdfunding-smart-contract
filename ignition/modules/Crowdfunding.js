const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("CrowdfundingModule", (m) => {

  // DEPLOY THE CROWDFUNDING CONTRACT
  const crowdfunding = m.contract("Crowdfunding");

  // RETURNS THE DEPLOYED CONTRACT 
  return { crowdfunding };
});
