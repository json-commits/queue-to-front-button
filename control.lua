script.on_event('front-craft', function(event)
    if event.selected_prototype and event.selected_prototype.base_type == "recipe" then
        local plr = game.players[event.player_index]
        global.queue_to_front = true
        plr.begin_crafting{count=1, recipe=event.selected_prototype.name, silent=true}
    end
end)

script.on_event('front-craft-5', function(event)
    if event.selected_prototype and event.selected_prototype.base_type == "recipe" then
        local plr = game.players[event.player_index]
        global.queue_to_front = true
        plr.begin_crafting{count=5, recipe=event.selected_prototype.name, silent=true}
    end
end)

script.on_event('front-craft-all', function(event)
    if event.selected_prototype and event.selected_prototype.base_type == "recipe" then
        local plr = game.players[event.player_index]
        local recipe = event.selected_prototype.name
        local max = plr.get_craftable_count(recipe)
        global.queue_to_front = true
        plr.begin_crafting{count=max, recipe=recipe, silent=true}
    end
end)

script.on_event(defines.events.on_pre_player_crafted_item, function(event)
    if global.queue_to_front then
        if global.queue_busy then return nil end

        local plr = game.players[event.player_index]
        local local_queue = plr.crafting_queue
        local old_size = plr.character_inventory_slots_bonus
        plr.character_inventory_slots_bonus = 25 * old_size + 1000

        log("crafting: " .. event.recipe.name .. "x" .. event.queued_count)
        plr.cancel_crafting{index=local_queue[#local_queue].index,
                            count=local_queue[#local_queue].count}
        local_queue = plr.crafting_queue

        local saved_queue = {}
        while plr.crafting_queue do
            local queue_item = plr.crafting_queue[#plr.crafting_queue]
            table.insert(saved_queue, queue_item)
            plr.cancel_crafting{index=queue_item.index, count=queue_item.count}
        end

        global.queue_busy = true

        plr.begin_crafting{count=event.queued_count, recipe=event.recipe, silent=true}

        for i = #saved_queue,1,-1 do
            plr.begin_crafting{count=saved_queue[i].count, recipe=saved_queue[i].recipe, silent=true}
        end

        plr.character_inventory_slots_bonus = old_size
        global.queue_busy = false
        global.queue_to_front = false
    end
end)
