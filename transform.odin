package main

import "core:math/fixed"

Fixed16_16 :: fixed.Fixed16_16

Transform :: struct {
    owner : EntityId,

    x_pos : Fixed16_16,
    y_pos : Fixed16_16,

    x_vel : Fixed16_16,
    y_vel : Fixed16_16,

    x_acc : Fixed16_16,
    y_acc : Fixed16_16,

    facing : i8 // -1 left, 1 right
}

TransformPoolError :: enum {
    None,
    TransformPoolExhausted
}

// Transform Pool
transform_pool : [max_entity_count]Transform // Declare pool type
transform_count : int = 0 // This gives the current available index
entity_to_transform_map : [max_entity_count]int
// -1 means no transform exists in transform pool for entity

init_entity_to_transform_pool :: proc() {
    for i : EntityId = 0; i < max_entity_count; i += 1 {
        entity_to_transform_map[i] = -1
    }
}

upsert_to_transform_pool :: proc(transform : Transform) -> (int, TransformPoolError) {
    // If the current index is equal to or greater than max allowed transforms, we return an error
    if transform_count >= int(max_entity_count) {
        return -1, .TransformPoolExhausted
    }
    
    // The entity already contains a transform in the pool
    if entity_to_transform_map[transform.owner] != -1 {
        idx := int(transform.owner)
        return entity_to_transform_map[idx], .None
    }


    idx := transform_count
    transform_pool[idx] = transform
    entity_to_transform_map[transform.owner] = idx
    transform_count += 1

    return idx, .None
}