To install required ansible plugin

```bash
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
brew install session-manager-plugin
session-manager-plugin

ansible-galaxy collection list
ansible-galaxy collection install community.aws
```

Misc commands

```bash
aws ssm send-command \
    --document-name "AWS-RunPowerShellScript" \
    --targets "Key=instanceids,Values=i-0459a6460f665a52a" \
    --parameters '{"commands":["Get-Content C:\\winrm_setup.log"]}' \
    --profile iainblack \
    --output text
```

```bash
aws ssm start-session --target i-0459a6460f665a52a --profile iainblack
``