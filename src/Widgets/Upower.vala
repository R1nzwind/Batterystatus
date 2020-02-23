namespace UPower {
    
    [DBus (name = "org.freedesktop.UPower.Device")]
    private interface Device : Object {
        public abstract double percentage {get;}
        public abstract DeviceState state {get;}
        public abstract DeviceWarningLevel warninglevel {get;}
        public abstract int64 time_to_full  {get;}
        public abstract int64 time_to_empty  {get;}
    }

    [CCode (type_signature = "u")]
    public enum DeviceState {
        UNKNOWN = 0,
        CHARGING = 1,
        DISCHARGING = 2,
        EMPTY = 3,
        CHARGED = 4,
        PENDING_CHARGE = 5,
        PENDING_DISCHARGE = 6;
        public string to_string() {
            switch(this) {
                case UNKNOWN:
                    return  "Unknown"; // translation
                case CHARGING:
                    return "Charging"; // translation
                case DISCHARGING:
                    return "Discharging"; // translation
                case EMPTY:
                    return "Empty"; // translation
                case CHARGED:
                    return  "Charged"; // translation
                case PENDING_CHARGE:
                    return  "Pending charge"; // translation
                case PENDING_DISCHARGE:
                    return "Pending discharge"; // translation
                default:
                    return "";
            }
        }
    }
    
    [CCode (type_signature = "u")]
    public enum DeviceWarningLevel {
        UNKNOWN = 0,
        NONE = 1,
        DISCHARGING = 2,
        LOW = 3,
        CRITICAL = 4,
        ACTION = 5;
        public string to_string()
        {
            switch(this)
            {
                case UNKNOWN:
                    return "Unknown"; // translation
                case NONE:
                    return "None"; // translation
                case DISCHARGING:
                    return "Discharging"; // translation
                case LOW:
                    return "Low"; // translation
                case CRITICAL:
                    return "Very low"; // translation
                case ACTION:
                    return "Critical"; // translation
                default:
                    return "";
            }
        }
    }

    public string DeviceStatistics() {

        string devicestate = "";
        string devicewarninglevel = "";
        string time = "";
        string message = "";
     
        try{
            UPower.Device upower = Bus.get_proxy_sync(BusType.SYSTEM,
                        "org.freedesktop.UPower",
                    "/org/freedesktop/UPower/devices/battery_BAT0");
            string perc = upower.percentage.to_string();
            int state = upower.state;
            int level = upower.warninglevel;
            var timetoempty = upower.time_to_empty;
            var empty_h = timetoempty / 3600;
            var empty_m = (timetoempty / 60) - (empty_h * 60);
            var timetofull = upower.time_to_full;
            var full_h = timetofull / 3600;
            var full_m = (timetofull / 60) - (full_h * 60);
           
            time = ("%01g:%02g").printf(full_h,full_m);
            switch (state){
                case UPower.DeviceState.DISCHARGING:
                    devicestate = "Discharging"; // translation
                    time = ("%01g:%02g").printf(empty_h,empty_m);
                    break;
                case UPower.DeviceState.CHARGING:
                    devicestate = "Charging"; // translation
                    break;
                case UPower.DeviceState.EMPTY:
                    devicestate = "Empty"; // translation
                    break;
                case UPower.DeviceState.CHARGED:
                    devicestate = "Full"; // translation
                    break;
            } 
            if ( state == 2 || state == 3){
                switch (level){ 
                    case UPower.DeviceWarningLevel.LOW:
                        devicewarninglevel = "Low";  // translation
                        break;
                    case UPower.DeviceWarningLevel.CRITICAL:
                        devicewarninglevel = "Very low"; // translation
                        break;
                    case UPower.DeviceWarningLevel.ACTION:
                        devicewarninglevel = "Critical"; // translation
                        break;
                }
            }
            message = ("%s\n%s%s%% - (%s)").printf(devicestate,devicewarninglevel,perc,time);
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
            return "";
        }    
        return message;
    }    
}