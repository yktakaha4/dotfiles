import os
from http.server import HTTPServer, BaseHTTPRequestHandler
import cgi
import shlex
import datetime
import urllib
import urllib.parse

UPLOAD_DIR = os.environ.get("PY_APP_UPLOAD_DIR") or "/usr/share/nginx/html/shared/uploads"
UPLOAD_COMPLETE_REDIRECT_PATH = os.environ.get("PY_APP_UPLOAD_COMPLETE_REDIRECT_PATH") or "/shared/uploads"
SERVER = os.environ.get("PY_APP_SERVER") or "127.0.0.1"
PORT = int(os.environ.get("PY_APP_PORT") or 8181)
BASE_PATH = os.environ.get("PY_APP_BASE_PATH") or "/py"


class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def resp(self, msg = None, location_sub_path = None):
        payload = urllib.parse.urlencode({
            "msg": msg,
        })
        origin = self.headers.get("Origin")
        location_path = f"{origin}{location_sub_path or "/"}?{payload}"

        self.send_response(302)
        self.send_header("Location", location_path)
        self.end_headers()
        print(f"response: {msg=}, {location_path=}")

    def do_POST(self):
        if self.path == f"{BASE_PATH}/upload":
            content_type = self.headers.get("Content-Type")
            if not content_type or "multipart/form-data" not in content_type:
                return self.resp(msg="Invalid request")

            form = cgi.FieldStorage(
                fp=self.rfile,
                headers=self.headers,
                environ={"REQUEST_METHOD": "POST"}
            )
            file_item = form["file"]

            if file_item.filename:
                cleaned_filename = shlex.quote(os.path.basename(file_item.filename))
                timestamp_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"{timestamp_str}_{cleaned_filename}"

                file_path = os.path.join(UPLOAD_DIR, filename)
                with open(file_path, "wb") as output_file:
                    output_file.write(file_item.file.read())

                uploaded_path = f"{UPLOAD_COMPLETE_REDIRECT_PATH}"
                return self.resp(msg=f"File uploaded: <a href=\"{uploaded_path}\">{filename}<a>")
            else:
                return self.resp(msg="No file uploaded")
        else:
            return self.resp(msg="Invalid request")


def run(server_class=HTTPServer, handler_class=SimpleHTTPRequestHandler, server=SERVER, port=PORT):
    server_address = (server, port)
    httpd = server_class(server_address, handler_class)
    print(f"Starting server on {server}:{port}")
    httpd.serve_forever()


if __name__ == "__main__":
    run()
