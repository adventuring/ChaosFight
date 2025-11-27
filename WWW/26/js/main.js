// Main site functionality

document.addEventListener('DOMContentLoaded', function() {
    // Initialize all systems
    // Audio and transitions are initialized in their own files
    
    // Add smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href !== '#' && href.length > 1) {
                const target = document.querySelector(href);
                if (target) {
                    e.preventDefault();
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            }
        });
    });
    
    // Add loading state management
    window.addEventListener('beforeunload', function() {
        document.body.classList.add('page-exiting');
    });
});


