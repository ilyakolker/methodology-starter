# Designer Flow Checklist — DRAFT v2

> Exhaustive question list Designer works through with owner during the FLOW phase of feature intake.
>
> **Build verification happens via Playwright + screenshot review at build time (no wireframes).** This checklist is about pinning down every behavior in words; visual verification comes later, when FE renders the real screen.
>
> **How to use:** Designer reads `why.md` first, then walks owner through these questions in chat — section by section. Capture answers verbatim into a working note, then write the resolved answers into `docs/features/<feature>/flow.md`.
>
> **Discipline:** No question gets skipped because "the feature is small". Small features still have empty states, error states, deep-link behavior, and back-button quirks. The point of this checklist is to leave NO ambiguity for FE/BE to invent at build time.
>
> **When to ask vs. when to decide:** If the owner's WHY already implies an obvious answer (e.g. "no offline mode in MVP"), Designer states the assumption back to owner for confirmation rather than asking from scratch. Don't waste owner time on questions where the answer is forced by `why.md`.

---

## 0. Pre-flight (Designer to self, before opening chat)

- [ ] I have read `why.md` end to end.
- [ ] I can state the persona, pain, and outcome in one sentence each without looking.
- [ ] I have skimmed `design-system/MASTER.md` so I know which tokens already exist.
- [ ] I have noted any "Open questions for Designer" left by PM at the top of `flow.md`.
- [ ] I have looked at adjacent / upstream / downstream screens already in the product so I know what context this feature lives in.

If any box is unchecked, do not start owner Q&A.

---

## 1. Navigation & Entry

How does the user arrive at this feature, and where can they go from it?

### Entry
- What is the **primary** entry point? (Which screen, which button/link, after which event?)
- Are there **secondary** entry points? (Email link, deep link from WhatsApp, push notification, in-app banner, search result?)
- Is the feature reachable from the **home/dashboard**, or only via a flow?
- Is it reachable for **logged-out** users, or auth-gated?
- Is it reachable for **users who haven't completed onboarding**? If so, what state do they land in?
- Is it reachable on **first session** or only after some prior action?
- Is there a **CTA in marketing/landing** that deep-links here? What state should the user land in?

### Exit
- What is the **happy-path exit**? (After success, where does the user go?)
- What is the **abandon exit**? (User taps back / closes — where do they end up?)
- Is there an **explicit "done" / "close" button**? Or only system back?
- After exit, can the user **return to the same state**, or does the flow reset?
- After completing successfully, can the user **redo the flow** or is it one-shot?

### URL & route
- Is this a dedicated **route** (`/feature`) or a **modal** over another route?
- If route: what is the URL? Are there URL params (e.g. `?step=2`)?
- If modal: does **back-button close the modal** or navigate the underlying page back?
- Is the URL **shareable**? If a user pastes it to a friend, what does the friend see?
- Does the URL **change as the user progresses** through steps (so refresh keeps them in place)?

---

## 2. Interactions

What can the user do on this screen, and what happens when they do?

### Taps / clicks
- What is the **primary action** (the one the WHY hinges on)?
- What happens on tap — instant, optimistic, or wait for server?
- What is the **CTA's loading state** (spinner inside button, button disabled, full-screen blocker)?
- What happens on **tap of secondary actions** (cancel, skip, "I'll do this later")?
- Are there **tertiary affordances** (info icons, "?" tooltips, "learn more")? What do they do?

