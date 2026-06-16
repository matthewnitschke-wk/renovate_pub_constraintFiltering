# Pub `constraintsFiltering` — Reproduction Repo

This repo demonstrates that Renovate's **pub manager** does not support
[`constraintsFiltering`](https://docs.renovatebot.com/configuration-options/#constraintsfiltering),
causing it to propose dependency updates that violate the project's Dart SDK
constraint.

## The Problem

This package targets **Dart 2** (`sdk: ">=2.19.0 <3.0.0"`). Several of its
dependencies have released newer versions that require **Dart 3+**:

| Package      | Current | Latest Dart-2-compatible | Renovate proposes | Required SDK |
|--------------|---------|--------------------------|-------------------|--------------|
| `args`       | 2.3.1   | **2.4.2** (`>=2.19.0 <4.0.0`) | 2.7.0        | `^3.3.0`     |
| `collection` | 1.17.0  | **1.18.0** (`>=2.18.0 <4.0.0`) | 1.19.1       | `^3.4.0`     |
| `meta`       | 1.15.0  | **1.16.0** (`>=2.12.0 <4.0.0`) | 1.18.3       | `^3.5.0`     |

Even with `"constraintsFiltering": "strict"` in `renovate.json`, Renovate
still proposes the Dart-3-only versions because the **pub datasource is not
listed** as a supported datasource for this feature.

Currently supported datasources: `crate`, `go`, `jenkins-plugins`, `npm`,
`packagist`, `pypi`, `rubygems`.

## Expected Behavior

With `constraintsFiltering: "strict"`, Renovate should read the `environment.sdk`
constraint from `pubspec.yaml`, compare it against each release's own SDK
constraint (available via `pubspec.environment` in the
[pub.dev API](https://pub.dev/api/packages/args)), and filter out any release
whose SDK constraint is not satisfiable by the project's constraint.

For this repo, Renovate should propose:
- `args` → **2.4.2** (not 2.7.0)
- `collection` → **1.18.0** (not 1.19.1)
- `meta` → **1.16.0** (not 1.18.3)

## How to Run

1. **Fork** this repo.
2. Create a **GitHub Personal Access Token** (classic, with `repo` scope) and
   add it as a repository secret named `RENOVATE_TOKEN`.
3. Go to **Actions → Renovate → Run workflow** to trigger a run.
4. Observe that Renovate opens PRs proposing Dart-3-only versions despite the
   `constraintsFiltering: "strict"` setting.

## Why This Matters

In the Dart ecosystem, it is common practice to bump the minimum SDK version in
minor releases. This means packages frequently drop Dart 2 support without a
major version bump, relying instead on the `environment.sdk` constraint in
`pubspec.yaml` for compatibility signaling.

Without `constraintsFiltering` support in the pub manager, Renovate creates
PRs that:
- Fail `dart pub get` because the SDK constraint cannot be satisfied
- Require manual review to determine which version is actually compatible
- Generate noise that erodes trust in automated dependency updates

## Implementation Notes

The pub.dev API already exposes the necessary data. For example:

```
GET https://pub.dev/api/packages/args
```

Each version in the response includes:

```json
{
  "version": "2.7.0",
  "pubspec": {
    "environment": {
      "sdk": "^3.3.0"
    }
  }
}
```

This is analogous to how npm exposes `engines.node` — which Renovate already
uses for `constraintsFiltering` in the npm manager.

## Related

- [Renovate `constraintsFiltering` docs](https://docs.renovatebot.com/configuration-options/#constraintsfiltering)
- [pub.dev API](https://pub.dev/help/api)
