#!/usr/bin/env python3
"""
Debug SMS System - Check why emails aren't being detected
"""

import json
import os
from datetime import datetime

def debug_sms_system():
    print("========================================")
    print("  SMS SYSTEM DEBUG")
    print("========================================")
    print()
    
    # Check if we can actually access Gmail
    print("1. Checking Gmail API setup...")
    
    if not os.path.exists('gmail_credentials.json'):
        print("❌ gmail_credentials.json missing")
        return
    
    print("✅ Credentials file found")
    
    try:
        # Test if we can actually read Gmail
        print("\n2. Testing Gmail API connection...")
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
        
        credentials = service_account.Credentials.from_service_account_file(
            'gmail_credentials.json',
            scopes=['https://www.googleapis.com/auth/gmail.readonly',
                   'https://www.googleapis.com/auth/gmail.send']
        )
        
        # Try to connect to Gmail
        service = build('gmail', 'v1', credentials=credentials)
        print("✅ Gmail service created")
        
        # This is where it will likely fail - service accounts can't directly access user Gmail
        print("\n3. Testing email access...")
        profile = service.users().getProfile(userId='me').execute()
        print("✅ Can access Gmail!")
        
    except Exception as e:
        print(f"❌ Gmail Access Error: {e}")
        print("\n🔧 DIAGNOSIS:")
        
        if "Service accounts cannot login" in str(e) or "forbidden" in str(e).lower():
            print("PROBLEM: Service Account needs domain-wide delegation")
            print("SOLUTION: Need to set up Gmail access differently")
            
        elif "credentials" in str(e).lower():
            print("PROBLEM: Credentials file format issue")
            print("SOLUTION: Re-download service account JSON")
            
        else:
            print("PROBLEM: Unknown Gmail API issue")
            print("SOLUTION: Need alternative email access method")
    
    print("\n========================================")
    print("  SMS SYSTEM DIAGNOSIS COMPLETE")
    print("========================================")

if __name__ == "__main__":
    debug_sms_system()
    input("Press Enter to continue...")