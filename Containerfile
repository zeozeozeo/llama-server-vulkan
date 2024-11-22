FROM debian:latest AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y libvulkan-dev glslc cmake git build-essential

RUN git clone --depth 1 https://github.com/ggerganov/llama.cpp

WORKDIR /llama.cpp

RUN cmake -B build \
    -DGGML_VULKAN=1 \
    -DCMAKE_C_FLAGS="-march=sandybridge -mtune=generic -mno-avx -mno-avx2 -mno-bmi -mno-bmi2" \
    -DCMAKE_CXX_FLAGS="-march=sandybridge -mtune=generic -mno-avx -mno-avx2 -mno-bmi -mno-bmi2"

RUN cmake --build build --config llama-server

FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive

ARG MODEL
ARG QUANT

WORKDIR /app

RUN apt update && \
    apt install -y mesa-vulkan-drivers libgomp1 curl --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /llama.cpp/build/bin/llama-server .
COPY --from=builder /llama.cpp/build/src/libllama.so .
COPY --from=builder /llama.cpp/build/ggml/src/libggml-base.so .
COPY --from=builder /llama.cpp/build/ggml/src/libggml.so .
COPY --from=builder /llama.cpp/build/ggml/src/ggml-cpu/libggml-cpu.so .
COPY --from=builder /llama.cpp/build/ggml/src/ggml-amx/libggml-amx.so .
COPY --from=builder /llama.cpp/build/ggml/src/ggml-vulkan/libggml-vulkan.so .

COPY ${MODEL}-${QUANT}.gguf .

ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=8080
ENV LLAMA_ARG_CTX_SIZE=4096
ENV LLAMA_ARG_N_PARALLEL=3
ENV LLAMA_ARG_N_GPU_LAYERS=99
ENV LLAMA_ARG_MODEL=${MODEL}-${QUANT}.gguf

HEALTHCHECK CMD curl --fail http://127.0.0.1:8080/health || exit 1

CMD ["/app/llama-server"]
