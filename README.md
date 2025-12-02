# Bugz CLI

**Bugz** is an elite DevSecOps AI agent that helps you design, generate, secure, and deploy cloud infrastructure with best practices built-in.

## Features

- 🛡️ **Security-First**: Automatically scans infrastructure code with multiple security tools (Trivy, Checkov, Prowler)
- ☁️ **Multi-Cloud**: Supports AWS, GCP, and Azure
- 🤖 **AI-Powered**: Intelligent Infrastructure-as-Code generation and remediation
- 📋 **Compliance**: Built-in support for HIPAA, SOC2, PCI-DSS, and other frameworks
- 🔧 **DevSecOps Workflows**: Automated scanning, fixing, and deployment pipelines

## Installation

Install Bugz with a single command:

```bash
curl -sL https://raw.githubusercontent.com/Bugzidna-Labs/bugz/main/install.sh | bash
```

This will download the latest version and install it to `/usr/local/bin/bugz`.

## Usage

Start the interactive CLI:

```bash
bugz
```

**First-time Setup:**
On your first run, you will need to authenticate:
1. Run `bugz login`
2. Choose your provider (Google or GitHub)
3. Follow the instructions to authenticate

Then interact with Bugz to:
- Generate secure Terraform/OpenTofu infrastructure code
- Run security scans on your IaC
- Get compliance-focused recommendations
- Manage cloud resources across AWS, GCP, and Azure

## Requirements

- macOS or Linux
- Internet connection

## Support

For issues, feature requests, or questions, please visit our [GitHub Issues](https://github.com/Bugzidna-Labs/bugz/issues).

## License

Copyright © 2025 Bugzidna Labs
