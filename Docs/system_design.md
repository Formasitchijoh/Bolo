# Bolo — System Design Document

**Version:** 1.0  
**Author:** Formasit Chijoh  
**Status:** Living Document — updated as the system evolves  
**Last Updated:** May 2026

---

## 1. Project Overview

### What is Bolo

Bolo is a service marketplace platform that connects customers who need skilled labour with verified technicians who can perform the work. It is designed for the African market, initially targeting Cameroon, where informal service labour is abundant but discovery, trust, and payment infrastructure remain fragmented.

Bolo is not a job board. It is a real-time dispatch and fulfilment platform. A customer posts a job, the system automatically finds and notifies the nearest qualified technician, and the technician either accepts or the system cascades to the next best match. Once accepted, the platform manages the entire workflow from en-route tracking through to work completion and payment.

The name "Bolo" reflects the local context — a platform built for and by people who understand the market it serves.

### Users of the System

| Role | Description |
|---|---|
| **Customer** | Posts jobs, tracks technician progress, reviews and approves completed work |
| **Technician** | Receives job assignments, updates job status, records work done via line items |
| **Dispatcher** | Monitors active jobs and assignments across the platform |
| **Company Admin** | Manages technicians and operations within their company |
| **Account Owner** | Owns a tenant, can manage one or more companies |
| **Platform Admin** | Full access across the entire platform |

### Core Workflows

**Job Posting and Dispatch**
1. Customer creates a job with location, category, price range, and details
2. System identifies verified technicians with matching skills
3. System ranks technicians by proximity using the Haversine formula
4. Nearest technician receives a pending assignment with a 15-minute claim window
5. If they reject or the window expires, the system cascades to the next technician
6. Once accepted, the assignment progresses through: assigned → en_route → arrived

**Work Execution**
1. Technician marks themselves en route, then arrived
2. On arrival, a Work Order is automatically created
3. Technician starts work, records line items (what was done and cost)
4. Technician marks the work order complete
5. Customer reviews the work order and approves

**Payment (planned)**
1. Customer approves the work order
2. Payment is processed against the agreed line items
3. Platform fee is deducted and technician receives their portion

### Goals

- Reduce the friction of finding and hiring skilled labour in informal markets
- Give technicians a structured way to receive, manage, and record their work
- Give companies and dispatchers visibility into field operations in real time
- Build a foundation that can scale from a single city to multiple markets

### What Bolo is Not (v1 Scope Boundaries)

- Not a bidding platform — jobs are dispatched automatically by the system, not posted publicly for technicians to apply to
- Not a payments processor in v1 — payment infrastructure is designed but not yet integrated
- Not a mobile app — v1 is a responsive web application built for browser access
- Not a multi-region platform in v1 — architecture supports it but initial deployment targets Cameroon

### Key Assumptions

- Technicians carry smartphones with browser access and GPS capability
- Customers have reliable enough connectivity to submit a job form
- The matching engine proximity calculation is sufficient at city scale without dedicated geospatial infrastructure
- Verification of technicians is a human-assisted process in v1, not fully automated
- FCFA (Central African Franc) is the primary currency for all transactions

---

*Next: Section 2 — Architecture Decision Records*

---

## 2. Architecture Decision Records

Each decision below follows the ADR format: **Context** (why the decision was needed), **Decision** (what was chosen), **Rationale** (why), **Alternatives Rejected** (what else was considered and why it was dismissed), and **Consequences** (what we gain and what we give up).

---

### ADR-001 — Monolithic Architecture over Microservices

**Context:**
Bolo is an early-stage product with a small team. The system needs to be built quickly, iterated on rapidly, and understood fully by the people building it.

**Decision:**
Build a single Rails monolith that contains all domains — auth, jobs, assignments, work orders, payments — in one deployable application.

**Rationale:**
- A monolith is the right default at this stage. Microservices solve problems of scale and team coordination that do not exist yet.
- Shared database transactions are trivial in a monolith. Coordinating a transaction across services requires distributed transaction patterns that add significant complexity.
- Deployment, debugging, and onboarding are all simpler with one application.
- Rails enforces a clean separation of concerns (MVC + service objects) that keeps the monolith organised as it grows.

**Alternatives Rejected:**
- *Microservices:* Each domain (jobs, matching, payments) as a separate service. Rejected because the operational overhead — separate deployments, inter-service communication, distributed tracing — is not justified at this stage. Premature decomposition is one of the most common and expensive mistakes in early product engineering.

**Consequences:**
- Deployment is simple — one application, one server to start.
- All domains share a database, making cross-domain queries straightforward.
- As the system grows, the monolith can be decomposed into services if and when specific domains have scaling needs that justify it. The service object pattern used throughout makes extraction easier when that time comes.

---

### ADR-002 — PostgreSQL as the Primary Database

**Context:**
Bolo manages jobs, assignments, technicians, work orders, and payments. The data has clear relationships, consistency matters especially for financial records, and some fields (media attachments, metadata) benefit from flexible structure.

**Decision:**
Use PostgreSQL as the sole database.

**Rationale:**
- The data model is relational. Jobs belong to customers, assignments belong to jobs and technicians, line items belong to work orders. Foreign keys, joins, and referential integrity are natural fits for a relational database.
- ACID compliance is non-negotiable for assignment state transitions and payment records. A job must not simultaneously be assigned to two technicians. A payment must not be recorded twice.
- PostgreSQL's JSONB type handles flexible fields like `media` attachments on jobs and work orders without requiring a separate document store.
- Database-level constraints (`null: false`, `check_constraint`, foreign keys) enforce data integrity regardless of what the application layer does. This is the last line of defence against corrupt data.
- Mature Rails/ActiveRecord support with decades of production validation.

**Alternatives Rejected:**
- *MongoDB:* Rejected because Bolo's data is relational, not document-oriented. The flexibility of a document store is not needed here and would sacrifice the referential integrity guarantees that are critical for this domain.
- *MySQL:* Viable but PostgreSQL's JSONB support, advanced indexing, and stronger standards compliance made it the better long-term choice.

**Consequences:**
- Schema changes require migrations. Adding a column to a large table in production requires care to avoid locking.
- Horizontal scaling beyond a single node requires read replicas or sharding strategies. These are not needed now but are well-understood patterns for PostgreSQL at scale.

---

### ADR-003 — Ruby on Rails as the Application Framework

**Context:**
The project needed a framework that would allow rapid development of a full-stack web application with a strong database integration layer, a clear MVC structure, and built-in conventions that reduce decision fatigue.

**Decision:**
Use Ruby on Rails 8.1.

