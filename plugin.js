//
//  plugin.js
//  ReNaMe LaYeRs
//
//  Created by Dmitry Rodionov on 17.05.2025.
//

function onStartup(context) {
    if (!NSClassFromString("IEReNaMeLaYeRsPlugin")) {
        __mocha__.loadFrameworkWithName_inDirectory("ReNaMeLaYeRs", context.plugin.url().path() + "/Contents/Sketch/");
    }
    IEReNaMeLaYeRsPlugin.setEnabled(true);
}

function onShutdown(context) {
    if (NSClassFromString("IEReNaMeLaYeRsPlugin")) {
        IEReNaMeLaYeRsPlugin.setEnabled(false);
    }
}
