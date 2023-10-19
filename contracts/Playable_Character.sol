// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";

/*
struct Warrior {
    int healthpoints = 25;
    int energy = 4;
    int damage = 9;
    int strength = 5;
    int wisdom = 2;
    int agility = 3;
}

struct Healer {
    int healthpoints = 15;
    int energy = 10;
    int damage = 6;
    int strength = 3;
    int wisdom = 5;
    int agility = 2;
}

struct Archer {
    int healthpoints = 10;
    int energy = 6;
    int damage = 15;
    int strength = 2;
    int wisdom = 3;
    int agility = 5;
}
*/

enum Class {
    Warrior,
    Healer,
    Archer
}

struct Playable_Character {
    int healthpoints;
    int energy;
    int damage;
    int strength;
    int wisdom;
    int agility;
    Class class;
}

library Player {

    function damage(Playable_Character memory character, int hitpoints) public pure returns (Playable_Character memory) {
        character.healthpoints -= hitpoints;
        return character;
    }

    function useEnergy(Playable_Character memory character, int energy_spent) public pure returns (Playable_Character memory) {
        if (character.energy < 2)
            return character;
        //Needs to validate when using energy that there was no energy spent, so the character can't heal
        character.energy -= energy_spent;
        return character;
    }

    function getHealed(Playable_Character calldata healer, Playable_Character memory healed) public pure returns (Playable_Character memory) {
        int healed_amount = healer.wisdom * 2;
        healed.healthpoints += healed_amount;
        return healed;
    }

    function levelUp(Playable_Character memory character, int strength, int wisdom, int agility) public pure returns (Playable_Character memory) {
        if ((strength + wisdom + agility) != 3) {
            console.log("Invalid value to levelUp");
            return character;
        }
        character.strength += strength;
        character.wisdom += wisdom;
        character.agility += agility;
        return character;
    }

}

abstract contract Playable_CharacterGenerator {
    
    function createPlayableCharacter(Class class) public pure returns (Playable_Character memory) {
        if (class == Class.Warrior) {
            int healthpoints = 25;
            int energy = 4;
            int damage = 9;
            int strength = 5;
            int wisdom = 2;
            int agility = 3;
            return Playable_Character(healthpoints, energy, damage, strength, wisdom, agility, class);
        } else if (class == Class.Healer) {
            int healthpoints = 15;
            int energy = 10;
            int damage = 6;
            int strength = 3;
            int wisdom = 5;
            int agility = 2;
            return Playable_Character(healthpoints, energy, damage, strength, wisdom, agility, class);
        } else {
            int healthpoints = 10;
            int energy = 6;
            int damage = 15;
            int strength = 2;
            int wisdom = 3;
            int agility = 5;
            return Playable_Character(healthpoints, energy, damage, strength, wisdom, agility, class);
        }
    }
}