**Rationale:**
- Rails' convention over configuration means common patterns — routing, database access, form handling, session management — do not need to be designed from scratch.
- ActiveRecord provides a powerful ORM that maps naturally to the PostgreSQL schema and allows complex queries to be expressed clearly.
- Hotwire (Turbo + Stimulus) is built into Rails 8 and enables reactive UI without a separate JavaScript framework, keeping the stack simple.
- The asset pipeline and importmap handle JavaScript and CSS without requiring a Node.js build step.
- Rails enforces a project structure that scales well as a team and codebase grow.

**Alternatives Rejected:**
- *Node.js (Express/Fastify):* More flexibility but significantly more decisions to make — ORM, routing, project structure, middleware. The flexibility is a liability at the early stage.
- *Python (FastAPI):* Strong performance and modern async support but FastAPI is primarily an API framework. Building a server-rendered full-stack application would require pairing it with a separate templating layer and ORM, adding complexity without a clear benefit over Rails' integrated stack.
- *PHP (Laravel):* A full-stack framework with broad adoption, especially in emerging markets. Rejected because Laravel's conventions differ significantly from Rails and the team's existing knowledge and productivity were higher in Ruby. Both are valid choices for this class of application — the decision came down to where the team could move fastest with the most confidence.

**Consequences:**
- Rails' conventions create predictable structure that any Rails developer can navigate immediately.
- The framework's "magic" (callbacks, concerns, metaprogramming) must be used with discipline. Overuse leads to code that is hard to trace.

---

### ADR-004 — Manual Authentication over Devise

**Context:**
User authentication is required. The industry-standard Rails gem for this is Devise. The question was whether to use it or build authentication manually.

**Decision:**
Build authentication manually using Rails' `has_secure_password`, BCrypt, and cookie-based sessions.

**Rationale:**
- Understanding authentication primitives is a core engineering skill. Building it manually means understanding exactly what is happening at every step — password hashing, session creation, token validation.
- `has_secure_password` provides BCrypt hashing (cost factor 12) and the `authenticate` method out of the box. The hard parts are handled by Rails; the session management layer is straightforward to write.
- Manual auth is fully transparent. There are no gem internals to debug, no upgrade path dependencies, and no hidden behaviour.
- Devise adds significant complexity and many features (password reset mailers, confirmable, lockable) that are not yet needed.

**Alternatives Rejected:**
- *Devise:* Rejected for v1 to ensure full understanding of the auth layer. Devise is a strong choice for teams that need to move fast and do not need to deeply understand auth internals. It is not the right choice here given the learning objectives of this project.

**Consequences:**
- Password reset, email confirmation, and account locking must be built manually when needed.
- The auth layer is small, readable, and fully understood by the team.
- Session management is cookie-based with `httponly: true`, `secure: true` in production, and `same_site: :lax` — appropriate protection for a server-rendered application.

---

### ADR-005 — Cookie-Based Sessions over JWT

**Context:**
The application needed a session management strategy. Two common approaches are server-side cookie sessions and stateless JWT tokens.

**Decision:**
Use Rails' built-in cookie store for session management. The session contains only `user_id` and `company_id`.

**Rationale:**
- Cookie sessions are the correct choice for a server-rendered Rails application. The session is encrypted and signed by Rails using the application secret key — it cannot be tampered with.
- JWTs are designed for stateless API authentication, particularly across services. In a monolith serving HTML, they add complexity with no benefit.
- Revoking a cookie session is immediate — clear the session and the user is logged out. Revoking a JWT requires a token blacklist, which reintroduces statefulness and eliminates the primary benefit of JWT.
- No token storage decisions needed on the client — cookies are handled automatically by the browser.

**Alternatives Rejected:**
- *JWT:* Rejected because stateless token auth solves a distribution problem that does not exist in a monolith. The complexity of token refresh, expiry, and revocation is not justified.

**Consequences:**
- Sessions are stateful. Every request hits the server and the session is decoded from the cookie.
- If Bolo later exposes a public API consumed by mobile clients, JWT or API key authentication will need to be added for those endpoints.

---

### ADR-006 — Manual RBAC over Pundit or CanCanCan

**Context:**
Bolo has six user roles with different access levels. A policy layer was needed to enforce what each role can do.

**Decision:**
Implement role-based access control manually using `before_action` guards in controllers and role predicate methods on the User model.

**Rationale:**
- The access rules at this stage are simple enough to be expressed clearly as `before_action :require_technician` — readable, explicit, and easy to trace.
- Building RBAC manually builds a complete understanding of the authorization layer before abstracting it.
- Pundit and CanCanCan are excellent tools for complex policy matrices. Introducing them before the policy complexity justifies it adds indirection without benefit.

**Alternatives Rejected:**
- *Pundit:* Policy objects per resource with explicit permission checks. The right choice when the policy matrix becomes complex. Not yet justified.
- *CanCanCan:* Ability-based authorization defined centrally. Powerful but can become difficult to reason about as rules grow.

**Consequences:**
- As Bolo adds more roles and more nuanced permissions (e.g., a company admin can only manage technicians within their own company), the manual approach will become harder to maintain. Pundit will likely be introduced at that point.

---

### ADR-007 — Haversine Formula for Distance Calculation over PostGIS

**Context:**
The matching engine needs to rank technicians by their proximity to a job location. This requires calculating the distance between two GPS coordinates.

**Decision:**
Implement the Haversine formula in a Ruby service object to calculate great-circle distances between coordinates.

**Rationale:**
- The Haversine formula is accurate for the distances involved in a city-scale dispatch system. The error margin compared to PostGIS is negligible at distances under 100km.
- No additional database extension, infrastructure dependency, or query complexity is required.
- The implementation is self-contained, testable, and readable in pure Ruby.
- PostGIS is the correct choice at scale when geospatial queries need to be pushed into the database for performance. That threshold is not reached at current scale.

**Alternatives Rejected:**
- *PostGIS:* A powerful PostgreSQL extension for geospatial queries. Rejected because it introduces a database-level dependency and additional operational complexity that is not justified at this stage. The migration path from Haversine to PostGIS is straightforward when needed.
- *Google Maps Distance Matrix API:* External API call per match calculation, adds latency, cost, and an external dependency to a core system function. Rejected.

**Consequences:**
- Distance calculations happen in Ruby, not the database. If the technician pool grows to thousands, ranking all of them in Ruby before selecting the nearest becomes a performance concern. At that point, pushing the query to PostGIS or pre-filtering by a bounding box becomes necessary.

---

### ADR-008 — OpenStreetMap Nominatim for Geocoding

**Context:**
Job locations need to be converted from a human-readable address to latitude/longitude coordinates so the matching engine can calculate distances.

