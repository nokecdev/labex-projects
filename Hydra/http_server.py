
from http.server import HTTPServer, BaseHTTPRequestHandler
import base64

class AuthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        auth_header = self.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Basic '):
            self.send_response(401)
            self.send_header('WWW-Authenticate', 'Basic realm="LabEx"')
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'Authentication required')
            return

        auth_decoded = base64.b64decode(auth_header[6:]).decode('utf-8')
        username, password = auth_decoded.split(':', 1)

        if username == 'admin' and password == 'password123':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            with open('index.html', 'rb') as f:
                self.wfile.write(f.read())
        else:
            self.send_response(401)
            self.send_header('WWW-Authenticate', 'Basic realm="LabEx"')
            self.end_headers()
            self.wfile.write(b'Authentication failed')

if __name__ == '__main__':
    server_address = ('', 8000)
    httpd = HTTPServer(server_address, AuthHandler)
    print("Server running on port 8000...")
    httpd.serve_forever()
