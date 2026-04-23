# Study Vault - Setup Guide

This guide will help you run Study Vault locally or deploy it to your own server.

## 🚀 Quick Start (Local)

1. **Extract the ZIP file** to a folder.
2. **Install dependencies**:
   ```bash
   npm install
   ```
3. **Set up Environment Variables**:
   - Create a `.env` file in the root folder.
   - Use `.env.example` as a template.
   - **Crucial**: You must provide your own `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, and `VITE_GEMINI_API_KEY`.

4. **Prepare the Database**:
   - Go to your Supabase project.
   - Open the **SQL Editor**.
   - Copy the contents of `supabase_schema.sql` and run it to create the necessary tables and policies.

5. **Run the application**:
   ```bash
   npm run dev
   ```

## 🌐 Production Deployment

If you are uploading this ZIP to a platform like Render, Railway, or Vercel:

1. **Build the app**:
   ```bash
   npm run build
   ```
2. **Start the server**:
   ```bash
   npm start
   ```

### Deployment Configuration
- **Build Command**: `npm run build`
- **Output Directory**: `dist`
- **Start Command**: `npm start`
- **Environment Variables**: Add your Supabase and Gemini keys in your host's dashboard.

## 🛠 Troubleshooting

- **Error: "invalid input syntax for type integer"**: This usually means a value in the database doesn't match the expected type. Ensure you've run the latest `supabase_schema.sql`.
- **Database Connection**: If the Admin Panel is empty, double-check your RLS policies in Supabase.
- **AI Features not working**: Ensure your `VITE_GEMINI_API_KEY` is correct and has sufficient quota.
