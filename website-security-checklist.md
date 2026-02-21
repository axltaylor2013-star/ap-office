# Website Security Checklist - kermiclemedia.com

## 🔒 IMMEDIATE SECURITY ACTIONS

### 1. SSL Certificate (HTTPS)
**Status:** Check current status
- Visit: https://kermiclemedia.com (should show padlock)
- If HTTP only, enable SSL through GitHub Pages settings
- **Critical:** All business sites MUST have HTTPS

### 2. Domain Security
**Protect the domain itself:**
- Enable domain lock with registrar
- Use strong registrar account password + 2FA
- Set auto-renewal to prevent expiration
- Add privacy protection (hide personal info)

### 3. GitHub Repository Security
**Lock down the source:**
- Enable 2FA on GitHub account
- Make repository private (if needed)
- Limit collaborator access
- Review commit history for sensitive data

### 4. Content Security
**Protect the sales information:**
- No API keys or sensitive data in HTML
- Remove any internal file paths
- Clean meta tags of dev information
- Verify no database credentials exposed

### 5. Professional Trust Signals
**Build visitor confidence:**
- Valid SSL certificate (HTTPS padlock)
- Professional email address (not Gmail)
- Contact information clearly displayed
- Terms of Service and Privacy Policy
- Copyright notice

## 🛡️ ADVANCED PROTECTION

### 6. DDoS Protection
**Use Cloudflare (free tier):**
- Protects against attacks
- Speeds up site loading
- Adds extra security layer
- Easy DNS management

### 7. Backup Strategy
**Protect your work:**
- GitHub automatically backs up files
- Download local copy of index.html
- Save to multiple locations
- Document rebuild process

### 8. Legal Protection
**Cover your bases:**
- Terms of Service page
- Privacy Policy page
- GDPR compliance statement
- Contact information accuracy

## ⚡ QUICK WINS (Do Now)

### A. Check SSL Status
1. Go to: https://kermiclemedia.com
2. Look for padlock icon in browser
3. If missing, enable in GitHub Pages settings

### B. Strong Passwords
- GitHub account: unique, complex password
- Domain registrar: unique, complex password
- Enable 2FA on both

### C. Clean Code Review
- Remove any comments with sensitive info
- Check for hardcoded credentials
- Verify all links work properly

### D. Professional Email Setup
- Set up jeremy@kermiclemedia.com
- Forward to current email
- Update contact forms to use professional address

## 🔍 SECURITY AUDIT TOOLS

### Free Website Security Scanners:
- SSL Labs Test: ssllabs.com/ssltest/
- Security Headers: securityheaders.com
- Mozilla Observatory: observatory.mozilla.org
- Google Safe Browsing: transparencyreport.google.com/safe-browsing/search

### Manual Checks:
- Try accessing /admin, /wp-admin (should 404)
- Check robots.txt doesn't expose sensitive paths
- Verify no directory listings enabled
- Test contact forms don't expose server info

## 💼 BUSINESS CONTINUITY

### Recovery Plan:
1. **Domain hijacked:** Contact registrar support immediately
2. **GitHub compromised:** Change passwords, revoke access tokens
3. **Site defaced:** Restore from GitHub repository backup
4. **SSL expires:** Renew through hosting provider/GitHub

### Contact Numbers:
- Domain registrar support: [ADD NUMBER]
- GitHub support: support.github.com
- Cloudflare support: support.cloudflare.com (if using)

## 🎯 IMPLEMENTATION ORDER

### Phase 1 (Do Now - 15 minutes):
1. Check HTTPS status
2. Enable 2FA on GitHub
3. Review visible contact information
4. Check for sensitive data exposure

### Phase 2 (Within 24 hours):
1. Set up professional email
2. Add Terms of Service page
3. Add Privacy Policy page
4. Run security scans

### Phase 3 (This week):
1. Consider Cloudflare setup
2. Create backup procedures
3. Document security procedures
4. Schedule regular security reviews

## ✅ COMPLETION CHECKLIST

- [ ] HTTPS enabled and working
- [ ] GitHub 2FA enabled
- [ ] Domain registrar secured with 2FA
- [ ] Professional email set up
- [ ] Sensitive data removed from code
- [ ] SSL Labs test shows A+ rating
- [ ] Terms of Service page added
- [ ] Privacy Policy page added
- [ ] Contact information verified
- [ ] Backup procedure documented
- [ ] Security scan completed (no critical issues)
- [ ] Professional trust signals in place

**Priority Level: HIGH** - Complete Phase 1 before any sales outreach!