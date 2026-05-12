# Senior Engineer Checklist — What I Look For Before Shipping

This is not a tutorial. It is a mental model. Every section is a lens you put on when reading or writing code.
The goal is not to implement all of this at once. The goal is to know it exists so nothing surprises you at scale.

---

## 1. Security

The most expensive bugs are security bugs. They cost money, trust, and sometimes the company.

### What to look for
- **Mass assignment** — only permit what the user is allowed to set. If `role` or `status` is in `permit()`, a malicious user can promote themselves to admin via curl.
- **Insecure Direct Object Reference (IDOR)** — can a user access another user's records by changing an ID in the URL? Scope every query to the current user. `Job.find(params[:id])` is dangerous. `current_user.customer.jobs.find(params[:id])` is safe.
- **Authentication vs Authorization** — authentication is who you are. Authorization is what you are allowed to do. Most apps get authentication right and skip authorization entirely.
- **Sensitive data in logs** — Rails logs all params by default. Passwords, tokens, and card numbers end up in log files. Use `config.filter_parameters` to suppress them.
- **SQL injection** — never interpolate user input directly into a query string. Always use ActiveRecord's parameterized queries or `.where("column = ?", value)`.
- **XSS (Cross-Site Scripting)** — Rails ERB escapes output by default with `<%= %>`. `<%= raw %>` and `.html_safe` turn that off. Never use them on user-provided content.
- **CSRF** — Rails handles this with `protect_from_forgery`. Never disable it. Understand why it exists: without it, another website can make requests on behalf of your logged-in users.
- **Secrets in version control** — credentials, API keys, and database passwords must never be committed. Use Rails credentials or environment variables.

### The question to ask on every controller action
*"What happens if a user crafts a request manually? Can they access or modify something they should not?"*

---

## 2. Database Integrity

The database outlives the application. Bad data is permanent. Defend it at every layer.

### What to look for
- **Validations at the model level** — catch bad data before it hits the database.
- **Constraints at the database level** — `null: false`, `unique: true`, `check_constraint` in migrations. Model validations can be bypassed with `update_all` or direct SQL. The database cannot be bypassed.
- **Foreign key constraints** — declare them in migrations. Without them, you can have an assignment pointing to a deleted technician and Rails will never warn you.
- **Missing indexes** — every foreign key column and every column used in a `WHERE` clause should be indexed. Without indexes, queries do full table scans. Fine at 100 rows. Catastrophic at 1 million.
- **N+1 queries** — loading a collection and then querying inside the loop. Use `includes()`, `preload()`, or `eager_load()` to batch the queries.
- **Partial state from failed transactions** — if you do two writes and the second one fails, you have corrupt data. Wrap related writes in `ActiveRecord::Base.transaction {}`. If anything raises, everything rolls back.
- **Migrations that lock tables** — `add_column` with a default value on a large table rewrites every row and locks the table. On production with millions of rows, this takes the site down. Learn about zero-downtime migrations before you hit production.

### The question to ask on every migration
*"What happens to existing data when this migration runs? Can it fail halfway through? Does it lock?"*

---

## 3. Performance

Performance is a feature. Slow software loses users before they ever complain.

### What to look for
- **Queries in views** — any database call in a view is a smell. Data should come from the controller, preloaded and ready.
- **Queries inside loops** — the classic N+1. One query to get 100 records, then 100 queries to get related data. Should be 2 queries total.
- **Unbounded queries** — `User.all` with no limit. Fine in dev with 10 records. Will crash production with 500,000. Always paginate or limit queries that could grow.
- **Synchronous work that should be async** — sending an email, calling an external API, resizing an image. These should happen in a background job, not in the request cycle. The user should not wait for your email server.
- **Caching** — repeated expensive queries that return the same result should be cached. Rails has fragment caching, low-level caching, and HTTP caching. Learn when each applies.
- **Database vs application logic** — counting and summing in Ruby after loading all records is slow. `COUNT`, `SUM`, `GROUP BY` in SQL is fast. Push aggregations to the database.

### The question to ask on every action
*"What is the worst-case number of queries this action makes if the data grows to 100,000 records?"*

---

## 4. Reliability

The system will fail. The question is whether it fails gracefully or catastrophically.

### What to look for
- **Unhandled exceptions** — a crash that shows a 500 page to the user is a crash that loses their work. Rescue expected errors and handle them explicitly.
- **External service failures** — if your geocoding API is down, does your entire job creation fail? Wrap external calls in rescue blocks and have a fallback.
- **Idempotency** — if a background job runs twice (retries are normal), does it create duplicate records? Write jobs so running them twice produces the same result as running them once.
- **Background job failures** — jobs fail silently by default in many setups. You need dead letter queues and alerting to know when they fail.
- **Race conditions** — two requests arriving at the same millisecond can both read the same data, both decide to create a record, and you end up with duplicates. Use database-level uniqueness constraints and optimistic locking for concurrent writes.
- **Clock drift and timezones** — store all times in UTC. Display in user's local timezone. Never store local time in the database. Never compare times across timezones without normalizing.

### The question to ask on every background job
*"What happens if this runs twice? What happens if it never runs?"*

---

## 5. Code Quality

Code is read far more than it is written. The reader is usually you, six months later, under pressure.

