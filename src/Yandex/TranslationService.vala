
namespace Yandex {

    public class TranslationService : JsonWebClient {

        public signal void result (string text);

        public override void process_response (Json.Node? root_node) {
            if (status_code != 200 || root_node == null)
                return;
            var data = new Gee.ArrayList<string>();
            var strings = root_node.get_object().get_array_member("text");
            var sb = new StringBuilder();
            if (strings != null) {
                strings.foreach_element((arr, index, node) => {
                    sb.append(node.get_string());
                });
            }
            result(sb.str);
            return;
        }

        public void update (string from, string to, string text) {
            var escaped_text = Soup.URI.encode(text, null);
            var e_from = Soup.URI.encode(from, null);
            var e_to = Soup.URI.encode(to, null);
            var sb = new StringBuilder(@"https://translate.yandex.net/api/v1.5/tr.json/");
            sb.append(@"translate?key=$(TRNSL_API_KEY)");
            sb.append(@"&lang=$(e_from)-$(e_to)");
            sb.append(@"&text=$(escaped_text)");
            request = sb.str;
            return;
        }

    }

}
