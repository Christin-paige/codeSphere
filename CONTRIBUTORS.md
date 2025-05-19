# 🤝 Contributing to Codesphere

First off, thank you for your interest in contributing to Codesphere! This is a community-driven project built on collaboration, curiosity, and a shared love for building in public.

Whether you're submitting a bug fix, feature, documentation improvement, or helping with security, we're excited to have you here.

---

## 🚀 How to Get Started

1. **Clone this repo**
2. **Create a new branch** (`git checkout -b my-branch`)
3. **Make your changes**
4. **Commit with clear messages**
5. **Push to your branch**
6. **Submit a pull request to the `development` branch**

Keep your PR focused and descriptive. If you're fixing a bug or adding a feature, include context so we understand what you're solving.

---

## 🧑‍💻 Developer Setup & Local Security Checks

To keep your pull requests clean and passing all CI checks, here’s how to run the same security and formatting tools we use in GitHub Actions, locally:


### ✅ Prettier – Code Formatter

```bash
npx prettier . --check    # Check for formatting issues
npx prettier . --write    # Auto-format your files
```

This keeps the codebase clean and consistent.

---

### ✅ ESLint – Code Linting

```bash
npx eslint .              # Identify code issues
npx eslint . --fix        # Fix fixable ones
```

Run this before pushing to make sure your code follows project linting rules.

---

### ✅ Gitleaks – Secret Scanning

To avoid committing sensitive info like API keys or tokens:

1. [Install Gitleaks](https://github.com/gitleaks/gitleaks#installation)
2. Run this in the project root:

```bash
gitleaks detect --source . --redact
```

This helps catch secrets before they hit GitHub.

---

### 🟡 CodeQL – (Optional for Contributors)

CodeQL scans your code for security vulnerabilities. It runs automatically in CI.

You only need to run it locally if you’re developing CodeQL rules or debugging a specific result. Learn more:  
[https://docs.github.com/en/code-security/codeql-cli](https://docs.github.com/en/code-security/codeql-cli)

---

### 🔒 Dependabot

Dependabot automatically scans for vulnerable dependencies and opens pull requests.

If you want to manually check for issues or outdated packages:

```bash
npm audit
npm outdated
```

---

## ✨ Code Style & Practices

- Use consistent formatting (Prettier, ESLint, etc.)
- Break large features into small, reviewable chunks
- Avoid pushing commented-out code or unrelated changes
- Write meaningful commit messages (e.g., `fix: sanitize user input in form`)

---

## 🔐 Secure Coding Practices

We care deeply about security and ask that you keep the following principles in mind when contributing:

### Input Validation & Sanitization

- **Character Encoding:**  
  Always specify and enforce UTF-8 for all input sources to prevent encoding-related attacks.

- **Validation Techniques:**  
  Use *allow-list validation* for input—only accept what you expect. Check data types, ranges, and lengths before processing.

- **Sanitize Outputs:**  
  Escape and sanitize user input when outputting it to the DOM, APIs, command line, or database.

### General Secure Development Practices

- **Secrets Handling:**  
  Never commit API keys, tokens, or sensitive info. Use `.env` files and ensure `.env` is in `.gitignore`.

- **Avoid Injection:**  
  Use parameterized queries and avoid string concatenation in SQL or shell commands.

- **Authentication & Authorization:**  
  If your changes interact with user accounts or permissions, think about least privilege and access control.

- **Log Carefully:**  
  Don’t log anything sensitive like passwords, tokens, or personally identifiable data.

### Bonus Points

We love when contributors go the extra mile by:

- Adding unit tests
- Updating related documentation
- Leaving inline comments explaining tricky logic

---

## 🛡️ Reporting Security Issues

Please do **not** open GitHub issues for anything security-related. Instead, follow our [security policy](./SECURITY.md) to report vulnerabilities responsibly.

---

## ❤️ Acknowledgments

All contributors, whether you write code, spot bugs, suggest ideas, or help with security—make this project better. Thank you!

---

We’re excited to build Codesphere with you.
