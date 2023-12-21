const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("ArtistManagement", function () {
  async function deploy() {
    const [owner, otherAccount] = await ethers.getSigners();

    const HITZ_ERC20 = await ethers.getContractFactory("HITZ_ERC20");
    const token = await HITZ_ERC20.deploy();

    const ArtistManagement = await ethers.getContractFactory(
      "ArtistManagement"
    );
    const contractAM = await ArtistManagement.deploy(token.target);

    return { token, contractAM, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const { token, contractAM, owner, otherAccount } = await loadFixture(
        deploy
      );
      // console.log(contractAM.target)

      const incTx = await contractAM.incrementTracksCount(owner.address, 123);
      await incTx.wait();

      const uri = await contractAM.trackURI(owner.address, 1);
      console.log(uri);

      const hash1 = await contractAM.encode(1000, 100, 10);
      const hash2 = await contractAM.encode(2000, 200, 20);

      const addStatTx = await contractAM.addStatistics(
        [owner.address, otherAccount.address],
        [hash1, hash2]
      );

      await addStatTx.wait();

      const rewards1 = await contractAM.checkRewards(owner.address);

      const mintToContract = await token.mint(contractAM.target);
      await mintToContract.wait();

      // console.log(await token.balanceOf(contractAM.target));

      const withdrawTx = await contractAM.withdraw();
      await withdrawTx.wait();

      const ownerBalance = await token.balanceOf(owner.address);
      console.log(ownerBalance);

      expect(rewards1[0]).to.equal(ownerBalance);
      console.log(await contractAM.statistic(owner.address));
      console.log(await contractAM.withdrawnRewards(owner.address));
    });
  });
});
