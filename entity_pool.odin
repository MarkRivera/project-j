package main

import "core:container/queue"

EntityId :: distinct int

EntityPool :: struct {
    current_id : EntityId,
    recycled_ids : queue.Queue(EntityId)
}

next_id :: proc(entity_pool : ^EntityPool) -> EntityId {
    if queue.len(entity_pool.recycled_ids) > 0 {
        return queue.pop_front(&entity_pool.recycled_ids)
    }

    curr := entity_pool.current_id
    entity_pool.current_id += 1

    return curr
}

release_id :: proc (entity_pool : ^EntityPool, used_id : EntityId) {
    queue.append(&entity_pool.recycled_ids, used_id)
}