**Decision:**
Use the OpenStreetMap Nominatim API for address geocoding, with browser geolocation as the primary method and Nominatim as the fallback for typed addresses.

**Rationale:**
- Nominatim is free with no API key required, removing a billing and key management dependency from the critical job creation path.
- Browser geolocation provides the most accurate location data when the customer is at or near the job site.
- The Stimulus controller handles both paths — geolocation first, Nominatim fallback — without page reloads.
- OpenStreetMap coverage for Cameroon and West Africa is sufficient for city-level dispatch accuracy.

**Alternatives Rejected:**
- *Google Maps Geocoding API:* More accurate globally but requires an API key, billing setup, and introduces a cost-per-request dependency on the job creation path. Rejected for v1.
- *Mapbox:* Similar trade-offs to Google. Generous free tier but still requires account setup and key management.

**Consequences:**
- Nominatim has rate limits and is a shared public service. High volume usage requires either self-hosting Nominatim or migrating to a paid geocoding provider.
- Geocoding accuracy in rural areas may be lower than commercial alternatives.

---

### ADR-009 — Service Objects for Business Logic

**Context:**
The job matching logic involves multiple steps: skill filtering, proximity ranking, exclusion of previously assigned technicians, and assignment creation. This logic does not belong in a model callback or a controller action.

**Decision:**
Encapsulate complex business logic in service objects — plain Ruby classes in `app/services/` that take inputs, perform a single well-defined operation, and return a result.

**Rationale:**
- Models should contain data, validations, associations, and simple domain logic. Matching engine logic does not belong in the Job model.
- Controllers should receive input, call a service, and render output. They should not contain business logic.
- Service objects are testable in isolation without needing to spin up a full Rails request cycle.
- The pattern scales naturally — each new piece of complex business logic gets its own service object with a clear responsibility.

**Alternatives Rejected:**
- *Fat model with callback:* The `after_create :broadcast_to_technicians` callback on Job calls the service. The callback is the trigger, not the implementation. Putting the full matching logic in the model would make it untestable and hard to reason about.
- *Concerns:* Shared modules mixed into models or controllers. Rejected because they obscure where logic lives and make the call chain harder to trace.

**Consequences:**
- Business logic is concentrated in small, focused, testable classes.
- The service layer is the right place to add background job offloading when the matching engine needs to run asynchronously.

---

---

### ADR-010 — Sidekiq and Redis for Background Job Processing

**Context:**
Several operations in Bolo must not run in the web request cycle. The claim window expiry check needs to fire after 15 minutes regardless of user activity. Notifications, email delivery, and eventually payment processing are all operations that should be decoupled from the HTTP request that triggers them. A background job processor is required.

**Decision:**
Use Sidekiq backed by Redis as the background job processing infrastructure.

**Rationale:**
- Sidekiq is the most widely adopted background job processor in the Rails ecosystem with a proven track record at production scale.
- Redis as an in-memory store makes job enqueuing and dequeuing extremely fast — jobs are not competing with application database queries.
- Sidekiq's concurrency model (multi-threaded workers) handles high job throughput efficiently without requiring many processes.
- The Sidekiq web UI provides real-time visibility into queues, running jobs, retries, and dead jobs — critical for operational awareness.
- Sidekiq integrates directly with ActiveJob, meaning jobs can be written using Rails' standard job API and the underlying processor can be swapped if needed.

**Alternatives Rejected:**
- *Solid Queue (Rails 8 default):* Database-backed queue that requires no additional infrastructure. A reasonable default for low-volume background processing but introduces write load on the primary PostgreSQL database. For Bolo's dispatch-heavy workload — claim window checks firing frequently across many active jobs — a dedicated Redis-backed queue is the better long-term choice.
- *Delayed Job:* Older database-backed processor. Less performant than Sidekiq and largely superseded.
- *Resque:* Redis-backed like Sidekiq but uses forking instead of threading, making it more memory-intensive. Sidekiq's threading model is more efficient for Bolo's workload profile.

**Consequences:**
- Redis becomes an infrastructure dependency that must be provisioned, monitored, and kept available. If Redis goes down, background jobs stop processing.
- Sidekiq workers run as a separate process alongside the Rails web server, requiring process management in deployment.
- Job idempotency must be considered — if a Sidekiq job retries due to failure, it must not create duplicate records or send duplicate notifications. Each job must be written with retry safety in mind.

*Next: Section 3 — System Architecture*

---

## 3. System Architecture

### 3.1 Architectural Style

Bolo is a **server-rendered monolith** following the MVC (Model-View-Controller) pattern. All domains — authentication, job management, dispatch, work orders, and payments — live in a single Rails application backed by a single PostgreSQL database.

The frontend is rendered server-side using ERB templates. Interactivity is handled by **Hotwire** (Turbo for page updates, Stimulus for JavaScript behaviour) without a separate frontend build pipeline or JavaScript framework.

```
Browser
   │
   │  HTTP Request
   ▼
Rails Router
   │
   ├── Controller (receives input, calls services, renders response)
   │       │
   │       ├── Service Objects (business logic — matching, sync)
   │       │
   │       └── Models (data, validations, associations)
   │               │
   │               └── PostgreSQL
   │
   └── ERB Views + Hotwire (server-rendered HTML, Stimulus JS)
```

---

### 3.2 Technology Stack

| Layer | Technology | Version | Rationale |
|---|---|---|---|
| Language | Ruby | 3.x | Expressive, productive, strong Rails ecosystem |
| Framework | Ruby on Rails | 8.1 | Full-stack, convention-driven, Hotwire built-in |
| Database | PostgreSQL | 16 | Relational, ACID, JSONB, foreign key constraints |
| Frontend | Hotwire (Turbo + Stimulus) | Rails 8 default | Reactive UI without a separate JS framework |
| CSS | Custom CSS (no framework) | — | Full control, no utility class bloat |
| Auth | BCrypt via has_secure_password | Rails built-in | Secure password hashing, no gem dependency |
| Sessions | Rails cookie store | Rails built-in | Encrypted, signed, browser-native |
| Geocoding | OpenStreetMap Nominatim | Public API | Free, no API key, sufficient accuracy |
| Background Jobs | Sidekiq | 7.x | Redis-backed, proven at scale, rich ecosystem |
| Job Queue Store | Redis | 7.x | In-memory store for Sidekiq job queue |
| Asset Pipeline | Propshaft + Importmap | Rails 8 default | No Node.js build step required |

---

### 3.3 Application Layers

**Router**
Maps incoming HTTP requests to controller actions. All routes are explicitly declared — no resourceful catch-alls that expose unintended actions.

