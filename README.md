# Ayur - Unified Healthcare Service Platform

![Ayur Logo](https://img.shields.io/badge/Ayur-Healthcare-2E86C1?style=for-the-badge)
![PHP](https://img.shields.io/badge/PHP-8.0+-777BB4?style=flat-square&logo=php)
![MySQL](https://img.shields.io/badge/MySQL-5.7+-4479A1?style=flat-square&logo=mysql)
![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-F7DF1E?style=flat-square&logo=javascript)

## Overview

Ayur is a unified digital healthcare service platform that connects patients with verified healthcare providers across Bangladesh. The platform enables easy discovery of doctors, hospitals, clinics, pharmacies, and blood banks while providing features like appointment booking, secure payments, and transparent reviews.

## Features

### For Patients
- 🔍 Search verified healthcare providers
- 📅 Book appointments online
- 💳 Secure payment integration (bKash/Nagad)
- ⭐ Read and submit reviews
- 🩸 Access blood bank services

### For Healthcare Providers
- 👨‍⚕️ Doctors: Manage consultations and appointments
- 🏥 Hospitals: List departments and services
- 🏪 Clinics: Reach more patients
- 💊 Pharmacies: Expand customer base

### For Administrators
- ✅ Verify provider registrations
- 📊 Monitor platform statistics
- 🛡️ Manage user accounts
- 📝 Moderate reviews

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | HTML5, CSS3, JavaScript (ES6+) |
| Backend | PHP 8.0+ |
| Database | MySQL 5.7+ |
| Server | Apache (XAMPP) |
| Payment | bKash & Nagad API |

## Quick Start

### Prerequisites
- XAMPP (Apache + MySQL + PHP 8.0+)
- Modern web browser

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/2202037/2202037.github.io.git
   cd 2202037.github.io
   ```

2. **Setup database**
   - Open phpMyAdmin: `http://localhost/phpmyadmin`
   - Create database: `ayur_db`
   - Import: `database/schema.sql`

3. **Deploy files**
   - Copy to XAMPP htdocs: `C:\xampp\htdocs\ayur\`
   - Or configure virtual host

4. **Configure database**
   - Edit `backend/config/db.php`
   - Verify credentials match your MySQL setup

5. **Access application**
   - Open browser: `http://localhost/ayur/`

For detailed setup instructions, see [SETUP.md](SETUP.md)

## Default Admin Credentials

- **Email:** admin@ayurbd.me
- **Password:** admin123

⚠️ **Change the default password immediately after first login!**

## Project Structure

```
ayur/
├── index.html              # Homepage
├── login.html             # Login page
├── register.html          # Registration role selection
├── admin_dashboard.html   # Admin panel
├── assets/
│   ├── css/              # Stylesheets
│   ├── js/               # JavaScript
│   └── images/           # Static images
├── backend/
│   ├── config/           # Database configuration
│   ├── auth/             # Authentication handlers
│   └── admin/            # Admin functions
├── database/
│   └── schema.sql        # Database schema
└── uploads/              # User uploaded files
```

## Key Workflows

### 1. Patient Registration
Patient → Register → Fill Form → Instant Approval → Login

### 2. Provider Registration
Provider → Register → Fill Form → Upload Documents → Admin Review → Approval/Rejection → Login

### 3. Appointment Booking
Patient → Search Provider → Select Time Slot → Pay → Confirmed

### 4. Admin Verification
Admin Login → View Pending Requests → Review Documents → Approve/Reject

## Security Features

- ✅ Password hashing (bcrypt)
- ✅ Session-based authentication
- ✅ SQL injection prevention (PDO prepared statements)
- ✅ File upload validation
- ✅ Role-based access control
- ✅ Input sanitization

## Database Schema

The platform uses the following main tables:
- `admins` - Administrator accounts
- `patients` - Patient accounts (direct registration)
- `doctors`, `hospitals`, `clinics`, `pharmacies` - Verified providers
- `temp_*` - Pending provider registrations
- `appointments` - Booking records
- `payments` - Transaction records
- `reviews` - User reviews
- `blood_banks`, `blood_requests` - Blood management

## API Endpoints

### Authentication
- `POST /backend/auth/login.php` - User login
- `POST /backend/auth/register.php` - User registration
- `GET /backend/auth/logout.php` - User logout

### Admin
- `GET /backend/admin/pending_requests.php?type={type}` - Get pending requests
- `POST /backend/admin/approve.php` - Approve provider
- `POST /backend/admin/reject.php` - Reject provider
- `GET /backend/admin/stats.php` - Dashboard statistics

## Contributing

This project is developed as an educational platform. Contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## Future Enhancements

- [ ] Video consultation
- [ ] Prescription management
- [ ] SMS notifications
- [ ] Mobile application
- [ ] AI health assistant
- [ ] Multi-language support

## License

This project is licensed for educational purposes.

## Contact

- **Website:** https://ayurbd.me
- **Email:** info@ayurbd.me
- **Support:** support@ayurbd.me

---

**Developed with ❤️ for a healthier Bangladesh**