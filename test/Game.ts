import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Game", async function () {

  async function deploy() {

    const PlayerLib__factory = await ethers.getContractFactory("PlayerLib");
    const playerLib = await PlayerLib__factory.deploy();
    const EnemyLib__factory = await ethers.getContractFactory("EnemyLib");
    const enemyLib = await EnemyLib__factory.deploy();

    const [owner, otherAccount, otherAccount2, otherAccount3] = await ethers.getSigners();

    const Game = await ethers.getContractFactory("Game", {
      libraries: {
        PlayerLib: (await playerLib.getAddress()),
        EnemyLib: (await enemyLib.getAddress()),
      }
    });
    const game = await Game.deploy();
    return { game, owner, otherAccount, otherAccount2, otherAccount3 };
  }

  describe("Deployment", function () {
    it("Should be at the stage GM_Creation_Round", async function () {

      const { game } = await loadFixture(deploy);

      expect((await game.gameStage()).toString()).to.equal('0');
      
    });

    it("Should have the owner as GameMaster", async function () {

      const { game, owner } = await loadFixture(deploy);

      expect((await game.gameMaster()).toString()).to.equal(owner.address);
      
    });

    it("Should be at the turnIndex 0", async function () {

      const { game } = await loadFixture(deploy);

      expect((await game.turnIndex()).toString()).to.equal('0');
      
    });

    it("Should have zero players", async function () {

      const { game } = await loadFixture(deploy);

      expect(await game.getPlayerListLength()).to.equal(0);
      
    });

    it("Should have no enemy", async function () {

      const { game } = await loadFixture(deploy);

      expect((await game.enemy()).healthPoints).to.equal(0);
      expect((await game.enemy()).damage).to.equal(0);
      
    });
  });

  describe("Create Enemy and Players", function () {
    it("Should create Enemy and increment turnIndex", async function () {

      const { game } = await loadFixture(deploy);
      await game.createEnemy(10,2);

      expect((await game.enemy()).healthPoints).to.equal(10);
      expect((await game.enemy()).damage).to.equal(2);
      expect((await game.turnIndex()).toString()).to.equal('1');
      
    });

    it("Should create Warrior and increment turnIndex", async function () {

      const { game, otherAccount } = await loadFixture(deploy);
      await game.createEnemy(10,2);

      await game.connect(otherAccount).createCharacter(0);

      expect(await game.getPlayerListLength()).to.equal(1);
      expect((((await game.getPlayer(otherAccount.address)).character.class))).to.equal(0);
      expect((((await game.getPlayer(otherAccount.address)).character.healthPoints))).to.equal(25);
      expect((((await game.getPlayer(otherAccount.address)).character.energy))).to.equal(4);
      expect((((await game.getPlayer(otherAccount.address)).character.damage))).to.equal(9);
      expect((((await game.getPlayer(otherAccount.address)).character.strength))).to.equal(5);
      expect((((await game.getPlayer(otherAccount.address)).character.wisdom))).to.equal(2);
      expect((((await game.getPlayer(otherAccount.address)).character.agility))).to.equal(3);
      expect((await game.turnIndex()).toString()).to.equal('2');
      
    });

    it("Should not create a class that is already in use", async function () {

      const { game, otherAccount, otherAccount2 } = await loadFixture(deploy);
      await game.createEnemy(10,2);

      await game.connect(otherAccount).createCharacter(0);

      await expect(
        (game.connect(otherAccount2).createCharacter(0))
      ).to.be.revertedWith('There is already a player using that class!');
      
    });

    it("Should fill player list and change Stage", async function () {

      const { game, otherAccount, otherAccount2, otherAccount3 } = await loadFixture(deploy);
      await game.createEnemy(10,2);

      await game.connect(otherAccount).createCharacter(0);
      await game.connect(otherAccount2).createCharacter(1);
      await game.connect(otherAccount3).createCharacter(2);

      expect(await game.getPlayerListLength()).to.equal(3);
      expect((await game.gameStage()).toString()).to.equal('2');
      
    });
  });
})