**Controllers**
Thin by design. Each action does three things only: authenticate/authorise the request, call the appropriate model or service, and render or redirect. Business logic never lives in a controller.

**Service Objects (`app/services/`)**
Plain Ruby classes that encapsulate complex business logic. Currently:
- `JobMatchingService` — skill filtering, proximity ranking, assignment creation

**Models (`app/models/`)**
ActiveRecord models responsible for data integrity, associations, validations, and simple domain behaviour. Complex multi-step operations are delegated to service objects.

**Views (`app/views/`)**
ERB templates rendered server-side. Stimulus controllers handle browser-side interactivity (geolocation, address search). No client-side state management.

**Database**
PostgreSQL enforces integrity at the data layer independently of the application — foreign keys, null constraints, check constraints, and unique indexes are all declared at the schema level, not only in Rails validations.

---

### 3.4 Request Lifecycle

A typical job creation request flows as follows:

```
1. Customer submits job form
      │
2. Router → JobsController#create
      │
3. Controller authenticates (require_login)
   Controller authorises (require_customer)
      │
4. Controller builds Job from permitted params
   Sets customer from current_user (not from params)
      │
5. job.save triggers after_create callback
      │
6. JobMatchingService.new(job).call
      │
      ├── find_matched_technicians
      │     Skill filter → company filter → exclusion filter
      │
      ├── rank_by_proximity (Haversine)
      │
      └── broadcast_to_next
            Creates Assignment record for nearest technician
      │
7. Controller redirects to jobs_path
```

---

### 3.5 Multi-Tenancy Model

Bolo uses a **shared database, shared schema** multi-tenancy model where tenant isolation is enforced at the application layer through `company_id` scoping.

```
Tenant (Account Owner)
   └── Company (one or many per tenant)
         ├── Technicians
         ├── Jobs (optional — jobs can be company-specific or open)
         └── Assignments
```

- A `Tenant` record represents the account owner's subscription entity
- A `Company` belongs to a `Tenant` and is the operational unit
- All queries for company-scoped data pass through `for_company` scopes
- Platform-level data (job categories, skills) is shared across all tenants

**Consequence:** This model is simpler to build and query than row-level security or separate schemas, but requires disciplined scoping at the application layer. A missing scope check exposes cross-tenant data. This is mitigated by always querying through `current_user` associations rather than bare model finders.

---

### 3.6 Third-Party Services

| Service | Purpose | Dependency Level |
|---|---|---|
| OpenStreetMap Nominatim | Address geocoding | Medium — used in job creation only |
| Browser Geolocation API | GPS coordinates from device | Low — optional fallback path |

No other external services are integrated in v1. Payment providers, SMS/notification services, and mapping SDKs are planned but not yet introduced.

---

*Next: Section 4 — Data Model*

---

## 4. Data Model

**Full schema:** [`db/schema.rb`](../db/schema.rb) — the schema file is the authoritative reference for all tables, columns, types, constraints, and indexes.

**ER Diagram:** [`Docs/Bolo.pdf`](Bolo.pdf)

---

### 4.1 Key Design Decisions

**Normalisation**
The schema follows 3NF. Each piece of data lives in one place. `Skills` are their own table linked to `JobCategories`, not stored as strings on the technician. `JobCategories` are their own table, not an enum column on jobs. This allows categories and skills to grow without schema changes.

**Deliberate Denormalisation**
`average_rating` is stored directly on the `Technician` record rather than being computed from the `Ratings` table on every read. This is a deliberate trade-off — a write-time update in exchange for a cheap read on every profile or listing. The rating table remains the source of truth; the column is a performance optimisation.

**Polymorphic Associations**
`Address` and `Contact` use polymorphic associations (`addressable`, `contactable`) so a single table serves multiple parent models without duplicating structure. This was chosen for genuine generality — both customers and companies have addresses; both technicians and companies have contacts. The trade-off is that foreign key constraints cannot be enforced at the database level on polymorphic columns.

**Database-Level Integrity**
Constraints are declared at the schema level, not only in Rails validations. Foreign keys, `null: false`, `unique: true` indexes, and check constraints (e.g., `star >= 1 AND star <= 5` on ratings) are enforced by PostgreSQL regardless of what the application layer does. Rails validations are the first line of defence; database constraints are the last.

**JSONB for Flexible Fields**
`media` on `Job` and `WorkOrder` is stored as JSONB. These fields hold arrays of attachment metadata that do not have a fixed schema. JSONB avoids creating a separate attachments table for a field that is not queried relationally.

**Status as String**
Status columns (`job.status`, `assignment.status`, `work_order.status`) are stored as strings with inclusion validations at the model level. This keeps statuses readable in the database and in logs without requiring enum integer mappings. The trade-off is that invalid string values are caught at the application layer, not the database layer — mitigated by database check constraints where correctness is critical.

---

### 4.2 Core Entity Relationships

```
User
 ├── Customer (1:1)
 │     └── Jobs (1:many)
 │           ├── Address (1:1, polymorphic)
 │           ├── Assignments (1:many)
 │           └── belongs to JobCategory
 │
 └── Technician (1:1)
       ├── TechnicianSkills → Skills → JobCategory
       ├── Assignments (1:many)
       │     └── WorkOrder (1:1)
       │           └── LineItems (1:many)
       └── Ratings (1:many)

Tenant
 └── Companies (1:many)
       └── Technicians (optional company_id)

Skills belong to JobCategories
JobCategories have many Skills
```

---

### 4.3 Indexes

All foreign key columns have indexes generated by Rails migrations (`index: true` on `references`). Additional indexes worth noting:

| Table | Column(s) | Purpose |
|---|---|---|
| `users` | `email` | Unique — login lookup |
| `job_categories` | `name` | Unique — prevent duplicate categories |
| `skills` | `name` | Unique — prevent duplicate skills |
| `shifts` | `technician_id, start_time, end_time` | Composite — availability range queries |

---

*Next: Section 5 — Module Design*

---

## 5. Module Design

### 5.1 Job Matching Service

**File:** [`app/services/job_matching_service.rb`](../app/services/job_matching_service.rb)

**Purpose:**
Finds the most suitable available technician for a job and creates a pending assignment for them. Called automatically via the `after_create` callback on `Job`.

**Inputs:**
- A `Job` record with `job_category_id`, `latitude`, `longitude`, and optional `company_id`

**Outputs:**
- A new `Assignment` record with `status: "pending"` and a `claim_window` timestamp — or nothing if no eligible technician is found

