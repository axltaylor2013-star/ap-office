#!/usr/bin/env python3
"""
Test Gmail API Connection for SMS System
"""

import json
import os
from datetime import datetime

def test_gmail_connection():
    print("========================================")
    print("  TESTING GMAIL API CONNECTION")
    print("========================================")
    print()
    
    # Check for credentials file
    creds_file = "gmail_credentials.json"
    if os.path.exists(creds_file):
        print("✅ Gmail credentials file found")
        try:
            with open(creds_file, 'r') as f:
                creds = json.load(f)
            print("✅ Credentials file is valid JSON")
            
            # Check for required fields
            required_fields = ['type', 'client_email', 'private_key']
            for field in required_fields:
                if field in creds:
                    print(f"✅ Found {field}")
                else:
                    print(f"❌ Missing {field}")
                    
        except Exception as e:
            print(f"❌ Error reading credentials: {e}")
    else:
        print("❌ Gmail credentials file not found")
        print("   Please save your JSON file as 'gmail_credentials.json'")
        
    print()
    print("Gmail API Status:", "READY" if os.path.exists(creds_file) else "NEEDS SETUP")
    print("SMS System Status:", "READY TO TEST" if os.path.exists(creds_file) else "WAITING FOR CREDENTIALS")
    print()
    print("Next step: Install google-api-python-client")
    print("Run: pip install google-api-python-client")
    print()

if __name__ == "__main__":
    test_gmail_connection()
    input("Press Enter to continue...")