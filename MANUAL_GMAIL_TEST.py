#!/usr/bin/env python3
"""
Manual Gmail API Test - Check if we can actually read emails
"""

import json
import os
from datetime import datetime

def test_gmail_read():
    print("========================================")
    print("  MANUAL GMAIL API TEST")
    print("========================================")
    print()
    
    # Check credentials
    if not os.path.exists('gmail_credentials.json'):
        print("❌ gmail_credentials.json not found")
        return
    
    print("✅ Credentials file exists")
    
    try:
        # Test Gmail API import
        print("Testing Gmail API library...")
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
        print("✅ Gmail API libraries imported successfully")
        
        # Load credentials
        print("Loading credentials...")
        credentials = service_account.Credentials.from_service_account_file(
            'gmail_credentials.json',
            scopes=['https://www.googleapis.com/auth/gmail.readonly']
        )
        print("✅ Service account credentials loaded")
        
        # Try to build Gmail service
        print("Building Gmail service...")
        service = build('gmail', 'v1', credentials=credentials)
        print("✅ Gmail service built successfully")
        
        # Test basic API call
        print("Testing Gmail API connection...")
        # This should fail with current setup but will show us the specific error
        profile = service.users().getProfile(userId='me').execute()
        print("✅ Gmail API working perfectly!")
        print(f"Email: {profile.get('emailAddress', 'Unknown')}")
        
    except Exception as e:
        print(f"❌ Gmail API Error: {e}")
        print("\nThis error tells us what's wrong with the setup.")
        
    print()
    print("Test complete. Check the results above.")
    
if __name__ == "__main__":
    test_gmail_read()
    input("Press Enter to continue...")