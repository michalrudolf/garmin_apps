import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;

enum prop_keys {
    TOTAL = "beers_total_prop_id",
    SESSION = "beers_session_prop_id"
}


class beersView extends WatchUi.View {
    private var IMAGES = new Array<Number>[6];
    private var update_timer;
    
    private const PLACE_KEYS = [
        "place0",
        "place1",
        "place2",
        "place3",
        "place4",
        "place5"
    ];

    private const IMAGE_RES = [
        $.Rez.Drawables.res0,
        $.Rez.Drawables.res1,
        $.Rez.Drawables.res2,
        $.Rez.Drawables.res3,
        $.Rez.Drawables.res4,
        $.Rez.Drawables.res5
    ];
    
    function initialize() {
        View.initialize();

        IMAGES = [
            WatchUi.loadResource(IMAGE_RES[0]),
            WatchUi.loadResource(IMAGE_RES[1]),
            WatchUi.loadResource(IMAGE_RES[2]),
            WatchUi.loadResource(IMAGE_RES[3]),
            WatchUi.loadResource(IMAGE_RES[4]),
            WatchUi.loadResource(IMAGE_RES[5])
        ];

    }

    
    private function update_label(label_id as String, label_text as String) as Void {
        var drawable = View.findDrawableById(label_id);
        if (drawable != null) {
            (drawable as Text).setText(label_text);
        }
    }
    
    private function update_drawables(dc as Dc) as Void {
        var session = Properties.getValue($.SESSION);
        for (var i = 0; i < 6; i++) {
            var res;
            if (session >= (i+1) * 5) {
                res = IMAGES[5];
            } else if (session <= i * 5) {
                res = IMAGES[0];
            } else {
                res = IMAGES[session - i * 5];
            }
            update_drawable(PLACE_KEYS[i], res, dc);
        }
    }
    
    private function update_drawable(drawable_id as String, res, dc as Dc) as Void {
        var drawable = View.findDrawableById(drawable_id);
        if (drawable != null) {
            (drawable as Bitmap).setBitmap(res);
        }
    }

    private function get_display_string(property_prefix as String, property_id as PropertyKeyType) as String {
        var value = Properties.getValue(property_id);
        if (value == null) {
            return "Value = null";
        }
        return property_prefix + ": " + value.toString();
    }
    
    private function update_time() as Void {
        var drawable = View.findDrawableById("clock");
        if (drawable == null) {
            return;
        }
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var now_str = (today.hour as Number).format("%02d") + ":" + (today.min as Number).format("%02d") + ":" + (today.sec as Number).format("%02d");

        (drawable as Text).setText(now_str);
    }

    public function refresh() as Void {
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        update_timer = new Timer.Timer();
        update_timer.start(method(:refresh), 1000, true);  // Update every 1000ms (1 second)
    }

    function onHide() as Void {
        if (update_timer != null) {
            update_timer.stop();
        }
    }

    function onUpdate(dc) as Void {
        update_label("beers_total_label", get_display_string("Total", $.TOTAL));
        update_label("beers_session_label", get_display_string("Session", $.SESSION));
        update_drawables(dc);
        update_time();
        
        View.onUpdate(dc);
    }

    function onLayout(dc as Dc) as Void {
        setLayout($.Rez.Layouts.MainLayout(dc));
    }
}

//! Input handler for the storage view
class BeerStorageViewDelegate extends WatchUi.BehaviorDelegate {

    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    }

    private function increment_property(property_id as PropertyKeyType) as Void {
        var int = Properties.getValue(property_id);
        if (int instanceof Number) {
            int++;
            Properties.setValue(property_id, int);
        }
        WatchUi.requestUpdate();
    }
    
    private function reset_session() as Void {
        Properties.setValue($.SESSION, 0);
        WatchUi.requestUpdate();
        // Reset images
    }

    public function onKey(evt as KeyEvent) as Boolean {
        if (evt.getKey() == WatchUi.KEY_ENTER) {
            increment_property($.TOTAL);
            increment_property($.SESSION);
            return true;
        } else if (evt.getKey() == WatchUi.KEY_DOWN) {
            reset_session();    
        }
        return false;
    }
}
