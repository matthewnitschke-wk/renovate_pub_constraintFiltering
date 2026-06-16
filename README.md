# Pub `constraintsFiltering` — Reproduction Repo

This repo demonstrates that Renovate's **pub manager** does not support
[`constraintsFiltering`](https://docs.renovatebot.com/configuration-options/#constraintsfiltering),
causing it to propose dependency updates that violate the project's Dart SDK
constraint.

## The Problem

This package targets **Dart 2** (`sdk: ">=2.19.0 <3.0.0"`). The `args` dependency has released 
newer versions that require **Dart 3+**:

| Package      | Current | Latest Dart-2-compatible | Renovate proposes | Required SDK |
|--------------|---------|--------------------------|-------------------|--------------|
| `args`       | 2.3.1   | **2.4.2** (`>=2.19.0 <4.0.0`) | 2.7.0        | `^3.3.0`     |

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

For this repo, Renovate should propose: `args` → **2.4.2** (not 2.7.0)
