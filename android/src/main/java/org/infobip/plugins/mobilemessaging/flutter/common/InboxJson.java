package org.infobip.plugins.mobilemessaging.flutter.common;

import org.infobip.mobile.messaging.inbox.Inbox;
import org.json.JSONObject;

public class InboxJson extends Inbox {

    public static JSONObject toJSON(final Inbox inbox) {
        if (inbox == null) {
            return new JSONObject();
        }
        try {
            return new JSONObject(inbox.toString());
        } catch (Exception e) {
            e.printStackTrace();
            return new JSONObject();
        }
    }
}
