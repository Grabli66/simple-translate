
public abstract class JsonWebClient : Object {

    public static int timeout = 10;
    public static Soup.URI? proxy = get_default_proxy_uri();

    /**
     * status_code of last request
     */
    public static uint status_code = 0;

    /**
     * message length of last request
     */
    public static int64 length = 0;

    static GLib.Once <Json.Parser> _parser;
    /**
     * JsonWebClient:parser:
     *
     * @return      #Json.Parser instance in use
     */
    public static unowned Json.Parser parser {
        get {
            return _parser.once (() => { return new Json.Parser(); });
        }
    }

    /**
     * JsonWebClient:get_json_response:
     *
     * @return      #Json.Object response to request
     */
    public static Json.Node get_json_response (string request) {
        var session = new Soup.SessionSync();
        session.timeout = timeout;
        session.proxy_uri = proxy;
        var msg = new Soup.Message.from_uri("GET", new Soup.URI(request));
        session.send_message(msg);
        status_code = msg.status_code;
        length = msg.response_body.length;
        var data = (string) msg.response_body.data;
        parser.load_from_data(data != null ? data : "{}");
        return parser.get_root();
    }

    /**
     * JsonWebClient:request:
     *
     * Setting a new request causes the client to update
     */
    public string? request {
        get {
            return _request;
        }
        set {
            _request = value;
            add_request();
        }
    }

    /**
     * JsonWebClient:request_delay:
     *
     * Microseconds to wait before processing request
     */
    public int request_delay { get; set; default = 1000000 / 4; }

    string? _request = null;
    JsonRequest? current_request = null;
    ThreadPool <JsonRequest> pool;

    construct {
        pool = new ThreadPool<JsonRequest>.with_owned_data(
                    (r) => {
                        r.process();
                    },
                    -1,
                    false
                );
    }

    /**
     * process_response:
     *
     * Only requirement to inherit from this class.
     */
    public abstract void process_response (Json.Node? response);

    protected void add_request () {
        if (current_request != null)
            current_request.cancel();
        current_request = new JsonRequest(this, request_delay);
        try {
            pool.add(current_request);
        } catch (ThreadError e) {
            warning("ThreadError: %s\n", e.message);
        }
        return;
    }

    internal class JsonRequest : Object {

        public int delay;
        public JsonWebClient parent;

        bool cancelled = false;

        public JsonRequest (JsonWebClient parent, int delay) {
            this.parent = parent;
            this.delay = delay;
        }

        public void cancel () {
            cancelled = true;
            return;
        }

        public bool is_cancelled () {
            return cancelled;
        }

        public void process () {
            Thread.usleep(delay);
            if (cancelled || parent.request == null)
                return;
            Json.Node response = get_json_response(parent.request);
            if (cancelled)
                return;
            Idle.add(() => {
                lock (parent) { parent.process_response(response); }
                return false;
            });
            return;
        }

    }

}
