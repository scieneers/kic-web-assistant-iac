## Encrypted secrets in github: Sops
### Encrypting / decrypting commands 
Install sops with [brew install sops](https://github.com/mozilla/sops) for locally working with the encrypted files. 
After the key-ring and key for sops were deployed, secrets can be encoded within a readable file structure and checked into git.

The general command for encrypting secrets: 
`sops --encrypt secrets.json > secrets.enc.json` 
For decrpyting:
`sops --decrypt secrets.enc.json`. 

Sops is configured in the root directory in the file '.sops.yaml' 