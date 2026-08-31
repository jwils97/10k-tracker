# 10K Workout Tracker PWA

A private, installable workout-tracking Progressive Web App built around:
- Baseline: 32:00 5K
- Goal: sub-60:00 10K
- 10-week / 70-day daily plan
- Training runs capped at 6.0 miles
- Interval-heavy running sessions
- Gym, treadmill, track, bike, pool, turf, and weights
- Separate Jonathan and Nicole completion tracking
- Duration logs for cardio/time-based workouts
- Weight logs for strength workouts
- Per-workout notes and photo uploads
- Offline support
- Local device storage
- JSON backup/export

## Easiest free deployment from Windows: GitHub Pages
1. Create a free GitHub account if you do not already have one.
2. Create a new public repository, e.g. `10k-tracker`.
3. Upload the contents of this folder (not the outer folder itself) to the repository.
4. In the repository, open Settings -> Pages.
5. Under Build and deployment, choose "Deploy from a branch".
6. Select `main` and `/ (root)`, then Save.
7. GitHub will provide an HTTPS site address.

## Install on iPhone
1. Open the GitHub Pages site in Safari on the iPhone.
2. Tap Share.
3. Tap "Add to Home Screen".
4. Name it "10K Tracker" and tap Add.
5. Launch from the Home Screen.

## Important
Workout logs are stored locally in Safari/PWA storage on each device. Jonathan's phone and Nicole's phone will NOT automatically sync with one another in this version. If both people use one shared phone/app instance, both completion fields work together.

Photos are stored locally in IndexedDB and are not included in the JSON backup in v1.
