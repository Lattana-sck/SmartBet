const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SmartBet", function () {
  let smartBet;
  let owner;
  let user1;
  let user2;
  let matchId = 1;
  let bettingAmount = ethers.utils.parseEther("1"); // 1 ETH

  beforeEach(async function () {
    // Deploy the SmartBet contract before each test
    const SmartBet = await ethers.getContractFactory("SmartBet");
    [owner, user1, user2] = await ethers.getSigners();
    smartBet = await SmartBet.deploy();
    await smartBet.deployed();
  });

  describe("User Registration", function () {
    it("should allow users to register", async function () {
      await smartBet.connect(user1).registerUser("user1");
      const userInfo = await smartBet.users(user1.address);
      expect(userInfo.isRegistered).to.be.true;
      expect(userInfo.username).to.equal("user1");
    });
  });

  describe("Betting on Matches", function () {
    beforeEach(async function () {
      // Register users and add a match before each betting test
      await smartBet.connect(user1).registerUser("user1");
      await smartBet.connect(user2).registerUser("user2");
      await smartBet.connect(owner).addMatch(matchId);
    });

    it("should allow registered users to place bets", async function () {
      await smartBet
        .connect(user1)
        .placeBet(matchId, 2, 1, { value: bettingAmount });
      const bet = await smartBet.betsByMatch(matchId, 0);
      expect(bet.bettor).to.equal(user1.address);
      expect(bet.amount).to.equal(bettingAmount);
    });

    it("should not allow unregistered users to place bets", async function () {
      await expect(
        smartBet
          .connect(user2)
          .placeBet(matchId, 2, 1, { value: bettingAmount })
      ).to.be.revertedWith("User not registered.");
    });
  });

  describe("Match Management and Winnings Distribution", function () {
    beforeEach(async function () {
      // Register users and add a match before testing match management and winnings distribution
      await smartBet.connect(user1).registerUser("user1");
      await smartBet.connect(user2).registerUser("user2");
      await smartBet.connect(owner).addMatch(matchId);
      await smartBet
        .connect(user1)
        .placeBet(matchId, 2, 1, { value: bettingAmount });
      await smartBet
        .connect(user2)
        .placeBet(matchId, 1, 2, { value: bettingAmount });
    });

    it("should distribute winnings correctly", async function () {
      // Assuming user1 wins the bet
      await smartBet.connect(owner).updateMatch(matchId, 2, 1);
      // Add code to check balance changes and assert winnings were distributed correctly
    });
  });
});
