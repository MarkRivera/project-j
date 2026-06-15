package main

import "core:fmt"
import "vendor:raylib"

Input :: enum {
    Left,
    Right,
    Up,
    Down,
    Light,
    Medium,
    Heavy,
    Special
}

PlayerInput :: bit_set[Input; u8]

FrameInput :: struct {
    p1 : PlayerInput,
    p2 : PlayerInput
}

KeyBindings :: [Input] raylib.KeyboardKey {
    .Left = raylib.KeyboardKey.Q,
    .Right = raylib.KeyboardKey.E,
    .Down = raylib.KeyboardKey.W,
    .Up = raylib.KeyboardKey.V,
    .Light = raylib.KeyboardKey.U,
    .Medium = raylib.KeyboardKey.I,
    .Heavy = raylib.KeyboardKey.O,
    .Special = raylib.KeyboardKey.J,
}

process_input :: proc() -> PlayerInput {
    fmt.println("Processing input...")
    
    fmt.println("Reading input state...")
    input_state : PlayerInput = read_input()
    
    fmt.println("Cleaning up input state...")
    socd_input(&input_state)

    return input_state
}

read_input :: proc() -> PlayerInput {
    fmt.println("Reading input...")
    
    // LDRU LMHS  - assuming 1 player for now, we can expand this to support multiple players later
    input_state : PlayerInput

    for key, input in KeyBindings {
        if raylib.IsKeyDown(key) {
            fmt.println("Key pressed: ", key)
            input_state += { input } // Set the corresponding bit to 1
        }
    }

    return input_state
}

socd_input :: proc(input_state : ^PlayerInput) {
    fmt.println("Processing SOCD input...")

    if .Left in input_state && .Right in input_state {
        fmt.println("SOCD detected: Left and Right pressed simultaneously, neutralizing horizontal input.")
        input_state^ -= {.Left, .Right} // Clear both L and R bits
    }

    if .Up in input_state && .Down in input_state {
        fmt.println("SOCD detected: Up and Down pressed simultaneously, neutralizing vertical input.")
        input_state^ -= {.Up, .Down} // Clear both U and D bits
    }
}