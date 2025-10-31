# **BingoBits – Assembly-Based Bingo Game**

## **Overview**

**BingoBits** is a command-line Bingo game implemented entirely in x86 assembly language (NASM).
It allows the player to generate Bingo cards, call random Bingo numbers, mark their cards, and check for a winning combination — all through text-based commands.

The system is modular, consisting of multiple assembly files that handle specific game components:

* **`bingobits.asm`** — Main program and command interpreter
* **`card_generator.asm`** — Card creation, validation, and display
* **`number_caller.asm`** — Random number generation and tracking
* **`card_marker.asm`** — Card marking and Bingo checking (linked but not shown)

This project demonstrates structured modular programming, random number generation, and user interaction in low-level assembly.

---

## **File Structure**

| File                   | Description                                                                                                                                  |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **bingobits.asm**      | Main control logic. Handles user input, game flow, and command dispatching.                                                                  |
| **card_generator.asm** | Responsible for generating valid Bingo cards (5x5) with random numbers in correct column ranges. Also handles displaying and clearing cards. |
| **number_caller.asm**  | Generates unique random numbers (1–75), displays the list of called numbers, and manages call history.                                       |
| **card_marker.asm**    | Marks selected positions on the Bingo card and checks for winning patterns (Bingo).                                                          |

---

## **Compilation and Linking**

Ensure that **NASM** and **GCC (32-bit)** are installed on your system.

### **Step 1: Assemble**

```bash
nasm -f elf32 bingobits.asm -o bingobits.o
nasm -f elf32 card_generator.asm -o card_generator.o
nasm -f elf32 number_caller.asm -o number_caller.o
nasm -f elf32 card_marker.asm -o card_marker.o
```

### **Step 2: Link**

```bash
gcc -m32 -no-pie bingobits.o card_generator.o number_caller.o card_marker.o -o bingobits
```

### **Step 3: Run**

```bash
./bingobits
```

---

## **Gameplay Instructions**

When launched, the program displays a welcome message and awaits player input through the command prompt (`> `).
The following commands are available:

| Command              | Description                                                 |
| -------------------- | ----------------------------------------------------------- |
| **help**             | Displays all available commands.                            |
| **new**              | Generates a new Bingo card and resets the game state.       |
| **card**             | Displays the current unmarked Bingo card.                   |
| **marked**           | Displays the card with current marks applied.               |
| **call**             | Calls a random Bingo number (1–75).                         |
| **called**           | Shows all previously called numbers.                        |
| **mark [row] [col]** | Marks a square at the specified coordinates (0–4 for both). |
| **BINGO**            | Checks if you have achieved a winning Bingo pattern.        |
| **exit**             | Exits the game gracefully.                                  |

> ⚠️ **Note:** You must generate a card first using the `new` command before performing any game actions.

---

## **Game Rules**

1. Each Bingo card is a **5×5 grid** labeled under columns **B**, **I**, **N**, **G**, **O**.
2. Each column has unique number ranges:

   * **B:** 1–15
   * **I:** 16–30
   * **N:** 31–45
   * **G:** 46–60
   * **O:** 61–75
3. The center square (N column, row 2) is automatically marked as **FREE**.
4. The player wins if any **row, column, or diagonal** is fully marked.

---

## **Core Functionalities**

### **1. Bingo Card Generation (`card_generator.asm`)**

* Creates a randomized and valid Bingo card based on column constraints.
* Ensures no duplicate numbers within a column.
* Displays the card in a formatted grid with headers.
* The center cell is always the “FREE” space (value 0).

### **2. Random Number Calling (`number_caller.asm`)**

* Randomly selects numbers from **1–75** using the C library’s `rand()` function.
* Prevents duplicates through flag tracking.
* Displays the called number with its corresponding Bingo letter.
* Maintains a list of all numbers called so far.

### **3. Card Marking and Bingo Checking (`card_marker.asm`)**

* Marks selected card positions when a player uses the `mark` command.
* Verifies valid input (row and column range 0–4).
* Checks if the player has achieved Bingo (complete line horizontally, vertically, or diagonally).

### **4. Game Management (`bingobits.asm`)**

* Handles user input and command interpretation.
* Validates whether a card is generated before executing dependent commands.
* Displays appropriate prompts and messages for feedback.
* Supports replay after winning via `new` command.

---

## **Program Flow**

1. **Startup:** Displays greeting message and awaits input.
2. **Generate Card:** User inputs `new` to create a randomized card.
3. **Call Numbers:** The player uses `call` to generate Bingo numbers.
4. **Mark Card:** The player marks matching numbers on the card using `mark [row] [col]`.
5. **Check for Bingo:** The player enters `BINGO` to verify a win.
6. **End or Restart:** User can restart with `new` or quit with `exit`.

---

## **Technical Details**

* **Language:** NASM Assembly (Intel syntax)
* **Architecture:** 32-bit (x86)
* **Libraries Used:**

  * `printf` and `scanf` from C standard library for input/output
  * `rand`, `srand`, and `time` for randomization
* **Memory Management:** Static allocation via `.bss` for game data arrays
* **Data Structures:**

  * 5×5 Bingo card stored as a linear array
  * Call flags (76 bytes) used to track called numbers
* **Validation:**

  * Ensures valid row/column inputs
  * Prevents duplicate numbers and invalid range errors

---

## **Sample Output**

```
Welcome to BingoBits!
Type 'help' to learn how to play

> new
A new BINGO card has been generated!
+----+----+----+----+----+
    B    I    N    G    O
+----+----+----+----+----+
   10   29   37   57   72
   12   25   41   53   64
   14   18  FREE  47   61
   11   27   44   54   67
    2   21   43   51   63
+----+----+----+----+----+

> call
Calling number: G-54

> mark 3 3
Marked (Row 3, Col 3)

> BINGO
You haven't hit BINGO yet, keep playing.

> exit
Thank you for playing! ^-^
```