**Flow:**
```
1. find_matched_technicians
   ├── Get skill IDs for the job's category
   ├── Find verified technicians with at least one matching skill
   ├── If job has company_id → prefer that company's technicians
   │     (fall back to all technicians if none found in company)
   └── Exclude technicians already assigned to this job

2. rank_by_proximity
   ├── Filter out technicians with no coordinates
   └── Sort by Haversine distance from job location (ascending)

3. broadcast_to_next
   └── Create Assignment for the first technician in the ranked list
         status: "pending"
         claim_window: Time.current + 15 minutes
```

**Key Decisions:**
- Company-preference logic falls back to the open pool rather than failing. A company-specific job will still be filled if no company technician is available.
- Technicians without coordinates are excluded from ranking. They cannot be proximity-ranked and are not eligible until they set their location.
- The exclusion of already-assigned technicians (`already_assigned_ids`) is what enables the cascade — each rejection re-runs the service and the previously rejected technician is excluded by this filter.

**Dependencies:**
- `Skill`, `Technician`, `TechnicianSkill`, `Assignment` models
- `CLAIM_WINDOW_MINUTES` constant (15)

---

### 5.2 Assignment Lifecycle

**File:** [`app/controllers/assignments_controller.rb`](../app/controllers/assignments_controller.rb)

**Purpose:**
Manages the state progression of an assignment from the technician's perspective — from receiving a job through to arriving on site and triggering work order creation.

**States:**
```
pending → assigned → en_route → arrived
        ↘
         rejected (triggers re-broadcast via JobMatchingService)
```

**Key Decisions:**
- All assignment queries are scoped through `current_user.technician.assignments` — a technician can only act on their own assignments.
- The `accept` action validates that the claim window has not expired before updating status. An expired pending assignment cannot be accepted.
- The `reject` action immediately re-invokes `JobMatchingService` so the next technician receives the assignment without delay.
- The `arrived` action is the boundary between the Assignment and WorkOrder domains. It creates a `WorkOrder` inside a database transaction — if either the assignment update or the work order creation fails, both are rolled back.

---

### 5.3 WorkOrder Lifecycle

**File:** [`app/controllers/work_orders_controller.rb`](../app/controllers/work_orders_controller.rb)

**Purpose:**
Manages the execution phase of a job after the technician has arrived on site — from starting work through recording what was done to marking the job complete.

**States:**
```
arrived → in_progress → completed
                      → incomplete
                      → cancelled
        → on_hold (paused mid-work, e.g. waiting for parts)
```

**Key Decisions:**
- `arrived` is the initial status when a WorkOrder is created — not `pending`. The technician is already on site. `pending` has no meaningful interpretation at this stage.
- `on_hold` is a distinct status from `incomplete`. On hold means temporarily paused with intent to resume. Incomplete means the job could not be finished.
- `started_at` is recorded when the technician transitions from `arrived` to `in_progress`, and `completed_at` when they mark it done. These timestamps enable future analytics on time-on-site and job duration.
- WorkOrder queries are scoped through `current_user.technician.work_orders` — a technician cannot access or modify another technician's work orders.

---

### 5.4 Line Items

**File:** [`app/controllers/line_items_controller.rb`](../app/controllers/line_items_controller.rb)

**Purpose:**
Allows a technician to build the bill for a job — recording each piece of work performed and its cost. Line items together form the basis for the customer's invoice and the payment total.

**Inputs:**
- `description` — what was done
- `amount` — cost in FCFA

**Key Decisions:**
- `work_order_id` is never accepted from form params. It is always taken from the URL (`params[:work_order_id]`) which is itself scoped through `current_user.technician.work_orders`. This prevents a technician from attaching line items to a work order that is not theirs.
- Line item routes are nested under work orders (`/work_orders/:work_order_id/line_items`) so the scoping context is always present in the URL.
- Line items can be added and removed while the work order is `in_progress`. Once the work order is marked `completed`, modification should be locked — this guard is planned but not yet implemented.

---

### 5.5 Authentication and RBAC

**Files:** [`app/controllers/application_controller.rb`](../app/controllers/application_controller.rb), [`app/models/user.rb`](../app/models/user.rb)

**Purpose:**
Controls who can access the system and what each role is permitted to do.

**Authentication flow:**
```
1. User submits email + password
2. SessionsController finds user by email
3. BCrypt authenticates password via user.authenticate(password)
4. On success: session[:user_id] = user.id
5. current_user reads session[:user_id] on every subsequent request
6. require_login redirects to login if current_user is nil
```

**RBAC:**
Each controller action that is role-restricted declares a `before_action` guard:

| Guard | Permitted Role |
|---|---|
| `require_customer` | customer |
| `require_technician` | technician |
| `require_dispatcher` | dispatcher |
| `require_company_admin` | company_admin |
| `require_account_owner` | account_owner |
| `require_platform_admin` | platform_admin |

**Profile auto-creation:**
The `after_create` callback on `User` creates the associated profile record based on role — `Customer`, `Technician`, or `Tenant` — at registration time. This ensures the profile record always exists when the controller needs it.

**Key Decisions:**
- `require_guest` guards login and register routes — a logged-in user who visits `/login` is redirected to the dashboard rather than seeing the auth layout rendered with the sidebar.
- Technicians are redirected to the profile setup page on first registration rather than the dashboard, ensuring location and skills are set before they can be matched.

---

*Next: Section 6 — Security Model*

---

## 6. Security Model

### 6.1 Defence in Depth

Bolo applies security at multiple layers. No single layer is trusted to be the only protection. If one layer fails or is bypassed, the next layer holds.

```
Layer 1 — Network:      HTTPS in production (TLS in transit)
Layer 2 — Session:      Encrypted, signed cookie — tamper-proof
Layer 3 — Controller:   Authentication + role guards on every action
Layer 4 — Query:        All queries scoped through current_user associations
Layer 5 — Params:       Strong parameters — only permitted fields accepted
Layer 6 — Model:        Validations reject invalid data before persistence
Layer 7 — Database:     Constraints enforce integrity regardless of app layer
```

A request must pass every relevant layer to result in a data change. A bypass at one layer is caught by the next.

---

### 6.2 Authentication

**Mechanism:** `has_secure_password` with BCrypt (cost factor 12)

BCrypt is a one-way hashing function. The plain text password is never stored. On login, the submitted password is hashed and compared to the stored digest. If the digest does not match, authentication fails. There is no way to reverse the digest to recover a password.

**Session management:**
- Session cookie is encrypted and signed by Rails using the application secret key
- `httponly: true` — JavaScript cannot read the cookie, blocking XSS-based session theft
- `secure: true` in production — cookie is only transmitted over HTTPS
- `same_site: :lax` — protects against CSRF from cross-site requests while allowing normal navigation

