package main

import "core:math/fixed"

apply_velocity :: proc(transform : []Transform) {
    for &t in transform {
        t.x_pos = fixed.add(t.x_pos, t.x_vel)
        t.y_pos = fixed.add(t.y_pos, t.y_vel)
    }
}