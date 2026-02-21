#!/usr/bin/env python3
"""
Test if we can access jeremy@kermiclemedia.com with service account
"""

from google.oauth2 import service_account
from googleapiclient.discovery import build

def test_business_email_access():
    print("========================================")
    print("  TESTING BUSINESS EMAIL ACCESS")
    print("========================================")
    print()
    
    try:
        print("Loading service account credentials...")
        credentials = service_account.Credentials.from_service_account_file(
            'gmail_credentials.json',
            scopes=[
                'https://www.googleapis.com/auth/gmail.readonly',
                'https://www.googleapis.com/auth/gmail.send'
            ]
        )
        print("✅ Credentials loaded")
        
        print("\nTesting direct service account access...")
        service = build('gmail', 'v1', credentials=credentials)
        
        # Try to get profile (this will likely fail)
        try:
            profile = service.users().getProfile(userId='me').execute()
            print("✅ AMAZING! Direct access works!")
            print(f"Email: {profile.get('emailAddress')}")
            return True
        except Exception as direct_error:
            print(f"❌ Direct access failed: {direct_error}")
            
        print("\nTesting delegated access to jeremy@kermiclemedia.com...")
        delegated_credentials = credentials.with_subject('jeremy@kermiclemedia.com')
        delegated_service = build('gmail', 'v1', credentials=delegated_credentials)
        
        try:
            profile = delegated_service.users().getProfile(userId='me').execute()
            print("✅ EXCELLENT! Delegated access works!")
            print(f"Email: {profile.get('emailAddress')}")
            return True
        except Exception as delegated_error:
            print(f"❌ Delegated access failed: {delegated_error}")
            
        # Both failed - need domain-wide delegation setup
        print("\n🔧 DIAGNOSIS:")
        print("Service account needs domain-wide delegation to access Gmail")
        print("\nSOLUTION OPTIONS:")
        print("1. Set up domain-wide delegation (complex)")
        print("2. Use OAuth instead of service account (simpler)")
        print("3. Use manual email checking for now")
        
        return False
        
    except Exception as e:
        print(f"❌ Setup error: {e}")
        return False

if __name__ == "__main__":
    test_business_email_access()
    input("Press Enter to continue...")