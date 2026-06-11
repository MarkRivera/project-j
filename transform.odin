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

// Transform Pool
max_transforms : int : 255 // The max number of transforms per pool
transform_pool : [max_transforms]Transform // Declare pool type
transform_count : int = 0 // This gives the current available index
entity_to_transform_map : [dynamic]int // This uses the entity id as an index, the return value is the index of the entity's transform in the pool
// -1 means no transform exists in transform pool for entity

init_entity_to_transform_pool :: proc() {
    // Initialize entity to transform map
    for i := 0; i < len(entity_to_transform_map); i += 1 {
        entity_to_transform_map[i] = -1
    }
}

add_to_transform_pool :: proc(transform : Transform) -> int {
// TODO: Determin the max number of entities in my game to make this logic simple

    if int(transform.owner) >= max_transforms {
        return -1
    }

    // The entity already contains a transform in the pool
    if entity_to_transform_map[transform.owner] != -1 {
        return -1
    }

    if transform_count >= max_transforms {
        return -1
    }

    idx := transform_count
    transform_pool[idx] = transform
    entity_to_transform_map[transform.owner] = idx
    transform_count += 1

    return idx
}