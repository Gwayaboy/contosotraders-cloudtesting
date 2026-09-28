# TfL AI-Assisted Testing Hack Day — Track 3 (Optional): Azure Load Testing & Chaos Studio

> **Optional back-pocket track.** Two cloud exercises — **performance** (Azure Load Testing) and
> **resilience** (Azure Chaos Studio) — run against a **live, already-deployed** Contoso Traders
> environment. Nothing to deploy: you just need portal access to the subscription hosting the app.

Contoso Traders is a microservices e-commerce app — React UI, a **Carts API** on Azure Container
Apps, a **Products API** on AKS, plus Cosmos DB, Azure SQL and Key Vault. It's the richer cloud
target for the performance/resilience part of the day: the local movies app is great for *learning*
JMeter, but this is where you drive **real distributed load** and **inject faults**.

> This guide is deliberately scoped to **Load Testing and Chaos Studio only**. For the other
> Contoso Traders demos (Developer Workflow, Playwright) see the [main README](./README.md).

## Live environment (region: swedencentral)

| Service | URL | Hosted on |
|---------|-----|-----------|
| **UI (main app)** | https://contoso-traders-ui2ct26-budwfddfdjfbc7db.z03.azurefd.net/ | Storage + Front Door |
| **Carts API** (Swagger) | https://contoso-traders-cartsct26.happyrock-fb72c3f0.swedencentral.azurecontainerapps.io/swagger/index.html | Azure Container Apps |
| **Products API** (Swagger) | https://contoso-traders-productsct26.swedencentral.cloudapp.azure.com/swagger/index.html | AKS |

**Azure resources** (resource group `contoso-traders-rgct26`):

| Purpose | Resource name |
|---------|---------------|
| Load Testing service | `contoso-traders-loadtestct26` |
| Application Insights | `contoso-traders-aict26` |
| Key Vault (chaos target) | `contosotraderskvct26` |
| Chaos experiment — Key Vault deny access | `contoso-traders-chaos-kv-experimentct26` |
| Chaos experiment — AKS pod failures | `contoso-traders-chaos-aks-experimentct26` |

- **Load-test target endpoint:** `GET {Carts API base}/v1/ShoppingCart/loadtest`

> These endpoints are live now. If they stop responding (the environment may be torn down after the
> event), redeploy via the [deployment instructions](./docs/deployment-instructions.md) — it's a
> single GitHub Actions run against a **personal MSDN / sandbox** subscription, never a TfL one.

---

## Exercise 1 — Azure Load Testing (performance)

**Goal:** put the Carts API under load, push it to its breaking point, and use server-side metrics
to find the bottleneck (Cosmos DB RU saturation) — then guard against regressions in CI.

**Quick path:**
1. In the Azure portal, open the **Azure Load Testing** resource `contoso-traders-loadtestct26` in `contoso-traders-rgct26`.
2. Create a **URL-based test** against `GET {Carts API}/v1/ShoppingCart/loadtest` (start ~5 users, 120s).
3. Run it, then add the **Cosmos DB** app component to overlay **server-side metrics**.
4. Ramp to ~**250 users / 300s** to drive it to failure, then open **App Insights** (`contoso-traders-aict26`) → **Failures** to find the root cause (500s from a Cosmos gateway timeout).
5. See how the **GitHub Actions** workflow runs the same load test in CI with pass/fail criteria (e.g. `avg(response_time_ms) > 5000`).

👉 **Full step-by-step with screenshots:** [demo-scripts/azure-load-testing/walkthrough.md](./demo-scripts/azure-load-testing/walkthrough.md)
Extras: [regression testing in CI](./demo-scripts/azure-load-testing/walkthrough.md#walkthrough-regression-testing-with-github-workflows) · [private endpoints behind a VNet](./demo-scripts/azure-load-testing/private-endpoints.md) · [right-size your AKS cluster](./demo-scripts/azure-load-testing/aks-cost-optimization.md)

---

## Exercise 2 — Azure Chaos Studio (resilience)

**Goal:** inject a real fault, watch the app degrade, then recover — testing *resilience*, not just
speed. The Products API reads its DB connection string from Key Vault on startup, so denying Key
Vault access is a great way to expose a resiliency gap.

**Quick path:**
1. In the Azure portal, open **Chaos Studio** → **Experiments** and select `contoso-traders-chaos-kv-experimentct26` (targets Key Vault `contosotraderskvct26` with a **Key Vault Deny Access** fault for 5 min).
2. Confirm the app works first: open the UI and click a product category (e.g. *laptops*).
3. **Start** the experiment.
4. Force the Products API pod to restart (delete it) so it must re-read Key Vault → it fails to start → the category page breaks. This exposes the resilience issue.
5. When the 5 minutes end, Key Vault access returns and AKS restarts the pod cleanly — the app recovers.
6. Explore the CI angle: `contoso-traders-chaos-aks-experimentct26` injects **pod failures** (via [Chaos Mesh](https://chaos-mesh.org/)) into the AKS cluster while a load test runs simultaneously.

👉 **Full step-by-step with screenshots:** [demo-scripts/azure-chaos-studio/walkthrough.md](./demo-scripts/azure-chaos-studio/walkthrough.md)

---

## The AI angle (what makes this a hack, not a click-through)

Use **GitHub Copilot** to:
- Draft **NFRs / SLAs** first — e.g. *"Carts API p95 < 1s at 250 concurrent users, error rate < 1%"*.
- Generate or tweak the **JMeter (JMX)** plan and the load-test pass/fail YAML.
- Interpret the **App Insights** failure stack traces and explain the Cosmos bottleneck in plain English.
- Write a short **pass/fail performance report** from the results — moving the conversation from
  *"CPU was 80%"* to *"we met / missed the NFR, and here's why"*.

## More

- [Azure Load Testing docs](https://learn.microsoft.com/azure/load-testing/) · [Azure Chaos Studio docs](https://learn.microsoft.com/azure/chaos-studio/)
- Back to the hack day: [TfL AI-Assisted Testing Hack Day repo](https://github.com/Gwayaboy/tfl-ai-assisted-testing-hackday)
