FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root

# --- Step 1: Download the prebuilt Rust binary (CPU, Linux x86_64) ---
RUN curl -fSL -o asr-linux-x86_64.zip \
    "https://github.com/second-state/qwen3_asr_rs/releases/latest/download/asr-linux-x86_64.zip" \
    && unzip -q asr-linux-x86_64.zip \
    && mv asr-linux-x86_64 qwen3_asr_rs \
    && rm asr-linux-x86_64.zip

WORKDIR /root/qwen3_asr_rs

# --- Step 2: Download libtorch (bundled in CPU release, but download if missing) ---
RUN if [ ! -d "libtorch/lib" ]; then \
      curl -fSL -o libtorch-cpu.zip \
        "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.7.1%2Bcpu.zip" \
        && unzip -q libtorch-cpu.zip \
        && rm libtorch-cpu.zip; \
    fi

# --- Step 3: Download Qwen3-ASR-0.6B model weights from HuggingFace (~1.2 GB) ---
RUN mkdir -p Qwen3-ASR-0.6B \
    && curl -fSL --retry 5 --retry-delay 5 -o Qwen3-ASR-0.6B/config.json \
        "https://huggingface.co/Qwen/Qwen3-ASR-0.6B/resolve/main/config.json" \
    && curl -fSL --retry 5 --retry-delay 10 -o Qwen3-ASR-0.6B/model.safetensors \
        "https://huggingface.co/Qwen/Qwen3-ASR-0.6B/resolve/main/model.safetensors"

# --- Step 4: Copy the pre-built tokenizer from release assets ---
RUN cp tokenizers/tokenizer-0.6B.json Qwen3-ASR-0.6B/tokenizer.json

# --- Step 5: Download sample audio ---
RUN curl -fSL -o sample.wav \
    "https://github.com/second-state/qwen3_asr_rs/raw/main/test_audio/sample1.wav"

# Mount point for your own audio files
VOLUME ["/audio"]

ENTRYPOINT ["./asr", "./Qwen3-ASR-0.6B"]
CMD ["sample.wav"]