**Session contents:**
```ruby
session[:user_id]    # used to identify the current user
session[:company_id] # used to scope company context for account owners
```

Nothing sensitive is stored in the session. The session holds only IDs. The full record is fetched from the database on each request via `current_user`.

---

### 6.3 Authorisation and RBAC

Authentication answers *who are you*. Authorisation answers *what are you allowed to do*.

Every controller action that modifies or reads restricted data declares a role guard as a `before_action`. The guard redirects immediately if the current user's role does not match.

**Example — a technician cannot access the jobs creation flow:**
```
JobsController
  before_action :require_login     # must be authenticated
  before_action :require_customer  # must be a customer
```

A technician hitting `POST /jobs` is redirected at the `require_customer` guard before any business logic runs.

**Role predicate methods on User:**
```ruby
user.customer?       # role == "customer"
user.technician?     # role == "technician"
user.platform_admin? # role == "platform_admin"
```

These are the only methods used in guards — the role is never compared by string directly in a controller.

---

### 6.4 Insecure Direct Object Reference (IDOR) Protection

IDOR is the vulnerability where a user changes an ID in a URL or request body to access a record that belongs to someone else.

**The rule applied throughout Bolo:**
Never use a bare model finder. Always scope through the current user's association chain.

| Vulnerable | Safe |
|---|---|
| `Job.find(params[:id])` | `current_user.customer.jobs.find(params[:id])` |
| `Assignment.find(params[:id])` | `current_user.technician.assignments.find(params[:id])` |
| `WorkOrder.find(params[:id])` | `current_user.technician.work_orders.find(params[:id])` |

The scoped finder generates SQL with both the ID condition and the ownership condition. Even if a user guesses a valid ID, the ownership check will not match and Rails raises `ActiveRecord::RecordNotFound`, returning a 404.

---

### 6.5 Mass Assignment Protection

Rails strong parameters (`params.permit`) control which fields are accepted from a form or API request. Any field not explicitly permitted is stripped before it reaches the model.

**Critical fields that are never permitted:**
- `role` — a user cannot promote themselves by submitting a role in registration params
- `status` — a user cannot set their own account status
- `customer_id` / `technician_id` — ownership is always set server-side from `current_user`, never from params
- `work_order_id` on line items — always taken from the scoped URL, never from the request body

---

### 6.6 Cross-Site Request Forgery (CSRF)

Rails `protect_from_forgery with: :exception` is active on all non-GET requests. Rails generates a unique token per session, embeds it in all forms via `form_with`, and verifies it on every state-changing request. A request without a valid token raises an exception and is rejected.

This prevents a malicious third-party website from submitting forms on behalf of a logged-in Bolo user.

---

### 6.7 Sensitive Data in Logs

Rails filters sensitive parameters from logs. The following are configured in `config/application.rb`:

```ruby
config.filter_parameters += [:password, :password_confirmation]
```

Passwords are never written to log files. As payment integration is added, card numbers, CVVs, and payment tokens must be added to this filter list before going to production.

---

### 6.8 Known Risks and Planned Mitigations

| Risk | Current State | Planned Mitigation |
|---|---|---|
| Claim window not enforced server-side | Buttons hidden in UI only | Background job to expire and rebroadcast on window close |
| No rate limiting on login endpoint | Open to brute force | Rack::Attack middleware to throttle failed login attempts |
| No account lockout after failed attempts | Open to brute force | Lockout after N failed attempts with cooldown |
| Technician self-verification | Profile save auto-verifies | Admin verification flow to replace auto-verify |
| No audit trail on status changes | State changes are silent | Event log table to record who changed what and when |
| Payment data not yet handled | Not integrated | PCI-DSS considerations required before integration |

---

*Next: Section 7 — Performance Considerations*

---

## 7. Performance Considerations

### 7.1 Current Mitigations

**Eager loading to prevent N+1 queries**
Any controller action that loads a collection and renders associated data uses `includes()` to batch the associated queries into a fixed number of database calls regardless of collection size.

```ruby
# AssignmentsController#index
@assignments = current_user.technician.assignments
                           .includes(job: :job_category)
                           .order(created_at: :desc)
```

Without `includes`, rendering 50 assignments would fire 1 query for assignments + 50 for jobs + 50 for job categories = 101 queries. With `includes`, it is 3 queries regardless of collection size.

**Preloading associated IDs in views**
Where a view needs to check membership in a collection (e.g. which skills a technician already has selected), the IDs are loaded once in the controller and passed to the view rather than querying inside the loop.

```ruby
# TechnicianProfilesController#edit
@selected_skill_ids = @technician.skill_ids  # one query
```

The view then calls `@selected_skill_ids.include?(skill.id)` — an in-memory array lookup, not a database call per iteration.

**Aggregations pushed to the database**
Dashboard KPI counts use SQL `COUNT` via ActiveRecord rather than loading records into Ruby and calling `.length`.

```ruby
@total_jobs     = customer.jobs.count          # SELECT COUNT(*)
@completed_jobs = customer.jobs.where(...).count
```

**Scoped queries**
All queries are scoped to the current user's associations. This limits result sets to only what the user owns, keeping query cost proportional to the user's data rather than the total dataset size.

---

### 7.2 Known Performance Risks

**Matching engine runs in the request cycle**
`JobMatchingService` is called synchronously inside `after_create` on `Job`. For a small technician pool this is fast. As the pool grows, the Ruby-side proximity ranking loads all matched technicians into memory and sorts them in the application. At scale this becomes a bottleneck.

*Planned mitigation:* Move `JobMatchingService` into a Sidekiq background job. The job creation response returns immediately; matching runs asynchronously. A Turbo Stream or notification then informs the customer when a technician has been assigned.

**Haversine calculated in Ruby**
Distance calculations happen in the application layer after loading technicians from the database. At a large technician pool, this means loading potentially thousands of records into memory to sort them.

*Planned mitigation:* Pre-filter by a bounding box in SQL before the Haversine sort. A simple `WHERE latitude BETWEEN x AND y AND longitude BETWEEN a AND b` eliminates distant technicians before they reach Ruby. At very high scale, migrate to PostGIS for native geospatial indexing and querying.

**No pagination on collections**
Assignment and work order index pages currently load all records for a user. For an active technician with hundreds of historical assignments this grows unbounded.

*Planned mitigation:* Add cursor-based or offset pagination to all index actions before going to production.

**No caching layer**
Job categories and skills are loaded fresh from the database on every job creation and profile setup page render. These collections change rarely.

*Planned mitigation:* Fragment caching on category and skill lists. Low-level `Rails.cache` for reference data that changes infrequently.

---

### 7.3 Scaling Considerations

