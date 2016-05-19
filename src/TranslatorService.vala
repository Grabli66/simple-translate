// Translation service that use Yandex translate
public class TranslateService : AsyncTaskExecuter {
  private string[] _result;
  private string _from;
  private string _to;
  private string _text;

  public signal void result(string[] text);

  public TranslateService() {
    base();
  }

  public override void OnExecute() {
    var ntext = Soup.URI.encode(_text, null);
    var request = @"https://translate.yandex.net/api/v1.5/tr.json/translate?key=$(TRNSL_API_KEY)&lang=$(_from)-$(_to)&text=$(ntext)";
    var root = WebJsonClient.Get(request);
    var data = new Gee.ArrayList<string>();

    if (root != null) {
        var sentences = root.get_array_member("text");

        if (sentences != null) {
            foreach (var s in sentences.get_elements()) {
                var el = s.get_string();
                data.add(el);
            }
        }
        _result = data.to_array();
    }
  }

  public override void OnResult() {
    result(_result);
  }

  public void Translate(string from, string to, string text) {
    _from = from;
    _to = to;
    _text = text;
    Run();
  }
}
