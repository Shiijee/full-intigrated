function toggleUserMenu() {
    const dropdown = document.getElementById('user-dropdown');
    if (dropdown) {
        dropdown.classList.toggle('active');
        
        // On mobile, prevent body scroll when dropdown is open
        if (window.innerWidth <= 768) {
            if (dropdown.classList.contains('active')) {
                document.body.style.overflow = 'hidden';
            } else {
                document.body.style.overflow = '';
            }
        }
    }
}

// Close dropdown when clicking outside on mobile
document.addEventListener('click', function(event) {
    const dropdown = document.getElementById('user-dropdown');
    const burgerBtn = document.querySelector('.burger-btn');
    
    if (dropdown && dropdown.classList.contains('active')) {
        if (!dropdown.contains(event.target) && !burgerBtn.contains(event.target)) {
            dropdown.classList.remove('active');
            if (window.innerWidth <= 768) {
                document.body.style.overflow = '';
            }
        }
    }
});

// Handle escape key to close dropdown on mobile
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const dropdown = document.getElementById('user-dropdown');
        if (dropdown && dropdown.classList.contains('active')) {
            dropdown.classList.remove('active');
            if (window.innerWidth <= 768) {
                document.body.style.overflow = '';
            }
        }
    }
});

// Reset body overflow on window resize
window.addEventListener('resize', function() {
    if (window.innerWidth > 768) {
        document.body.style.overflow = '';
    }
});

function toggleAccordion(button) {
    const accordion = button.closest('.nav-accordion');
    if (accordion) {
        accordion.classList.toggle('open');
    }
}

function ensureMobileSidebar() {
    if (document.querySelector('.mobile-sidebar-drawer')) {
        return;
    }

    const sidebar = document.querySelector('.sidebar');
    if (!sidebar) {
        return;
    }

    const nav = sidebar.querySelector('.sidebar-nav');
    const logoLink = sidebar.querySelector('.sidebar-logo .logo-link');
    const drawer = document.createElement('div');
    drawer.className = 'mobile-sidebar-drawer';

    const brandMarkup = logoLink ? logoLink.outerHTML : '<span>Menu</span>';
    drawer.innerHTML = `
        <div class="mobile-sidebar-header">
            <div class="mobile-sidebar-brand">${brandMarkup}</div>
            <button type="button" class="mobile-sidebar-close" aria-label="Close menu">
                <i class="fas fa-times"></i>
            </button>
        </div>
        ${nav ? nav.outerHTML : ''}
    `;

    document.body.appendChild(drawer);

    const closeButton = drawer.querySelector('.mobile-sidebar-close');
    if (closeButton) {
        closeButton.addEventListener('click', closeSidebar);
    }

    // Ensure there is a logout button at the bottom of the drawer's navigation
    const drawerNav = drawer.querySelector('.sidebar-nav');
    if (drawerNav) {
        // Remove any existing duplicate mobile logout links first to prevent duplication
        const existingLogouts = drawerNav.querySelectorAll('.sidebar-mobile-logout');
        existingLogouts.forEach(el => el.remove());

        // Create a new logout link at the bottom of the mobile sidebar navigation
        const logoutLink = document.createElement('a');
        logoutLink.href = '/logout';
        logoutLink.className = 'nav-item sidebar-mobile-logout';
        logoutLink.innerHTML = '<i class="fas fa-right-from-bracket"></i><span class="nav-item-text"> Logout</span>';
        
        // Add click listener to trigger the logout modal
        logoutLink.addEventListener('click', function(e) {
            e.preventDefault();
            if (typeof window.showLogoutModal === 'function') {
                window.showLogoutModal(e);
            } else {
                window.location.href = '/logout';
            }
        });

        drawerNav.appendChild(logoutLink);
    }

    drawer.querySelectorAll('.nav-item:not(.sidebar-mobile-logout)').forEach(function (link) {
        link.addEventListener('click', function () {
            if (window.innerWidth <= 1024) {
                closeSidebar();
            }
        });
    });

    const overlay = document.createElement('div');
    overlay.className = 'mobile-sidebar-overlay';
    overlay.addEventListener('click', closeSidebar);
    document.body.appendChild(overlay);
}

function closeSidebar() {
    const drawer = document.querySelector('.mobile-sidebar-drawer');
    const overlay = document.querySelector('.mobile-sidebar-overlay');

    if (drawer) {
        drawer.classList.remove('open');
    }

    if (overlay) {
        overlay.classList.remove('active');
    }

    document.body.classList.remove('sidebar-open');
    document.body.style.overflow = '';
}

function toggleSidebar() {
    ensureMobileSidebar();

    const drawer = document.querySelector('.mobile-sidebar-drawer');
    const overlay = document.querySelector('.mobile-sidebar-overlay');

    if (!drawer) {
        return;
    }

    const isOpen = drawer.classList.toggle('open');
    if (overlay) {
        overlay.classList.toggle('active', isOpen);
    }

    document.body.classList.toggle('sidebar-open', isOpen && window.innerWidth <= 1024);
    document.body.style.overflow = isOpen && window.innerWidth <= 1024 ? 'hidden' : '';
}

function toggleSidebarMinimize() {
    const sidebar = document.querySelector('.sidebar');
    if (sidebar) {
        sidebar.classList.toggle('minimized');
        // Persist state across page loads
        localStorage.setItem('sidebarMinimized', sidebar.classList.contains('minimized') ? '1' : '0');
    }
}

