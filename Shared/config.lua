---@class DrugItem
---@field item string The name of the item
---@field amount number The quantity of the item

---@class DrugProgress
---@field time number Duration in seconds
---@field label string The text to display on the progress bar
---@field canCancel? boolean (Optional) Whether the progress can be cancelled
---@field disable? table (Optional) Table of things to disable during the progress (e.g., { car = true })
---@field anim? table { dict: string, clip: string } (Optional) Animation data
---@field prop? table { model: number, pos: vector3, rot: vector3 } (Optional) Prop data for the first prop
---@field propTwo? table { model: number, pos: vector3, rot: vector3 } (Optional) Prop data for the second prop

---@class DrugConfig
---@field label string The text shown in the TextUI
---@field donelabel? string (Optional) Notification text on success
---@field coords vector3 The location of the interaction
---@field distance? number (Optional) Radius for interaction
---@field removeitem? DrugItem[] (Optional) Items required to start
---@field getitem? DrugItem[] (Optional) Items rewarded on finish
---@field progress? DrugProgress (Optional) Progress bar settings

Config = {}

Config.KeyBind = 'E'

Config.Debug = false

Config.CreatedDrug = {
    {
        label = '[E] - Order Coke Leaves',
        donelabel = 'Collected Coke Leaves',
        coords = vec3(-335.5667, -2449.2004, 7.3581),
        distance = 2,
        removeitem = {{ money = 'cash', amount = 1} },
        getitem = { { item = 'coca_leaf', amount = 5} },
        progress = {
            duration = 5000,
            label = 'Collecting',
            canCancel = true,
            disable = {
                movement = true,
                car = true,
            },
        },
        blip = {
            name = 'Coke',
            coords = vec3(-335.5667, -2449.2004, 7.3581),
            sprite = 497,
            color = 4,
            scale = 0.5,
        },
    },
    {
        label = '[E] - Proccess Coke Leaves',
        donelabel = 'Proccessed Coke Leaves',
        coords = vec3(-330.3773, -2442.8318, 7.3581),
        distance = 2,
        removeitem = { { item = 'coca_leaf', amount = 5} },
        getitem = { {item = 'coke', amount = 1} },
        progress = {
            duration = 5000,
            label = 'Collecting',
            canCancel = true,
            disable = {
                movement = true,
                car = true,
            },
        },
    },
    {
        label = '[E] - Package Coke',
        donelabel = 'Packaged Coke',
        coords = vec3(-323.9514, -2441.3103, 7.3581),
        distance = 2,
        removeitem = { {item = 'coke', amount = 1}, {item = 'empty_weed_bag', amount = 1} },
        getitem = { {item = 'cokebaggy', amount = 1} },
        progress = {
            duration = 5000,
            label = 'Collecting',
            canCancel = true,
            disable = {
                movement = true,
                car = true,
            },
        },
    },
}