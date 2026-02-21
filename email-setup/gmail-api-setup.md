# Gmail API Setup Guide - Kermicle Media

## 📧 **STEP 1: Create/Choose Email Account**

### Option A: Use Existing Gmail
- Use your current gmail account for sales

### Option B: Create New Sales Gmail (Recommended)
1. Go to gmail.com
2. Create new account: `jeremykermicle.sales@gmail.com` or similar
3. Use this dedicated for business outreach

## 🔧 **STEP 2: Enable Gmail API**

### 1. Go to Google Cloud Console
- Visit: https://console.cloud.google.com/
- Sign in with the Gmail account you want to use

### 2. Create New Project
- Click "Select a Project" → "New Project"
- Name: "Kermicle Media Sales"
- Click "Create"

### 3. Enable Gmail API
- In search bar, type "Gmail API"
- Click "Gmail API" result
- Click "Enable" button

### 4. Create Credentials
- Click "Create Credentials" button
- Select "Gmail API"
- Select "User data"
- Click "Next"

### 5. OAuth Consent Screen
- App name: "Kermicle Media Sales"
- User support email: your email
- Developer contact: your email
- Click "Save and Continue"

### 6. Scopes
- Click "Add or Remove Scopes"
- Select: "Send emails on your behalf"
- Select: "View your email messages and settings"
- Click "Update" → "Save and Continue"

### 7. Create OAuth Client
- Application type: "Desktop application"
- Name: "Kermicle Sales Bot"
- Click "Create"

### 8. Download Credentials
- Click "Download" to get JSON file
- Save as `gmail-credentials.json`

## 🔑 **STEP 3: Add to OpenClaw**

### Method 1: Config Patch (Recommended)
```bash
openclaw gateway config.patch --note "Add Gmail API for sales outreach"
```
When prompted, add:
```json
{
  "email": {
    "gmail": {
      "credentialsPath": "path/to/gmail-credentials.json",
      "scopes": ["https://www.googleapis.com/auth/gmail.send", "https://www.googleapis.com/auth/gmail.readonly"]
    }
  }
}
```

### Method 2: Manual Config Edit
1. Find your openclaw.json config file
2. Add email section with Gmail credentials
3. Restart OpenClaw gateway

## ✅ **STEP 4: Test Setup**

I'll test the email system with:
1. Send test email to yourself
2. Verify sending works
3. Confirm message tracking
4. Ready for outreach campaign!

## 🚨 **COMMON ISSUES:**

### "App not verified" warning:
- Normal for personal use
- Click "Advanced" → "Go to app (unsafe)"
- Only you will see this warning

### Permission denied:
- Make sure you're logged into correct Gmail
- Check API is enabled in Cloud Console
- Verify credentials file is correct

### OAuth errors:
- Try incognito browser for OAuth setup
- Clear browser cache and retry

## 🎯 **SECURITY NOTES:**

- Credentials file contains sensitive data
- Only Jeremy and authorized agents can access
- Used solely for legitimate business outreach
- Full control remains with Jeremy

## 📊 **WHAT HAPPENS NEXT:**

Once setup complete:
1. I can send personalized sales emails
2. Track opens, responses, meetings scheduled
3. Follow up automatically after 3-5 days
4. Scale to 50+ prospects per day
5. Generate pipeline reports and metrics

**Estimated setup time: 15-20 minutes**
**Result: Automated professional outreach system**