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
                    return  (_("Unknown"));
                case CHARGING:
                    return (_("Charging"));
                case DISCHARGING:
                    return (_("Discharging"));
                case EMPTY:
                    return (_("Empty"));
                case CHARGED:
                    return  (_("Charged"));
                case PENDING_CHARGE:
                    return  (_("Pending charge"));
                case PENDING_DISCHARGE:
                    return (_("Pending discharge"));
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
                    return (_("Unknown"));
                case NONE:
                    return (_("None"));
                case DISCHARGING:
                    return (_("Discharging"));
                case LOW:
                    return (_("Low"));
                case CRITICAL:
                    return (_("Very low"));
                case ACTION:
                    return (_("Critical"));
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
                    devicestate = (_("Discharging"));
                    time = ("%01g:%02g").printf(empty_h,empty_m);
                    break;
                case UPower.DeviceState.CHARGING:
                    devicestate = (_("Charging"));
                    break;
                case UPower.DeviceState.EMPTY:
                    devicestate = (_("Empty"));
                    break;
                case UPower.DeviceState.CHARGED:
                    devicestate = (_("Full"));
                    break;
            } 
            if ( state == 2 || state == 3){
                switch (level){ 
                    case UPower.DeviceWarningLevel.LOW:
                        devicewarninglevel = (_("Low"));
                        break;
                    case UPower.DeviceWarningLevel.CRITICAL:
                        devicewarninglevel = (_("Very low"));
                        break;
                    case UPower.DeviceWarningLevel.ACTION:
                        devicewarninglevel = (_("Critical"));
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