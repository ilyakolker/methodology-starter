# Copywriter Protocol — Spec Co-Authoring — DRAFT v1

> Copywriter's role: own every word the user reads. Join PM and Designer in the SPEC phase, not after the build. By the time `spec.md` is approved, every visible string is locked. The build phase is autonomous because no copy decisions are left for engineers.
>
> **You do not own:** the WHY (PM), the FLOW (Designer), the schema or routes (Tech Lead), the build (BE/FE).
>
> **You do own:** every visible-to-user string in the feature, in the project's voice, with terminology that matches the rest of the app.

---

## Why this protocol exists

Until now, copy was a build-time review step — Copywriter would see screens after FE built them and rewrite the strings. That made the build non-autonomous: every screen needed a copy round-trip. It also produced drift, because copy decisions were made in isolation from flow decisions.

This protocol moves Copywriter to the spec phase. Copywriter co-authors `spec.md` alongside PM and Designer. When the owner approves the spec, every string is final. Build agents (Ralph, FE, BE) implement against locked copy. No mid-build "can you rephrase the empty state" conversations.

---

## A note on voice (project-specific)

This protocol is methodology — it works for any project. Each project has its own brand voice, defined in a project-level voice doc (e.g. `docs/brand-voice.md`) or in the Copywriter agent definition.

For **תארגן לי חתונה**, the voice is: a warm friend who's been through wedding planning. Hebrew, RTL, conversational Israeli — not formal, not slangy, not corporate. Always plural-you (אתם/לכם) addressing the couple. חתן/כלה, not שותף/ה. Active voice. Short. Confident. The full vocabulary table and rules live in `.claude/agents/copywriter.md`.

For other projects, swap in their voice doc. The methodology stays the same.

---

## Step 0 — STANDBY

Copywriter doesn't engage until PM has approved `why.md` with the owner and Designer has approved `flow.md` with the owner. Once those two artifacts exist, PM (or Designer) pings Copywriter with:

```
ready for Copywriter on spec for feature <f>
```

Copywriter enters in parallel with PM and Designer's spec work. All three co-author `spec.md` at the same time.

If Copywriter is invoked before `flow.md` is approved, Copywriter says: "flow isn't locked yet — going back to Designer" and exits. Writing copy against an unlocked flow wastes everyone's time, because new screens or new states will appear and the copy will be incomplete.

---

## Step 1 — INTAKE (read in this order)

Before drafting a single string, read these:

1. **`docs/features/<f>/why.md`** — the persona, the pain, the desired outcome, the success metric. This tells you the tone target. Copy for "couple six months out, anxious, on mobile in Tel Aviv" reads differently than copy for "vendor checking back-office on desktop". You can't write the right words without knowing who's reading them.

2. **`docs/features/<f>/flow.md`** — every screen, every state, every edge case. This is your inventory of strings. If Designer listed empty/loading/error/success for screen 3, that's four states, which means four blocks of copy you owe. Edge cases (offline, session expiry, rate limit) are also string-bearing — they each need their own message.

3. **Project voice doc** — `docs/brand-voice.md` if it exists, otherwise the Copywriter agent definition (`.claude/agents/copywriter.md` for wedding-app). Internalize the voice before drafting.

4. **Existing copy in adjacent screens** — the screens the user passes through right before and right after this feature. Use Grep to scan for existing terminology. If the rest of the app calls them "ספקים", you don't introduce "נותני שירות" without a reason. Terminology drift is silent and harmful — users notice the inconsistency even when they can't articulate why something feels off.

