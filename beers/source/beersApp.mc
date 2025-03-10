import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

// Define your constants here
const TOTAL_PROPS = ["beers_total_prop_id", "snyts_total_prop_id", "shots_total_prop_id"];
const SESSION_PROPS = ["beers_session_prop_id", "snyts_session_prop_id", "shots_session_prop_id"];

class beersApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        // Initialize properties if they are not set
        for (var i = 0; i < TOTAL_PROPS.size(); i++) {
            if (Properties.getValue(TOTAL_PROPS[i]) == null) {
                Properties.setValue(TOTAL_PROPS[i], 0);
            }
            if (Properties.getValue(SESSION_PROPS[i]) == null) {
                Properties.setValue(SESSION_PROPS[i], 0);
            }
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new $.beersView(), new $.BeerStorageViewDelegate()];
    }

}

function getApp() as beersApp {
    return Application.getApp() as beersApp;
}
