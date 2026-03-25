# Workflow Optimization Guide

## 🚀 Smart Provisioning

The workflow now intelligently detects changes and skips unnecessary provisioning to save time and costs.

### How It Works

#### 1. **Change Detection Job**
The `detect-changes` job analyzes which files changed in your commit:

```yaml
filters:
  iac:
    - 'iac/**'                    # Infrastructure as Code (Bicep templates)
    - '.github/workflows/**'       # Workflow files
  src:
    - 'src/**'                    # Application source code
```

#### 2. **Conditional Provisioning**
Provisioning **RUNS** when:
- ✅ Manual workflow dispatch (button click in GitHub Actions)
- ✅ Infrastructure files changed (`iac/**`)
- ✅ Workflow file changed

Provisioning **SKIPS** when:
- ⏭️ Only source code changed (`src/**`)
- ⏭️ Only documentation changed (`docs/**`, `README.md`)

#### 3. **Time Savings**

| Scenario | Provision Time | Total Time | Savings |
|----------|---------------|------------|---------|
| **IaC + Code Changes** | ~35 min | ~40 min | Baseline |
| **Code Only Changes** | ⏭️ Skipped | ~5 min | **~35 min saved** |
| **README Only** | ⏭️ Skipped | 0 min | **Not triggered** |

### Example Scenarios

#### Scenario 1: Update Application Code
```bash
# You changed: src/ContosoTraders.Api.Carts/Controllers/CartController.cs
git commit -m "Fix: Update cart calculation logic"
git push
```
**Result:** ⏭️ Provision skipped, only builds and deploys code (~5 min)

---

#### Scenario 2: Update Infrastructure
```bash
# You changed: iac/createResources.bicep
git commit -m "Add: New Azure Function resource"
git push
```
**Result:** ✅ Full provision runs (~40 min)

---

#### Scenario 3: Manual Deployment
```bash
# Click "Run workflow" button in GitHub Actions
```
**Result:** ✅ Full provision always runs (safety override)

---

#### Scenario 4: Documentation Update
```bash
# You changed: README.md
git commit -m "Docs: Update installation instructions"
git push
```
**Result:** 🚫 Workflow not triggered at all (`paths-ignore`)

---

### Benefits

1. **⏱️ Faster Feedback**: Code changes deploy in ~5 minutes instead of ~40 minutes
2. **💰 Cost Savings**: Fewer Azure resource operations = lower costs
3. **🌱 Sustainability**: Reduced compute usage
4. **🔄 More Iterations**: Developers can iterate faster on code changes

### Force Full Provisioning

To force a full provision (even without IaC changes):

**Option 1: Manual Trigger**
1. Go to GitHub Actions
2. Select "contoso-traders-cloud-testing" workflow
3. Click "Run workflow"

**Option 2: Touch IaC File**
```bash
touch iac/createResources.bicep
git commit -am "Trigger: Force provision"
git push
```

### Troubleshooting

**Q: Workflow skipped but I need infrastructure changes?**  
A: Use workflow_dispatch (manual trigger) or commit a change to `iac/` folder

**Q: Why did provision run when I only changed code?**  
A: Check if you also modified workflow or IaC files in the same commit

**Q: Can I disable this optimization?**  
A: Yes, remove the `if: needs.detect-changes.outputs.should-provision == 'true'` condition from the provision job
