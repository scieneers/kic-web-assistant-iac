## Encrypted secrets in github: Sops
### Encrypting / decrypting commands 
Install sops with [brew install sops](https://github.com/mozilla/sops) for locally working with the encrypted files. 
After the key-ring and key for sops were deployed, secrets can be encoded within a readable file structure and checked into git.

The general command for encrypting secrets: 
`sops --encrypt --gcp-kms projects/<PROJECT_ID>/locations/<KEY-RING-LOCATION>/keyRings/<KEY-RING-NAME>/cryptoKeys/<KEY-NAME> <YAML-JSON-FILE> > <YAML-JSON-FILE>` 
So for our key:
`sops --encrypt --gcp-kms projects/kic-chat-assistant/locations/europe-west3/keyRings/sops/cryptoKeys/sops secrets.json > secrets.enc.json` 
For decrpyting:
`sops --decrypt secrets.enc.json`. 