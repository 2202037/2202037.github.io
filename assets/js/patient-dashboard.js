/**
 * Patient Dashboard JavaScript
 */

document.addEventListener('DOMContentLoaded', function() {
    loadPatientStats();
    loadRecentAppointments();
});

/**
 * Load patient statistics
 */
async function loadPatientStats() {
    // Placeholder - will be implemented with backend API
    document.getElementById('upcoming-appointments').textContent = '0';
    document.getElementById('completed-appointments').textContent = '0';
    document.getElementById('total-reviews').textContent = '0';
    document.getElementById('total-payments').textContent = '0';
}

/**
 * Load recent appointments
 */
async function loadRecentAppointments() {
    // Placeholder - will be implemented with backend API
    const container = document.getElementById('recent-appointments');
    container.innerHTML = '<p class="text-center text-muted">No appointments yet. <a href="search.html">Book your first appointment</a></p>';
}
