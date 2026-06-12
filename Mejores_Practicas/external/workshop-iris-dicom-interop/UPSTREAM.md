# Upstream snapshot

This directory is a **frozen snapshot** of a third-party MIT-licensed
repository, vendored here so the workshop is offline-friendly and so the
canonical reference survives if the upstream disappears.

| Field | Value |
|---|---|
| Upstream URL | https://github.com/intersystems-ib/workshop-iris-dicom-interop |
| License | MIT (see `LICENSE` in this directory) |
| Snapshot commit SHA | `75dcf2f30102432fe41086d86d5e3c9521c45144` |
| Upstream commit date | `2026-03-09T15:30:25+01:00` |
| Snapshot taken | 2026-05-14 |
| Cited by skill | `skills/iris-interop-dicom/SKILL.md` |
| Cited by docs | `Mejores_Practicas/examples/external-repos.md` |

## Modification policy

**Read-only.** Do not edit files inside this tree. Treat it as a vendored
artefact. If you need to extend or correct the sample, fork the upstream
repo and refresh this snapshot, do not mutate the local copy in place.

## Refresh policy

Frozen. Refresh manually by re-cloning when upstream evolves and the
workshop needs the newer content:

```powershell
Remove-Item -Recurse -Force Mejores_Practicas/external/workshop-iris-dicom-interop
git clone https://github.com/intersystems-ib/workshop-iris-dicom-interop.git Mejores_Practicas/external/workshop-iris-dicom-interop
Remove-Item -Recurse -Force Mejores_Practicas/external/workshop-iris-dicom-interop/.git
```

Then update the SHA and date in this file.

## Why a snapshot rather than a submodule

A `git submodule` re-introduces the failure mode this snapshot is meant
to prevent: if the upstream repo disappears or moves, `git submodule
update --init` fails and the workshop becomes uninstallable. A frozen
snapshot trades disk size (small — few MB) for resilience.

## Attribution

The MIT `LICENSE` file in this directory preserves attribution to the
upstream authors. Code snippets quoted in the workshop skill cite the
source file by relative path inside this snapshot.
