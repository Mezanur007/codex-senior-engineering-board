# Laravel Audit Playbook

Load this file when a project appears to use Laravel or Laravel-adjacent structure.

## Detection

Laravel signals include:

- `composer.json` requiring `laravel/framework`
- `artisan`
- `app/Http/Controllers`
- `app/Http/Middleware`
- `routes/web.php`, `routes/api.php`, or `routes/console.php`
- `database/migrations`
- `config/app.php`

## Routing And Middleware

- Inspect `routes/web.php` and `routes/api.php` for public endpoints, admin routes, and state-changing routes.
- Verify sensitive routes use appropriate middleware: `auth`, guards, throttling, signed URLs, verified email, or custom authorization middleware.
- Check route model binding does not expose records without tenant or ownership checks.
- Confirm API routes use rate limits for auth, password reset, OTP, upload, export, and expensive endpoints.

## Authorization

- Check controllers and services for policy/gate usage on user-owned or tenant-owned models.
- Verify authorization is enforced server-side, not only by Blade/Inertia/Vue/React UI visibility.
- Inspect `app/Policies`, `AuthServiceProvider`, custom gates, and admin middleware.
- Flag direct model lookups such as `Model::find($id)` when ownership or tenant scoping is not proven.

## Validation And Mass Assignment

- Prefer Form Request classes for complex validation.
- Check controllers for raw `$request->all()`, `$request->input()` passed directly into `create`, `update`, or service methods.
- Verify models define `$fillable` or guarded patterns intentionally.
- Flag broad `$guarded = []` on user-controlled models unless the code proves safe input filtering.

## Eloquent And Database

- Check for N+1 risks in loops, resources, notifications, exports, and Blade views.
- Look for missing eager loading on relationships used in collections.
- Inspect migrations for foreign keys, indexes on foreign keys, nullable fields, cascade behavior, and irreversible operations.
- Check tenant scoping in global scopes, query builders, repositories, and policies.
- Flag unbounded `all()`, large exports without chunking, and queue jobs that load excessive records.

## Queues, Jobs, Events

- Inspect `app/Jobs`, listeners, notifications, mailables, and scheduled commands.
- Verify jobs are idempotent and safe on retry.
- Check timeout, retry, backoff, uniqueness, and failed-job handling for high-impact jobs.
- Flag jobs that send money, emails, webhooks, or entitlement changes without dedupe keys.

## Files, Uploads, And Storage

- Verify uploads validate MIME type, extension, size, and authorization.
- Check storage disks and visibility; private user files should not be placed on public disks.
- Flag use of original filenames without sanitization.
- Confirm download routes authorize access and avoid path traversal.

## Security And Secrets

- Check `.env.example`, `config/*`, and deployment docs for secret handling. Do not print real secret values.
- Verify `APP_DEBUG=false` is expected in production.
- Check CSRF behavior for web routes and token/auth behavior for APIs.
- Review password reset, email verification, signed routes, and session settings.
- Flag raw queries, `DB::statement`, `whereRaw`, `orderByRaw`, and dynamic validation rules using user input.

## Testing Expectations

Critical Laravel tests should cover:

- Policies and unauthorized access.
- Validation failure paths.
- Tenant or ownership isolation.
- Queue/job retry idempotency.
- File upload limits and download authorization.
- Migrations or feature flows that affect payments, entitlements, or user data.
