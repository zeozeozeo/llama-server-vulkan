[llama.cpp server](https://github.com/ggerganov/llama.cpp/tree/master/examples/server) and Llama 3.2 3B model bundled together inside a [Docker](https://www.docker.com) image. Compiled with Vulkan support and without AVX support to run on old hardware. Tested on [i3-3220 CPU](https://www.intel.com/content/www/us/en/products/sku/65693/intel-core-i33220-processor-3m-cache-3-30-ghz/specifications.html?q=CM8063701137502) with [RX 470 GPU](https://www.techpowerup.com/gpu-specs/radeon-rx-470.c2861).

```
podman run -d -p 8001:8080 --init --device /dev/kfd --device /dev/dri ghcr.io/kth8/llama-server-vulkan
```
Verify if the server is running by going to http://127.0.0.1:8001 in your web browser or using the terminal:
```
curl http://127.0.0.1:8001/v1/chat/completions -H "Content-Type: application/json" -d '{"messages":[{"role":"user","content":"Hello"}]}'
```
