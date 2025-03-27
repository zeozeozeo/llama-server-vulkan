[llama.cpp server](https://github.com/ggerganov/llama.cpp/tree/master/examples/server) and [Gemma 3 4B](https://huggingface.co/bartowski/google_gemma-3-4b-it-GGUF) model bundled together inside a Docker image. Compiled with Vulkan support and without AVX support to run on old hardware. Tested using [i3-3220 CPU](https://www.intel.com/content/www/us/en/products/sku/65693/intel-core-i33220-processor-3m-cache-3-30-ghz/specifications.html?q=CM8063701137502) with [RX 470 GPU](https://www.techpowerup.com/gpu-specs/radeon-rx-470.c2861) running Fedora Linux.

```
docker run -d --device /dev/kfd --device /dev/dri --init -p 8001:8080 ghcr.io/kth8/llama-server-vulkan
```
Verify if the server is running by going to http://127.0.0.1:8001 in your web browser or using the terminal:
```
curl http://127.0.0.1:8001/v1/chat/completions -H "Content-Type: application/json" -d '{"messages":[{"role":"user","content":"Hello"}]}'
```
To load another model you can download the GGUF from [Hugging Face](https://huggingface.co) then mount that into the container and set the `LLAMA_ARG_MODEL` environment variable, for example by adding this to the Docker run command:
```
-v ~/Downloads/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf:/app/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf:z -e LLAMA_ARG_MODEL=DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf
```
