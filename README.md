# Bolo

A service marketplace for skilled labour in Cameroon. Bolo connects customers who need work done with verified technicians who can do it — handling job posting, matching, assignment, work orders, and quote approval in a single platform.

Built as a real product, not a portfolio project. Every architectural decision was made deliberately and documented.

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Ruby on Rails 8.1 (monolith) |
| Database | PostgreSQL |
| Frontend | Hotwire (Turbo + Stimulus) |
| Auth | Manual — BCrypt + sessions (no Devise) |
| File uploads | Active Storage |
| Geocoding | Nominatim API |
| Styles | Vanilla CSS with custom properties |
| Deployment | Docker + Kamal |

---

## Architecture

### Why a monolith
The problem domain is well understood and the team is small. A monolith gives us ACID transactions across the full job lifecycle — matching, assignment, work order, payment — without distributed transaction complexity. Extracted to services only when there is a demonstrated need.

### Why PostgreSQL
JSONB for flexible media metadata, strong ACID guarantees, and future support for PostGIS if proximity queries need to scale beyond the Haversine implementation. Also used for Solid Cache, Solid Queue, and Solid Cable to avoid Redis as an early dependency.

### Why manual auth
Understanding what Devise abstracts before reaching for the gem. BCrypt password hashing, session management, and role guards are implemented in `SessionsController`, `RegistrationsController`, and `ApplicationController`.

### Why no PostGIS
Job matching uses the Haversine formula in a plain Ruby service object (`JobMatchingService`). Sufficient for current scale and avoids a PostgreSQL extension dependency in early development.

---

## User Roles

| Role | Description |
|---|---|
| `customer` | Posts jobs, approves quotes, tracks job progress |
| `technician` | Receives assignments, submits quotes, completes work orders |
| `dispatcher` | Assigns jobs within a company |
| `company_admin` | Manages a company's technicians and operations |

---

## Core Flows

### Customer
1. Register and post a job with location, category, description, and price range
2. Job is matched to nearby technicians via `JobMatchingService`
3. Technician accepts assignment and travels to site
4. Technician adds line items and submits a quote
5. Customer reviews and approves or rejects the quote from their dashboard
6. Work begins — technician can pause and resume — then marks complete
7. Customer sees actual duration and total billed

### Technician
1. Register and set up profile with location and skills
2. Receives a pending assignment with a claim window
3. Accepts → updates status (en route → arrived → opens work order)
4. Adds line items to build a quote → submits for customer approval
5. On approval: starts work, pauses if needed, completes
6. Duration tracked accurately: `actual_time = completed_at - started_at - total_paused_seconds`

---

## Data Model

See [Docs/system_design.md](Docs/system_design.md) for the full system design and [Docs/Bolo.pdf](Docs/Bolo.pdf) for the original ERD.

### Key relationships

```
users
  └── customers
  └── technicians ── technician_skills ── skills ── job_categories
  └── tenants ── companies ── service_territories

jobs (belongs_to customer, job_category)
  └── assignments (belongs_to technician, job)
        └── work_orders
              └── line_items
              └── quotes
              └── payments
              └── ratings

comments   (polymorphic — commentable on Job, WorkOrder)
notifications (polymorphic — notifiable on any model)
addresses  (polymorphic — addressable on Job, Technician)
```

---

## Setup

### Requirements
- Ruby 3.x
- PostgreSQL
- libvips (Active Storage image processing)

```bash
brew install vips
```

### Install

```bash
git clone <repo>
cd bolo
bundle install
```

### Database

```bash
rails db:create
rails db:migrate
rails db:seed
```

### Run

```bash
bin/dev
```

---

## Key Design Decisions

### Job matching
`JobMatchingService` ranks technicians by proximity using the Haversine formula. Located at `app/services/job_matching_service.rb`.

### Quote flow
Line items on a work order serve as the quote. The technician submits them for customer approval. The same line items become the invoice on completion. No separate Quote model is needed for the core flow.

### Work order duration tracking
Pause/resume cycles accumulate into `total_paused_seconds`. `paused_at` records the current pause start and is cleared on resume. Actual duration on completion:

```ruby
actual_seconds = completed_at - started_at - total_paused_seconds
```

### IDOR protection
All queries are scoped through `current_user` associations. No record is fetched by raw `params[:id]` without first scoping through the authenticated user's owned records.

### Mobile-first UI
80%+ of expected users are on mobile. CSS is written base-mobile with `min-width` breakpoints. Bottom navigation on mobile, sidebar on desktop. All values use CSS custom properties defined in `app/assets/stylesheets/variables.css` — no static values.

---

## Architecture Decision Records

Documented in [Docs/guide.md](Docs/guide.md). Covers: database choice, monolith vs microservices, auth approach, job matching algorithm, and queue strategy.

---

## Roadmap

- [ ] In-app notifications (Turbo Streams)
- [ ] Polymorphic comment system on jobs and work orders
- [ ] Technician and customer ratings
- [ ] Multitenant scoping validation
- [ ] Freelance technician job broadcast
- [ ] Profile pages
- [ ] Password recovery via email
- [ ] Payment proof upload and tracking
