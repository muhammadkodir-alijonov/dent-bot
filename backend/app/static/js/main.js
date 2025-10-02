// Stomatologiya Klinika JavaScript Functions

document.addEventListener('DOMContentLoaded', function() {
    // Search functionality
    const searchForm = document.getElementById('searchForm');
    const searchInput = document.getElementById('searchInput');
    
    if (searchForm) {
        searchForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const query = searchInput.value.trim();
            if (query) {
                window.location.href = `/search?q=${encodeURIComponent(query)}`;
            }
        });
    }
    
    // Real-time search (optional)
    if (searchInput) {
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                const query = this.value.trim();
                if (query.length >= 3) {
                    // Perform live search
                    performLiveSearch(query);
                }
            }, 500);
        });
    }
    
    // Category filter active state
    const categoryButtons = document.querySelectorAll('.category-btn');
    categoryButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            categoryButtons.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
        });
    });
    
    // Image lazy loading
    const images = document.querySelectorAll('img[data-src]');
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.removeAttribute('data-src');
                imageObserver.unobserve(img);
            }
        });
    });
    
    images.forEach(img => imageObserver.observe(img));
    
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // Form validation
    const forms = document.querySelectorAll('.needs-validation');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            if (!form.checkValidity()) {
                e.preventDefault();
                e.stopPropagation();
            }
            form.classList.add('was-validated');
        });
    });
    
    // Admin panel specific functions
    initAdminFunctions();
    
    // Initialize tooltips and popovers
    if (typeof bootstrap !== 'undefined') {
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
        
        var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
        var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
            return new bootstrap.Popover(popoverTriggerEl);
        });
    }
});

// Live search function
async function performLiveSearch(query) {
    try {
        const response = await fetch(`/api/items?search=${encodeURIComponent(query)}`);
        if (response.ok) {
            const items = await response.json();
            updateSearchResults(items);
        }
    } catch (error) {
        console.error('Search error:', error);
    }
}

// Update search results
function updateSearchResults(items) {
    const resultsContainer = document.getElementById('itemsContainer');
    if (!resultsContainer) return;
    
    if (items.length === 0) {
        resultsContainer.innerHTML = `
            <div class="col-12 text-center py-5">
                <h4>Hech narsa topilmadi</h4>
                <p class="text-muted">Boshqa kalit so'zlar bilan qidiring</p>
            </div>
        `;
        return;
    }
    
    resultsContainer.innerHTML = items.map(item => createItemCard(item)).join('');
}

// Create item card HTML
function createItemCard(item) {
    const formatPrice = (price) => {
        return new Intl.NumberFormat('uz-UZ').format(price) + " So'm";
    };
    
    return `
        <div class="col-lg-4 col-md-6 mb-4">
            <div class="card item-card h-100">
                ${item.image_url ? 
                    `<img src="${item.image_url}" class="item-image" alt="${item.name}">` :
                    `<div class="item-placeholder">🦷</div>`
                }
                <div class="card-body item-card-body">
                    <h5 class="item-title">${item.name}</h5>
                    <div class="item-price">${formatPrice(item.price)}</div>
                    <p class="item-description">${item.description}</p>
                    <div class="item-details">
                        <small>⏱️ Davomiylik: ${item.duration}</small><br>
                        <small>📅 Seanslar: ${item.min_sessions}-${item.max_sessions}</small>
                    </div>
                    <a href="/item/${item.id}" class="btn btn-details mt-3">
                        Batafsil ko'rish
                    </a>
                </div>
            </div>
        </div>
    `;
}

// Admin panel functions
function initAdminFunctions() {
    // Delete confirmation
    const deleteButtons = document.querySelectorAll('.btn-delete');
    deleteButtons.forEach(btn => {
        btn.addEventListener('click', function(e) {
            if (!confirm('Rostdan ham o\'chirmoqchimisiz?')) {
                e.preventDefault();
            }
        });
    });
    
    // Image preview
    const imageInputs = document.querySelectorAll('input[type="file"][accept*="image"]');
    imageInputs.forEach(input => {
        input.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    let preview = document.getElementById('imagePreview');
                    if (!preview) {
                        preview = document.createElement('img');
                        preview.id = 'imagePreview';
                        preview.className = 'img-thumbnail mt-2';
                        preview.style.maxWidth = '200px';
                        input.parentNode.appendChild(preview);
                    }
                    preview.src = e.target.result;
                };
                reader.readAsDataURL(file);
            }
        });
    });
    
    // Auto-resize textareas
    const textareas = document.querySelectorAll('textarea');
    textareas.forEach(textarea => {
        textarea.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = this.scrollHeight + 'px';
        });
    });
}

// Price formatting function
function formatPrice(price) {
    return new Intl.NumberFormat('uz-UZ').format(price) + " So'm";
}

// Show loading spinner
function showLoading(container) {
    if (container) {
        container.innerHTML = `
            <div class="loading">
                <div class="spinner"></div>
            </div>
        `;
    }
}

// Hide loading spinner
function hideLoading() {
    const loadingElements = document.querySelectorAll('.loading');
    loadingElements.forEach(el => el.remove());
}

// Telegram Web App integration
if (window.Telegram && window.Telegram.WebApp) {
    const tg = window.Telegram.WebApp;
    
    // Initialize Telegram Web App
    tg.ready();
    tg.expand();
    
    // Set theme
    document.documentElement.style.setProperty('--tg-theme-bg-color', tg.themeParams.bg_color || '#ffffff');
    document.documentElement.style.setProperty('--tg-theme-text-color', tg.themeParams.text_color || '#000000');
    
    // Handle back button
    tg.BackButton.onClick(() => {
        history.back();
    });
    
    // Show back button on detail pages
    if (window.location.pathname.includes('/item/')) {
        tg.BackButton.show();
    }
}

// Export functions for use in other scripts
window.StomApp = {
    formatPrice,
    showLoading,
    hideLoading,
    performLiveSearch,
    updateSearchResults
};