### Forms
- What does the user **type / paste / select**?
- Is there **autofill** support (browser autofill, OS-level password manager, address autocomplete)?
- Is there **inline validation** (as-you-type) or only on submit?
- What does an invalid field **look like** (border color, helper text, icon)?
- Can the user **paste long content** that exceeds a limit? Truncate, warn, or reject?
- Are there **smart defaults** (today's date, last selection, location)?
- Does **Enter key** submit, or do nothing? Does Escape cancel?
- Does the field auto-focus on screen entry?
- For multi-step: does the user **navigate back** to a previous step? Are answers preserved?

### Mobile-specific
- Is there a **long-press** affordance? (Reorder, copy, context menu.)
- Is there a **swipe** action? (Swipe-to-delete, swipe-to-archive, swipe between cards.)
- Does **pull-to-refresh** work? What does it refresh?
- Does the **soft keyboard** push the CTA out of view? (Critical — common mobile bug.)
- Does it work in **one-handed** use (CTA in thumb zone)?

### Desktop-specific
- Are there **keyboard shortcuts**? (Cmd+Enter to submit, Esc to close, Tab order.)
- Does **hover** reveal anything important (tooltips, action buttons)? (Reminder: hover doesn't exist on mobile — never hide critical info behind hover.)
- Does **right-click** do anything custom or fall through to browser default?
- Does **drag-and-drop** apply? (File upload, reordering.)

---

## 3. State

Every screen has every state. List them explicitly.

### Empty
- What does the user see **before they have any data**? (First-time use, fresh account.)
- Is the empty state **instructive** (tells them what to do next) or just blank?
- Is there a **CTA in the empty state** that kickstarts the flow?
- Is there **placeholder/example content** to show what filled-in looks like?

### Loading
- What does the user see during **initial fetch**?
- Is loading **full-screen** (blocker) or **inline** (skeleton)?
- For long operations (>2s), is there **progress indication** (percent, step counter)?
- For very long operations (>10s), can the user **cancel**?
- Are there **optimistic updates** (UI updates before server confirms)? If yes, what happens on rollback?

### Partial
- What if **some data loaded but not all**? (E.g. list of 10 items, 7 came back, 3 still loading.)
- What if a **secondary call fails** but the primary succeeded? (E.g. main content loaded, but related sidebar fails.)
- Show partial + retry, or block until everything loads?

### Error
- What does a **network error** look like? (Offline, timeout, 500.)
- What does a **validation error** look like? (Field-level vs form-level.)
- What does a **permission error** look like? (Not authorized, expired session.)
- What does a **server-side business error** look like? (E.g. "vendor already has 5 quotes pending".)
- Is there a **retry** affordance? Auto-retry with backoff, or user-triggered?
- Does the error **preserve** the user's input, or wipe it?
- Where does the error message appear — toast, inline, modal, full-page?

### Success / completed
- What does the user see **immediately after success**?
- Is success **silent** (just navigates) or **celebratory** (toast, confetti, copy)?
- Does success **auto-navigate** away, or stay on screen?
- After success, can the user **see what they just did** (receipt, summary)?

### Disabled / pre-condition
- What if a **prerequisite is missing** (e.g. user hasn't completed onboarding)?
- Is the feature **visible but disabled** with explanation, or **hidden entirely**?
- If disabled, what's the **path to enable** it?

---

## 4. Edge Behaviors

The behaviors people forget to spec. Each one has shipped a real bug for someone, somewhere.

### Browser & device
- What does **F5 / hard refresh** do mid-flow? (Loses progress, restores from URL, restores from server?)
- What does **pull-to-refresh** on mobile do? (Same answer as F5, or different?)
- What does **browser back** do? (Native back-stack vs in-app history.)
- What does **in-app back** ("←" arrow in header) do? (Same as browser back, or different?)
- What if user opens the screen in a **new tab**? Does state in tab A affect tab B?
- What if user **closes the tab mid-flow** and reopens later? Resume, or fresh?

### Connectivity
- What if user is **offline** when they tap the CTA? Queue, error, or block?
- What if user **goes offline mid-flow**? Show banner, save draft, or freeze?
- What if user is on a **slow connection** (3G simulator)? Are skeletons in place?
- What if a request **times out**? Retry button, or auto-retry?

### Auth & session
- What if the user's **session expires** while on screen? Redirect to login, modal re-auth, or fail silently?
- What if the user is **on a stale session** (logged in on another device, password changed)?
- What if the user **logs out in another tab** while this screen is open?
- What if the URL is **deep-linked from email** but the user isn't logged in? Land on login → return here, or block?

### Permissions (mobile / browser)
- Does this feature ask for **camera, microphone, location, push, contacts**?
- What does the **permission prompt copy** say? (Browser/OS rules.)
- What if the user **denies** the permission? Fallback, error, or hard-block?
- What if the user **already denied** and we can't re-prompt? Send them to settings?
- What if permission is **partially granted** (iOS approximate location)?

### Data freshness
- What if **server-side data changes** while user is on screen? (E.g. a vendor goes offline.)
- Does the screen **subscribe to live updates** (Supabase realtime), or refresh on next user action?
- If live: what if **conflicting changes** arrive (user is editing X, server pushes new X)?
- If poll: what's the **interval**?

### Time
- What if the user **leaves the screen for 5 minutes** and returns? Refresh, resume, or warn?
- What if the screen is **left open overnight**? Auto-refresh, lazy refresh on first interaction, or stale-but-functional?
- Are there **time-sensitive elements** (countdown, expiring offer, "live now")? What happens at expiry?

### Multi-user
- What if **two users edit the same record** at once? (Optimistic concurrency, last-write-wins, lock, merge.)
- What if a **user receives a quote** from a vendor while staring at their dashboard? Toast, badge, auto-update?
- What if a **collaborator (e.g. partner)** is on a shared account and acts in parallel?

### Rate / volume
- What if the user does the action **very rapidly** (double-tap CTA, spam-click)? Idempotency, button disable, debounce?
- What if there are **too many items to show** (1000+ vendors)? Pagination, infinite scroll, virtualization, search-only?
- What if the user **uploads a huge file**? Size limit, progress bar, chunking?

---

## 5. Cross-Device & Context

The same flow lives on different surfaces. Don't forget any.

### Viewports
- **Mobile** (375px) — primary. Default.
- **Tablet** (768px) — does layout change, or just stretch?
- **Desktop** (1024px+) — multi-column, sidebar, modal-vs-inline?
- **Large desktop** (1440px+) — does it max-width and center, or fill?

For each: what's different? Specifically.

### RTL / LTR
- Hebrew is RTL. Does the flow have any **directional elements** (arrows, progress bars, swipe gestures)?
- Are there **embedded LTR fragments** (phone numbers, prices, English brand names) in RTL context?
- Are there **mixed-direction inputs** (user pastes English URL into Hebrew form)?

### Accessibility
- What's the **keyboard tab order** through the screen?
- What does a **screen reader** announce on screen entry? After action?
- Are all interactive elements **labeled** (aria-label or visible label)?
- Are **error messages associated** with their fields (aria-describedby)?
- Are non-decorative **icons labeled**? Are decorative icons hidden from SR?
- Is **color alone** sufficient to convey state? (No — must have icon + text too.)
- Does **contrast meet WCAG AA** (4.5:1 for body, 3:1 for large)?
- Does **prefers-reduced-motion** disable animations?
- Is **focus visible** on every interactive element (no `outline: none` without replacement)?

### Locale / format
- Are **dates** localized (Hebrew calendar quirks, day-first vs month-first)?
- Are **currencies** displayed correctly (₪, comma vs dot decimal)?
- Are **phone numbers** formatted readably in the local phone convention?
- Are **numbers** formatted per local convention (some locales use non-Western digits)?

---

## 6. Failure & Recovery

When the flow breaks, what does the user do?

- If the user gets **stuck mid-flow** with no clear action — what's the escape hatch? (Help link, support contact, "I'll come back later" save-draft.)
- Is there an **undo** for destructive actions? Time window, hard delete vs soft delete?
- If the operation is **multi-part and partially fails** (e.g. send to 5 vendors, 3 succeed, 2 fail): show per-item status, retry only failed, or all-or-nothing?
- If a payment / external API fails after charging the user — what's the **rollback / refund** path?
- If the user **reports a bug from this screen** — is there an in-app contact path?
- Is there a **"too many attempts"** lockout (e.g. wrong password 5x)? What does it look like?

---

## 7. Performance & Perceived Performance

- What's the **target time-to-interactive** for this screen? (LCP target.)
- What's **above the fold** on mobile? (First 600px tall on 375px wide.)
- What can be **deferred / lazy-loaded** below the fold?
- Are there **expensive computations** that should be skeletoned in?
- Should we **prefetch** the likely next screen on hover/idle?
- What's the **perceived performance trick** for this flow? (Optimistic UI, instant skeletons, micro-interactions to mask latency.)

---

## 8. Analytics & Observability

(These mostly belong to PM, but Designer needs to know what to instrument.)

- What's the **single most important event** to track on this screen?
- What **funnel steps** does the user pass through that need event names?
- Are there **error states** worth tracking separately (validation failure vs server failure)?
- What **dimensions / properties** does each event need (which step, which item, etc.)?

---

## 9. Edge Personas (often forgotten)

- **First-time user** with zero context — does the screen orient them?
- **Power user** who has done this 50 times — is the screen out of their way?
- **Returning-after-30-days** user — does anything need re-explanation?
- **User on a borrowed device** (a friend's phone, a spouse) — any logged-in assumptions break?
- **User who shared their account** with their partner — does the flow assume single-user?
- **User in a bad context** (loud venue, walking, distracted) — is the flow forgiving?

---

## 10. Existential

Last gut-check before writing flow.md.

- Can a real user complete this flow **without reading any tooltip or help text**? (If not, the flow is too complex.)
- If we **removed the second most-prominent element** on the screen, would the WHY still be served?
- Is there **one screen here that could be deleted** by combining with another?
- If the user does **only the primary action** and ignores everything else, do they get the value the WHY promises?

---

## Wrap-up

Once all sections are answered (or explicitly marked "N/A — not relevant because X" or "deferred — out of scope, justified"), Designer writes `docs/features/<feature>/flow.md`. Owner reviews; if anything is still ambiguous, return to the relevant section.

> **Reminder:** "I'll figure that out at build time" is not an acceptable answer here. If a question is truly out of scope, mark it explicitly out of scope with a sentence of justification. Silence is not an answer.
