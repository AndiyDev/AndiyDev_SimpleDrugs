Config = {}

Config.KeyBind = 'E'

--[[ CreateDrug information
    {
        label = '[E] - Collect Coke Leaves',
        donelabel = '', if no donelabel then remove line
        coords = vec3(),
        distance = 5,
        removeitem = { { item = '', amount = }, { item = '', amount = } }, -- if no removeitem then remove line
        getitem = { { item = '', amount = } }
        progress = { -- if not progress remove progress = {},
            time = 5, -- Seconds
            label = 'Collecting', -- Text
            anim = { -- if no anim remove anim = {},
                dict = 'anim@amb@business@coc@coc_unpack_cut@',
                clip = 'fullcut_cycle_v6_v6_player',
            },
        },
    },
]]
Config.CreatedDrug = {
    {
        label = '[E] - Collect Coke Leaves',
        donelabel = 'Collected Coke Leaves',
        coords = vec3(),
        distance = 5,
        getitem = { { item = 'cokeleaves', amount = 5} },
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
        coords = vec3(),
        distance = 5,
        removeitem = { { item = 'cokeleaves', amount = 5} },
        getitem = { {item = '1gcokepowder', amount = 1} },
        progress = {
            time = 5,
            label = 'Proccessing',
        },
    },
    {
        label = '[E] - Package Coke',
        donelabel = 'Packaged Coke',
        coords = vec3(),
        distance = 5,
        removeitem = { {item = '1gcokepowder', amount = 1}, {item = 'ziplockbag', amount = 1} },
        getitem = { {item = '1gcokebag', amount = 1} },
        progress = {
            time = 5,
            label = 'Packageing',
        },
    },
}