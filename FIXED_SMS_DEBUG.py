#!/usr/bin/env python3
"""
Fixed SMS System Debug - Use absolute path to credentials
"""

import json
import os
from datetime import datetime

def debug_sms_system():
    print("========================================")
    print("  FIXED SMS SYSTEM DEBUG")
    print("========================================")
    print()
    
    print(f"1. Current working directory: {os.getcwd()}")
    
    # Try multiple possible locations for credentials
    possible_paths = [
        'gmail_credentials.json',
        r'C:\Users\alfre\.openclaw\workspace\gmail_credentials.json',
        os.path.join(os.path.dirname(__file__), 'gmail_credentials.json')
    ]
    
    credentials_path = None
    for path in possible_paths:
        if os.path.exists(path):
            credentials_path = path
            print(f"✅ Found credentials at: {path}")
            break
        else:
            print(f"❌ Not found at: {path}")
    
    if not credentials_path:
        print("❌ Credentials not found in any expected location")
        return
    
    try:
        print("\n2. Testing Gmail API connection...")
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
        
        credentials = service_account.Credentials.from_service_account_file(
            credentials_path,
            scopes=['https://www.googleapis.com/auth/gmail.readonly',
                   'https://www.googleapis.com/auth/gmail.send']
        )
        print("✅ Credentials loaded successfully")
        
        # Create Gmail service
        service = build('gmail', 'v1', credentials=credentials)
        print("✅ Gmail service created")
        
        # Test API access - this will show the real authentication issue
        print("\n3. Testing Gmail access...")
        try:
            profile = service.users().getProfile(userId='me').execute()
            print(f"✅ Gmail access successful! Email: {profile.get('emailAddress')}")
        except Exception as api_error:
            print(f"❌ Gmail API Access Error: {api_error}")
            
            # Diagnose the specific error
            error_str = str(api_error).lower()
            if 'forbidden' in error_str or 'access denied' in error_str:
                print("\n🔧 DIAGNOSIS: Service Account Permission Issue")
                print("SOLUTION NEEDED: Service account can't access personal Gmail")
                print("OPTIONS:")
                print("1. Use OAuth instead of service account")
                print("2. Set up domain-wide delegation (complex)")
                print("3. Change Google Voice to forward to business email")
            elif 'not found' in error_str:
                print("\n🔧 DIAGNOSIS: Invalid user ID")
                print("SOLUTION: Use specific email address instead of 'me'")
            else:
                print("\n🔧 DIAGNOSIS: Unknown Gmail API issue")
        
    except ImportError as e:
        print(f"❌ Missing Gmail API library: {e}")
        print("SOLUTION: Run 'pip install google-api-python-client google-auth'")
    except Exception as e:
        print(f"❌ Setup Error: {e}")
    
    print("\n========================================")
    print("  DEBUG COMPLETE")
    print("========================================")

if __name__ == "__main__":
    debug_sms_system()
    input("Press Enter to continue...")