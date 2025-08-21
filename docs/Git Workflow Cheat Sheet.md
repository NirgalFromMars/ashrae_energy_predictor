# 📝 Git Workflow Cheat Sheet

This document provides the most common Git commands to work with this repository.

---

## 🔄 Keeping your local repo up-to-date

Always **pull first** before making changes locally:

```bash
git pull origin main


➕ Adding and committing changes

After editing or creating files:

git add .
git commit -m "Describe your changes here"


Examples of good commit messages:

Update README with new screenshots

Add preprocessing notebook

Fix SQL query for gold_features


⬆️ Pushing changes to GitHub

Once committed, push your changes:

git push origin main


🌐 Typical workflow

1. Sync with remote:

git pull origin main


2. Make changes (edit files, add notebooks, etc.)

3. Stage and commit:

git add .
git commit -m "Your message"

4. Push to GitHub:

git push origin main



🛠️ Useful commands

Check repo status:

git status


See commit history:

git log --oneline --graph --decorate


Cancel local changes (⚠️ careful):

git checkout -- filename


Create and switch to a new branch:

git checkout -b feature-branch


Switch back to main branch:

git checkout main



✅ Best practices

Always git pull before starting work.

Write clear and short commit messages.

Use branches for larger features or experiments.

Push often to avoid losing work.