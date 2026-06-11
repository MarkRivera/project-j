package main

import "core:math/fixed"
import "vendor:raylib"
import "core:mem"
import "core:fmt"
import "core:time"

FIXED_TIME_STEP :: 16_666_667 // 60 updates per second

GameState :: struct {
    accumulator : i64,
    max_simulation_steps : int,
    previous_time : i64,
    is_running : bool
}

Cube :: struct {
    position_x : fixed.Fixed16_16,
    position_y : fixed.Fixed16_16,
    forward_speed : fixed.Fixed16_16,
    backward_speed : fixed.Fixed16_16,
}

main :: proc() {
    when ODIN_DEBUG {
        track : mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        context.allocator = mem.tracking_allocator(&track)

        defer {
            if len(track.allocation_map) > 0 {
                fmt.println("=== Memory Leaks Detected ===")
                fmt.eprintf("=== %v allocations not freed ===\n", len(track.allocation_map))

                for _, entry in track.allocation_map {
                    fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
                }
            }

            mem.tracking_allocator_destroy(&track)
        }
    }

    fmt.println("Debug mode: %v", ODIN_DEBUG)

    width : i32 = 800
    height : i32 = 600

    raylib.InitWindow(width, height, "Hello, Raylib!")
    defer raylib.CloseWindow()

    camera : raylib.Camera3D = raylib.Camera3D {}
    camera.position = [3]f32 { 0, 3, 15 }
    camera.target = [3]f32 { 0, 1, 0 }
    camera.up = [3]f32 { 0, 1, 0 }
    camera.fovy = 45.0
    camera.projection = .PERSPECTIVE

    cube : Cube = Cube {}

    fixed.init_from_f64(&cube.position_x, 0)
    fixed.init_from_f64(&cube.position_y, 0)
    fixed.init_from_f64(&cube.forward_speed, 0.1)
    fixed.init_from_f64(&cube.backward_speed, -0.1)

    game_state : GameState = GameState {
        accumulator = 0,
        max_simulation_steps = 8,
        previous_time = time.time_to_unix_nano(time.now()),
    }

    for !raylib.WindowShouldClose() {
        fmt.println("=== New Window Tick ===")
        current_time := time.time_to_unix_nano(time.now())
        delta_time := current_time - game_state.previous_time
        game_state.previous_time = current_time
        
        
        // If user drags window or system is paused, cap delta_time to prevent spiral of death
        if delta_time > 250_000_000 { 
            delta_time = 250_000_000
        }

        
        steps_executed := 0
        game_state.accumulator += delta_time

        for game_state.accumulator >= FIXED_TIME_STEP  {
            fmt.println("=== New Simulation Step ===")
            
            
            if steps_executed >= game_state.max_simulation_steps  {
                fmt.println("Too many simulation steps, preventing spiral...")
                game_state.accumulator = 0
                break
            }

            
            input_state : Input_Set = process_input()

            
            fmt.println("SIM: Updating game state...")
            if input_state >= { .Left } {
                fmt.println("SIM: Player is moving left...")
                cube.position_x = fixed.add(cube.position_x, cube.backward_speed)
            }

            if input_state >= { .Right } {
                fmt.println("SIM: Player is moving right...")
                cube.position_x = fixed.add(cube.position_x, cube.forward_speed)
            }
            

            game_state.accumulator -= FIXED_TIME_STEP
            steps_executed += 1
        }

        // Rendering Logic
        fmt.println("Rendering frame...")
        alpha := f64(game_state.accumulator) / f64(FIXED_TIME_STEP) // Calculate how far we are into the next sim

        raylib.BeginDrawing()
            raylib.ClearBackground(raylib.WHITE)
            raylib.BeginMode3D(camera)

                cube_position := [3]f32 { f32(fixed.to_f64(cube.position_x)), f32(fixed.to_f64(cube.position_y)), 0 }
                raylib.DrawCube(cube_position, 2.0, 2.0, 2.0, raylib.RED)
                raylib.DrawCubeWires(cube_position, 2.0, 2.0, 2.0, raylib.MAROON)

                raylib.DrawGrid(100, 1.0)
            raylib.EndMode3D()

            raylib.DrawText("Welcome to the third dimension!", 10, 40, 20, raylib.DARKGRAY)
            raylib.DrawFPS(10, 10)
        raylib.EndDrawing()
    }
}