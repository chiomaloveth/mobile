package com.company.qik_talk;

import android.content.Context;
import android.os.PowerManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {

    private static final String CHANNEL = "com.qiktalk/proximity";
    private PowerManager.WakeLock proximityWakeLock;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
            flutterEngine.getDartExecutor().getBinaryMessenger(),
            CHANNEL
        ).setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "enableProximityWakeLock":
                    enableProximityWakeLock();
                    result.success(null);
                    break;
                case "disableProximityWakeLock":
                    disableProximityWakeLock();
                    result.success(null);
                    break;
                default:
                    result.notImplemented();
                    break;
            }
        });
    }

    private void enableProximityWakeLock() {
        try {
            PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
            if (proximityWakeLock == null) {
                proximityWakeLock = pm.newWakeLock(
                    PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK,
                    "QikTalk::ProximityWakeLock"
                );
                proximityWakeLock.setReferenceCounted(false);
            }
            if (!proximityWakeLock.isHeld()) {
                proximityWakeLock.acquire();
                android.util.Log.d("Proximity", "✅ Proximity wake lock ACQUIRED");
            }
        } catch (Exception e) {
            android.util.Log.e("Proximity", "❌ Failed to acquire proximity wake lock: " + e.getMessage());
        }
    }

    private void disableProximityWakeLock() {
        try {
            if (proximityWakeLock != null && proximityWakeLock.isHeld()) {
                proximityWakeLock.release();
                android.util.Log.d("Proximity", "✅ Proximity wake lock RELEASED");
            }
        } catch (Exception e) {
            android.util.Log.e("Proximity", "❌ Failed to release proximity wake lock: " + e.getMessage());
        }
    }

    @Override
    public void onDestroy() {
        disableProximityWakeLock();
        super.onDestroy();
    }
}