### What to look for
- **Naming** — a variable or method name should tell you what it is without a comment. `x`, `data`, `temp`, `result` are not names.
- **Method length** — a method that does not fit on your screen is doing too much. Each method should do one thing.
- **Fat models / fat controllers** — controllers should receive input, call a service, and render output. Models should be data + validations + associations. Business logic belongs in service objects.
- **Duplication** — the same logic in two places will eventually diverge. One will get updated, one will not. Extract it.
- **Magic numbers and strings** — `status: "pending"` scattered across 20 files. If "pending" ever changes, you miss one. Use constants or enums.
- **Dead code** — commented-out code, unused methods, unreachable branches. Delete it. Git history exists.
- **Premature abstraction** — do not build a generic framework for a problem you have once. Wait until you have the same problem three times, then abstract.

### The question to ask when reviewing a pull request
*"Could someone who has never seen this codebase understand what this does and why in under two minutes?"*

---

## 6. Observability

You cannot fix what you cannot see. In production, you are blind unless you built in the lights.

### What to look for
- **Structured logging** — log enough context to reconstruct what happened. Include user IDs, record IDs, and action names. Avoid logging sensitive data.
- **Error tracking** — you need to know when exceptions happen in production before users report them. Tools like Sentry or Honeybadger aggregate and alert on exceptions.
- **Performance monitoring** — slow queries and slow actions should be visible. You need to know your p95 response time, not just average.
- **Audit trails** — for anything that changes money, status, or access, log who did what and when. Not just in the application — in the database.
- **Health checks** — a `/up` endpoint that verifies the database is reachable, the background queue is running, and the app is alive. Used by load balancers and uptime monitors.

### The question to ask before deploying a feature
*"If this breaks at 3am, will I know? Will I have enough information to fix it without reading through the code?"*

---

## 7. Testing

Tests are documentation that cannot lie. They describe exactly what the code does.

### What to look for
- **Unit tests** — test one method in isolation. Fast. No database, no external services.
- **Integration tests** — test the full stack from controller to database. Slower but catches what unit tests miss.
- **Edge cases** — what happens with nil? With an empty collection? With the maximum value? With a string where you expect a number?
- **Testing behaviour, not implementation** — test what the code does, not how it does it. Tests that break every time you refactor internals are not useful.
- **Test coverage of critical paths** — payment processing, authentication, and data mutations must have tests. UI polish does not.
- **Regression tests** — every bug you fix should get a test. If it broke once, it will break again.

### The question to ask before merging
*"If I deleted all the code for this feature, would the tests catch it?"*

---

## 8. Data Modeling

Getting the data model wrong is the most expensive mistake in software. Schema changes on a live system with real data are painful and risky.

### What to look for
- **Normalization** — each piece of data should live in one place. Duplication means the copies diverge. Understand 1NF, 2NF, 3NF.
- **Deliberate denormalization** — sometimes you break the rules intentionally for performance (e.g., `average_rating` on Technician). Document why. Know the trade-off.
- **Polymorphism** — powerful but makes queries harder and foreign key constraints impossible. Use it for genuinely generic relationships. Do not use it to avoid making a decision.
- **Soft deletes vs hard deletes** — deleting records breaks foreign key relationships and audit trails. Consider `deleted_at` timestamps instead of destroying records.
- **Enum columns** — storing status as a string is readable but easy to mistype. Storing as an integer is compact but unreadable. Rails enums give you both. Understand the trade-offs.
- **Schema evolution** — your data model will change. Design for change. Avoid wide tables with nullable columns that accumulate over years.

### The question to ask before writing a migration
*"Am I storing this data in the right place, or am I storing it here because it is convenient right now?"*

---

## 9. API Design (if you expose one)

An API is a contract. Once published, breaking it breaks every client that depends on it.

### What to look for
- **Versioning** — `/api/v1/jobs`. When you change the response shape, you bump the version rather than breaking existing clients.
- **Consistent error responses** — errors should always return the same structure. Status code, message, and optionally an error code the client can act on.
- **Pagination** — never return an unbounded list. Every collection endpoint should have limit/offset or cursor-based pagination.
- **Rate limiting** — without it, a single misbehaving client can bring down the API for everyone.
- **Authentication** — API keys, JWTs, or OAuth. Understand what each is protecting against and what the rotation story is.

---

## 10. Product Thinking

A senior engineer thinks about the problem, not just the implementation.

### What to look for
- **Is this the right thing to build?** — before writing code, understand the user problem. A technically perfect solution to the wrong problem is waste.
- **Edge cases at the product level** — what happens when a technician accepts a job and then their phone dies? What happens when a customer cancels after the technician is already en route?
- **Reversibility** — can mistakes be undone? Build admin tools to correct bad data before users need support.
- **Operational cost** — who supports this feature when it breaks? Does it require manual intervention? Can support staff resolve issues without a developer?
- **Metrics** — how will you know if this feature is working? Define the success metric before you ship, not after.

### The question to ask before starting any feature
*"What problem does this solve, for whom, and how will I know it is working?"*

---

## How to use this

Do not try to apply everything at once. Pick one lens per week and read your own code through it.

Week 1: Read every controller action and ask the IDOR question.  
Week 2: Open the schema and check every foreign key for an index.  
Week 3: Read every action and count the queries.  
Week 4: Find one thing in the codebase that would confuse a new developer and fix the naming.

The goal is to make this thinking automatic. Eventually you do not consult the list — you just see the gaps.
