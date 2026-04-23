-- STUDY VAULT SUPABASE SCHEMA (V2 - ENHANCED SECURITY)
-- COPY AND PASTE THIS TO THE SQL EDITOR IN SUPABASE

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  email TEXT,
  unique_study_id TEXT UNIQUE, -- 10 character unique ID (XXXXXXXXXX)
  role TEXT DEFAULT 'user', -- 'user' or 'admin'
  subscription_status TEXT DEFAULT 'free', -- 'free', 'active'
  subscription_type TEXT,
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  category TEXT DEFAULT 'Student',
  is_active BOOLEAN DEFAULT TRUE, -- For account deactivation
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. EXAMS TABLE
CREATE TABLE IF NOT EXISTS exams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  subject_name TEXT NOT NULL,
  exam_date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TASKS TABLE
CREATE TABLE IF NOT EXISTS tasks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  title TEXT NOT NULL,
  subject_name TEXT,
  completed BOOLEAN DEFAULT FALSE,
  due_date TIMESTAMP WITH TIME ZONE,
  priority TEXT DEFAULT 'medium',
  duration_mins INTEGER DEFAULT 25,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. PAYMENTS (UTR) TABLE
CREATE TABLE IF NOT EXISTS payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  plan_id TEXT NOT NULL,
  amount TEXT NOT NULL,
  utr_number TEXT UNIQUE NOT NULL,
  status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. STUDY PLANS (AI Generated)
CREATE TABLE IF NOT EXISTS study_plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  plan_json JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. FLASHCARDS TABLE
CREATE TABLE IF NOT EXISTS flashcards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  front TEXT NOT NULL,
  back TEXT NOT NULL,
  knowledge TEXT, -- 'hard', 'good', 'easy'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. NOTES TABLE
CREATE TABLE IF NOT EXISTS notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT DEFAULT 'General',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. LINKS (Resource Hub)
CREATE TABLE IF NOT EXISTS bookmarks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  type TEXT DEFAULT 'Link',
  is_public BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. NOTICES (Global Announcements)
CREATE TABLE IF NOT EXISTS notices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT DEFAULT 'info', -- 'info', 'warning', 'urgent'
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. ASSETS (Files like APK, PDF)
CREATE TABLE IF NOT EXISTS assets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  url TEXT NOT NULL,
  file_type TEXT NOT NULL, -- 'apk', 'pdf', 'image'
  version TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ENABLE ROW LEVEL SECURITY (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;

-- POLICIES
-- Admin Override: Specific admins can do anything
CREATE POLICY "Admin full access" ON users FOR ALL USING (auth.jwt() ->> 'email' IN ('kprince43703@gmail.com', 'yadavsarkaryadav218@gmail.com'));
CREATE POLICY "Admin access all exams" ON exams FOR ALL USING (auth.jwt() ->> 'email' IN ('kprince43703@gmail.com', 'yadavsarkaryadav218@gmail.com'));
CREATE POLICY "Admin access all tasks" ON tasks FOR ALL USING (auth.jwt() ->> 'email' IN ('kprince43703@gmail.com', 'yadavsarkaryadav218@gmail.com'));
CREATE POLICY "Admin access all payments" ON payments FOR ALL USING (auth.jwt() ->> 'email' IN ('kprince43703@gmail.com', 'yadavsarkaryadav218@gmail.com'));
CREATE POLICY "Admin access all study plans" ON study_plans FOR ALL USING (auth.jwt() ->> 'email' IN ('kprince43703@gmail.com', 'yadavsarkaryadav218@gmail.com'));
CREATE POLICY "Admin access all flashcards" ON flashcards FOR ALL USING (auth.jwt() ->> 'email' IN ('kprince43703@gmail.com', 'yadavsarkaryadav218@gmail.com'));
CREATE POLICY "Admin access all notes" ON notes FOR ALL USING (auth.jwt() ->> 'email' IN ('kprince43703@gmail.com', 'yadavsarkaryadav218@gmail.com'));
CREATE POLICY "Admin access all bookmarks" ON bookmarks FOR ALL USING (auth.jwt() ->> 'email' IN ('kprince43703@gmail.com', 'yadavsarkaryadav218@gmail.com'));
CREATE POLICY "Admin access all notices" ON notices FOR ALL USING (auth.jwt() ->> 'email' IN ('kprince43703@gmail.com', 'yadavsarkaryadav218@gmail.com'));
CREATE POLICY "Admin access all assets" ON assets FOR ALL USING (auth.jwt() ->> 'email' IN ('kprince43703@gmail.com', 'yadavsarkaryadav218@gmail.com'));

-- Regular User Policies
CREATE POLICY "Users read all notices" ON notices FOR SELECT USING (true);
CREATE POLICY "Users read all assets" ON assets FOR SELECT USING (true);
CREATE POLICY "Users see own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users update own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users access own exams" ON exams FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users access own tasks" ON tasks FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users create own payments" ON payments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users read own payments" ON payments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users access own flashcards" ON flashcards FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users access own notes" ON notes FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users access own bookmarks" ON bookmarks FOR ALL USING (auth.uid() = user_id);

-- USER PROFILE TRIGGER WITH UNIQUE ID GENERATION
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  new_study_id TEXT;
BEGIN
  -- Generate a random 10-character alphanumeric ID
  new_study_id := upper(substring(md5(random()::text), 1, 10));
  
  INSERT INTO public.users (id, full_name, email, role, subscription_status, unique_study_id)
  VALUES (
    new.id, 
    new.raw_user_meta_data->>'full_name', 
    new.email, 
    CASE WHEN new.email = 'kprince43703@gmail.com' THEN 'admin' ELSE 'user' END, 
    'free', 
    new_study_id
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Be sure to drop old trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
