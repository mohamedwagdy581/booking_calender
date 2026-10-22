"""Generate client configuration without copying server/mail credentials."""
import base64
import json
from pathlib import Path

PUBLIC_KEYS = ('SUPABASE_URL', 'SUPABASE_ANON_KEY')

def public_values(text):
    values = {}
    for line in text.splitlines():
        if '=' in line and not line.lstrip().startswith('#'):
            key, value = line.split('=', 1)
            if key.strip() in PUBLIC_KEYS:
                values[key.strip()] = value.strip().strip('"').strip("'")
    if any(not values.get(key) for key in PUBLIC_KEYS):
        raise ValueError('Missing public Supabase configuration')
    key = values['SUPABASE_ANON_KEY']
    if key.startswith('sb_secret_'):
        raise ValueError('Server keys must never be bundled')
    if key.count('.') == 2:
        payload = key.split('.')[1]
        role = json.loads(base64.urlsafe_b64decode(payload + '=' * (-len(payload) % 4))).get('role')
        if role != 'anon':
            raise ValueError('Only an anon or publishable key belongs in the app')
    elif not key.startswith('sb_publishable_'):
        raise ValueError('Unrecognized public Supabase key format')
    return values

if __name__ == '__main__':
    values = public_values(Path('.env').read_text(encoding='utf-8-sig'))
    target = Path('assets/config/public.env')
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(''.join(f'{key}={values[key]}\n' for key in PUBLIC_KEYS), encoding='utf-8')
    print('Generated public client configuration (no credentials printed).')
