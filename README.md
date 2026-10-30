# F12221 Inspection ITP — SSL & NSL

Live, shared inspection and UT data entry for the Christmas Island ship loader structures, hosted on **GitHub Pages** with data in **Supabase**.

| File | What it is |
|---|---|
| `index.html` | Project landing page linking to both tools |
| `ssl.html`, `nsl.html` | The SSL and NSL inspection tools |
| `config.js` | Supabase connection settings (the only file you edit) |
| `supabase/schema.sql` | Database tables, access rules, history and live updates (run once) |

## Access rules

- **@franmarine.com.au** addresses: **Editor** automatically, and can manage access (the **Access** tab, last tab in the right-hand panel).
- **Everyone else**: must be added in the Access tab first. They start as **Viewer** (see live data, export to the ITP workbook / CSV, cannot change anything). Change their role to **Editor** in the Access tab to let them enter readings; change it back or **Remove** them at any time.
- Sign-in is by emailed link (no passwords). Every save is stamped with who and when, and all previous versions are kept in `member_history`.

## One-time setup (about 30 minutes)

### 1. Supabase project
1. Sign up at supabase.com → **New project** → region **Sydney (ap-southeast-2)**. Note the database password somewhere safe.
2. **SQL Editor → New query** → paste all of `supabase/schema.sql` → **Run**.
3. **Project Settings → API**: copy the **Project URL** and the **anon public** key into `config.js`.

### 2. Email for sign-in links (required)
Supabase's built-in email only delivers to members of your Supabase team and only 2 per hour, so outside users would never get a link. Set up your own sender:
- **Authentication → Emails → SMTP Settings → Enable custom SMTP**, using either
  - a Franmarine Microsoft 365 mailbox (e.g. `no-reply@franmarine.com.au`; host `smtp.office365.com`, port 587 — IT must allow SMTP AUTH on that mailbox), or
  - a transactional email service such as Brevo, Resend or SendGrid (IT adds their DNS records for franmarine.com.au).
- **Authentication → Rate Limits**: raise "emails per hour" to suit (e.g. 100).
- **Authentication → Sign In / Providers → Email**: keep **Confirm email ON** (it is by default) — this is what proves an address really is @franmarine.com.au.

### 3. GitHub Pages
1. Create a repository (e.g. `f12221-inspection`) and upload all of these files (keep the `supabase` folder and `.nojekyll`).
2. **Settings → Pages → Build and deployment → Deploy from a branch → main / (root)** → Save. After a minute the site is at `https://<your-user>.github.io/f12221-inspection/`.
3. Back in Supabase: **Authentication → URL Configuration** → set **Site URL** to that address and add `https://<your-user>.github.io/f12221-inspection/**` to **Redirect URLs**.

### 4. Check
Open the site, choose SSL, sign in with your Franmarine address, open the link from the email. The header pill should read **Live · Editor** and the **Access** tab should appear. Add an outside address as Viewer and test with it.

## Cost
Free to set up and trial. Free Supabase projects pause after 7 days without use, so move to **Pro (about US$25/month)** for the live campaign and downgrade afterwards. GitHub Pages is free (a public repository is fine: no data or secrets are stored in it).

## Notes
- Data is stored per member, so two people working on different members never clash; if two people change the same member at once, each person's own changed fields are kept and merged.
- Without signing in (or with `config.js` blank) the tools run in **Local only** mode: data stays in that browser — use Save backup / Load backup.
- `Load backup` while signed in as an Editor replaces the team's copy (after a confirmation).

## Change log
- **2026-10-30** — UT report: Franmarine style (Calibri, navy, logo, UNCONTROLLED WHEN PRINTED footer); 3D pictures added — location on the structure and the member with its reading points on the report page, and a close-up of the grid on each defect sheet.
- **2026-10-30** — Export UT report (Excel): one report per member in a simple single-page layout (test conditions, one row per ring / additional point / defect, result, sign-off), plus Readings and defect detail sheets. New Inspection details fields: UT unit, serial no., probe, calibration block, couplant, technique, surface condition. The previous ITP workbook export is kept.
- **2026-10-30** — Export all data (CSV): every reading on the structure (rings, additional points, defect grid / edge / pit readings) with point IDs, plus one row per defect. The single-member export is now labelled Export member CSV.
- **2026-10-29** — Access jetty added to both models as a visual reference (Layers → Access jetty): SSL per 63X30Z/M61, NSL per 76-X30E/M33A. Not inspected.
- **2026-10-29** — Member ID fills in automatically as structure + member (e.g. SSL-NW-21, NSL-P29-S2); it is the ITP document number. Editable; clearing it restores the default.
- **2026-10-29** — Compass marks moved above the structure; labels are hidden while a member is between them and the viewer.
- **2026-10-29** — Layers → Member IDs: shows each member's ID on the model (nearest labels only, more appear as you zoom in).
- **2026-10-29 (pm)** — SSL rebuilt from the engineer's model (SSL_Substructure DWG): 600 members — towers NW/NE/SW-01 … -104 and SE-01 … -80 (no base frame under SE), tie bracing TN/TE/TS/TW-01 … -52 (outer frame, inner frame, plan bracing). Member sizes from the model shown as OD / WT hints. Member IDs issued earlier on 29 Oct do not carry over.
- **2026-10-29** — SSL member IDs renumbered: tower + number from the top down (NW-01 … NW-88), the same number for the same position on every tower; inter-tower bracing by elevation (TN, TE, TS, TW -01 … -14). Previous IDs in saved data, backups and scope lists convert automatically. SSL bracing corrected to one diagonal per bay with tie bracing on the outside elevations (28 Oct).
- **2026-10-28** — Scopes (project / phase member lists, e.g. client-nominated repair members): highlight on the model, list with progress, CSV export. Stored in the existing shared record — no database change.
- **2026-10-28** — Fix: defects could not be saved on a member after its data was loaded from the shared database. Fix: defect list reading count now updates as readings are entered.

## Updating the app
Upload the new `ssl.html` and `nsl.html` to the repository (Add file → Upload files, replace existing) and commit. GitHub Pages republishes in 1–2 minutes. Users press Ctrl+F5 (Cmd+Shift+R on Mac) to load the new version. Data in Supabase is untouched.