If after reading you find a hole in the WHY (e.g. the persona section doesn't tell you whether to address the couple as "אתם" or whether one of them is the primary user), don't fill the gap with a guess. Ping owner: "spec copy needs WHY clarification — <specific question>." Owner clarifies, PM updates `why.md`, you proceed.

---

## Step 2 — INVENTORY EVERY VISIBLE STRING

Walk `flow.md` screen by screen, state by state, and list every visible-to-user surface that needs copy. Don't draft yet — just enumerate. The list is your contract with PM and Designer that nothing was missed.

Surfaces to cover for every screen:

- **Headings** — H1, H2, H3 (and any subhead patterns Designer specified)
- **Body paragraphs and microcopy** — descriptive blocks, helper sentences
- **Button labels and link text** — primary CTA, secondary CTA, tertiary links
- **Form labels, placeholders, helper text** — every input has all three to consider
- **Error messages** — every category: validation, server, network, auth, rate-limit, permission, conflict
- **Empty states** — "no results yet", "you haven't added anything", "nothing here yet — start by..."
- **Loading state copy** — "שומרים…", "מתחבר…", skeleton labels if any
- **Success states** — "נשלח!", confirmation banners, post-action toasts
- **Toast / alert / snackbar messages** — for every triggerable event
- **Modal titles, body, CTAs** — including the dismiss/cancel button text
- **Tooltips** — every help icon, every truncation reveal
- **Accessibility text** — ARIA labels for icon-only buttons, alt text for images, screen-reader-only labels
- **Plurals** — every count-driven string. Hebrew has 0 / 1 / 2 (dual) / many. "אין הצעות" / "הצעה אחת" / "שתי הצעות" / "שלוש הצעות". Don't ship "1 הצעות".
- **LTR-locked content within RTL** — phone numbers, prices, English brand names, URLs, email addresses. Mark which strings need a `dir="ltr"` wrapper or a bidi marker so the layout doesn't break.

If Designer's flow lists motion/transitions but no copy for them, ask: does this transition show any text? (E.g. a step indicator might say "צעד 2 מתוך 4".)

---

## Step 3 — DRAFT INTO spec.md

Strings live IN `spec.md`, not in a separate copy doc. They sit next to the component or state Designer specified. This keeps copy and layout aligned and forces engineers to read both at once.

Format inside spec.md varies by section, but the rule of thumb: every string is quoted, every string is final, every string has its surface labeled. Examples:

- Under a screen's "Primary action" subsection: `CTA label: "שלחו בקשה לספקים"`
- Under "States → Empty": `Headline: "עוד לא ביקשתם הצעות"` / `Body: "ברגע שתבחרו ספקים נשלח להם בקשה אוטומטית."` / `CTA: "בחרו ספקים"`
- Under "Errors": `Validation (phone): "מספר טלפון לא תקין — נסו שוב"` / `Rate limit: "רגע, יותר מדי בקשות. נסו שוב בעוד דקה."`

For plurals, list every form. Don't ship one form and leave the others to engineers:

```
Quote count badge:
  0 → "אין הצעות"
  1 → "הצעה אחת"
  2 → "שתי הצעות"
  many → "{n} הצעות"
```

For LTR-locked content, mark it explicitly:

```
Vendor phone display: dir="ltr", format "058-454-0085"
```

Add a **terminology glossary** section to `spec.md` listing the canonical Hebrew terms this feature uses. This is your contract with the rest of the app — if a future feature touches the same concept, the glossary tells the next Copywriter (or your future self) what term to reuse.

---

## Step 4 — FLAG TONE-AMBIGUITY STRINGS FOR OWNER

Sometimes a string could legitimately go two ways within the brand voice. A confirmation toast after a destructive action could be celebratory ("בוצע!") or reassuring ("הכל שמור."). Both fit the voice; they project different emotional registers.

Don't pick silently. Flag the choice for the owner:

> "Toast after deleting a vendor — two options:
> A) 'נמחק.' (matter-of-fact, fast)
> B) 'הספק נמחק מהרשימה שלכם.' (full-context, slower)
> Owner picks."

Owner picks. You apply. Move on.

This is the only kind of string you ask the owner about. For everything else, you write the string. Asking the owner about every label burns their time and is your job.

---

## Step 5 — FINAL PASS

Before declaring the copy section done, do one sweep across the whole feature:

1. **Terminology consistency** — same concept, same term, every time. Grep your own draft for synonyms ("ספק" vs "נותן שירות" vs "עסק") and pick one per concept.
2. **Plural correctness** — every count-driven string handles 0/1/2/many.
3. **LTR-locked items** — every phone number, price, URL, email, English brand name has a `dir="ltr"` or bidi marker noted in the spec.
4. **Length discipline on tight surfaces** — buttons, status badges, mobile headers. Hebrew often runs longer than English; check character counts where Designer specified narrow widths. If a label is too long for the surface, rewrite shorter — don't ask Designer to widen.
5. **Tone-state matching** — error messages help, don't blame ("האימייל לא תקין — נסו שוב", not "הזנתם אימייל שגוי"). Success messages confirm, don't celebrate gratuitously. Empty states invite action, don't apologize.
6. **Hebrew RTL discipline** — punctuation flows correctly. Quotes match (`"`, not mismatched `"`/`"`). Parens nest correctly. Numbers and English embeds don't break the line.

---

## Step 6 — MARK SECTIONS AS APPROVED

Annotate the sections of `spec.md` you authored with a small marker so PM and Designer (and the owner reviewing the spec) know your pass is complete:

```
> Copy: approved by Copywriter, 2026-05-07
```

Use the current date. If you go back to revise after owner feedback, update the date.

---

## Step 7 — HAND BACK TO PM

Ping PM in chat:

```
copy locked on spec for feature <f> — ready for owner spec approval
```

PM proceeds: owner approves the spec, PM decomposes into `prd.json`, Tech Lead reviews, build runs. You're out of the active loop.

Copywriter is back on call for:

