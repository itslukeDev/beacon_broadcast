# Porting to this version

In order to use this updated version of `beacon_broadcast`, you simply need to update your `pubspec.yaml` file to point to this version of the plugin.

**Replace:**

```yaml
dependencies:
  beacon_broadcast: ^0.3.1
```

**With:**

```yaml
dependencies:
  beacon_broadcast:
    git:
      url: git@github.com:itslukeDev/beacon_broadcast.git
      ref: fix/version-bump
```

After updating your `pubspec.yaml` file, run `flutter clean` and `flutter pub get` to download the updated version of the plugin.
