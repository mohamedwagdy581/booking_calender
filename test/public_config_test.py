import base64
import json
import unittest
from tools.generate_public_config import public_values

class PublicConfigTest(unittest.TestCase):
    def test_only_public_values_are_exported(self):
        values = public_values('SUPABASE_URL=https://example.supabase.co\nSUPABASE_ANON_KEY=sb_publishable_test\nGMAIL_APP_PASSWORD=private-fixture')
        self.assertEqual(set(values), {'SUPABASE_URL', 'SUPABASE_ANON_KEY'})

    def test_secret_key_is_rejected(self):
        with self.assertRaises(ValueError):
            public_values('SUPABASE_URL=https://example.supabase.co\nSUPABASE_ANON_KEY=sb_secret_test')

    def test_service_role_jwt_is_rejected(self):
        payload = base64.urlsafe_b64encode(json.dumps({'role': 'service_role'}).encode()).decode().rstrip('=')
        with self.assertRaises(ValueError):
            public_values(f'SUPABASE_URL=https://example.supabase.co\nSUPABASE_ANON_KEY=header.{payload}.signature')

    def test_missing_public_values_are_rejected(self):
        with self.assertRaises(ValueError):
            public_values('GMAIL_APP_PASSWORD=private-fixture')

if __name__ == '__main__':
    unittest.main()
