package main

import "core:fmt"
import "core:math/fixed"

apply_inputs :: proc(state : ^SimState, input : FrameInput) {
    apply_player_input(state.fighters[0].entity_id, input.p1)
}

apply_player_input :: proc (id : EntityId, input : PlayerInput) {
    transform := get_transform_ptr(id)
    if transform == nil do return

    if input >= { .Left } {
        fmt.println("SIM: Player is moving left...")
        
        backward_speed : Fixed16_16
        fixed.init_from_f64(&backward_speed, -1)

        transform.x_vel = backward_speed
    } 
    else if input >= { .Right } {
        fmt.println("SIM: Player is moving right...")
        
        forward_speed : Fixed16_16
        fixed.init_from_f64(&forward_speed, 1)
        
        transform.x_vel = forward_speed
    } 
    else {
        transform.x_vel = {}
    }
}