/*
Created by: Blake Swing
3 Sept 24
*/

// Variables

LIST attackerTypes = (Enemy), (Player)
LIST combatChoice = (Attack), (Defend)

VAR goblin_max_damage = 10
VAR goblin_min_damage = 5

VAR orc_max_damage = 15
VAR orc_min_damage = 10

VAR player_nongeared_max_damage = 2
VAR player_nongeared_min_damage = 0

VAR player_geared_health = 100
VAR player_geared_max_damage = 20
VAR player_geared_min_damage = 10

VAR player_current_health = 15
VAR npc_current_health = 40

VAR current_enemy = ""

VAR first_attacker = ""

VAR enemy_combat_choice = ""
VAR player_combat_choice = ""

VAR damage = 0

VAR defending = false

VAR geared = false

LIST enemies = (Orc), (Goblin)
VAR whileValue = 0

VAR Count = 0

// RANDOM(min,max) #
// LIST_RANDOM


-> cave_mouth // Redirect

== cave_mouth == // Knot
You are at the entrance to a cave. {torch_pickup: |There is a torch on the floor in front of you.} The cave extends to the east and west. // {knot name: true value | false value }  conditional
+ [Test] ->TestMethod
+ [Take the east tunnel] -> east_tunnel_entrance
+ [Take the west tunnel] -> west_tunnel_entrance // Brackets makes it not repeat in convo
* [Pick up torch] -> torch_pickup

== TestMethod ==
    
    ~while(Count,3,"Count+=1")
    ->DONE

== east_tunnel_entrance ==
You enter the east tunnel. It is dark and you can hardly see anything.
* {torch_pickup} [Light Torch] -> east_tunnel_entrance_lit // Adds conditional that torch pickup must have been completed for option to show
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
* [Inspect right corner] -> east_tunnel_room2_encounter_treasure
+ [Return to previous room] -> east_tunnel_room1
->END

== east_tunnel_room2_encounter_treasure ==
You move closer to the shine you saw, and find out it was a set of steel armor and a knight's sword! What a find! 
*[Equip Gear]->equip_gear

->END

== east_tunnel_bossRoom ==
    ~setEncounteredEnemy()
    As you travel down the stairs you pass through a set of extremely thick, giant sized marble doors. As you pass through them, they abruptly shut and your torch blows out.
    You are now in complete darkness.....
    *[Continue] -> east_tunnel_bossRoom_encounter
    ->END

== east_tunnel_bossRoom_encounter ==
    All of a sudden torches covered in blue flames begin lighting the perimeter of the room you are in, revealing what seems to be a small arena. You hear banging and uncomprehendable language from a wooden door on the far side wall from you.
    * {equip_gear} [Prepare your sword! You are about to enter combat!] -> east_tunnel_bossRoom_encounter_begin
    * [Oh no! What do you do? Raise fists! You are about to enter combat!] -> east_tunnel_bossRoom_encounter_begin
    
    ->END
    

== east_tunnel_bossRoom_encounter_begin ==
    BANG! The door swings open and out pops a single {current_enemy}.
    *[Enter Combat] -> combat
    ->END

== east_tunnel_bossRoom_encounter_end ==
    The {current_enemy} falls to the ground, perishing before you. You have successfully defeated the creature! Congratulations!
    After the intense battle with the creature, the door in front of you swings open. You ready yourself, prepared for combat again...
    *[Continue] ->
    ->END
    
== combat ==
    What will you do?
    ~rollCombatOrder()
    ~rollNPCCombatMove()
    +[Attack]
        ~player_combat_choice = "Attack"
        -> handleCombat
    +[Defend]
        ~player_combat_choice = "Defend"
        ~defending = true
        -> handleCombat
    ->END

== handleCombat == 
    
    {   first_attacker == Enemy:
            {enemy_combat_choice == Attack:
                ~attack("player")
            }
        -else:
            ~attack("enemy")
    }

    {
    -npc_current_health <= 0:
        ->east_tunnel_bossRoom_encounter_end
    -player_current_health <= 0:
        ->handleDeath
    -else:
        -> combat
    }
    ->END

== handleDeath ==
    You have fallen in combat... your eyes shut and the world goes black.
    *[Restart] ->cave_mouth

== west_tunnel_entrance ==
You enter the west tunnel
+ [Return to entrance] -> cave_mouth
-> END

// Conditionals

== torch_pickup ==
You acquire a torch! What are you going to use this for?
* [Go Back] -> cave_mouth // No star does it automatically
-> END

== equip_gear ==
You're now wearing steel armor and are holding a torch and a sword!
~ geared = true
~ player_current_health = player_geared_health
* [Return to front] ->east_tunnel_room2
-> END

//Functions

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
            ~ player_current_health -= damage
            The {current_enemy} hits you, dealing {damage} and leaving you with {player_current_health} health.
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
    

=== function setHP(target) ===
    ~return
    
=== function while(x, y, z) ===
    ~whileValue = x
    ~WhileNotLoop(y,z)
    - 
    
=== function WhileNotLoop(y,z) ===
     {whileValue != y:
        whileValue = ~{z}
        Count
        ~WhileNotLoop(y,z)
    }
    
=== function getDictionaryKeyByValue(dict, x) ===
    ~return
=== function getDictionaryValueByKey(dict, x) ===
    ~return
=== function getDictionaryKeyByPosition(dict, x) ===
    ~return
=== function getDictionaryValueByPosition(dict, x) ===
    ~return
    
