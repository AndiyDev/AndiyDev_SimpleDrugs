# AndiyDev SimpleDrugs (v1.0.3)
* A lightweight, modular, and framework-agnostic drug creation system. Built to work seamlessly with ESX, QBCore, and QBX through the specialized andiydev_bridge.

## 🚀 Features
* Multi-Framework: Automatic detection for ESX, QB, and QBX.
* Inventory Agnostic: Works with ox_inventory, qb-inventory, and standard ESX systems.
* Secure: Double-validation logic to prevent item-dropping exploits.
* Anti-Spam: isBusy state handling to prevent progress bar stacking.
* Clean Config: Easily add new collection or processing points.

## How to Add New Drug Locations

```
{
    label = '[E] - Action Name',      -- Text displayed on screen
    donelabel = 'Task Complete!',     -- (Optional) Notification text on success
    coords = vec3(0.0, 0.0, 0.0),     -- Location coordinates
    distance = 5,                     -- (Optional) Interaction radius
    removeitem = {                    -- (Optional) Required items to start
        { item = 'required_item', amount = 1 } 
    },
    getitem = {                       -- (Optional) Reward items
        { item = 'reward_item', amount = 1 } 
    },
    progress = {                      -- (Optional) Progress bar settings
        time = 5,                     -- Duration in seconds
        label = 'Working...',         -- Progress bar text
        anim = {                      -- (Optional) Animation settings
            dict = 'anim_dict',
            clip = 'anim_clip',
        },
    },
},
```