// F12221 Inspection ITP — connection settings (shared by ssl.html and nsl.html).
// Paste the two values from Supabase → Project Settings → API. The anon key is designed to be public:
// the database rules (supabase/schema.sql) decide who can read or change anything.
// Leave them blank and the pages run in "Local only" mode (data stays in each browser).
window.F12221_CONFIG = {
  SUPABASE_URL: 'https://pzcdkljbmendumaudjxe.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB6Y2RrbGpibWVuZHVtYXVkanhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMxNzI5MTQsImV4cCI6MjEwODc0ODkxNH0.j7gNBT8ozOdjzaPcmB1pcl_Vt9c7E3ZFFdpGo7IgZKU',
  STAFF_DOMAIN: 'franmarine.com.au'   // addresses on this domain are Editors and can manage access
};
