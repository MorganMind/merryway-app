# Environment Variables Setup

## 📋 Overview

This project uses a `.env` file to securely store API keys and configuration. **Never commit your `.env` file to git!**

## 🚀 Quick Setup

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your actual values:**
   Edit `.env` and replace the placeholder values with your real keys

3. **Run the app:**
   ```bash
   flutter run
   ```

## 🔐 Security

- ✅ `.env` is already in `.gitignore` - it won't be committed
- ✅ Use `.env.example` as a template for your team
- ✅ Never share your `.env` file publicly
- ✅ Never hardcode API keys in your code

## 🌐 Deployment (Render)

Render deployment uses Docker to build and serve the Flutter web app.

### **Setup Steps:**

1. **Create a new Web Service** on Render
2. **Connect your GitHub repository**
3. **Configure the service:**
   - **Environment:** Docker
   - **Dockerfile Path:** `Dockerfile` (default)
   - **Docker Build Context Directory:** `.` (default)

4. **Add Environment Variables** in Render dashboard:
   - `SUPABASE_URL` - Your Supabase project URL
   - `SUPABASE_ANON_KEY` - Your Supabase anonymous key
   - `OPENAI_API_KEY` - Your OpenAI API key (optional)
   - `API_URL` - Your production Django API URL

5. **Deploy!** Render will automatically build and deploy using the Dockerfile

### **How It Works:**

- The `Dockerfile` uses the official Flutter Docker image
- Build arguments pass environment variables securely
- A `.env` file is created during build (not in git)
- The built web app is served using Nginx
- Auto-deploys on git push to master

### **Local Docker Testing (Optional):**

```bash
# Build the Docker image
docker build \
  --build-arg SUPABASE_URL=your-url \
  --build-arg SUPABASE_ANON_KEY=your-key \
  --build-arg OPENAI_API_KEY=your-key \
  --build-arg API_URL=http://localhost:8000/api/v1 \
  -t merryway .

# Run the container
docker run -p 8080:80 merryway

# Visit http://localhost:8080
```
