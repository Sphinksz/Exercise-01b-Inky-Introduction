/*
Created by: Blake Swing
3 Sept 24
*/

// Global Variables
//--------------------------------------------------------//
// Lists
LIST attackerTypes = (Enemy), (Player)
LIST combatChoice = (Attack), (Defend)
LIST enemies = (Orc), (Goblin)

// Enemy Stats
VAR goblin_max_damage = 10
VAR goblin_min_damage = 5
VAR goblin_coin_bonus = 0
VAR orc_max_damage = 15
VAR orc_min_damage = 10
VAR orc_coin_bonus = 3
VAR npc_current_health = 40

// Player Stats
VAR player_nongeared_max_damage = 2
VAR player_nongeared_min_damage = 0
VAR player_geared_max_damage = 20
VAR player_geared_min_damage = 10
VAR player_current_health = 15

VAR player_coins = 200

LIST inventory = (CoinPouch)

// Combat Vars
VAR current_enemy = ""
VAR first_attacker = ""
VAR enemy_combat_choice = ""
VAR player_combat_choice = ""
VAR damage = 0
VAR defending = false
VAR geared = false

//IDR
VAR Count = 0

// Base Stats
VAR Health = 5
VAR Experience = 0
VAR Strength = 1
VAR Luck = 1 // Hidden stat
VAR Perception = 1
VAR amountToAdd = 0 // For stat update
VAR upgradePoints = 15

// Helper functions
VAR targetLocation = -> Start
VAR Beginner_Stats_Applied = false
//--------------------------------------------------------//

-> Start

== upgrade ==
You have {upgradePoints} available upgrade points remaining.
Current stats: {Health} Health. {Perception} Perception. {Strength} Strength.
+ {upgradePoints > 0} [Increase Health] 
    ~upgradeStat(Health, "Health")
        ->upgrade
+ {upgradePoints > 0} [Increase Strength]
    ~upgradeStat(Strength, "Strength")
        ->upgrade
+ {upgradePoints > 0} [Increase Perception]
    ~upgradeStat(Perception, "Perception")
        ->upgrade
+ {upgradePoints == 0 && Beginner_Stats_Applied == false} [Finish Upgrading]
    ~Beginner_Stats_Applied = true 
    ->character_builder

== Start ==
    Welcome adventurer. You are about to embark on a small journey. Have fun!
    +[Begin] ->character_builder

== character_builder ==
{Beginner_Stats_Applied == false: Adventurer, before we begin, you must set your stats. You currently are at {Health} Health, {Strength} Strength, and {Perception} Perception. You will be given 15 stat points to begin the game. Utilize them wisely. After you use these, You will be required to earn experience to gain more stat points.}
+{Beginner_Stats_Applied == false} [Upgrade Stats] ->upgrade
    
+{Beginner_Stats_Applied == true}Congrats on upgrading your stats. Let's begin your adventure! 
->cave_mouth
    

== cave_mouth == 
You are at the entrance to a cave. {torch_pickup: |There is a torch on the floor in front of you.} The cave extends to the east and west.
+ [Take the east tunnel] -> east_tunnel_entrance
+ [Take the west tunnel] -> west_tunnel_entrance
* [Pick up torch] -> torch_pickup

//--------------------------EAST------------------------------//

== east_tunnel_entrance ==
You enter the east tunnel. It is dark and you can hardly see anything.
* {torch_pickup} [Light Torch] -> east_tunnel_entrance_lit
+ [Return to entrance] -> cave_mouth
-> END

== east_tunnel_entrance_lit ==
The light of your torch illuminates the cave walls and allows you to see the way forward.
+[Move Forward] -> east_tunnel_room1
+[Return to entrance] -> cave_mouth
-> END

== east_tunnel_room1 ==
You enter the first room of the east tunnel. You look around the small room and notice the different features glistening off your dimly lit torch. You see crystaline stalactites and stalagmites of various sizes covering the room, with small pools of ice blue water scattered about.
+ [Return to previous room] -> east_tunnel_entrance_lit
+ [Move forward to next room] -> east_tunnel_room2
->END

