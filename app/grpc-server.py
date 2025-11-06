import asyncio
from concurrent import futures
import grpc
import subprocess

import mode_controll_pb2
import mode_controll_pb2_grpc

class ModeControllerServicer(mode_controll_pb2_grpc.ModeControllerServicer):
    def __init__(self):
        self.current_mode = "LOW"
        self.proc = None

    async def _restart_process(self):
        # 既存プロセス終了
        if self.proc is not None:
            self.proc.kill()
            await self.proc.wait()
        # モードに応じてモデルを選択
        if self.current_mode == "FULL":
            cmd = ["yolo", "segment", "predict", "model=nvidia/segformer-b5-finetuned-ade-640-640", "source=https://ultralytics.com/images/bus.jpg"]
        else:
            cmd = ["yolo", "segment", "predict", "model=nvidia/segformer-b0-finetuned-ade-512-512", "source=https://ultralytics.com/images/bus.jpg"]
        self.proc = await asyncio.create_subprocess_exec(*cmd)

    async def SetMode(self, request, context):
        # モード更新
        if request.mode not in ("FULL", "LOW"):
            return mode_controll_pb2.ModeResponse(success=False)
        if request.mode != self.current_mode:
            self.current_mode = request.mode
            await self._restart_process()
        return mode_controll_pb2.ModeResponse(success=True)

async def serve():
    server = grpc.aio.server(futures.ThreadPoolExecutor())
    mode_controll_pb2_grpc.add_ModeControllerServicer_to_server(ModeControllerServicer(), server)
    server.add_insecure_port('[::]:50051')
    await server.start()
    await server.wait_for_termination()

if __name__ == '__main__':
    asyncio.run(serve())

