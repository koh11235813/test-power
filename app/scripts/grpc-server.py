#!/usr/bin/env python3
import asyncio
from concurrent.futures import ThreadPoolExecutor
import grpc
import os, requests
from transformers import SegformerImageProcessor, SegformerForSemanticSegmentation
from PIL import Image
import torch
from logging import basicConfig, getLogger, DEBUG, INFO, WARNING

import mode_controll_pb2
import mode_controll_pb2_grpc

basicConfig(level=DEBUG)
logger = getLogger(__name__)

getLogger('urllib3').setLevel(WARNING)
getLogger('grpc').setLevel(INFO)
getLogger('filelock').setLevel(INFO)

TEST_IMAGE_URL = "https://ultralytics.com/images/bus.jpg"

def run_inference(model_id: str, image_path: str):
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

    async def _restart_process(self):
        model_id = (
            "nvidia/segformer-b5-finetuned-ade-640-640"
            if self.current_mode == "FULL"
            else "nvidia/segformer-b0-finetuned-ade-512-512"
        )

        image_path = "/tmp/bus.jpg"
        os.makedirs(os.path.dirname(image_path), exist_ok=True)
        response = requests.get(TEST_IMAGE_URL)
        response.raise_for_status()
        with open(image_path, "wb") as f:
            f.write(response.content)

        # Predict with SegFormer
        logits = run_inference(model_id, image_path)
        logger.debug(f"{self.current_mode} mode: tensor shape {tuple(logits.shape)}")

    async def SetMode(self, request, context):
        if request.mode not in ("FULL", "LOW"):
            return mode_controll_pb2.ModeResponse(success=False)
        if request.mode != self.current_mode:
            self.current_mode = request.mode
            await self._restart_process()
        return mode_controll_pb2.ModeResponse(success=True)

async def serve():
    server = grpc.aio.server(ThreadPoolExecutor())
    mode_controll_pb2_grpc.add_ModeControllerServicer_to_server(ModeControllerServicer(), server)
    server.add_insecure_port("[::]:50051")
    await server.start()
    await server.wait_for_termination()

if __name__ == "__main__":
    logger.debug('gRPC server started')
    asyncio.run(serve())

