; adventure_data.asm - Data for Enhanced Tiny Text Adventure
; Contains:
; - Room descriptions
; - Exit tables
; - Game state (current room, key, puzzle)
; - Messages and command words

section .data

; -----------------------------------------------------------
; Game state
; -----------------------------------------------------------
global current_room
current_room dq 0          ; index of current room (0..3)

global has_key
has_key dq 0               ; 0 = no key, 1 = has key

global puzzle_solved
puzzle_solved dq 0         ; 0 = 42 puzzle not solved, 1 = solved

; -----------------------------------------------------------
; Room descriptions
; -----------------------------------------------------------
; Room 0 - Small room (start)
room0_desc db "You are in a small, dimly lit room. A door leads north.", 10, 0

; Room 1 - Corridor with cat and glowing key
room1_desc db "You stand in a narrow corridor. Doors lead south and east.", 10, \
           "A sleepy cat watches you from the corner.", 10, \
           "On a stone pedestal rests a small brass key, glowing faintly.", 10, \
           "An inscription reads: 'Only the one who knows the answer to", 10, \
           "life, the universe and everything may claim this key.'", 10, 0

; Room 2 - Kitchen
room2_desc db "You are in a bright kitchen. A door leads west.", 10, 0

; Room 3 - Treasure room (victory)
room3_desc db "The door swings open. You step into a glittering treasure room.", 10, 0

; Table of room description pointers
global room_desc_table
room_desc_table:
    dq room0_desc
    dq room1_desc
    dq room2_desc
    dq room3_desc

; -----------------------------------------------------------
; Movement exit tables
; Each table has one entry per room.
; Value = next room index, or -1 if no exit in that direction.
; -----------------------------------------------------------
global exits_north, exits_south, exits_east, exits_west

; north exits
exits_north:
    dq 1, -1, -1, -1 ; 0->1, others have no north exit

; south exits
exits_south:
    dq -1, 0, -1, -1 ; 1->0

; east exits
exits_east:
    dq -1, 3, -1, -1 ; 1->3 (locked by key and puzzle)

; west exits
exits_west:
    dq -1, -1, 1, -1 ; 2->1

; -----------------------------------------------------------
; Messages
; -----------------------------------------------------------
global msg_drop_key, msg_drop_no_key
global msg_welcome, msg_help, msg_unknown, msg_nogo
global msg_locked, msg_goodbye, msg_victory
global msg_take_key, msg_have_key, msg_take_key_locked
global msg_inventory_empty, msg_inventory_key
global msg_pet_cat, msg_take_cat_fail, msg_no_cat
global msg_no_puzzle, msg_puzzle_wrong, msg_puzzle_solved
global msg_answer_usage, msg_cant_take
global prompt, newline

msg_drop_key       db "You drop the brass key onto the floor.", 10, 0
msg_drop_no_key    db "You aren't carrying a key to drop.", 10, 0

msg_welcome        db "Welcome to the Tiny Adventure! Type 'help' for commands.", 10, \
                      "--- QUICK TUTORIAL ---", 10, \
                      "• To move around, use basic compass directions: north, south, east, west", 10, \
                      "• To interact with your surroundings, type: look, inventory, pet cat, take key", 10, \
                      "• If you find a mystery puzzle, use: answer <number>", 10, \
                      "-----------------------", 10, 0
msg_unknown        db "I don't understand that.", 10, 0
msg_nogo           db "You can't go that way.", 10, 0
msg_locked         db "The door is locked.", 10, 0
msg_help           db "=== IN-GAME MANUAL ===", 10, \
                      "• MOVEMENT: Type 'north', 'south', 'east', or 'west' to walk through doors.", 10, \
                      "• INSPECT:  Type 'look' at any time to re-examine your current room.", 10, \
                      "• ITEMS:    Type 'take <item>' to pick something up, or 'drop <item>' to place it down.", 10, \
                      "• BAGS:     Type 'inventory' to check the items you are currently holding.", 10, \
                      "• PUZZLES:  Type 'answer <number>' if you encounter an inscription puzzle.", 10, \
                      "• CAT:      Type 'pet cat' if a friendly feline is nearby.", 10, \
                      "• EXIT:     Type 'quit' to abandon your quest.", 10, \
                      "======================", 10, 0
msg_goodbye        db 10, "--- GAME OVER ---", 10, \
                      "You sit down on the cold stone floor, blow out your torch, and accept defeat.", 10, \
                      "The shadows swallow the room as you abandon your quest. Goodbye!", 10, 0
msg_victory        db 10, "****************************************************", 10, \
                      "   CONGRATULATIONS! VICTORY IS YOURS!   ", 10, \
                      "****************************************************", 10, \
                      "The heavy door creaks open... Blinded by the sudden light, you step", 10, \
                      "into a legendary treasure room overflowing with gold, jewels, and ancient", 10, \
                      "artifacts. You have successfully escaped the Tiny Adventure!", 10, 0



msg_take_key        db "You pick up the brass key.", 10, 0
msg_have_key        db "You already have the key.", 10, 0
msg_take_key_locked db "The key seems fixed in place. The glow does not fade.", 10, 0

msg_inventory_empty db "You are carrying nothing.", 10, 0
msg_inventory_key   db "You are carrying: brass key", 10, 0

msg_pet_cat         db "The cat purrs happily.", 10, 0
msg_take_cat_fail   db "The cat does not want to be picked up.", 10, 0
msg_no_cat          db "There is no cat here.", 10, 0

msg_no_puzzle       db "There is no puzzle to answer here.", 10, 0
msg_puzzle_wrong   db "Nothing happens. That does not seem to be the right answer.", 10, 0
msg_puzzle_solved  db "The pedestal stops glowing. The key looks free to take.", 10, 0
msg_answer_usage   db "Use 'answer X' to set X as your answer.", 10, 0
msg_cant_take      db "You cannot take that.", 10, 0

prompt             db "> ", 0
newline            db 10, 0

; -----------------------------------------------------------
; Command words
; -----------------------------------------------------------
global cmd_drop
global cmd_north, cmd_south, cmd_east, cmd_west
global cmd_look, cmd_help, cmd_quit
global cmd_take, cmd_inventory, cmd_pet, cmd_answer
global cmd_key, cmd_cat

cmd_drop           db "drop", 0

cmd_north          db "north", 0
cmd_south          db "south", 0
cmd_east           db "east", 0
cmd_west           db "west", 0

cmd_look           db "look", 0
cmd_help           db "help", 0
cmd_quit           db "quit", 0

cmd_take           db "take", 0
cmd_inventory      db "inventory", 0
cmd_pet            db "pet", 0
cmd_answer         db "answer", 0

cmd_key            db "key", 0
cmd_cat            db "cat", 0
