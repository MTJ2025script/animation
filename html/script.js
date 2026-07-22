/* ═══════════════════════════════════════════
   MTJ Animation System – script.js
   UI Logic: categories, search, favorites, emote play
═══════════════════════════════════════════ */

'use strict';

// ─────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────
let allEmotes     = [];
let allCategories = [];
let favorites     = [];
let activeIndex   = null;
let currentCat    = 'all';
let searchQuery   = '';
let locale        = {};

// ─────────────────────────────────────────────────
// DOM refs
// ─────────────────────────────────────────────────
const overlay      = document.getElementById('overlay');
const menuTitle    = document.getElementById('menu-title');
const searchInput  = document.getElementById('search-input');
const clearSearch  = document.getElementById('clear-search');
const categoryTabs = document.getElementById('category-tabs');
const emoteGrid    = document.getElementById('emote-grid');
const noResults    = document.getElementById('no-results');
const activeLabel  = document.getElementById('active-label');
const stopBtn      = document.getElementById('stop-btn');
const closeBtn     = document.getElementById('close-btn');

// ─────────────────────────────────────────────────
// Message Bus (FiveM NUI ↔ JS)
// ─────────────────────────────────────────────────
window.addEventListener('message', (e) => {
    const data = e.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'openMenu':
            openMenu(data);
            break;
        case 'closeMenu':
            closeMenu();
            break;
        case 'updateFavorites':
            favorites = Array.isArray(data.favorites) ? data.favorites : [];
            renderGrid();
            break;
        case 'setActiveEmote':
            setActiveEmote(data.index);
            break;
        case 'clearActive':
            clearActive();
            break;
    }
});

// ─────────────────────────────────────────────────
// Open / Close
// ─────────────────────────────────────────────────
function openMenu(data) {
    allEmotes     = data.emotes     || [];
    allCategories = data.categories || [];
    favorites     = Array.isArray(data.favorites) ? data.favorites : [];
    locale        = data.locale     || {};

    // Apply locale strings
    if (locale.menu_title)  menuTitle.textContent       = locale.menu_title;
    if (locale.search_hint) searchInput.placeholder     = locale.search_hint;
    if (locale.no_results)  noResults.querySelector('p').textContent = locale.no_results;

    currentCat   = 'all';
    searchQuery  = '';
    searchInput.value = '';
    clearSearch.classList.add('hidden');

    renderCategories();
    renderGrid();

    overlay.classList.remove('hidden');
    searchInput.focus();
}

function closeMenu() {
    overlay.classList.add('hidden');
    postAction('close');
}

// ─────────────────────────────────────────────────
// Category Tabs
// ─────────────────────────────────────────────────
function renderCategories() {
    categoryTabs.innerHTML = '';

    allCategories.forEach((cat) => {
        const btn = document.createElement('button');
        btn.className = 'cat-tab' + (cat.id === currentCat ? ' active' : '');
        btn.dataset.id = cat.id;
        btn.innerHTML = `<span class="cat-icon">${cat.icon}</span> ${escapeHtml(cat.label)}`;
        btn.addEventListener('click', () => selectCategory(cat.id));
        categoryTabs.appendChild(btn);
    });
}

function selectCategory(catId) {
    currentCat = catId;
    searchQuery = '';
    searchInput.value = '';
    clearSearch.classList.add('hidden');

    // Update active tab style
    document.querySelectorAll('.cat-tab').forEach((btn) => {
        btn.classList.toggle('active', btn.dataset.id === catId);
    });

    renderGrid();
}

// ─────────────────────────────────────────────────
// Emote Grid
// ─────────────────────────────────────────────────
function renderGrid() {
    const filtered = getFilteredEmotes();

    emoteGrid.innerHTML = '';

    if (filtered.length === 0) {
        noResults.classList.remove('hidden');
        return;
    }

    noResults.classList.add('hidden');

    filtered.forEach(({ emote, index }) => {
        const card = buildCard(emote, index);
        emoteGrid.appendChild(card);
    });
}

function getFilteredEmotes() {
    const q = searchQuery.toLowerCase().trim();

    return allEmotes
        .map((emote, i) => ({ emote, index: i + 1 })) // 1-based for Lua
        .filter(({ emote, index }) => {
            // Category filter
            if (currentCat === 'favorites') {
                if (!favorites.includes(index)) return false;
            } else if (currentCat !== 'all') {
                if (emote.category !== currentCat) return false;
            }

            // Search filter
            if (q) {
                const label = (emote.label || '').toLowerCase();
                const cat   = (emote.category || '').toLowerCase();
                if (!label.includes(q) && !cat.includes(q)) return false;
            }

            return true;
        });
}