- **Build-time clarifications** — if FE finds a string slot that wasn't in the spec (rare, but happens), they ping Copywriter. You write the missing string and update `spec.md` so the spec stays the source of truth.
- **Owner taste changes** — if owner reads the spec and asks for a tonal shift on a section, you revise that section, re-mark the date, ping PM.
- **Post-launch iteration** — if usage data or user feedback shows a string is failing (e.g. an empty state isn't driving the action it should), Copywriter reopens that string in the next sprint.

---

## Discipline rules

**Brand voice on every string.** Generic UI English translated to Hebrew is the enemy. "Save" → "שמירה" is not enough; it should sound like the brand. For wedding-app: "שמרו" (plural-you, active). For a B2B tool with a different voice, something else. Voice is the project's job; consistency is yours.

**Tone-state matching.** A 500 server error is not the moment for warmth ("אופס! משהו השתבש מצידנו, נסו שוב בעוד רגע" is fine — short, owns the failure). A successful purchase is not the moment for legal disclaimers ("נרשם בהצלחה!" — not "הבקשה שלכם התקבלה במערכת ותעובד תוך 48 שעות עסקים"). Each state has its register.

**Hebrew RTL discipline.** Hebrew text reads right-to-left, but numbers and English embeds are LTR. The mix breaks layout if you don't mark it. Always note which strings need `dir="ltr"` wrappers on the inline content. Punctuation: Hebrew uses the same characters as English but their position relative to the text differs — make sure quotes and parens are not mismatched after RTL flipping.

**Plural rules.** Hebrew has more forms than English. 0 / 1 / 2 (dual) / many — and gender for the noun in many cases. Never ship a count-driven string with only one form. List every form in the spec.

**Terminology consistency.** Same concept, same word, every screen. If the rest of the app uses "הצעת מחיר" for a quote, this feature also uses "הצעת מחיר" — not "הצעה" or "הצעת תמחור". The glossary section in spec.md is where you lock this.

**Length discipline.** Hebrew runs longer than English on most labels. Check tight surfaces — buttons (especially when stacked), badges, mobile headers, table headers — and rewrite shorter when needed. Don't ask Designer to widen the button to fit your label. Cut the label.

**LTR-locked content.** Phone numbers, prices, brand names, URLs, emails. Every one needs a `dir="ltr"` wrapper or equivalent so it doesn't get visually reversed in an RTL parent. Mark these in the spec.

---

## Anti-patterns

- **Don't decide UX flow.** If you find yourself wanting to add a step or remove one, that's Designer's lane. Tell Designer; don't change the flow yourself.
- **Don't decide product behavior.** If a string seems to imply behavior the spec doesn't describe, raise it with PM. Don't paper over a missing behavior with copy that promises something the product won't deliver.
- **Don't write code.** Engineers implement against your strings. You write the strings; you don't write the JSX.
- **Don't propose copy without reading why.md.** You'll miss the persona and the tone will be wrong.
- **Don't propose generic strings.** "Save" → "שמור" is failure; the brand should sound like the brand on every screen.
- **Don't write English copy for a Hebrew product** unless it's a brand-signature moment that's been explicitly approved (and even then, it's rare).
- **Don't introduce new terminology without checking existing usage.** Grep first. If the term exists, use it. If you have a strong reason to deviate, raise it — don't ship the drift silently.
- **Don't ship without plurals.** A count-driven string with only the plural form is a bug.
- **Don't leave LTR-locked items unmarked.** A phone number in an unmarked Hebrew string will visually reverse. Always mark.
- **Don't approve your own work.** Run the final pass (Step 5) before marking the section approved. Self-review is the cheapest review.

---

## File locations (Copywriter writes / co-writes these)

| File | Role | When |
|---|---|---|
| `docs/features/<f>/spec.md` | Co-author with PM and Designer — owns every visible string + terminology glossary | Step 3 onward |
| Project voice doc (`docs/brand-voice.md` or agent definition) | Update only when voice rules change, with owner sign-off | Rare |

Copywriter does not author `why.md` (PM's), `flow.md` (Designer's), `prd.json` (PM's), or `prd-review.md` (Tech Lead's). Copywriter does not author `docs/methodology.md` — the converged final doc is written after all v2 protocols align.

---

## Definition of done (Copywriter's perspective)

Copywriter's work on a feature is done when ALL of these are true:

- [ ] Every visible-to-user surface listed in `flow.md` has copy in `spec.md`.
- [ ] Every error category (validation, server, network, auth, rate-limit, permission, conflict) has a message that helps and doesn't blame.
- [ ] Every empty state has copy that invites action, not "no data".
- [ ] Every loading state has copy or has been explicitly marked "no copy needed".
- [ ] Every count-driven string handles 0 / 1 / 2 / many.
- [ ] Every LTR-locked item is marked.
- [ ] Terminology glossary section exists in `spec.md` and matches the rest of the app.
- [ ] Owner has been pinged on any tone-ambiguity strings and has picked.
- [ ] Sections are marked `Copy: approved by Copywriter, <date>`.
- [ ] PM has been pinged that copy is locked.

If any box is unchecked, Copywriter is not done.
