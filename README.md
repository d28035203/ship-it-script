# Ship-It Script

Bash deploy helper: per-environment config, dry-run mode, timestamped release directories, and a `current` symlink.

## Usage

```bash
./ship.sh dev --dry-run
./ship.sh staging
./ship.sh prod --dry-run
```

## Config

| File | Fields |
|------|--------|
| `env/dev.env` | `APP_NAME`, `DEPLOY_USER`, `DEPLOY_HOST`, `APP_PATH` |
| `env/staging.env` | same |
| `env/prod.env` | same |

Remote `rsync` / `systemctl` commands are printed (and recorded under dry-run) so you can plug in real hosts without committing secrets.

## License

MIT
