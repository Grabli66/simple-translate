/* Utils.vala
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

/**
 * Language:
 *
 * @id           2 letter language code (ISO 639-1)
 * @name        language name (suitable for display in user interface)
 */
public class Language : Object {

    public string id { get; set; }
    public string name { get; set; }

    public Language (string id, string name) {
        Object(id: id, name: name);
    }

}

/**
 * get_preferred_language:
 *
 * @return      2 letter language code (ISO 639-1)
 */
public string get_preferred_language () {
    foreach (string lang in Intl.get_language_names())
        if (lang.length == 2)
            return lang;
    return "en";
}

/**
 * get_preferred_languages:
 *
 * @return      string containing all found 2 letter language codes (ISO 639-1)
 *               separated by commas, i.e "en,es,fr"
 */
public string get_preferred_languages () {
    var sb = new StringBuilder("");
    foreach (string lang in Intl.get_language_names()) {
        if (lang.length == 2) {
            if (sb.len > 0)
                sb.append(",");
            sb.append(lang);
        }
    }
    return sb.str;
}

/**
 * get_supported_languages:
 *
 * @return      Sorted #Gee.ArrayList of supported #Language
 */
public Gee.ArrayList <Language>? get_supported_languages () {
    Gee.ArrayList <Language>? result = null;
    const string url = "https://translate.yandex.net/api/v1.5/tr.json/getLangs?ui=%s&key=%s";
    string request = url.printf(get_preferred_language(), TRNSL_API_KEY);
    Json.Object response = JsonWebClient.get_json_response(request).get_object();
    if (response != null) {
        Json.Object langs = response.get_object_member("langs");
        result = new Gee.ArrayList <Language> ();
        langs.foreach_member((obj, id, name_node) => {
            result.add(new Language(id, name_node.dup_string()));
        });
        result.sort((a, b) => {
            return strcmp(a.name, b.name);
        });
    }
    return result;
}

internal enum ProxyMode {
    NONE,
    AUTO,
    MANUAL;
}

/**
 * get_default_proxy_uri:
 *
 * @return      #Soup.URI
 */
public Soup.URI get_default_proxy_uri() {
    var settings = get_settings("org.gnome.system.proxy");
    if (settings.get_enum("mode") != ProxyMode.MANUAL)
        return null;
    settings = get_settings("org.gnome.system.proxy.http");
    var host = settings.get_string("host");
    var port = settings.get_int("port");
    return new Soup.URI(@"http://$host:$port");
}

