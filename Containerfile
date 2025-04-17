FROM debian:latest AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y libvulkan-dev glslc cmake git build-essential libcurl4-openssl-dev

RUN git clone --depth 1 https://github.com/ggerganov/llama.cpp

WORKDIR /llama.cpp

RUN cmake -B build \
    -DGGML_VULKAN=1 \
    -DLLAMA_CURL=ON \
    -DCMAKE_C_FLAGS="-march=sandybridge -mtune=generic -mno-avx -mno-avx2 -mno-bmi -mno-bmi2" \
    -DCMAKE_CXX_FLAGS="-march=sandybridge -mtune=generic -mno-avx -mno-avx2 -mno-bmi -mno-bmi2"

RUN cmake --build build --config llama-server

RUN ldd /llama.cpp/build/bin/llama-server

FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive

ARG MODEL
ARG QUANT

WORKDIR /app

RUN apt update && \
    apt install -y mesa-vulkan-drivers libgomp1 --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /llama.cpp/build/bin/llama-server .
COPY --from=builder /llama.cpp/build/bin/libllama.so .
COPY --from=builder /llama.cpp/build/bin/libggml-base.so .
COPY --from=builder /llama.cpp/build/bin/libggml.so .
COPY --from=builder /llama.cpp/build/bin/libggml-cpu.so .
COPY --from=builder /llama.cpp/build/bin/libggml-vulkan.so .

COPY ${MODEL}-${QUANT}.gguf .

ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=8080
ENV LLAMA_ARG_CTX_SIZE=8192
ENV LLAMA_ARG_N_PARALLEL=3
ENV LLAMA_ARG_N_GPU_LAYERS=99
ENV LLAMA_ARG_MODEL=${MODEL}-${QUANT}.gguf

CMD ["/app/llama-server"]
