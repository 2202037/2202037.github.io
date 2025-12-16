/**
 * Form Validation for Ayur Healthcare Platform
 */

document.addEventListener('DOMContentLoaded', function() {
    // Password confirmation validation
    const forms = document.querySelectorAll('form');
    
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            const password = form.querySelector('#password');
            const confirmPassword = form.querySelector('#confirm_password');
            
            if (password && confirmPassword) {
                if (password.value !== confirmPassword.value) {
                    e.preventDefault();
                    alert('Passwords do not match!');
                    confirmPassword.focus();
                    return false;
                }
                
                if (password.value.length < 6) {
                    e.preventDefault();
                    alert('Password must be at least 6 characters long!');
                    password.focus();
                    return false;
                }
            }
            
            // File size validation
            const fileInputs = form.querySelectorAll('input[type="file"]');
            fileInputs.forEach(input => {
                if (input.files.length > 0) {
                    const file = input.files[0];
                    const maxSize = input.accept.includes('pdf') ? 5 * 1024 * 1024 : 2 * 1024 * 1024;
                    
                    if (file.size > maxSize) {
                        e.preventDefault();
                        const maxSizeMB = maxSize / (1024 * 1024);
                        alert(`File ${file.name} is too large. Maximum size is ${maxSizeMB}MB`);
                        input.focus();
                        return false;
                    }
                }
            });
        });
    });
    
    // Email validation
    const emailInputs = document.querySelectorAll('input[type="email"]');
    emailInputs.forEach(input => {
        input.addEventListener('blur', function() {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (this.value && !emailRegex.test(this.value)) {
                this.setCustomValidity('Please enter a valid email address');
            } else {
                this.setCustomValidity('');
            }
        });
    });
    
    // Phone validation (Bangladesh format)
    const phoneInputs = document.querySelectorAll('input[type="tel"]');
    phoneInputs.forEach(input => {
        input.addEventListener('blur', function() {
            const phoneRegex = /^(\+?88)?01[0-9]{9}$/;
            if (this.value && !phoneRegex.test(this.value.replace(/[\s-]/g, ''))) {
                this.setCustomValidity('Please enter a valid phone number');
            } else {
                this.setCustomValidity('');
            }
        });
    });
    
    // Show/hide password toggle
    const passwordToggles = document.querySelectorAll('.toggle-password');
    passwordToggles.forEach(toggle => {
        toggle.addEventListener('click', function() {
            const target = document.querySelector(this.dataset.target);
            if (target.type === 'password') {
                target.type = 'text';
                this.textContent = '🙈';
            } else {
                target.type = 'password';
                this.textContent = '👁️';
            }
        });
    });
});

/**
 * Display form errors from session
 */
function displaySessionMessages() {
    // This would be populated by PHP session variables
    // For now, it's a placeholder for future implementation
}

/**
 * Confirm password match on typing
 */
function validatePasswordMatch() {
    const password = document.querySelector('#password');
    const confirmPassword = document.querySelector('#confirm_password');
    
    if (password && confirmPassword) {
        confirmPassword.addEventListener('input', function() {
            if (this.value !== password.value) {
                this.setCustomValidity('Passwords do not match');
            } else {
                this.setCustomValidity('');
            }
        });
    }
}

// Call validation functions
validatePasswordMatch();
