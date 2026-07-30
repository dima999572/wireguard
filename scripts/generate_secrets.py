import os
import yaml
import base64
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import x25519

# Configuration
CLIENTS = ['phone', 'raspberry', 'windows']
OUTPUT_FILE = '../ansible/secrets/wg_secrets.yaml'

def generate_wg_keypair():
    """Generates a WireGuard compatible private and public key pair."""
    private_key = x25519.X25519PrivateKey.generate()
    private_bytes = private_key.private_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PrivateFormat.Raw,
        encryption_algorithm=serialization.NoEncryption()
    )
    public_key = private_key.public_key()
    public_bytes = public_key.public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw
    )
    return (
        base64.b64encode(private_bytes).decode('utf-8'),
        base64.b64encode(public_bytes).decode('utf-8')
    )

def main():
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)

    # 1. Try to load existing data
    existing_data = {}
    if os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, 'r') as f:
            content = f.read()
            # Safety Check: If the file contains SOPS metadata, do not attempt to parse
            if "sops" in content and "version" in content:
                print("ERROR: The file is encrypted with SOPS.")
                print("Please decrypt it first: sops -d " + OUTPUT_FILE + " > " + OUTPUT_FILE)
                return

            try:
                existing_data = yaml.safe_load(content) or {}
                print(f"--- Loaded existing {OUTPUT_FILE} ---")
            except yaml.YAMLError:
                print("--- Warning: Could not parse YAML. Starting fresh. ---")

    # 2. Initialize structure (Renamed to wireguard_server)
    if 'wireguard_server' not in existing_data:
        existing_data['wireguard_server'] = {}
    if 'wireguard_clients' not in existing_data:
        existing_data['wireguard_clients'] = {}

    # 3. Check/Generate Server Keys
    if 'server_private_key' not in existing_data['wireguard_server']:
        priv, pub = generate_wg_keypair()
        existing_data['wireguard_server']['server_private_key'] = priv
        existing_data['wireguard_server']['server_public_key'] = pub
        print("[+] Generated brand new Server keys.")
    else:
        print("[skip] Server keys already exist.")

    # 4. Check/Generate Client Keys
    for client in CLIENTS:
        if client not in existing_data['wireguard_clients']:
            priv, pub = generate_wg_keypair()
            existing_data['wireguard_clients'][client] = {
                'private_key': priv,
                'public_key': pub
            }
            print(f"[+] Generated keys for: {client}")
        else:
            print(f"[skip] Keys for '{client}' already exist.")

    # 5. Save back to file
    with open(OUTPUT_FILE, 'w') as f:
        yaml.dump(existing_data, f, default_flow_style=False, sort_keys=False)
    
    print(f"\nSuccess! Secrets managed in: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()