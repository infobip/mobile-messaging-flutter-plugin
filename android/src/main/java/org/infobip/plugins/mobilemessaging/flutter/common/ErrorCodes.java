package org.infobip.plugins.mobilemessaging.flutter.common;

public enum ErrorCodes {

    SAVE_USER("SAVE_USER_ERROR"),
    PERSONALIZE("PERSONALIZE_ERROR"),
    DEPERSONALIZE_INSTALLATION("DEPERSONALIZE_INSTALLATION_ERROR"),
    CUSTOM_EVENT("CUSTOM_EVENT_ERROR");

    private final String code;

    ErrorCodes(String code) {
        this.code = code;
    }

    public String getErrorCode() {
        return code;
    }
}