function buildCard(emote, index) {
    const isFav  = favorites.includes(index);
    const isActive = activeIndex === index;

    const card = document.createElement('div');
    card.className = 'emote-card' + (isActive ? ' active' : '');
    card.dataset.index = index;

    const icon      = getEmoteIcon(emote);
    const typeLabel = getTypeLabel(emote.type);

    card.innerHTML = `
        <span class="emote-icon">${icon}</span>
        <span class="emote-label">${escapeHtml(emote.label || 'Unbekannt')}</span>
        <span class="emote-type-badge ${escapeHtml(emote.type || '')}">${typeLabel}</span>
        <button class="fav-btn${isFav ? ' is-fav' : ''}" title="${isFav ? 'Favorit entfernen' : 'Favorit'}" data-index="${index}">
            ${isFav ? '★' : '☆'}
        </button>
    `;

    // Play emote on card click (not fav button)
    card.addEventListener('click', (e) => {
        if (e.target.classList.contains('fav-btn')) return;
        playEmote(index, emote);
    });

    // Toggle favorite
    card.querySelector('.fav-btn').addEventListener('click', (e) => {
        e.stopPropagation();
        toggleFavorite(index);
    });

    return card;
}

// ─────────────────────────────────────────────────
// Emote Actions
// ─────────────────────────────────────────────────
function playEmote(index, emote) {
    if (activeIndex === index) {
        stopEmote();
        return;
    }

    activeIndex = index;
    updateFooter(emote);
    highlightCard(index);
    postAction('playEmote', { index });
}

function stopEmote() {
    clearActive();
    postAction('stopEmote');
}

function setActiveEmote(index) {
    activeIndex = index;
    const emote = allEmotes[index - 1];
    if (emote) updateFooter(emote);
    highlightCard(index);
}

function clearActive() {
    activeIndex = null;
    activeLabel.innerHTML = '–';
    stopBtn.classList.add('hidden');
    document.querySelectorAll('.emote-card.active').forEach(c => c.classList.remove('active'));
}

function updateFooter(emote) {
    activeLabel.innerHTML = `<span class="playing-dot"></span>${escapeHtml(emote.label || '')}`;
    stopBtn.classList.remove('hidden');
}

function highlightCard(index) {
    document.querySelectorAll('.emote-card').forEach(c => c.classList.remove('active'));
    const card = emoteGrid.querySelector(`[data-index="${index}"]`);
    if (card) card.classList.add('active');
}

// ─────────────────────────────────────────────────
// Favorites
// ─────────────────────────────────────────────────
function toggleFavorite(index) {
    const pos = favorites.indexOf(index);
    if (pos === -1) {
        if (favorites.length >= 16) favorites.shift();
        favorites.push(index);
    } else {
        favorites.splice(pos, 1);
    }

    postAction('saveFavorites', { favorites });
    renderGrid();
}

// ─────────────────────────────────────────────────
// Search
// ─────────────────────────────────────────────────
searchInput.addEventListener('input', () => {
    searchQuery = searchInput.value;
    clearSearch.classList.toggle('hidden', !searchQuery);
    renderGrid();
});

clearSearch.addEventListener('click', () => {
    searchQuery = '';
    searchInput.value = '';
    clearSearch.classList.add('hidden');
    searchInput.focus();
    renderGrid();
});

// ─────────────────────────────────────────────────
// Controls
// ─────────────────────────────────────────────────
closeBtn.addEventListener('click', closeMenu);

stopBtn.addEventListener('click', stopEmote);

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeMenu();
});

// ─────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────
function postAction(action, data = {}) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
    }).catch(() => {});
}

function getEmoteIcon(emote) {
    if (emote.type === 'prop')     return '🎸';
    if (emote.type === 'scenario') return '🎬';
    if (emote.category === 'dance')   return '🎵';
    if (emote.category === 'sit')     return '🪑';
    if (emote.category === 'greet')   return '👋';
    if (emote.category === 'fun')     return '🎉';
    if (emote.category === 'taunt')   return '😤';
    if (emote.category === 'idle')    return '🧍';
    if (emote.category === 'couple')  return '👫';
    return '▶';
}

function getTypeLabel(type) {
    const map = { scenario: 'Szenario', anim: 'Anim', prop: 'Prop', couple: 'Duo' };
    return map[type] || type || '';
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

// FiveM NUI helper
function GetParentResourceName() {
    return window.GetParentResourceName ? window.GetParentResourceName() : 'animation';
}
