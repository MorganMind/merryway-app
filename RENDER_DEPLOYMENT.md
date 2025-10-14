# 🚀 Render Deployment Guide

## Quick Setup (5 minutes)

### 1. **Push to GitHub**
Make sure your latest code (including Dockerfile) is pushed to GitHub:
```bash
git add .
git commit -m "Add Docker deployment configuration"
git push origin master
```

### 2. **Create Render Web Service**
1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository: `MorganMind/merryway-app`
4. Configure:
   - **Name:** `merryway-app` (or your choice)
   - **Environment:** **Docker** ⚠️ (Important!)
   - **Region:** Choose closest to your users
   - **Branch:** `master`
   - **Dockerfile Path:** `Dockerfile` (leave default)
   - **Docker Build Context Directory:** `.` (leave default)

### 3. **Add Environment Variables**
In the **Environment** section, add these variables:

| Key | Value | Example |
|-----|-------|---------|
| `SUPABASE_URL` | Your Supabase project URL | `https://xnvzkjqnirqfgemjakok.supabase.co` |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous key | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |
| `OPENAI_API_KEY` | Your OpenAI API key | `sk-proj-...` (optional) |
| `API_URL` | Your Django API URL | `https://your-django-api.com/api/v1` |

**Pro tip:** Copy from your local `.env` file!

### 4. **Deploy!**
1. Click **"Create Web Service"**
2. Wait for build to complete (~5-10 minutes first time)
3. Your app will be live at: `https://merryway-app.onrender.com` (or your chosen name)

## 🔄 Auto-Deploy

Once set up, Render will automatically:
- ✅ Build and deploy on every push to `master`
- ✅ Use environment variables securely
- ✅ Serve your app with Nginx (fast & efficient)
- ✅ Provide HTTPS automatically

## 🐛 Troubleshooting

### Build fails with "flutter: command not found"
- **Solution:** Make sure **Environment** is set to **Docker** (not "Native")

### Environment variables not working
- **Solution:** Verify all 4 variables are set in Render dashboard

### App loads but API calls fail
- **Solution:** Check `API_URL` points to your production Django server

### 502 Bad Gateway
- **Solution:** Wait a few minutes - the service might still be starting

## 📊 Monitoring

- **Logs:** View in Render dashboard → Your service → "Logs" tab
- **Metrics:** Check "Metrics" tab for performance data
- **Events:** See "Events" tab for deployment history

## 🔐 Security Notes

✅ **Good:**
- Environment variables are encrypted at rest
- `.env` file is NOT in git (thanks to `.gitignore`)
- HTTPS is automatic on Render
- Nginx serves static files securely

❌ **Never:**
- Commit `.env` to git
- Share environment variables publicly
- Use development keys in production

## 💰 Pricing

- **Free Tier:** Perfect for testing (sleeps after 15 min inactivity)
- **Paid Plans:** Start at $7/month (always on, better performance)

Need help? Check [Render Docs](https://render.com/docs) or ask in their Discord!
