/* Settings.vala
 *
 * Copyright (C) 2009 - 2016 Jerry Casiano
 *
 * This file is part of Translate.
 *
 * Translate is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Translate is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Translate.  If not, see <http://www.gnu.org/licenses/>.
*/

const string [] POSSIBLE_SCHEMA_DIRS = {
    "/usr/share/glib-2.0/schemas",
    "/home/grabli66/Workspace/simple-translate/data"
};

public Settings? get_settings (string schema_id) {

    SettingsSchema? schema;
    SettingsSchemaSource schema_source = SettingsSchemaSource.get_default();

    schema = schema_source.lookup(schema_id, true);

    if (schema == null) {
        debug("No valid schema in default source. Checking for fallbacks");
        var possible_schema_dirs = new Array <string> ();
        string user_data_dir = Environment.get_user_data_dir();
        string user_schema_dir = Path.build_filename(user_data_dir, "glib-2.0", "schemas");
        possible_schema_dirs.append_val(user_schema_dir);
        foreach (var dir in POSSIBLE_SCHEMA_DIRS)
            possible_schema_dirs.append_val(dir);

        for (int i = 0; i < possible_schema_dirs.length; i++) {
            string dir = possible_schema_dirs.index(i);

            {
                File d = File.new_for_path(dir);
                if (!d.query_exists())
                    continue;
            }

            try {
                debug("Checking for schema in %s", dir);
                schema_source = new SettingsSchemaSource.from_directory(dir, null, false);
            } catch (Error e) {
                debug("Failed to create schema source for %s : %s", dir, e.message);
                continue;
            }
            schema = schema_source.lookup(schema_id, true);
            if (schema != null) {
                debug("Loading schema with id %s from %s", schema_id, dir);
                break;
            }
        }
    }

    if (schema == null) {
        critical("Failed to find valid settings schema! Unable to store settings.");
        return null;
    }

    return new Settings.full(schema, null, null);
}
