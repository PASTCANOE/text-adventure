# 64-bit Linux Assembly:Text Adventure

A text adventure game built in x86_64 NASM using direct Linux syscalls (`SYS_read`/`SYS_write`).

## Files Included
* `adventure_main.asm` - Core game loop and command dispatch
* `adventure_data.asm` - Game state variables and text strings
* `adventure_io.asm` - String printing and line reading helper functions
* `conversions.asm` - Standard `atoi`/`itoa` processing routines
* `adventure` - Pre-compiled standalone Linux binary

---

## Running the Binary
To test the pre-compiled game immediately under Linux/WSL:
```bash
chmod +x adventure
./adventure
```

---

## Build Sequence
To re-assemble and link the source files from scratch:
```bash
nasm -f elf64 adventure_main.asm -o adventure_main.o
nasm -f elf64 adventure_data.asm -o adventure_data.o
nasm -f elf64 adventure_io.asm -o adventure_io.o
nasm -f elf64 conversions.asm -o conversions.o
ld adventure_main.o adventure_data.o adventure_io.o conversions.o -o adventure
```

---

## Extension Tasks Implemented
* **In-Game Manual:** Expanded the `help` command with a detailed command guide layout.
* **Custom Win/Quit text:** Rewrote the endgame dispatch routines with cinematic description paths.
* **Dynamic Inventory State:** Implemented a functional `drop key` tracking pipeline that alters room variables.
