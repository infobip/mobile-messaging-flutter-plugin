//
//  ConfigCache.java
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

package org.infobip.plugins.mobilemessaging.flutter.common;

public class ConfigCache {
    private static final ConfigCache INSTANCE = new ConfigCache();

    private Configuration configuration = null;

    private ConfigCache() {
    }

    public static ConfigCache getInstance() {
        return INSTANCE;
    }

    public Configuration getConfiguration() {
        return configuration;
    }

    public void setConfiguration(Configuration configuration) {
        this.configuration = configuration;
    }
}
