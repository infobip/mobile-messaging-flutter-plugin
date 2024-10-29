package org.infobip.plugins.mobilemessaging.flutter.common;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.collection.ArraySet;
import androidx.core.app.ActivityCompat;

import org.infobip.mobile.messaging.logging.MobileMessagingLogger;
import org.infobip.mobile.messaging.permissions.PermissionsHelper;

import java.util.Set;

import io.flutter.plugin.common.PluginRegistry;

public class PermissionsRequestManager {
    public interface PermissionsRequester {

        /**
         * This method will be called when required permissions are granted.
         */
        void onPermissionGranted();

        /**
         * Provide permissions which you need to request.
         * <br>
         * For example:
         * <pre>
         * {@code
         * new String[]{Manifest.permission.CAMERA}
         * </pre>
         **/
        @NonNull
        String[] requiredPermissions();

        /**
         * Should application show the dialog with information that not all required permissions are granted and button which leads to the settings for granting permissions after it was already shown once.
         * Recommendations:
         * - If you are asking for permissions by button tap, better to return true, so user will be informed, why an action can't be done, if the user didn't grant the permissions.
         * - If you are asking for permissions on the application start, without any additional user actions, better to return false not to disturb the user constantly.
         **/
        boolean shouldShowPermissionsNotGrantedDialogIfShownOnce();

        /**
         * This method is for providing custom title for the permissions dialog.
         *
         * @return reference to string resource for permissions dialog title
         */
        @StringRes
        int permissionsNotGrantedDialogTitle();

        /**
         * This method is for providing custom message for the permissions dialog.
         *
         * @return reference to string resource for permissions dialog message
         */
        @StringRes
        int permissionsNotGrantedDialogMessage();
    }

    protected PermissionsRequester permissionsRequester;
    protected PermissionsHelper permissionsHelper;
    public static final int REQ_CODE_POST_NOTIFICATIONS_PERMISSIONS = 10000;

    public PermissionsRequestManager(@NonNull PermissionsRequester permissionsRequester) {
        this.permissionsRequester = permissionsRequester;
        this.permissionsHelper = new PermissionsHelper();
    }

    public void onRequestPermissionsResult(String[] permissions, int[] grantResults) {
        for (int result : grantResults) {
            if (result == -1) return;
        }
        permissionsRequester.onPermissionGranted();
    }

    public boolean isRequiredPermissionsGranted(Activity activity, PluginRegistry.RequestPermissionsResultListener listener) {
        final Activity _activity = activity;
        final Set<String> permissionsToAsk = new ArraySet<>();
        final Set<String> neverAskPermissions = new ArraySet<>();

        for (String permission : permissionsRequester.requiredPermissions()) {
            if (!permissionsHelper.hasPermissionInManifest(_activity, permission)) {
                return false;
            }
            checkPermission(_activity, permission, permissionsToAsk, neverAskPermissions);
        }

        if (neverAskPermissions.size() > 0) {
            showSettingsDialog(_activity, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    openSettings(_activity);
                    dialog.dismiss();
                }
            }, neverAskPermissions.toString());
            return false;
        }
        String[] permissionsToAskArray = new String[permissionsToAsk.size()];
        permissionsToAsk.toArray(permissionsToAskArray);
        if (permissionsToAsk.size() > 0) {
            ActivityCompat.requestPermissions(
                    activity,
                    permissionsToAskArray,
                    REQ_CODE_POST_NOTIFICATIONS_PERMISSIONS);
            return false;
        }
        return true;
    }

    protected void checkPermission(Activity activity, String permission, final Set<String> permissionsToAsk, final Set<String> neverAskPermissions) {
        permissionsHelper.checkPermission(activity, permission, new PermissionsHelper.PermissionsRequestListener() {
            @Override
            public void onNeedPermission(Activity activity, String permission) {
                permissionsToAsk.add(permission);
            }

            @Override
            public void onPermissionPreviouslyDeniedWithNeverAskAgain(Activity activity, String permission) {
                neverAskPermissions.add(permission);
            }

            @Override
            public void onPermissionGranted(Activity activity, String permission) {
            }
        });
    }

    protected void showSettingsDialog(Activity activity, DialogInterface.OnClickListener onPositiveButtonClick, String permission) {
        if (!permissionsHelper.isPermissionSettingsDialogShown(activity, permission) ||
                permissionsRequester.shouldShowPermissionsNotGrantedDialogIfShownOnce()) {
            AlertDialog.Builder builder = new AlertDialog.Builder(activity)
                    .setMessage(permissionsRequester.permissionsNotGrantedDialogMessage())
                    .setTitle(permissionsRequester.permissionsNotGrantedDialogTitle())
                    .setPositiveButton(org.infobip.mobile.messaging.resources.R.string.mm_button_settings, onPositiveButtonClick)
                    .setNegativeButton(org.infobip.mobile.messaging.resources.R.string.mm_button_cancel, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.dismiss();
                        }
                    });
            builder.show();
            permissionsHelper.setPermissionSettingsDialogShown(activity, permission, true);
        }
    }

    protected void openSettings(Activity activity) {
        MobileMessagingLogger.d("Will open application settings activity");
        Intent intent = new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        Uri uri = Uri.fromParts("package", activity.getPackageName(), null);
        intent.setData(uri);
        if (intent.resolveActivity(activity.getPackageManager()) != null) {
            activity.startActivity(intent);
        }
    }
}