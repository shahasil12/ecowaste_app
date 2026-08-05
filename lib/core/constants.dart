const String baseUrl = 'https://eco-waste-green.vercel.app/api/v1';
// For local testing on your Android device, uncomment the line below and comment the one above:
// const String baseUrl = 'http://192.168.0.157:8000/api/v1';

// Auth
const String registerUrl        = '$baseUrl/auth/register/';
const String companyRegisterUrl = '$baseUrl/auth/company-register/';
const String loginUrl           = '$baseUrl/auth/login/';
const String companyLoginUrl    = '$baseUrl/auth/company-login/';
const String tokenRefreshUrl    = '$baseUrl/auth/token/refresh/';

// Citizen
const String profileUrl     = '$baseUrl/citizen/profile/';

// Reports
const String reportsUrl     = '$baseUrl/reports/';

// Pickups
const String pickupsUrl     = '$baseUrl/pickups/';

// Public
const String binsUrl            = '$baseUrl/bins/';
const String recyclingCentersUrl= '$baseUrl/recycling-centers/';
const String leaderboardUrl     = '$baseUrl/leaderboard/';

// Admin
const String adminLoginUrl      = '$baseUrl/admin/login/';
const String adminCitizensUrl   = '$baseUrl/admin/citizens/';
const String adminCompaniesUrl  = '$baseUrl/admin/companies/';
const String adminReportsUrl    = '$baseUrl/admin/reports/';
const String adminBinsUrl       = '$baseUrl/admin/bins/';

// Company Portal
const String companyReportsUrl  = '$baseUrl/companies/reports/';
const String companyPickupsUrl  = '$baseUrl/companies/pickups/';
