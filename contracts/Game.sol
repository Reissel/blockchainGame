// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./Playable_Character.sol";
import "./Enemy.sol";

contract Game is Playable_CharacterGenerator {
    using PlayerLib for Playable_Character;

    event NewGameCreated();
    event NewEnemyCreated();
    event NewPlayerCreated();

    Enemy public enemy;

    // Controls the turn order
    int turnIndex = 0;

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
    }

    address public gameMaster;

    mapping(address => Player) public players;

    Player[] public turnList;

    // Creates a new enemy for the game
    function createEnemy(int healthPoints, int damage) public {
        if (gameStage != GameStage.GM_Creation_Round) {
            console.log("Can't create an enemy in this game stage!");
            return;
        }

        require(
            msg.sender == gameMaster,
            "Only the game master can create an Enemy!"
        );

        enemy = Enemy(healthPoints, damage);

        players[gameMaster].id = gameMaster;
        players[gameMaster].enemy = enemy;

        turnList.push(players[gameMaster]);
        emit NewEnemyCreated();
    }


    // Creates a new character for a player
    function createCharacter(Class class, address player) public {
        if (gameStage != GameStage.GM_Creation_Round) {
            console.log("Can't create a Player in this game stage!");
            return;
        }

        if (player != msg.sender) {
            console.log("Can't create a Character for another player!");
        }

        players[player].id = msg.sender;
        players[player].character = createPlayableCharacter(class);
        turnList.push(players[player]);
        emit NewPlayerCreated();
    }

    constructor() {
        gameMaster = msg.sender;
        gameStage = GameStage.GM_Creation_Round;
        emit NewGameCreated();
    }
}