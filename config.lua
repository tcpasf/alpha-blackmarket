Config = {}

Config.NPC = {
    model = 'g_m_y_ballaeast_01',
    coords = vector4(705.71, -966.99, 29.4, 330.48),
    scenario = 'WORLD_HUMAN_DRUG_DEALER_HARD',
    freeze = true,
    invincible = true,
    blockevents = true
}

Config.Target = {
    icon = 'fas fa-comments',
    label = 'Talk to Agent',
    distance = 2.0
}

Config.Permissions = {
    mode = 'gang', -- all | gang | job | none
    admin = 'AlphaDev',
    allowedGangs = {
        'ballas',
        'vagos',
        'families',
        'bloods',
        'crips'
    }
}

Config.Items = {
    {
        name = 'lockpick',
        label = 'Lockpick',
        price = 150,
        category = 'tools',
        image = 'https://media.wickdev.me/36f0b677b6.png',
        description = 'Professional lockpicking tool for silent entry'
    },
    {
        name = 'thermite',
        label = 'Thermite',
        price = 2500,
        category = 'explosives',
        image = 'https://media.wickdev.me/e2a288d0b2.png',
        description = 'High-temperature explosive compound'
    },
    {
        name = 'drill',
        label = 'Drill',
        price = 5000,
        category = 'tools',
        image = 'https://media.wickdev.me/410257c548.png',
        description = 'Heavy-duty drilling equipment'
    },
    {
        name = 'laptop',
        label = 'Hacking Laptop',
        price = 7500,
        category = 'electronics',
        image = 'https://media.wickdev.me/62b4aefb53.png',
        description = 'Advanced computer for digital infiltration'
    }
}

Config.Weapons = {
    {
        name = 'weapon_pistol',
        label = 'Pistol',
        price = 15000,
        category = 'handguns',
        image = 'https://media.wickdev.me/ffb2a3368d.png',
        description = 'Standard sidearm for personal protection'
    },
    {
        name = 'weapon_combatpistol',
        label = 'Combat Pistol',
        price = 18000,
        category = 'handguns',
        image = 'https://media.wickdev.me/ccc5019616.png',
        description = 'Military-grade tactical pistol'
    },
    {
        name = 'weapon_microsmg',
        label = 'Micro SMG',
        price = 35000,
        category = 'smg',
        image = 'https://media.wickdev.me/6b6c41bf4c.png',
        description = 'Compact submachine gun for close combat'
    },
    {
        name = 'weapon_assaultrifle',
        label = 'Assault Rifle',
        price = 75000,
        category = 'rifles',
        image = 'https://media.wickdev.me/6b6c41bf4c.png',
        description = 'High-powered automatic rifle'
    }
}
