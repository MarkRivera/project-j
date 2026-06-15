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

    facing : i8, // -1 left, 1 right
    gravity_enabled : bool
}

TransformPoolError :: enum {
    None,
    TransformPoolExhausted,
    
}

// Transform Pool
transform_pool : [max_entity_count]Transform // Declare pool type
transform_sparse : [max_entity_count]int
transform_count : int = 0 // This gives the current available index
// -1 means no transform exists in transform pool for entity

init_entity_to_transform_pool :: proc() {
    for i : EntityId = 0; i < max_entity_count; i += 1 {
        transform_sparse[i] = -1
    }
}

get_from_transform_pool :: proc(entity_id: EntityId) -> (transform : Transform, exists: bool) {
    idx := transform_sparse[entity_id]
    if idx == -1 do return
    return transform_pool[idx], true
}

get_transform_ptr :: proc(entity_id : EntityId) -> (transformPtr : ^Transform) {
    idx := transform_sparse[entity_id]
    if idx == -1 do return nil

    return &transform_pool[idx]
}

insert_to_transform_pool :: proc(transform : Transform) -> (int, TransformPoolError) {
    // The entity already contains a transform in the pool
    if transform_sparse[transform.owner] != -1 {
        transform_pool_idx := transform_sparse[transform.owner]
        transform_pool[transform_pool_idx] = transform

        return transform_pool_idx, .None
    }

    // If the current index is equal to or greater than max allowed transforms, we return an error
    if transform_count >= int(max_entity_count) {
        return -1, .TransformPoolExhausted
    }
    
    idx := transform_count
    transform_pool[idx] = transform
    transform_sparse[transform.owner] = idx
    transform_count += 1

    return idx, .None
}

remove_from_transform_pool :: proc(entity_id: EntityId) -> bool {
    pool_index := transform_sparse[entity_id]
    if pool_index == -1 {
        return false
    }
    
    last_transform := transform_pool[transform_count - 1]

    transform_pool[pool_index] = last_transform
    transform_count -= 1

    transform_sparse[last_transform.owner] = pool_index
    transform_sparse[entity_id] = -1

    return true
}