public class Assets : GLib.Object {
    public static Gtk.Image getImage(string name) {
        var global = GlobalSettings.instance();
        return new Gtk.Image.from_file(global.getPath(name));
    }
}

public const string SCHEMA_ID = "skyprojects.eos.translator";
public const string TRNSL_API_KEY = "trnsl.1.1.20150427T160217Z.69da78079263823e.0f0caa9724cee126c18028e70f227b633a3fe58f";
public const string DICT_API_KEY = "dict.1.1.20150726T191533Z.aa2d3a3f5122d94c.aa319cbc89e74736fb2a2ec874c31610796ad862";
