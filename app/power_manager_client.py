import time
import grpc
import mode_controller_pb2
import mode_controller_pb2_grpc

def get_power_status():
    import subprocess
    result = subprocess.check_output(['./fake_power_source.sh'], text=True).strip()
    return result

def main():
    channel = grpc.insecure_channel('localhost:50051')
    stub = mode_controller_pb2_grpc.ModeControllerStub(channel)
    last_mode = None
    while True:
        status = get_power_status()  # "AC" または "BATTERY"
        mode = "FULL" if status == "AC" else "LOW"
        if mode != last_mode:
            print(f"Power state changed, setting mode to {mode}")
            stub.SetMode(mode_controller_pb2.ModeRequest(mode=mode))
            last_mode = mode
        time.sleep(10)

if __name__ == '__main__':
    main()