Bolo is built on a single server with a single database. The following describes the path to scale as demand grows — not what is built today, but what the architecture supports.

**Vertical scaling first**
The first scaling step is always to give the server more CPU and memory. A well-optimised Rails monolith on a beefy single server handles significant traffic. This is always cheaper and simpler than horizontal scaling.

**Read replicas**
PostgreSQL supports read replicas. Analytics queries, reporting, and dashboard aggregations can be routed to a replica, reducing load on the primary. Rails supports this via `connected_to(role: :reading)`.

**Background job scaling**
Sidekiq workers are independent processes. Adding workers scales job processing capacity without touching the web layer. Worker counts can be tuned per queue — a high-priority dispatch queue can have more workers than a low-priority notification queue.

**Database connection pooling**
As web server concurrency grows, database connections become a bottleneck. PgBouncer as a connection pooler sits between the application and PostgreSQL, multiplexing many application connections over fewer database connections.

**Extracting hot domains**
If a specific domain — matching, payments, notifications — becomes the bottleneck, it can be extracted from the monolith into its own service. The service object pattern used throughout makes this extraction cleaner than if the logic lived in models or controllers. This is not planned for v1 but the architecture does not prevent it.

---

*Next: Section 8 — API and Route Design*

---

## 8. API and Route Design

Bolo is a server-rendered application. There is no separate REST or GraphQL API in v1 — routes serve HTML responses, not JSON. All state changes use standard HTTP verbs and redirect on success.

**Full route file:** [`config/routes.rb`](../config/routes.rb)

---

### 8.1 Naming Conventions

- Resources use plural nouns — `/jobs`, `/assignments`, `/work_orders`
- State transition actions are named after what they do, not the resulting state — `/accept`, `/reject`, `/en_route`, `/arrived`, `/start`, `/complete`
- Nested resources use the parent ID in the path — `/work_orders/:work_order_id/line_items` — so the parent scope is always present in the URL without relying on the request body

---

### 8.2 Route Table

**Authentication**

| Method | Path | Action | Access |
|---|---|---|---|
| GET | `/login` | `sessions#new` | Guest only |
| POST | `/login` | `sessions#create` | Guest only |
| DELETE | `/logout` | `sessions#destroy` | Authenticated |
| GET | `/register` | `registrations#new` | Guest only |
| POST | `/register` | `registrations#create` | Guest only |

**Dashboard**

| Method | Path | Action | Access |
|---|---|---|---|
| GET | `/dashboard` | `dashboard#index` | Authenticated — renders role-specific view |

**Jobs**

| Method | Path | Action | Access |
|---|---|---|---|
| GET | `/jobs` | `jobs#index` | Customer |
| GET | `/jobs/new` | `jobs#new` | Customer |
| POST | `/jobs` | `jobs#create` | Customer |

**Technician Profile**

| Method | Path | Action | Access |
|---|---|---|---|
| GET | `/technician/profile` | `technician_profiles#edit` | Technician |
| PATCH | `/technician/profile` | `technician_profiles#update` | Technician |

**Assignments**

| Method | Path | Action | Access |
|---|---|---|---|
| GET | `/assignments` | `assignments#index` | Technician |
| PATCH | `/assignments/:id/accept` | `assignments#accept` | Technician |
| PATCH | `/assignments/:id/reject` | `assignments#reject` | Technician |
| PATCH | `/assignments/:id/en_route` | `assignments#en_route` | Technician |
| PATCH | `/assignments/:id/arrived` | `assignments#arrived` | Technician |

**Work Orders**

| Method | Path | Action | Access |
|---|---|---|---|
| GET | `/work_orders` | `work_orders#index` | Technician |
| GET | `/work_orders/:id` | `work_orders#show` | Technician |
| PATCH | `/work_orders/:id/start` | `work_orders#work_order_started` | Technician |
| PATCH | `/work_orders/:id/complete` | `work_orders#work_order_completed` | Technician |

**Line Items** *(nested under work orders)*

| Method | Path | Action | Access |
|---|---|---|---|
| GET | `/work_orders/:work_order_id/line_items/new` | `line_items#new` | Technician |
| POST | `/work_orders/:work_order_id/line_items` | `line_items#create` | Technician |
| DELETE | `/work_orders/:work_order_id/line_items/:id` | `line_items#destroy` | Technician |

---

### 8.3 Scoping Strategy

Every route that operates on a specific record passes the record ID through the URL. The controller never trusts that ID alone — it always fetches the record through the current user's association chain:

```ruby
# The ID in the URL is only a hint — ownership is verified by the scope
current_user.technician.assignments.find(params[:id])
current_user.technician.work_orders.find(params[:id])
current_user.technician.work_orders.find(params[:work_order_id])
```

If the record exists but does not belong to the current user, `find` raises `ActiveRecord::RecordNotFound` and Rails returns a 404.

---

### 8.4 Future API Considerations

When Bolo adds mobile clients, a versioned JSON API layer will be needed. The planned approach:

- Namespace under `/api/v1/` — breaking changes bump the version, existing clients continue working
- Token-based authentication (API key or JWT) for mobile clients — cookie sessions do not translate to native apps
- JSON responses following a consistent envelope: `{ data: {}, errors: [], meta: {} }`
- Rate limiting via Rack::Attack on all API endpoints

This is not built in v1. The server-rendered HTML layer is the only interface.

---

*Next: Section 9 — What Is Deliberately Not Built Yet*

---

## 9. What Is Deliberately Not Built Yet

This section is as important as everything before it. Every item here was a conscious decision to defer — not an oversight.

---

### 9.1 Claim Window Expiry

**What it is:** When a technician receives a pending assignment, they have 15 minutes to accept or reject. Currently the `claim_window` timestamp is stored and the UI hides the buttons past expiry, but the assignment status is never automatically changed server-side.

**Why it is not built yet:** It requires a background job infrastructure. Building it before Sidekiq is configured would mean a polling-based solution that is throwaway work.

**What triggers building it:** Sidekiq and Redis are integrated. The job is a simple `ClaimWindowExpiryJob` that runs after 15 minutes, checks if the assignment is still pending, and if so marks it rejected and re-invokes `JobMatchingService`.

**Idempotency requirement:** If the job runs twice due to a retry, it must not double-reject or double-broadcast. The guard is: only act if `status == "pending"`.

---

### 9.2 Real-Time Updates

**What it is:** When a technician is assigned, the customer currently has no way to know without refreshing the page. When a technician updates their status (en route, arrived), the customer does not see it in real time.

**Why it is not built yet:** ActionCable and Turbo Streams require careful design around who is subscribed to what channel and what data is broadcast. Building this before the core state machine is stable would mean rebuilding the broadcast logic as the states change.

