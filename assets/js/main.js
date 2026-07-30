/**
 * Main JavaScript for Ayur Healthcare Platform
 */

// Mobile menu toggle (for future responsive implementation)
document.addEventListener('DOMContentLoaded', function() {
    console.log('Ayur Healthcare Platform - Ready');
    
    // Smooth scroll for anchor links
    const anchorLinks = document.querySelectorAll('a[href^="#"]');
    anchorLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                e.preventDefault();
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
});
