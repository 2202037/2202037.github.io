# Ayur Healthcare Platform - Setup & Installation Guide

## System Requirements

- **Web Server:** Apache (XAMPP recommended)
- **PHP:** Version 8.0 or higher
- **MySQL:** Version 5.7 or higher
- **Browser:** Modern web browser (Chrome, Firefox, Safari, Edge)

## Installation Steps

### 1. Install XAMPP

1. Download XAMPP from [https://www.apachefriends.org/](https://www.apachefriends.org/)
2. Install XAMPP in your system
3. Start Apache and MySQL services from XAMPP Control Panel

### 2. Setup Database

1. Open phpMyAdmin: `http://localhost/phpmyadmin`
2. Create a new database named `ayur_db`
3. Import the database schema:
   - Click on the `ayur_db` database
   - Go to the "Import" tab
   - Select the file: `database/schema.sql`
   - Click "Go" to import

### 3. Deploy Application Files

**Option A: Using htdocs (Recommended for XAMPP)**

1. Copy all project files to: `C:\xampp\htdocs\ayur\` (Windows) or `/opt/lampp/htdocs/ayur/` (Linux/Mac)
2. Access the application: `http://localhost/ayur/`

**Option B: Using GitHub Pages (Frontend Only)**

For GitHub Pages deployment, only static HTML/CSS/JS files will work. PHP backend features require a PHP server.

### 4. Configure Database Connection

1. Open `backend/config/db.php`
2. Verify the database credentials:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_NAME', 'ayur_db');
   define('DB_USER', 'root');
   define('DB_PASS', ''); // Default XAMPP password is empty
   ```
3. If you changed MySQL password during XAMPP installation, update `DB_PASS`

### 5. Set File Permissions

Ensure the following directories are writable:

- `uploads/images/`
- `uploads/documents/`

**On Windows (XAMPP):** Right-click folders → Properties → Security → Edit → Allow "Write" for Users

**On Linux/Mac:**
```bash
chmod -R 755 uploads/
```

### 6. Default Admin Account

After importing the database, you can login as admin with:

- **Username:** `admin`
- **Email:** `admin@ayurbd.me`
- **Password:** `admin123`

⚠️ **Important:** Change the default admin password immediately after first login!

## File Structure

```
ayur/
├── index.html                 # Homepage
├── login.html                 # Login page
├── register.html              # Registration role selection
├── register_*.html            # Registration forms
├── admin_dashboard.html       # Admin dashboard
├── assets/
│   ├── css/                   # Stylesheets
│   │   ├── main.css
│   │   ├── auth.css
│   │   └── dashboard.css
│   ├── js/                    # JavaScript files
│   │   ├── main.js
│   │   ├── validation.js
│   │   └── admin-dashboard.js
│   └── images/                # Static images
├── backend/
│   ├── config/
│   │   └── db.php             # Database configuration
│   ├── auth/
│   │   ├── login.php          # Login handler
│   │   ├── register.php       # Registration handler
│   │   └── logout.php         # Logout handler
│   └── admin/
│       ├── pending_requests.php
│       ├── approve.php
│       ├── reject.php
│       └── stats.php
├── database/
│   └── schema.sql             # Database schema
└── uploads/                   # User uploads (auto-created)
    ├── images/
    └── documents/
```

## Testing the Application

### 1. Test Patient Registration

1. Go to: `http://localhost/ayur/`
2. Click "Register"
3. Select "Patient"
4. Fill in the registration form
5. Submit and login

### 2. Test Provider Registration

1. Go to: `http://localhost/ayur/register.html`
2. Select "Doctor", "Hospital", "Clinic", or "Pharmacy"
3. Fill in the form with all required fields
4. Upload required documents
5. Submit for admin verification

### 3. Test Admin Functions

1. Login as admin: `http://localhost/ayur/login.html`
   - Email: `admin@ayurbd.me`
   - Password: `admin123`
   - Role: Admin
2. View pending registrations
3. Approve or reject provider requests

## Common Issues & Solutions

### Issue 1: Database Connection Failed

**Solution:**
- Verify MySQL is running in XAMPP Control Panel
- Check database credentials in `backend/config/db.php`
- Ensure `ayur_db` database exists

### Issue 2: File Upload Errors

**Solution:**
- Check `uploads/` directory exists and is writable
- Verify PHP upload settings in `php.ini`:
  ```ini
  upload_max_filesize = 10M
  post_max_size = 10M
  ```

### Issue 3: Session Errors

**Solution:**
- Ensure PHP session directory is writable
- Check PHP error logs in XAMPP

### Issue 4: 404 Errors on Backend Files

**Solution:**
- Verify Apache is running
- Check file paths are correct
- Ensure `.htaccess` is not blocking PHP files

## Security Recommendations

1. **Change Default Admin Password**
   ```sql
   UPDATE admins SET password = '$2y$10$YOUR_NEW_HASH' WHERE username = 'admin';
   ```

2. **Enable HTTPS in Production**
   - Obtain SSL certificate
   - Configure Apache for HTTPS

3. **Regular Backups**
   - Backup database regularly
   - Backup `uploads/` directory

4. **File Upload Validation**
   - Already implemented in code
   - Review and adjust max file sizes as needed

## Development Notes

### Adding New Features

1. **Database Changes:** Update `database/schema.sql`
2. **Frontend:** Add HTML/CSS/JS in respective directories
3. **Backend:** Add PHP files in `backend/` with proper routing

### API Endpoints

All backend endpoints return JSON responses:

- `backend/auth/login.php` - POST - User login
- `backend/auth/register.php` - POST - User registration
- `backend/admin/pending_requests.php` - GET - Fetch pending requests
- `backend/admin/approve.php` - POST - Approve provider
- `backend/admin/reject.php` - POST - Reject provider
- `backend/admin/stats.php` - GET - Dashboard statistics

## Support

For issues or questions:
- Email: support@ayurbd.me
- Review code documentation in each file

## License

This project is developed for educational purposes.

---

**Version:** 1.0.0  
**Last Updated:** December 2025
