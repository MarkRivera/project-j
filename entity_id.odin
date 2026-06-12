package main

import "core:container/queue"

EntityId :: distinct int

EntityPool :: struct {
    current_id : EntityId,
    recycled_ids : queue.Queue(EntityId)
}

EntityPoolError :: enum {
    None,
    PoolExhausted
}

max_entity_count : EntityId : 2048

next_id :: proc(entity_pool : ^EntityPool) -> (id: EntityId, err: EntityPoolError) {
    if entity_pool.current_id >= max_entity_count && queue.len(entity_pool.recycled_ids) == 0 {
        // In production (-define:ODIN_DEBUG=false), this assert is entirely optimized away.
		assert(entity_pool.current_id < max_entity_count, "Entity pool exhaustion: Maximum entity count exceeded!")
        return -1, .PoolExhausted
    }

    if queue.len(entity_pool.recycled_ids) > 0 {
        return queue.pop_front(&entity_pool.recycled_ids), .None
    }

    curr := entity_pool.current_id
    entity_pool.current_id += 1

    return curr, .None
}

release_id :: proc (entity_pool : ^EntityPool, used_id : EntityId) {
    queue.append(&entity_pool.recycled_ids, used_id)
}