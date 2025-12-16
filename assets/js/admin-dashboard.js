/**
 * Admin Dashboard JavaScript
 */

// Load dashboard on page load
document.addEventListener('DOMContentLoaded', function() {
    loadDashboardStats();
    loadPendingDoctors();
    loadPendingHospitals();
    loadPendingClinics();
    loadPendingPharmacies();
});

/**
 * Load dashboard statistics
 */
async function loadDashboardStats() {
    try {
        const response = await fetch('backend/admin/stats.php');
        const data = await response.json();
        
        if (data.success) {
            document.getElementById('total-doctors').textContent = data.stats.total_doctors;
            document.getElementById('total-hospitals').textContent = data.stats.total_hospitals_clinics;
            document.getElementById('total-patients').textContent = data.stats.total_patients;
            document.getElementById('pending-requests').textContent = data.stats.pending_requests;
        }
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

/**
 * Load pending doctor registrations
 */
async function loadPendingDoctors() {
    await loadPendingRequests('doctors', 'pending-doctors-content');
}

/**
 * Load pending hospital registrations
 */
async function loadPendingHospitals() {
    await loadPendingRequests('hospitals', 'pending-hospitals-content');
}

/**
 * Load pending clinic registrations
 */
async function loadPendingClinics() {
    await loadPendingRequests('clinics', 'pending-clinics-content');
}

/**
 * Load pending pharmacy registrations
 */
async function loadPendingPharmacies() {
    await loadPendingRequests('pharmacies', 'pending-pharmacies-content');
}

/**
 * Generic function to load pending requests
 */
async function loadPendingRequests(type, contentId) {
    try {
        const response = await fetch(`backend/admin/pending_requests.php?type=${type}`);
        const data = await response.json();
        
        const contentDiv = document.getElementById(contentId);
        
        if (data.success && data.requests.length > 0) {
            let html = '<table class="data-table"><thead><tr>';
            
            // Table headers based on type
            if (type === 'doctors') {
                html += '<th>Name</th><th>Email</th><th>Specialization</th><th>Degree</th><th>Reg. No.</th><th>Submitted</th><th>Actions</th>';
            } else if (type === 'hospitals' || type === 'clinics') {
                html += '<th>Name</th><th>Email</th><th>License No.</th><th>Type</th><th>Address</th><th>Submitted</th><th>Actions</th>';
            } else if (type === 'pharmacies') {
                html += '<th>Name</th><th>Email</th><th>License No.</th><th>Owner</th><th>Address</th><th>Submitted</th><th>Actions</th>';
            }
            
            html += '</tr></thead><tbody>';
            
            // Table rows
            data.requests.forEach(request => {
                html += '<tr>';
                
                if (type === 'doctors') {
                    html += `
                        <td>${request.full_name}</td>
                        <td>${request.email}</td>
                        <td>${request.specialization}</td>
                        <td>${request.medical_degree}</td>
                        <td>${request.registration_no}</td>
                        <td>${new Date(request.submitted_at).toLocaleDateString()}</td>
                    `;
                } else if (type === 'hospitals') {
                    html += `
                        <td>${request.name}</td>
                        <td>${request.email}</td>
                        <td>${request.license_number}</td>
                        <td><span class="badge badge-primary">${request.type}</span></td>
                        <td>${request.address.substring(0, 30)}...</td>
                        <td>${new Date(request.submitted_at).toLocaleDateString()}</td>
                    `;
                } else if (type === 'clinics') {
                    html += `
                        <td>${request.name}</td>
                        <td>${request.email}</td>
                        <td>${request.license_number}</td>
                        <td><span class="badge badge-secondary">Clinic</span></td>
                        <td>${request.address.substring(0, 30)}...</td>
                        <td>${new Date(request.submitted_at).toLocaleDateString()}</td>
                    `;
                } else if (type === 'pharmacies') {
                    html += `
                        <td>${request.name}</td>
                        <td>${request.email}</td>
                        <td>${request.drug_license_number}</td>
                        <td>${request.owner_name}</td>
                        <td>${request.address.substring(0, 30)}...</td>
                        <td>${new Date(request.submitted_at).toLocaleDateString()}</td>
                    `;
                }
                
                html += `
                    <td class="action-buttons">
                        <button class="btn btn-sm btn-secondary" onclick='viewDetails(${JSON.stringify(request)}, "${type}")'>View</button>
                        <button class="btn btn-sm btn-primary" onclick="approveRequest(${request.id}, '${type}')">Approve</button>
                        <button class="btn btn-sm btn-danger" onclick="rejectRequest(${request.id}, '${type}')">Reject</button>
                    </td>
                </tr>
                `;
            });
            
            html += '</tbody></table>';
            contentDiv.innerHTML = html;
        } else {
            contentDiv.innerHTML = '<p class="text-center text-muted">No pending requests</p>';
        }
    } catch (error) {
        console.error(`Error loading ${type}:`, error);
        document.getElementById(contentId).innerHTML = '<p class="alert alert-danger">Error loading data</p>';
    }
}

/**
 * Approve a provider request
 */
async function approveRequest(id, type) {
    if (!confirm('Are you sure you want to approve this request?')) {
        return;
    }
    
    try {
        const response = await fetch('backend/admin/approve.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ id, type })
        });
        
        const data = await response.json();
        
        if (data.success) {
            alert('Provider approved successfully!');
            // Reload the appropriate section
            if (type === 'doctors') loadPendingDoctors();
            else if (type === 'hospitals') loadPendingHospitals();
            else if (type === 'clinics') loadPendingClinics();
            else if (type === 'pharmacies') loadPendingPharmacies();
            
            loadDashboardStats();
        } else {
            alert('Error: ' + (data.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error approving request:', error);
        alert('An error occurred while approving the request');
    }
}

/**
 * Reject a provider request
 */
async function rejectRequest(id, type) {
    if (!confirm('Are you sure you want to reject this request?')) {
        return;
    }
    
    try {
        const response = await fetch('backend/admin/reject.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ id, type })
        });
        
        const data = await response.json();
        
        if (data.success) {
            alert('Provider rejected');
            // Reload the appropriate section
            if (type === 'doctors') loadPendingDoctors();
            else if (type === 'hospitals') loadPendingHospitals();
            else if (type === 'clinics') loadPendingClinics();
            else if (type === 'pharmacies') loadPendingPharmacies();
            
            loadDashboardStats();
        } else {
            alert('Error: ' + (data.error || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error rejecting request:', error);
        alert('An error occurred while rejecting the request');
    }
}

/**
 * View provider details in modal
 */
function viewDetails(provider, type) {
    const modal = document.getElementById('detailModal');
    const modalBody = document.getElementById('modal-body');
    
    let html = '<div class="form-group">';
    
    if (type === 'doctors') {
        html += `
            <p><strong>Full Name:</strong> ${provider.full_name}</p>
            <p><strong>Email:</strong> ${provider.email}</p>
            <p><strong>Phone:</strong> ${provider.phone}</p>
            <p><strong>Medical Degree:</strong> ${provider.medical_degree}</p>
            <p><strong>Registration No:</strong> ${provider.registration_no}</p>
            <p><strong>Specialization:</strong> ${provider.specialization}</p>
            <p><strong>Experience:</strong> ${provider.experience_years} years</p>
            <p><strong>Consultation Fee:</strong> BDT ${provider.consultation_fee}</p>
            <p><strong>Available Days:</strong> ${provider.available_days || 'Not specified'}</p>
            <p><strong>Available Time:</strong> ${provider.available_time || 'Not specified'}</p>
        `;
        
        if (provider.profile_photo) {
            html += `<p><strong>Profile Photo:</strong> <a href="${provider.profile_photo}" target="_blank">View Document</a></p>`;
        }
        if (provider.degree_certificate) {
            html += `<p><strong>Degree Certificate:</strong> <a href="${provider.degree_certificate}" target="_blank">View Document</a></p>`;
        }
    } else if (type === 'hospitals' || type === 'clinics') {
        html += `
            <p><strong>Name:</strong> ${provider.name}</p>
            <p><strong>Email:</strong> ${provider.email}</p>
            <p><strong>Phone:</strong> ${provider.phone}</p>
            <p><strong>License Number:</strong> ${provider.license_number}</p>
            ${type === 'hospitals' ? `<p><strong>Type:</strong> ${provider.type}</p>` : ''}
            <p><strong>Address:</strong> ${provider.address}</p>
            <p><strong>Departments/Services:</strong> ${provider.departments || 'Not specified'}</p>
            <p><strong>Operating Hours:</strong> ${provider.operating_hours || 'Not specified'}</p>
        `;
        
        if (provider.license_document) {
            html += `<p><strong>License Document:</strong> <a href="${provider.license_document}" target="_blank">View Document</a></p>`;
        }
    } else if (type === 'pharmacies') {
        html += `
            <p><strong>Name:</strong> ${provider.name}</p>
            <p><strong>Email:</strong> ${provider.email}</p>
            <p><strong>Phone:</strong> ${provider.phone}</p>
            <p><strong>Drug License Number:</strong> ${provider.drug_license_number}</p>
            <p><strong>Owner Name:</strong> ${provider.owner_name}</p>
            <p><strong>Address:</strong> ${provider.address}</p>
            <p><strong>Operating Hours:</strong> ${provider.operating_hours || 'Not specified'}</p>
        `;
        
        if (provider.license_document) {
            html += `<p><strong>License Document:</strong> <a href="${provider.license_document}" target="_blank">View Document</a></p>`;
        }
    }
    
    html += `<p><strong>Submitted:</strong> ${new Date(provider.submitted_at).toLocaleString()}</p>`;
    html += '</div>';
    
    modalBody.innerHTML = html;
    modal.classList.add('active');
}

/**
 * Close modal
 */
function closeModal() {
    const modal = document.getElementById('detailModal');
    modal.classList.remove('active');
}

// Close modal on outside click
window.onclick = function(event) {
    const modal = document.getElementById('detailModal');
    if (event.target === modal) {
        closeModal();
    }
}
