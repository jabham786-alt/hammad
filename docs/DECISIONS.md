# Decisions

- Preserve the original `main` branch; all Ludo work is isolated on `feat/ludo-mvp`.
- Flutter + null-safe Dart; game rules are separated into `lib/engine/`.
- Offline-only MVP: pass-and-play and local computer opponent. No accounts, backend, ads, payments, or online play.
- Original visual treatment and generic Ludo branding; no copied third-party assets.
- Placeholder Android application ID: `com.example.ludo` (owner must verify/replace before release).
- Current MVP UI uses selectable token chips alongside a custom-painted board. Full track-accurate token placement and polished move animation remain follow-up work.
- Sound toggle is a UI placeholder until audio assets and persistence are added.