function bindSidebarControls() {
    ensureMobileSidebar();

    document.querySelectorAll('.sidebar-toggle').forEach(button => {
        if (button.dataset.sidebarBound === 'true') return;

        button.dataset.sidebarBound = 'true';
        button.onclick = null;
        button.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            toggleSidebar();
        });
    });

    const overlay = document.querySelector('.mobile-sidebar-overlay');
    if (overlay) {
        overlay.addEventListener('click', function() {
            closeSidebar();
        });
    }
}

// Close dropdown or sidebar when clicking outside
window.addEventListener('click', function(e) {
    const dropdown = document.getElementById('user-dropdown');
    const burger = document.querySelector('.burger-btn');
    const sidebar = document.querySelector('.sidebar');
    const overlay = document.querySelector('.sidebar-overlay');
    const toggleButton = document.querySelector('.sidebar-toggle');

    // Handle User Dropdown
    if (dropdown && dropdown.classList.contains('active')) {
        if (!dropdown.contains(e.target) && (!burger || !burger.contains(e.target))) {
            dropdown.classList.remove('active');
        }
    }

    // Handle Sidebar Overlay click
    if (overlay && overlay.contains(e.target)) {
        closeSidebar();
    }

    if (toggleButton && toggleButton.contains(e.target)) {
        e.stopPropagation();
    }
});

window.addEventListener('resize', function() {
    if (window.innerWidth > 1024) {
        closeSidebar();
    } else if (!document.querySelector('.mobile-sidebar-drawer')?.classList.contains('open')) {
        document.body.classList.remove('sidebar-open');
        document.body.style.overflow = '';
    }
});

// Global Loading & Transition Logic
function initializeGlobalUi() {
    // Inject UI elements (Guard against multiple injections if script is loaded twice)
    if (!document.getElementById('loading-overlay')) {
        const extraUI = `
            <div id="loading-overlay">
                <div class="spinner-container">
                    <div class="spinner-ring"></div>
                    <div class="spinner-ring"></div>
                </div>
                <div class="loading-text">Attendeez Loading...</div>
            </div>
            <div class="sidebar-overlay"></div>
        `;
        document.body.insertAdjacentHTML('beforeend', extraUI);
    }

    bindSidebarControls();

    const loader = document.getElementById('loading-overlay');
    let loaderTimeout = null;

    function showLoader() {
        if (loader) {
            loader.style.display = 'flex';
        }
        if (loaderTimeout) clearTimeout(loaderTimeout);
        loaderTimeout = setTimeout(() => {
            if (loader) loader.style.display = 'none';
            loaderTimeout = null;
        }, 8000);
    }

    function hideLoader() {
        if (loader) loader.style.display = 'none';
        if (loaderTimeout) { clearTimeout(loaderTimeout); loaderTimeout = null; }
    }

    // Show loader ONLY on full-page navigation (leaving the page)
    window.addEventListener('beforeunload', () => {
        showLoader();
    });

    // Add click feedback to all buttons and nav items (subtle scale only)
    const interactiveElements = document.querySelectorAll('.btn, .nav-item, .class-card, .subject-card');
    interactiveElements.forEach(el => {
        el.addEventListener('click', function() {
            this.style.transform = 'scale(0.97)';
            setTimeout(() => {
                this.style.transform = '';
            }, 120);
        });
    });

    // Sidebar scroll support: ensure scrollbar shows when nav overflows
    const sidebar = document.querySelector('.sidebar');
    if (sidebar) {
        sidebar.style.overflowY = 'auto';
        sidebar.style.scrollbarWidth = 'thin';

        // Restore minimized state on mobile (≤1024px)
        if (window.innerWidth <= 1024 && localStorage.getItem('sidebarMinimized') === '1') {
            sidebar.classList.add('minimized');
        }
    }
}

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeGlobalUi);
} else {
    initializeGlobalUi();
}

window.addEventListener('DOMContentLoaded', bindSidebarControls);

document.addEventListener('DOMContentLoaded', function() {

    // --- GO BACK CONFIRMATION MODAL ---
    const logoutModalHTML = `
        <div id="logout-modal-overlay" class="modal-overlay">
            <div class="confirm-modal">
                <div class="modal-icon">
                    <i class="fas fa-arrow-left"></i>
                </div>
                <h3 class="modal-title">Confirm Go Back</h3>
                <p class="modal-text">Are you sure you want to go back to the portal?</p>
                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeLogoutModal()">Cancel</button>
                    <a href="http://127.0.0.1:5000" class="btn-confirm-logout">Go Back</a>
                </div>
            </div>
        </div>
    `;

    if (!document.getElementById('logout-modal-overlay')) {
        document.body.insertAdjacentHTML('beforeend', logoutModalHTML);
    }

    window.closeLogoutModal = function() {
        document.getElementById('logout-modal-overlay').classList.remove('active');
    };

    window.showLogoutModal = function(e) {
        if (e) e.preventDefault();
        document.getElementById('logout-modal-overlay').classList.add('active');
    };

    // Intercept all go-back links EXCEPT the one in the modal
    const logoutLinks = document.querySelectorAll('a.go-back-link');
    logoutLinks.forEach(link => {
        link.addEventListener('click', showLogoutModal);
    });

});


