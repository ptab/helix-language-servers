import json
import sys


def read_lsp_message():
    try:
        headers = {}
        while True:
            line = sys.stdin.buffer.readline().decode("utf-8")
            if not line or line == "\r\n":
                break
            parts = line.strip().split(": ", 1)
            if len(parts) == 2:
                headers[parts[0]] = parts[1]

    except Exception as e:
        print(f"Error reading headers: {e}", file=sys.stderr)
        return None

    try:
        content_length = int(headers.get("Content-Length", 0))
        if content_length > 0:
            body = sys.stdin.buffer.read(content_length).decode("utf-8")
            return json.loads(body)
        else:
            return None
    except (ValueError, json.JSONDecodeError) as e:
        print(f"Error decoding message: {e}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"Error reading body: {e}", file=sys.stderr)
        return None


def send_lsp_message(message):
    try:
        body = json.dumps(message).encode("utf-8")
        header = f"Content-Length: {len(body)}\r\n\r\n".encode("utf-8")
        sys.stdout.buffer.write(header + body)
        sys.stdout.buffer.flush()
    except Exception as e:
        print(f"Error sending message: {e}", file=sys.stderr)


def process_stream():
    while True:
        message = read_lsp_message()
        if message is None:
            break

        if message.get("method") == "initialize" and "processId" in message.get("params", {}):
            message["params"]["processId"] = None

        send_lsp_message(message)


if __name__ == "__main__":
    process_stream()
