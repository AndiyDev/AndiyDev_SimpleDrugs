---@class DrugItem
---@field item string The name of the item
---@field amount number The quantity of the item

---@class DrugProgress
---@field time number Duration in seconds
---@field label string The text to display on the progress bar
---@field anim? table { dict: string, clip: string } (Optional) Animation data

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

---@type DrugConfig[]
Config.CreatedDrug = {
    {
        label = '[E] - Collect Coke Leaves',
        donelabel = 'Collected Coke Leaves',
        coords = vec3(-831.0637, -1332.7664, 5.1573),
        distance = 5,
        getitem = { { item = 'coca_leaf', amount = 5} },
        progress = {
            time = 5,
            label = 'Collecting',
            anim = {
                dict = 'anim@amb@business@coc@coc_unpack_cut@',
                clip = 'fullcut_cycle_v6_v6_player',
            },
        },
    },
    {
        label = '[E] - Proccess Coke Leaves',
        donelabel = 'Proccessed Coke Leaves',
        coords = vec3(-828.0864, -1345.0702, 5.1533),
        distance = 5,
        removeitem = { { item = 'coca_leaf', amount = 5} },
        getitem = { {item = 'coke', amount = 1} },
        progress = {
            time = 5,
            label = 'Proccessing',
        },
    },
    {
        label = '[E] - Package Coke',
        donelabel = 'Packaged Coke',
        coords = vec3(-818.7264, -1335.6440, 5.1506),
        distance = 5,
        removeitem = { {item = 'coke', amount = 1}, {item = 'empty_weed_bag', amount = 1} },
        getitem = { {item = 'cokebaggy', amount = 1} },
        progress = {
            time = 5,
            label = 'Packageing',
        },
    },
}