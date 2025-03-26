# Error Resolution Guide

This guide helps you solve common errors in the Gota Restaurant App.

## Database Errors

### Error: column "is_active" does not exist

This error occurs when trying to query the `is_active` column in the restaurants table, but the column hasn't been created yet.

**Solution:**

1. Navigate to the Supabase SQL Editor in your project dashboard
2. Open the `lib/docs/schema_update.sql` file from this project
3. Execute the SQL to add missing columns to your database

The SQL will check if the columns exist before attempting to add them, so it's safe to run multiple times.

### Error: PostgrestException(message: new row violates row-level security policy for table "profiles")

This error occurs during signup when the Row-Level Security (RLS) policies prevent the new user from creating their profile.

**Solution:**

1. Make sure you're using the latest version of `lib/docs/supabase_setup.sql` which includes the proper RLS policies:
   - "Users can insert their own profile"
   - "Service role can manage all profiles"

2. Execute the SQL to update your database security policies

## Authentication Errors

### Error: Invalid login credentials

This error occurs when attempting to sign in with incorrect email/password combination.

**Solutions:**

1. Double-check your email and password
2. If testing, use the test credentials: 
   - Email: `test@gota.com`
   - Password: `Test@123456`
3. Ensure the user exists in your Supabase Authentication dashboard

## App Flow Optimization

For better performance and reliability:

1. **Use the Proper Schema:** Make sure your database schema matches exactly with `lib/docs/supabase_setup.sql`

2. **Update Column Queries:** If you previously filtered restaurants with `is_active`, make sure this column exists

3. **Authentication Flow:** Use the PKCE authentication flow for better security by setting `authFlowType: AuthFlowType.pkce` in the Supabase initialization

4. **Error Handling:** Provide user-friendly error messages in Vietnamese:
   ```dart
   on AuthException catch (e) {
     if (e.message.contains('Invalid login credentials')) {
       throw AuthException(
         message: 'Email hoặc mật khẩu không chính xác. Vui lòng thử lại.',
         statusCode: e.statusCode
       );
     }
     // Other error handling
   }
   ```

This guide will be updated as new common errors are identified. 