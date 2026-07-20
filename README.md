## Encrypted secrets in github: Sops
### Encrypting / decrypting commands 
Install sops with [brew install sops](https://github.com/mozilla/sops) for locally working with the encrypted files. 
After the key-ring and key for sops were deployed, secrets can be encoded within a readable file structure and checked into git.

The general command for encrypting secrets: 
`sops --encrypt secrets.json > secrets.enc.json` 
For decrpyting:
`sops --decrypt secrets.enc.json`. 

Sops is configured in the root directory in the file '.sops.yaml' 

## Deployment

### Standard changes

```
task tf-plan ENV=dev   # or prod
task tf-apply ENV=dev
```

### First-time setup for a new/rebuilt environment

The Redis sidecar on `restapi` lives outside Terraform state (the azurerm
provider doesn't support App Service sidecar containers yet:
[hashicorp/terraform-provider-azurerm#25167](https://github.com/hashicorp/terraform-provider-azurerm/issues/25167)).
After destroying/recreating the environment (or standing up a new one), run
in this exact order:

1. `task tf-apply ENV=dev` — creates the base infra (ACR, identity, App Service Plan, `restapi` app, etc.).
2. `task refresh-redis-image ENV=dev` — mirrors `redis/redis-stack-server` into the ACR. Must happen before step 4, otherwise the sidecar has no image to pull.
3. `task convert-to-sitecontainers ENV=dev` — **one-time per App Service.** Switches `restapi` from the classic single-container model (`linuxFxVersion=DOCKER|...`) to the sitecontainers/sidecar model (`linuxFxVersion=SITECONTAINERS`). Without this, any sidecar you create in step 4 is silently inert — the platform never schedules it, with no error anywhere. Safe to re-run if unsure whether it already ran.
4. `task deploy-sidecar ENV=dev` — creates/updates the `redis-checkpointer` sitecontainer, pulling from the ACR (step 2) via the app's managed identity.

Steps 2-4 must be repeated any time the `restapi` App Service itself is
recreated. `terraform apply` alone will not restore the sidecar — this is
intentional; see the `lifecycle.ignore_changes` comment on
`azurerm_linux_web_app.restapi` in `environments/main.tf`, which deliberately
keeps Terraform's hands off `site_config` so it doesn't flip `linuxFxVersion`
back to `DOCKER|...` on a later apply.

### Ongoing maintenance

- `task refresh-langfuse-image ENV=dev` — re-pulls the latest `langfuse:2.x` patch into the ACR (Langfuse doesn't auto-update its own ACR mirror). Run whenever you want the newest v2 patch; must stay on the `2` major-version tag, not `3` — see the `langfuse` app's `docker_image_name` in `environments/main.tf`.
- `task refresh-redis-image ENV=dev` — re-imports the pinned `redis-stack-server` tag into the ACR. Run after bumping the tag in `scripts/refresh-redis-image.sh` and `scripts/deploy-sidecar.sh`, then follow up with `task deploy-sidecar ENV=dev` to point the sitecontainer at the new tag.
