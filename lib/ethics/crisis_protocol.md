# 🚨 Incident Response & Crisis Protocol

This protocol defines the standard operating procedures (SOP) for identifying, mitigating, and resolving critical incidents within the application ecosystem.

---

## 🛑 Severity Levels


| Severity | Definition | Target Response (TTA) | Target Resolution (TTR) |
|---|---|---|---|
| **P0 (Critical)** | Core app features down (Auth, Journaling, Encryption failures). Data loss or active security breach. | < 15 mins | < 2 hours |
| **P1 (High)** | Major feature degraded (Push notifications down, AI insights failing, edge functions slow). | < 30 mins | < 6 hours |
| **P2 (Medium)** | Minor feature malfunction (Analytics, UI/UX glitch, non-blocking errors). | < 4 hours | < 24 hours |

---

## 🛠️ Incident Response Workflow

```text
[Detection] ──> [Triage & Classification] ──> [Mitigation / Hotfix] ──> [Post-Mortem]
```

### 1. Detection & Alerting
* **Client-Side:** Real-time exceptions routed from `LogService` / `runZonedGuarded` to the Crash Reporting Pipeline.
* **Server-Side:** Supabase HTTP 5xx spikes or execution failures triggered via Edge Function logs.
* **Security:** Monitoring unauthorized JWT attempts or batch failures in the `cryptoSessionProvider`.

### 2. Immediate Containment Actions

#### Scenario A: Supabase Edge Functions / Database Down (P0)
1. **Verify Infrastructure:** Check [Supabase Status Page](https://supabase.com).
2. **Enable Maintenance Mode:** If the database is corrupted or requires immediate migration, toggle the global environment flag to force the client app into a blocking maintenance screen.
3. **Rollback Deployment:** If caused by a bad edge function update, immediately rollback using:
   ```bash
   supabase functions deploy send-notification --project-ref your_project_ref
   # (Re-deploy previous stable Git commit state)
   ```

#### Scenario B: Crypto / Key Sync Corruption (P0)
If users report an inability to decrypt their local journal entries (`decryptText()` fails gracefully but systematically):
1. **Stop Writes:** Deploy an immediate remote config block or feature flag update to disable new journal entry creation to prevent data overwrites.
2. **Isolate Backend Fallback:** Audit the `cryptoSessionProvider` resolution chain. If the backend fallback recovery mechanism is serving corrupted key payloads, temporarily isolate the recovery endpoint.

#### Scenario C: Firebase Cloud Messaging (FCM) Token Rotation Loop (P1)
If server logs show massive DB writes on the `user_devices` table due to `onTokenRefresh` loops:
1. **Disable Edge Function Ingestion:** Temporarily revoke or rate-limit the Service Role permission for the `send-notification` function.
2. **Apply Database Rate Limiting:** Run a Postgres patch to restrict rapid concurrent upserts on the `user_devices` table.

---

## 🔒 Security Breach Protocol (Data / Crypto Compromise)

Given that journal entries are protected with local **AES-256-GCM**, a server breach does not expose plaintext user data. However, if a vulnerability is found in the Key Lifecycle:

1. **Rotate Master Credentials:** Immediately invalidate and rotate all environment variables in the Supabase Dashboard:
   * `SUPABASE_SERVICE_ROLE_KEY`
   * `FCM_PRIVATE_KEY`
2. **Enforce Client Session Invalidation:** Execute a remote database command to terminate all active user JWT sessions, forcing the client app to run `clearSession()` and purge the local platform keychain if security parameters are violated.
3. **Emergency Patch:** Push a mandatory update via Google Play Store / Apple App Store utilizing a "Force Update" blocking dialog enforced by `AppConfig.init()`.

---

## 📝 Communication & Post-Mortem Template

Every P0/P1 incident requires a written post-mortem within 48 hours of resolution.

```markdown
### 📋 Incident Report: [Incident ID / Date]

* **Date/Time (UTC):** YYYY-MM-DD HH:MM
* **Duration:** X hours, Y minutes
* **Severity:** P0 / P1
* **Lead Engineer:** [Name]

#### 🔍 1. Executive Summary
[Brief description of what went wrong, user impact, and how it was fixed.]

#### 📈 2. Timeline
* **HH:MM** - Incident detected via [Alert System/User Report].
* **HH:MM** - Triage complete; classified as P[X].
* **HH:MM** - Mitigation strategy implemented ([e.g., Hotfix deployed / Config reverted]).
* **HH:MM** - Systems stabilized and fully operational.

#### 🪵 3. Root Cause Analysis (RCA)
[Detailed explanation of the technical failure, including relevant code blocks, edge cases, or infrastructure issues.]

#### 🛡️ 4. Preventative Actions
- [ ] Action item 1 (e.g., Add stricter unit testing for `cryptoSessionProvider`)
- [ ] Action item 2 (e.g., Configure automatic PagerDuty alerts for Supabase 5xx errors)
```

