import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Math;

const MENU_SIZE = 6;  // Total number of menu items

var index = 0;
var message_change = false;

// Define your constants here
const TOTAL_PROP_KEYS = ["beers_total_prop_id", "snyts_total_prop_id", "shots_total_prop_id"];
const SESSION_PROP_KEYS = ["beers_session_prop_id", "snyts_session_prop_id", "shots_session_prop_id"];

class beersView extends WatchUi.View {
    private var IMAGES;
    private var DRINK_ICONS;
    private var update_timer;
    private var drunkMessages;
    private var currentMessageIndex;
    private var layoutSet = false;

    private const ROW0 = [
        "r0c0",
        "r0c1",
        "r0c2",
        "r0c3"
    ];

    private const IMAGE_RES = [
        $.Rez.Drawables.res0,
        $.Rez.Drawables.res1,
        $.Rez.Drawables.res2,
        $.Rez.Drawables.res3,
        $.Rez.Drawables.res4,
        $.Rez.Drawables.res5
    ];

    private const DRINK_ICONS_RES = [
        $.Rez.Drawables.resBeer,
        $.Rez.Drawables.resSnyt,
        $.Rez.Drawables.resShot
    ];
    
    function initialize() {
        View.initialize();
        drunkMessages = loadDrunkMessages();
        currentMessageIndex = 0;

        try {
            IMAGES = new Array<BitmapResource>[6];
            for (var i = 0; i < 6; i++) {
                System.println("Loading image resource " + i);
                IMAGES[i] = WatchUi.loadResource(IMAGE_RES[i]);
                System.println("Image " + i + " loaded: " + (IMAGES[i] != null));
            }
            DRINK_ICONS = new Array<BitmapResource>[3];
            for (var i = 0; i < 3; i++) {
                System.println("Loading drink icon resource " + i);
                DRINK_ICONS[i] = WatchUi.loadResource(DRINK_ICONS_RES[i]);
                System.println("Drink icon " + i + " loaded: " + (DRINK_ICONS[i] != null));
            }
        } catch(ex) {
            System.println("Error loading resources: " + ex.getErrorMessage());
        }
    }

    private function loadDrunkMessages() as Array<String> {
        return [
            "Tak na zdravý!",
            "Už máš dost?",
            "Zítra do práce!",
            "Chceš zavolat taxíka?",
            "Kde máš peněženku?",
            "Zítra budeš litovat!",
            "Ty si borec!",
            "Hlavně se nezblij,",
            "Kde máš klíče?",
            "Ještě jedno!",
            "Hlavně, že máš pivo vole!",
            "Doufam, že to je Plzeň!",
            "Nezapomeň hydratovat,",
            "Kolik ještě, ty blázne?",
            "Už z toho je větrák...",
            "Ten náš zlatavý mok,",
            "Čas se vylejt!",
            "Až do dna!",
            "Dej si šplívo!",
            "Ať žije pivo!",
            "Na Ex! Na Ex!",
            "Začínáš mít slinu co?",
            "Jedno pivo (navíc) nevadí,",
            "Je třeba promastit,",
            "Brousíme pilu,",
            "Ať ti nespadne pěna,",
            "Hladinka sem, hladinka tam,",
            "To už nezachráníš,",
            "Čas to prolejt šnytem,",
            "Votáčej!",
            "To je jízda!",
            "Ještě jedno se tam vejde,",
            "Pivní opojení <3",
            "Měl bys přidat,",
            "A ještě do druhý nohy!",
            "A jeětě za babičku!",
            "Už tě brní zubý?",
            "Nečum a chlastej!",
            "Zlijem se jak dobytci!",
        ];
    }

    private function update_label(label_id as String, label_text as String) as Void {
        var drawable = View.findDrawableById(label_id);
        if (drawable != null) {
            drawable.setVisible(true);
            (drawable as Text).setText(label_text);
        }
    }
    
    private function update_drawables(dc as Dc, property_id as String) as Void {
        var value = Properties.getValue(property_id);
        while (value > 20) {
            value -= 20;
        }

        var place = 0;
        while (place < 4) {
            if (value >= 5) {
                update_drawable(place, 5, dc);
                value -= 5;
            } else {
                update_drawable(place, value % 6, dc);
                value -= value % 6;
            }
            place++;
        }
    }
    
    private function update_drawable(place_idx as Number, res_idx as Number, dc as Dc) as Void {
        var drawable = View.findDrawableById(ROW0[place_idx]);
        if (drawable == null) {
            System.println("Drawable not found: " + ROW0[place_idx]);
            return;
        }
        if (IMAGES[res_idx] == null) {
            System.println("Image resource not found: " + res_idx);
            return;
        }
        drawable.setVisible(true);
        (drawable as Bitmap).setBitmap(IMAGES[res_idx]);
    }

