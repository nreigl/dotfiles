# Security Best Practices for Dotfiles

## 🔐 General Principles

1. **Never commit secrets** - Use `.gitignore` and templates
2. **Use secret managers** - 1Password CLI, pass, or similar
3. **Rotate credentials regularly** - Set calendar reminders
4. **Principle of least privilege** - Only grant necessary permissions
5. **Audit regularly** - Review your dotfiles for accidental secrets

## 🚫 What NOT to Commit

### Never commit these files:
- `.zsh_secrets`
- `.env`
- `.env.local`
- `.env.*.local`
- `*.pem`
- `*.key`
- `*.p12`
- `*.pfx`
- `.npmrc` (with auth tokens)
- `.pypirc`
- `.netrc`
- `.aws/credentials`
- `.docker/config.json` (with auth)
- `gh/hosts.yml` (GitHub CLI auth)
- SSH private keys (`id_rsa`, `id_ed25519`, etc.)

### Patterns to watch for:
```bash
# API Keys
API_KEY=...
SECRET_KEY=...
TOKEN=...
PASSWORD=...

# URLs with credentials
https://user:pass@domain.com
postgresql://user:pass@localhost/db

# Base64 encoded secrets
echo "base64string" | base64 -d
```

## 🛡️ Secure Practices

### SSH Configuration
- Use Ed25519 keys: `ssh-keygen -t ed25519`
- Always use passphrases on private keys
- Use SSH agent or 1Password SSH agent
- Enable `StrictHostKeyChecking`
- Disable `ForwardAgent` unless necessary

### Git Configuration
```bash
# Sign commits with GPG
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_KEY_ID

# Use SSH for GitHub/GitLab
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

### Environment Variables
```bash
# Source secrets from secure file
if [[ -f ~/.zsh_secrets ]]; then
    source ~/.zsh_secrets
fi

# Or use 1Password CLI
export GITHUB_TOKEN="$(op read op://Personal/GitHub/token)"
```

### File Permissions
```bash
# Secure your secret files
chmod 600 ~/.zsh_secrets
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

## 🔍 Detecting Secrets

### Pre-commit Hooks
Install pre-commit hooks to catch secrets:
```bash
# Install pre-commit
brew install pre-commit

# Add to .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
```

### Manual Scanning
```bash
# Search for potential secrets
rg -i "api[_-]?key|secret|token|password|pwd" --type-not md

# Check git history for secrets
git log -p | rg -i "api[_-]?key|secret|token|password"

# Use dedicated tools
brew install truffleHog
trufflehog git file://./
```

## 🔄 Secret Rotation

### If You Accidentally Commit Secrets:
1. **Immediately rotate the compromised credentials**
2. Remove from repository:
   ```bash
   # Remove file from history (destructive!)
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch PATH_TO_FILE" \
     --prune-empty --tag-name-filter cat -- --all
   ```
3. Force push to remote (coordinate with team)
4. Consider the secret permanently compromised

### Regular Rotation Schedule
- **GitHub tokens**: Every 90 days
- **API keys**: Every 6 months
- **SSH keys**: Annually
- **Passwords**: When changed upstream

## 🔑 Secret Management Tools

### 1Password CLI
```bash
# Install
brew install --cask 1password-cli

# Sign in
eval "$(op signin)"

# Use in scripts
export TOKEN="$(op read op://vault/item/field)"
```

### macOS Keychain
```bash
# Store secret
security add-generic-password -s "service" -a "account" -w

# Retrieve secret
security find-generic-password -s "service" -a "account" -w
```

### Pass (Password Store)
```bash
# Install
brew install pass

# Initialize
pass init YOUR_GPG_ID

# Store/retrieve
pass insert tokens/github
export GITHUB_TOKEN="$(pass tokens/github)"
```

## 📋 Checklist

Before committing:
- [ ] Run `git diff --staged` to review changes
- [ ] Check for hardcoded secrets
- [ ] Ensure `.gitignore` is updated
- [ ] Verify file permissions are correct
- [ ] Test with clean clone on another machine

## 🆘 Emergency Contacts

If you accidentally expose secrets:
1. **GitHub**: Immediately revoke at https://github.com/settings/tokens
2. **AWS**: Use IAM console to rotate keys
3. **API Providers**: Check their security settings
4. **Your Organization**: Notify security team if applicable

## 📚 Additional Resources

- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [1Password Developer Tools](https://developer.1password.com/)
- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)