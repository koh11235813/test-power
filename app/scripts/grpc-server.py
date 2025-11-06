#!/usr/bin/env python3

import asyncio
from concurrent import futures
import grpc
import subprocess
from transformers import SegformerImageProcessor, SegformerForSemanticSegmentation
from PIL import Image
import torch, requests, os

import mode_controll_pb2
import mode_controll_pb2_grpc
url = "https://ultralytics.com/images/bus.jpg"


def run_inference(model_id, image_path):
    processor = SegformerImageProcessor.from_pretrained(model_id)
    model = SegformerForSemanticSegmentation.from_pretrained(model_id)
    image = Image.open(image_path)
    inputs = processor(images=image, return_tensors="pt")
    with torch.no_grad():
        outputs = model(**inputs)
    return outputs.logits

class ModeControllerServicer(mode_controll_pb2_grpc.ModeControllerServicer):
    def __init__(self):
        self.current_mode = "LOW"
        self.proc = None

    async def _restart_process(self):
        try:
            if self.proc is not None:
                self.proc.kill()
                await self.proc.wait()
        except ProcessLookupError:
            pass
        #set models
        if self.current_mode == "FULL":
           model_id = "model=nvidia/segformer-b5-finetuned-ade-640-640"
        else:
           model_id = "model=nvidia/segformer-b0-finetuned-ade-512-512"

        image_path = "/tmp/bus.jpg"

        response = requests.get(url)
        response.raise_for_status()

        os.makedirs(os.path.dirname(image_path), exist_ok=True)

        with open(image_path, "wb") as f:
            f.write(response.content)
        print(f"saved image: {image_path}")

        logits = run_inference(model_id, image_path)
        print(f"{self.current_mode} mode: tensor shape: {logits.shape}")

async def SetMode(self, request, context):
        # reload model
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
    print("gRPC server started")
    asyncio.run(serve())