**What triggers building it:** WorkOrder lifecycle is complete. At that point, Turbo Streams can be added incrementally — one broadcast per state transition — without disrupting the existing flow.

---

### 9.3 Notifications

**What it is:** Push notifications or in-app alerts to tell a technician they have a new assignment, or a customer that their job has been accepted or completed.

**Why it is not built yet:** The `Notification` model and polymorphic association are already in the schema. The delivery mechanism — email, SMS, or in-app — is not yet decided. Building the model before the delivery strategy is defined risks building the wrong abstraction.

**What triggers building it:** Delivery channel decision is made. The notification table is ready; it is the sender that needs to be built.

---

### 9.4 Payments

**What it is:** Processing payment from customer to technician after a work order is approved. The `Payment` model, `Quote` model, and line items are all in the schema.

**Why it is not built yet:** Payment integration requires selecting a provider that operates in Cameroon (likely a mobile money provider such as MTN Mobile Money or Orange Money rather than Stripe), setting up webhooks, handling failed payments, and addressing PCI-DSS requirements for handling payment data. This is significant scope that should not block the core dispatch and work execution flow.

**What triggers building it:** The end-to-end workflow from job posting through work order completion is stable and tested. A payment provider with Cameroon coverage is selected.

---

### 9.5 Technician Verification by Admin

**What it is:** Currently, saving a technician profile auto-verifies them. This was a deliberate shortcut for development — in production, verification should be a human-assisted process where an admin reviews the technician's credentials before they can receive jobs.

**Why it is not built yet:** An admin verification flow requires an admin dashboard, a review queue, and a decision action. This is non-trivial UI work that does not block testing the core matching engine.

**What triggers building it:** Before going to production. Auto-verification must be removed before real users onboard.

---

### 9.6 Customer-Facing Work Order View

**What it is:** After a technician marks a work order complete, the customer needs to see the line items, review what was done, and approve the work before payment is triggered.

**Why it is not built yet:** The technician side of the work order (creating, adding line items, completing) is being built first to establish the data. The customer view reads from that data — it makes sense to build it second.

**What triggers building it:** Work order completion flow on the technician side is finished.

---

### 9.7 Audit Trail

**What it is:** A log of every significant state change in the system — who changed what, when, and from what previous state. Critical for disputes, debugging, and compliance.

**Why it is not built yet:** Requires a design decision on granularity — do you log every model change (expensive) or only domain-significant events (targeted). The targeted approach is correct but needs the full state machine to be stable before the event points are clear.

**What triggers building it:** State machines for Job, Assignment, and WorkOrder are finalised.

---

### 9.8 Dispatcher and Admin Dashboards

**What it is:** A real-time view for dispatchers to see all active jobs, assignments, and technician locations. An admin view for platform management.

**Why it is not built yet:** These are read-heavy operational views. The data they read must exist first. Building the views before the underlying data is stable creates throwaway work.

**What triggers building it:** Core technician and customer flows are complete and stable.

---

*Next: Section 10 — Open Questions*

---

## 10. Open Questions

These are decisions that have not yet been made. They are documented here so they are not forgotten and so that when the answer becomes clear, the reasoning is recorded alongside it.

---

### 10.1 Payment Provider

**Question:** Which payment provider will Bolo use?

**Context:** Stripe is the default choice in most markets but has limited coverage in Cameroon. The primary payment methods in the target market are mobile money — MTN Mobile Money and Orange Money. A provider that abstracts these (such as Flutterwave, Campay, or a direct mobile money API integration) needs to be evaluated.

**What needs to be decided:** Provider selection, fee structure, payout timing to technicians, webhook reliability, and whether the platform holds funds in escrow or passes through immediately.

**Unblocked by:** Completing the work order approval flow so the payment trigger point is well defined.

---

### 10.2 Technician Location Updates

**Question:** How does the system track a technician's real-time location while they are en route?

**Context:** Currently, latitude and longitude on the `Technician` record are set once during profile setup. There is no mechanism to update them as the technician moves. For the matching engine to rank by true proximity at the moment a job is posted, location needs to be reasonably current.

**Options under consideration:**
- Technician manually updates location from their dashboard when they start their shift
- Stimulus controller periodically sends GPS coordinates via a background fetch request
- A dedicated mobile app with background location tracking (longer term)

**What needs to be decided:** Acceptable staleness of location data, battery and data cost of continuous updates, and whether the web browser geolocation API is sufficient or a native app is required.

---

### 10.3 Job Rebroadcast Limit

**Question:** How many times should a job be rebroadcast before it is marked as unfillable?

**Context:** The matching engine cascades through ranked technicians on each rejection. If all available technicians reject the job, the engine returns silently and the job sits with no active assignment. The customer is not notified and has no way to know.

**What needs to be decided:** Maximum rebroadcast count, what status the job moves to when the limit is hit, and how the customer is notified so they can modify the job or wait.

**Note:** The `rebroadcast_count` column already exists on the `jobs` table. The increment logic and the limit check need to be implemented in `JobMatchingService`.

---

### 10.4 Multi-City and Multi-Market Expansion

**Question:** How will Bolo handle multiple cities or countries with different currencies, tax rules, and regulatory requirements?

**Context:** The current data model has no concept of city or region. All technicians and jobs exist in a flat namespace. Proximity ranking is purely distance-based with no city boundary enforcement — a technician in Douala could theoretically be ranked for a job in Yaoundé.

**What needs to be decided:** Whether to introduce a `Region` or `ServiceTerritory` model to constrain matching within geographic boundaries, how to handle currency differences across markets, and at what user scale this becomes necessary.

---

### 10.5 Dispute Resolution

**Question:** What happens when a customer disputes a completed work order?

**Context:** Once a technician marks a work order complete and the customer approves, payment is triggered. There is currently no mechanism for a customer to raise a dispute — to say the work was not done, was done incorrectly, or the line items do not reflect what was agreed.

**What needs to be decided:** Dispute window duration, who adjudicates (platform admin, automated rules, or both), what evidence is accepted (photos, notes, timestamps), and how refunds or partial payments are handled.

---

### 10.6 Technician Availability and Shifts

**Question:** Should the matching engine respect technician shift schedules?

**Context:** The `Shift` model exists in the schema with `start_time` and `end_time`. The matching engine currently does not check whether a technician is within an active shift before assigning them. A technician could receive an assignment at midnight when they are not working.

**What needs to be decided:** Whether shift enforcement is mandatory or advisory, how to handle technicians without shifts defined, and whether the engine should filter by active shift or only warn the dispatcher.

---
