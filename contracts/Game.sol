// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Playable_Character.sol";
import "./Enemy.sol";

contract Game {
    using PlayerLib for Playable_Character;
    using EnemyLib for Enemy;

    event NewGameCreated();
    event NewEnemyCreated();
    event NewPlayerCreated();
    event EnemyDefeated();
    event GameStarted();

    Enemy public enemy;

    // Controls the turn order
    uint256 public turnIndex = 0;

    enum GameStage {
        GM_Creation_Round,
        Player_Creation_Round,
        Game_Start,
        Game_Finished
    }
    GameStage public gameStage;

    struct Player {
        address id;
        Playable_Character character;
        Enemy enemy;
        uint256 turnTime;
    }

    address private gameMaster;

    mapping(address => Player) public players;

    address[] private playerList;

    function incrementTurnIndex() private {
        
        // Skip Enemy check
        if(turnIndex != 0 && gameStage == GameStage.Game_Start) {
            // Skip turn of deceased players
            if(players[playerList[turnIndex]].character.healthPoints == 0) turnIndex += 1;
        }

        turnIndex += 1;
        // Reset turn Order
        if(turnIndex > 3) turnIndex = 0;
    }

    // Creates a new enemy for the game
    function createEnemy(int healthPoints, int damage) public {

        require(
            enemy.healthPoints == 0 && enemy.damage == 0,
            "There is already an enemy created!"
        );

        require(
            gameStage == GameStage.GM_Creation_Round,
            "Can't create an enemy in this game stage!"
        );

        require(
            msg.sender == gameMaster,
            "Only the game master can create an Enemy!"
        );

        enemy = Enemy(healthPoints, damage);

        players[gameMaster].id = gameMaster;
        players[gameMaster].enemy = enemy;

        players[gameMaster].turnTime = turnIndex;
        turnIndex += 1;
        emit NewEnemyCreated();

        gameStage = GameStage.Player_Creation_Round;
    }


    // Creates a new character for a player
    function createCharacter(Class class) public {

        require(
            gameStage == GameStage.Player_Creation_Round,
            "Can't create a Player in this game stage!"
        );

        // Searches if another player has already picked the same class
        for (uint256 i = 0; i < playerList.length; i++) {

            require(
                class != players[playerList[i]].character.class,
                "There is already a player using that class!"
            );

        }

        players[msg.sender].id = msg.sender;

        if (class == Class.Warrior) {
            int healthPoints = 25;
            int energy = 4;
            int damage = 9;
            int strength = 5;
            int wisdom = 2;
            int agility = 3;
            players[msg.sender].character = Playable_Character(healthPoints, energy, damage, strength, wisdom, agility, class);
        } else if (class == Class.Healer) {
            int healthPoints = 15;
            int energy = 10;
            int damage = 6;
            int strength = 3;
            int wisdom = 5;
            int agility = 2;
            players[msg.sender].character = Playable_Character(healthPoints, energy, damage, strength, wisdom, agility, class);
        } else {
            int healthPoints = 10;
            int energy = 6;
            int damage = 15;
            int strength = 2;
            int wisdom = 3;
            int agility = 5;
            players[msg.sender].character = Playable_Character(healthPoints, energy, damage, strength, wisdom, agility, class);
        }

        playerList.push(msg.sender);
        //turnList.push(players[player]);
        players[msg.sender].turnTime = turnIndex;

        incrementTurnIndex();

        if(playerList.length == 3) {
            gameStage = GameStage.Game_Start;
            emit GameStarted();
        }

        emit NewPlayerCreated();
    }

    // Attacks enemy
    function attackEnemy() public {

        require(
            gameStage == GameStage.Game_Start,
            "Can't attack the enemy in this game stage!"
        );

        require(
            turnIndex == players[msg.sender].turnTime,
            "It's not your turn yet!"
        );

        int hitPoints = players[msg.sender].character.damage;
        enemy = enemy.takesDamage(hitPoints);
        if(enemy.isDefeated()) {
            emit EnemyDefeated();
            gameStage = GameStage.Game_Finished;
            turnIndex = 0;
        }

        incrementTurnIndex();
    }

    // Enemy attacks
    function attackPlayer(address player) public {

        require(
            msg.sender == gameMaster,
            "Only the Game Master can attack with the Enemy!"
        );

        // Checks turn
        require(
            turnIndex == players[msg.sender].turnTime,
            "It's not the Enemy turn yet!"
        );

        players[player].character = players[player].character.takesDamage(enemy.damage);
        
        incrementTurnIndex();
    }

    // Enemy attacks
    function healPlayer(address player) public {

        require(
            players[msg.sender].enemy.healthPoints == 0 && players[msg.sender].enemy.damage == 0,
            "Enemy can't heal players and itself!"
        );

        require(
            players[msg.sender].character.energy > 2,
            "You don't have enough energy to heal! Energy Cost = 2"
        );

        players[msg.sender].character = players[msg.sender].character.useEnergy(2);

        int healPoints = players[msg.sender].character.wisdom;

        players[player].character = players[player].character.getHealed(healPoints);

        incrementTurnIndex();
    }

    constructor() {
        gameMaster = msg.sender;
        gameStage = GameStage.GM_Creation_Round;
        emit NewGameCreated();
    }
}