    private function hide_drawables() as Void {
        for (var i = 0; i < ROW0.size(); i++) {
            var drawable = View.findDrawableById(ROW0[i]);
            if (drawable != null) {
                System.println("Hiding drawable: " + ROW0[i]);
                drawable.setVisible(false);
            }
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
        var clockDrawable = View.findDrawableById("clock");
        
        if (clockDrawable == null) {
            return;
        }
        
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var timeStr = (today.hour as Number).format("%02d") + ":" + 
                     (today.min as Number).format("%02d") + ":" +
                     (today.sec as Number).format("%02d");
        (clockDrawable as Text).setText(timeStr);
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
        // Call parent's onUpdate first
        View.onUpdate(dc);
        
        // Hide all reset labels by default
        var resetSessionLabel = View.findDrawableById("reset_session_label");
        var resetAllLabel = View.findDrawableById("reset_all_label");
        var resetSessionHardLabel = View.findDrawableById("reset_session_hard_label");
        var drink_icon = View.findDrawableById("drink_icon");
        if (drink_icon == null) {
            System.println("Drink icon drawable not found");
        }
        var totalLabel = View.findDrawableById("total_label");
        var sessionLabel = View.findDrawableById("session_label");
        var messageDrawable = View.findDrawableById("message_label");
        
        update_time();
        // Set initial visibility
        if (resetSessionLabel != null) { resetSessionLabel.setVisible(false); }
        if (resetAllLabel != null) { resetAllLabel.setVisible(false); }
        if (resetSessionHardLabel != null) { resetSessionHardLabel.setVisible(false); }

        if (index >= 3) {
            // Hide beer counting
            hide_drawables();
            if (drink_icon != null) { drink_icon.setVisible(false); }
            if (totalLabel != null) { totalLabel.setVisible(false); }
            if (sessionLabel != null) { sessionLabel.setVisible(false); }
            if (messageDrawable != null) { messageDrawable.setVisible(false); }

            // Show appropriate menu item
            if (index == 3 && resetSessionLabel != null) {
                resetSessionLabel.setVisible(true);
                (resetSessionLabel as Text).setText("Dneska končím");
            } else if (index == 4 && resetSessionHardLabel != null) {
                resetSessionHardLabel.setVisible(true);
                (resetSessionHardLabel as Text).setText("Smazat dnešek");
            } else if (index == 5 && resetAllLabel != null) {
                resetAllLabel.setVisible(true);
                (resetAllLabel as Text).setText("Už nikdy nebudu pít!");
            }
        } else {
            update_drawables(dc, SESSION_PROP_KEYS[index]);
            // Show beer counting
            if (drink_icon != null) {
                drink_icon.setVisible(true);
                (drink_icon as Bitmap).setBitmap(DRINK_ICONS[index]);
            }
            if (messageDrawable != null && message_change) {
                messageDrawable.setVisible(true);
                message_change = false;
                currentMessageIndex = Math.rand() % drunkMessages.size();
                (messageDrawable as Text).setText(drunkMessages[currentMessageIndex]);
            }
            if (totalLabel != null) {
                totalLabel.setVisible(true);
                (totalLabel as Text).setText(get_display_string("Celkem", TOTAL_PROP_KEYS[index]));
            }
            if (sessionLabel != null) {
                sessionLabel.setVisible(true);
                (sessionLabel as Text).setText(get_display_string("Dneska", SESSION_PROP_KEYS[index]));
            }
        }
    }

    function onLayout(dc as Dc) as Void {
        if (!layoutSet) {
            System.println("Setting layout to Layout");
            
            setLayout(Rez.Layouts.Layout(dc));
            System.println("Layout set successfully");            
            layoutSet = true;
        } else {
            System.println("Layout already set, skipping");
        }
    }
}

//! Input handler for the storage view
class BeerStorageViewDelegate extends WatchUi.BehaviorDelegate {

    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
        // Initialize properties if they are not set
        for (var i = 0; i < 3; i++) {
            if (Properties.getValue(TOTAL_PROP_KEYS[i]) == null) {
                Properties.setValue(TOTAL_PROP_KEYS[i], 0);
            }
            if (Properties.getValue(SESSION_PROP_KEYS[i]) == null) {
                Properties.setValue(SESSION_PROP_KEYS[i], 0);
            }
        }
    }

    private function adjust_property(property_id as PropertyKeyType, diff as Number) as Void {
        var int = Properties.getValue(property_id);
        if (int instanceof Number) {
            int += diff;
            Properties.setValue(property_id, int);
        }
    }
    
    private function reset_session() as Void {
        for (var i = 0; i < 3; i++) {
            Properties.setValue(SESSION_PROP_KEYS[i], 0);
        }
    }

    private function reset_all() as Void {
        for (var i = 0; i < 3; i++) {
            Properties.setValue(TOTAL_PROP_KEYS[i], 0);
            Properties.setValue(SESSION_PROP_KEYS[i], 0);
        }
    }

    private function reset_session_hard() as Void {
        for (var i = 0; i < 3; i++) {
            var session_val = Properties.getValue(SESSION_PROP_KEYS[i]);
            if (session_val != 0) {
                adjust_property(TOTAL_PROP_KEYS[i], -session_val);
                Properties.setValue(SESSION_PROP_KEYS[i], 0);
            }
        }
    }

    public function onKey(evt as KeyEvent) as Boolean {
        if (evt.getKey() == WatchUi.KEY_ENTER) {
            if (index < 3) {
                adjust_property(TOTAL_PROP_KEYS[index], 1);
                adjust_property(SESSION_PROP_KEYS[index], 1);
                message_change = true;
            } else if (index == 3) {
                reset_session();
                return true;
            } else if (index == 4) {
                reset_session_hard();
                index = 0;
            } else if (index == 5) {
                reset_all();
                index = 0;
            }
        } else if (evt.getKey() == WatchUi.KEY_DOWN) {
            index = (index + 1) % MENU_SIZE;
        } else if (evt.getKey() == WatchUi.KEY_UP) {
            if (index - 1 < 0) {
                index = MENU_SIZE - 1;
            } else {
                index -= 1;
            }
        } else if (evt.getKey() == WatchUi.KEY_ESC) {
            System.exit();
        }
        WatchUi.requestUpdate();
        return true;
    }
}

