
public class WordTranslation {
    public string Text;
    public string Category;
    public string[] Examples;
    public string[] Synonyms;
    public string[] Means;
}

public class WordCategory {
    public string Category;
    public string Transcription;
    public WordTranslation[] Translations;
}

public class WordInfo {
    public WordCategory[] WordCategories;
}


namespace Yandex {

    public class DictionaryService : JsonWebClient {

        /* XXX Called from translator window */
        public static string GetSpeechPart(string s) {
            switch (s) {
                case "noun":
                    return _("Noun");
                case "adverb":
                    return _("Adverb");
                case "verb":
                    return _("Verb");
                case "adjective":
                    return _("Adjective");
                case "pronoun":
                    return _("Pronoun");
                case "conjunction":
                    return _("Conjunction");
                case "particle":
                    return _("Particle");
                case "participle":
                    return _("Participle");
                case "adverbial participle":
                    return _("AdverbialParticiple");
            }

            return s;
        }


        public signal void result(WordInfo data);

        public override void process_response (Json.Node? root_node) {
            if (status_code != 200 || root_node == null)
                return;

            Json.Object obj = root_node.get_object();
            if (obj != null && obj.has_member("def")) {

                var defs = obj.get_array_member("def");

    //            var json_gen = new Json.Generator();
    //            json_gen.root = root_node;
    //            json_gen.pretty = true;
    //            size_t len;
    //            stdout.printf("\n\n%s\n\n\n", json_gen.to_data(out len));

                if (defs != null) {
                    var cats = new Gee.ArrayList<WordCategory>();
                    foreach (var el1 in defs.get_elements()) {
                        var obj1 = el1.get_object();
                        var cat = new WordCategory();
                        cat.Category = obj1.get_string_member("pos");
                        cat.Transcription = obj1.get_string_member("ts");

                        var trs = obj1.get_array_member("tr");
                        if (trs == null)
                            continue;
                        var trList = new Gee.ArrayList<WordTranslation>();
                        foreach (var el2 in trs.get_elements()) {
                            var obj2 = el2.get_object();
                            var tr = new WordTranslation();
                            tr.Text = obj2.get_string_member("text");
                            tr.Category = obj2.get_string_member("pos");
                            trList.add(tr);
                        }
                        cat.Translations = trList.to_array();
                        cats.add(cat);
                  }

                  var res = new WordInfo();
                  res.WordCategories = cats.to_array();
                  result(res);
                }
            }

            return;
        }

        public void GetWordInfo(string word, string from, string to) {
            var escaped_text = Soup.URI.encode(word, null);
            var e_from = Soup.URI.encode(from, null);
            var e_to = Soup.URI.encode(to, null);
            var sb = new StringBuilder(@"https://dictionary.yandex.net/api/v1/dicservice.json/");
            sb.append(@"lookup?key=$(DICT_API_KEY)");
            sb.append(@"&lang=$(e_from)-$(e_to)");
            sb.append(@"&text=$(escaped_text)");
            request = sb.str;
            stdout.printf("%s\n", request);
            return;
        }

    }

}
