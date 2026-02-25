#!/usr/bin/env python3
"""
Proxy TCP IPv4 a IPv6 para conectarse a Supabase PostgreSQL
Escucha en localhost:54320 (IPv4) y forward a Supabase IPv6
"""
import socket
import threading
import sys

# Configuración
LOCAL_HOST = '127.0.0.1'
LOCAL_PORT = 54320
REMOTE_HOST = '2600:1f13:838:6e27:f1c:f263:958d:a766'  # IP IPv6 de db.qocpopgcpleijmhuznyi.supabase.co
REMOTE_PORT = 5432

def forward_data(source, destination):
    """Forward data from source socket to destination socket"""
    try:
        while True:
            data = source.recv(4096)
            if not data:
                break
            destination.sendall(data)
    except Exception as e:
        pass
    finally:
        source.close()
        destination.close()

def handle_client(client_socket):
    """Handle a client connection"""
    try:
        # Create IPv6 socket to remote server
        remote_socket = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
        remote_socket.connect((REMOTE_HOST, REMOTE_PORT, 0, 0))

        # Start forwarding threads
        client_to_server = threading.Thread(target=forward_data, args=(client_socket, remote_socket))
        server_to_client = threading.Thread(target=forward_data, args=(remote_socket, client_socket))

        client_to_server.daemon = True
        server_to_client.daemon = True

        client_to_server.start()
        server_to_client.start()

        client_to_server.join()
        server_to_client.join()
    except Exception as e:
        print(f"Error handling client: {e}")
        client_socket.close()

def main():
    """Main proxy server loop"""
    # Create IPv4 server socket
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((LOCAL_HOST, LOCAL_PORT))
    server.listen(5)

    print(f"Proxy TCP iniciado en {LOCAL_HOST}:{LOCAL_PORT}")
    print(f"Forwarding a {REMOTE_HOST}:{REMOTE_PORT} (IPv6)")
    print("Presiona Ctrl+C para detener...")
    print()
    print(f"Usa esta cadena de conexión en Django:")
    print(f"postgresql://postgres:Deicastillo123-@127.0.0.1:{LOCAL_PORT}/postgres")
    print()

    try:
        while True:
            client_socket, address = server.accept()
            print(f"Nueva conexión desde {address}")
            client_thread = threading.Thread(target=handle_client, args=(client_socket,))
            client_thread.daemon = True
            client_thread.start()
    except KeyboardInterrupt:
        print("\nProxy detenido")
        server.close()
        sys.exit(0)

if __name__ == "__main__":
    main()
