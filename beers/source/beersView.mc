import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;

enum prop_keys {
    TOTAL = "beers_total_prop_id",
    SESSION = "beers_session_prop_id",
    SNYT = "snyt_session_prop_id",
    SHOT = "shot_session_prop_id"
}


class beersView extends WatchUi.View {
    private var IMAGES = new Array<Number>[6];
    private var update_timer;
    
    private const ROW0 = [
        "r0c0",
        "r0c1",
        "r0c2",
        "r0c3"
    ];

    private const ROW1 = [
        "r1c0",
        "r1c1",
        "r1c2",
        "r1c3"
    ];

    private const ROW2 = [
        "r2c0",
        "r2c1",
        "r2c2",
        "r2c3"
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
    
    private function update_drawables(prop_id as String, PLACE_KEYS, dc as Dc) as Void {
        var value = Properties.getValue(prop_id);
        while (value > 20) {
            value -= 20;
        }

        if (value < 11) {
            update_drawable(PLACE_KEYS[0], IMAGES[0], dc);
            if (value < 6) {
                update_drawable(PLACE_KEYS[1], IMAGES[value % 6], dc);
                update_drawable(PLACE_KEYS[2], IMAGES[0], dc);
            } else {
                update_drawable(PLACE_KEYS[1], IMAGES[5], dc);
                update_drawable(PLACE_KEYS[2], IMAGES[(value - 5) % 6], dc);
            }
            update_drawable(PLACE_KEYS[3], IMAGES[0], dc);
        } else {
            var r = value - 10;
            update_drawable(PLACE_KEYS[0], IMAGES[5], dc);
            update_drawable(PLACE_KEYS[1], IMAGES[5], dc);
            if (r < 6) {
                update_drawable(PLACE_KEYS[2], IMAGES[r % 6], dc);
                update_drawable(PLACE_KEYS[3], IMAGES[0], dc);
            } else {
                update_drawable(PLACE_KEYS[2], IMAGES[5], dc);
                update_drawable(PLACE_KEYS[3], IMAGES[(r - 5) % 6], dc);
            }
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
        update_drawables($.SESSION, ROW0, dc);
        update_drawables($.SNYT, ROW1, dc);
        update_drawables($.SHOT, ROW2, dc);
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
        Properties.setValue($.SNYT, 0);
        Properties.setValue($.SHOT, 0);
        WatchUi.requestUpdate();
        // Reset images
    }

    public function onKey(evt as KeyEvent) as Boolean {
        if (evt.getKey() == WatchUi.KEY_ENTER) {
            increment_property($.TOTAL);
            increment_property($.SESSION);
            return true;
        } else if (evt.getKey() == WatchUi.KEY_UP) {
            increment_property($.SNYT);
            return true;    
        } else if (evt.getKey() == WatchUi.KEY_DOWN) {
            increment_property($.SHOT);
            return true;    
        } else if (evt.getKey() == WatchUi.KEY_LIGHT) {
            reset_session();
        }
        return false;
    }
}