== east_tunnel_room2 ==
{equip_gear: You've returned to the previous room, donned in your new steel armor. You see the staircase on the left. What will you do? | As you enter the room, you feel a gust of wind and shiver at the chill. This gust almost blows out your torch, but luckily the embers re-kindle the flame. The room is smaller and darker than the previous, with it being further from the entrance and natural sunlight. You notice a decending staircase on the left and catch a glimpse of a shiny object back in the right corner. What will you do?}
* [Go downstairs] -> east_tunnel_bossRoom
+ [FallTest] -> fallInSpikeTrap
+ [Return to previous room] -> east_tunnel_room1
* [Inspect right corner] -> east_tunnel_room2_encounter_treasure -> east_tunnel_room2

// ARMOR TREASURE ROOM

== east_tunnel_room2_encounter_treasure ==
You move closer to the shine you saw, and find out it was a set of steel armor and a knight's sword! What a find! 
*[Equip Gear]->equip_gear ->
->->

== equip_gear ==
You're now wearing steel armor and are holding a torch and a sword!
~ amountToAdd = 85
~ alterStat(Health, amountToAdd)
~geared = true
The armor has increased your Health by 85. You now have {Health} health.
->->


// BOSS ROOM

== east_tunnel_bossRoom ==
    ~setEncounteredEnemy()
    As you travel down the stairs you pass through a set of extremely thick, giant sized marble doors. As you pass through them, they abruptly shut and your torch blows out.
    You are now in complete darkness.....
    *[Continue] -> east_tunnel_bossRoom_encounter
    ->END

== east_tunnel_bossRoom_encounter ==
    All of a sudden torches covered in blue flames begin lighting the perimeter of the room you are in, revealing what seems to be a small arena. You hear banging and uncomprehendable language from a wooden door on the far side wall from you.
    * {equip_gear} [Prepare your sword! You are about to enter combat!] -> east_tunnel_bossRoom_encounter_begin
    * {!equip_gear}[Oh no! What do you do? Raise fists! You are about to enter combat!] -> east_tunnel_bossRoom_encounter_begin
    ->END
    

== east_tunnel_bossRoom_encounter_begin ==
    BANG! The door swings open and out pops a single {current_enemy}.
    *[Enter Combat] -> combat
    ->END

== east_tunnel_bossRoom_encounter_end ==
    The {current_enemy} falls to the ground, perishing before you. You have successfully defeated the creature! Congratulations!
    {current_enemy:
        -Orc: ~amountToAdd = 100
        -Goblin: ~amountToAdd = 30
    }
    ~ alterStat(Experience, amountToAdd)
    ~current_enemy = ""
    
    After the intense battle with the creature, the door in front of you swings open. You ready yourself, prepared for combat again...
    *[Continue..] -> east_tunnel_bossRoom_encounter_exit(1)
    ->END

== east_tunnel_bossRoom_encounter_exit(chest_level) ==
    You wait... but nothing comes out. You decide to press forward, entering into a small room surrounded by six marble pillars. In the middle you notice a cedar chest, adorned in gold clasps and buckles. You approach the chest, bending down before it and grasping it with both hands. 
    ~temp lootRoll = RANDOM(1 * chest_level * Luck,10 * chest_level * Luck )
    *[Open Chest] {lootTreasure(lootRoll)}
    ->DONE
    After looting the chest, you look around the room to find a possible exit.
    *[Search] -> east_tunnel_bossRoom_encounter_exit_1
    
    ->DONE

== east_tunnel_bossRoom_encounter_exit_1 ==
    You find a small crevice in the wall, with a dim light illuminating it. You turn sideways and squeeze through it. As you pass through, the light brightens and you are barely able to see in front of you.
    You reach the end of the crevice and as your eyes come to, in front of you is a whole new world...
    
    Your hero adventure begins now..
    
    *[To Be Continued. Return to Start] -> Start

== function lootTreasure(level) 
    {
    -level >= 5 && level <=10:
        ~temp coinsToAdd = RANDOM(15,30)
        ~player_coins += coinsToAdd
        You found {coinsToAdd} coins, sticking them in your coin pouch. You now have {player_coins} coins.
        ~coinsToAdd = 0
            
    - level >= 0 && level <5:
        ~temp lowCoinsToAdd = RANDOM(1,14)
        ~player_coins += lowCoinsToAdd
        You found {lowCoinsToAdd} coins, sticking them in your coin pouch. You now have {player_coins} coins.
        ~lowCoinsToAdd = 0
    - else:
        Error: Out of Bounds [lootTreasure(level)] - Value {level}
    }
            
    

// END BOSS ROOM

//------------------------WEST--------------------------------//

== west_tunnel_entrance ==
You enter the west tunnel. Small holes in the ceiling illuminate the room, showcasing an empty looking room.
What will you do?
* {Perception >= 5} [Examine room more thoroughly.]  ->west_tunnel_entrance_examin(true)
* {Perception < 5} [Examine room more thoroughly.]  ->west_tunnel_entrance_examin(false)
+ [Return to entrance] -> cave_mouth
-> END

== west_tunnel_entrance_examin(found) ==
    {found:
        -false:
            You search the room and find nothing.
            + [Return to entrance] -> cave_mouth
            ->DONE
        -true:
            Upon searching the room more thoroughly, you see a slighly recessed stone in the wall, which is roughly the size of a human.
            + {Strength >= 4} [Push stone] ->west_tunnel_entrance_examin_perception_passed(true)
            + {Strength < 4} [Push stone] -> west_tunnel_entrance_examin_perception_passed(false)
            + [Return to west entrance] -> west_tunnel_entrance
            ->DONE
    }
    

== west_tunnel_entrance_examin_perception_passed(pushCheck) ==    
    {pushCheck:
        -false:
            You push as hard as you can against the stone, but it doesn't budge. You aren't strong enough.
             + [Return to west entrance] -> west_tunnel_entrance
        -true:
            You brace yourself and push the stone with all your might. Your strong body easily moves the stone, revealing a passage to crawl through.
            ->DONE
    }
    

== west_tunnel_room1 ==

-> END

//-----------------------END WEST---------------------------------//
// Knot "Handles" and Helper Functions

== combat ==
    What will you do?
    ~first_attacker = ()
    ~rollCombatOrder()
    ~rollNPCCombatMove()
    ~defending = false
    +[Attack]
        ~player_combat_choice = "Attack"
        -> handleCombat
    +[Defend]
        ~player_combat_choice = "Defend"
        ~defending = true
        -> handleCombat
    ->END

== handleCombat == 
    {
        -first_attacker == Enemy:
            {
            -enemy_combat_choice == Attack:
                ~attack("player")
                {player_combat_choice == "Attack":
                    ~attack("enemy")
                }
            -enemy_combat_choice == Defend:
            {
                -player_combat_choice == "Attack":
                        ~attack("enemy")
                    -else:
                        You both defend yourselves, preparing for the next move.
            }
            }
        -first_attacker == Player:
            {
            -player_combat_choice == "Attack":
                ~attack("enemy")
                {enemy_combat_choice == Attack:
                    ~attack("player")
                }
            -player_combat_choice == "Defend":
                {
                    -enemy_combat_choice == Attack:
                        ~attack("player")
                    -else:
                        You both defend yourselves, preparing for the next move.
                }
            }
    }

    {
    -npc_current_health <= 0:
        ->east_tunnel_bossRoom_encounter_end
    -Health <= 0:
        ->handleDeath
    -else:
        ->combat
    }
    ->END

== handleDeath ==
    You have fallen in combat... your eyes shut and the world goes black.
    ~Beginner_Stats_Applied = false
    *[Restart] ->Start

// Conditionals

== torch_pickup ==
You acquire a torch! What are you going to use this for?
* [Go Back] -> cave_mouth // No star does it automatically
-> END



//Functions

// Functions

== moveTo(->targetReturn,->nextLocation)
    ~targetLocation = targetReturn
    ->nextLocation
    ->DONE

== targetReturnLocation
    ->targetReturnLocation
    ->DONE

//Functions

=== fallInSpikeTrap ===
    ~temp loopCount = (Health/10) + 1
    ~temp damageType = "Fire"
    ~loop2(loopCount,  ->takeCountDamage)
    {
    -Health <=0:
        ->handleDeath
    }
    

=== function rollCombatOrder() ===
    ~first_attacker = LIST_RANDOM(attackerTypes)

=== function setEncounteredEnemy() ===
    ~ current_enemy = LIST_RANDOM(enemies)
    

=== function attack(target) ===
    {target == "player" :
        {current_enemy} swings his club at you.
        ~damage = getAttackDamage("current_enemy")
        { - defending && geared: 
                You swiftly lift your sword, blocking the {current_enemy}'s attack!
          - else: 
            
            The {current_enemy} hits you, dealing {damage} damage.
            ~ alterStat(Health, -damage)
        }
        
    -else:
        ~ damage = getAttackDamage("player")
        {enemy_combat_choice == Defend:
                The enemy {rolled out of the way, dodging your attack. | used his weapon to block your attack}
          - else:
                You swing your sword at the enemy, doing {damage} damage.
                ~npc_current_health -= damage 
        }

    }
    

=== function rollNPCCombatMove ===
        ~enemy_combat_choice = LIST_RANDOM(combatChoice)
    

=== function getAttackDamage(creature) ===
    {
        - creature == "player" && equip_gear:
            ~ return RANDOM(player_geared_min_damage, player_geared_max_damage)
        - creature == "player" && !equip_gear:
            ~ return RANDOM(player_nongeared_min_damage, player_nongeared_max_damage)
        - creature == "Orc":
            ~ return RANDOM(orc_min_damage, orc_max_damage)
        - else:
            ~ return RANDOM(goblin_min_damage, goblin_max_damage)
    }
    

=== function upgradeStat(ref variable, varName) ===
    ~temp originalValue = variable
    ~variable += 1
    ~upgradePoints -=1
    You have increased your stat by 1. You now have {variable} {varName} points.

=== function alterStat(ref variable, amount) ===
    ~temp originalValue = variable
    ~variable += amount
    {variable:
        - Health:
            {originalValue < variable:
                Your health has increased by {amount}.
            }
            You now have {variable} health.
        - Experience:
            You have gained {amount} experience. You now have {variable} experience.
    }
    
=== function takeSpikeDamage 
    The sharp spikes impale you, dealing 10 damage.
    ~alterStat(Health, -10)
    
=== function takeCountDamage()
    ~temp type = "Fire"
    ~temp damageToDo = RANDOM(-20,-9)
    {type:
        - "Fire": You are on fire! You burn, taking {damageToDo} damage!
        - "Impale": You have been impaled! You bleed, taking {damageToDo} damage!
        - "Ice": You are freezing! Your skin frosts over, dealing {damageToDo} damage!
        - else: Error. [TakeCountDamage]
    }
    ~alterStat(Health, damageToDo)
    
=== function loop(count)
{count} bottles of beer on the wall...
{count > 0: 
    ~loop(count - 1)
    
}

=== function loop2(count, ->dothis)
{count > 0:
    ~dothis()
    ~loop2(count-1, dothis)
}

