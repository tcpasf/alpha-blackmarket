let currentData = null;

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'openUI') {
        currentData = data;
        openBlackmarket(data.items, data.weapons);
    } else if (data.action === 'closeUI') {
        hideUI();
    }
});

// Function to hide the UI
function hideUI() {
    const ui = document.getElementById('blackmarket-ui');
    ui.classList.add('hidden');
    document.body.style.cursor = 'none';
}

function openBlackmarket(items, weapons) {
    const ui = document.getElementById('blackmarket-ui');
    ui.classList.remove('hidden');
    document.body.style.cursor = 'default';
    populateItems(items);
    populateWeapons(weapons);
}

function closeUI() {
    // Hide the UI first
    hideUI();
    
    // Get resource name
    const resourceName = GetParentResourceName();
    
    // Send the closeUI callback
    fetch(`https://${resourceName}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    })
    .then(response => {
        document.body.style.cursor = 'none';
    })
    .catch(error => {
        // If closeUI fails, try escapePressed as fallback
        fetch(`https://${resourceName}/escapePressed`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        })
        .then(response => {
            document.body.style.cursor = 'none';
        })
        .catch(err => {
            // Silent fail
        });
    });
    
    // Additional safety - force hide cursor multiple times
    for (let i = 1; i <= 5; i++) {
        setTimeout(() => {
            document.body.style.cursor = 'none';
        }, i * 100);
    }
}

function showTab(tabName) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));

    document.querySelector(`[onclick="showTab('${tabName}')"]`).classList.add('active');
    document.getElementById(`${tabName}-tab`).classList.add('active');
}

function populateItems(items) {
    const container = document.getElementById('items-container');
    container.innerHTML = '';

    items.forEach(item => {
        const itemCard = createItemCard(item, 'item');
        container.appendChild(itemCard);
    });
}

function populateWeapons(weapons) {
    const container = document.getElementById('weapons-container');
    container.innerHTML = '';

    weapons.forEach(weapon => {
        const weaponCard = createItemCard(weapon, 'weapon');
        container.appendChild(weaponCard);
    });
}

function createItemCard(item, type) {
    const card = document.createElement('div');
    card.className = 'item-card';
    card.setAttribute('data-name', item.label.toLowerCase());
    card.setAttribute('data-category', item.category.toLowerCase());

    card.innerHTML = `
        <div class="item-image">
            <img src="${item.image}" alt="${item.label}" onerror="this.src='https://via.placeholder.com/150x150/333/fff?text=No+Image'">
        </div>
        <div class="item-content">
            <div class="item-header">
                <div class="item-name">${item.label}</div>
                <div class="item-category">${item.category}</div>
            </div>
            <div class="item-description">${item.description}</div>
            <div class="item-price">$${item.price.toLocaleString()}</div>
            <button class="buy-btn" onclick="buyItem('${item.name}', ${item.price}, '${type}')">
                <i class="fas fa-shopping-cart"></i> Purchase
            </button>
        </div>
    `;

    return card;
}

function buyItem(itemName, price, type) {
    const endpoint = type === 'weapon' ? 'buyWeapon' : 'buyItem';
    const dataKey = type === 'weapon' ? 'weapon' : 'item';
    const resourceName = 'alpha-blackmarket'; // Hardcoded for reliability
    
    // Create the data object explicitly
    const data = {};
    data[dataKey] = itemName;
    data.price = price;
    
    // Use the direct approach
    fetch(`https://${resourceName}/${endpoint}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
    .then(response => {
        // Success - silent
    })
    .catch(error => {
        // Error - silent
    });
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});

function filterItems(type) {
    const searchInput = document.getElementById(`${type}-search`);
    const searchTerm = searchInput.value.toLowerCase();
    const container = document.getElementById(`${type}-container`);
    const cards = container.querySelectorAll('.item-card');

    cards.forEach(card => {
        const itemName = card.getAttribute('data-name');
        const itemCategory = card.getAttribute('data-category');

        if (itemName.includes(searchTerm) || itemCategory.includes(searchTerm)) {
            card.style.display = 'block';
            card.style.animation = 'fadeIn 0.3s ease-in';
        } else {
            card.style.display = 'none';
        }
    });
}

function GetParentResourceName() {
    return 'alpha-blackmarket';
}
