# RustScribe

> High-performance speech-to-text service powered by Qwen3-ASR and Rust, with CPU and GPU support.

RustScribe is a fast, self-hosted speech recognition service built on the [Qwen3-ASR](https://github.com/QwenLM/Qwen3-ASR) Rust engine. Transcribe audio in 30 languages with near real-time performance on CPU — and 10–20× faster with a GPU. No cloud, no API keys, no data leaving your machine.

Powered by the upstream [qwen3_asr_rs](https://github.com/second-state/qwen3_asr_rs) project — a pure Rust implementation of Qwen3-ASR using libtorch (with optional CUDA) that loads model weights directly from safetensors files.

---

## Features

- **Zero setup** — single `docker compose build` gets you running
- **30 languages** — Chinese, English, Arabic, Japanese, Hindi, French, German, Spanish, and 22 more
- **Any audio format** — WAV, MP3, M4A, FLAC, OGG, MP4 — FFmpeg statically compiled in, no install needed
- **CPU or GPU** — runs on any machine today, drop-in GPU upgrade when ready
- **Self-hosted** — your audio never leaves your machine
- **Near real-time** on CPU, 10–20× faster with NVIDIA GPU

---

## Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

### 1. Clone

```bash
git clone https://github.com/YOUR_USERNAME/rustscribe.git
cd rustscribe
```

### 2. Build

First-time build downloads the prebuilt Rust binary + Qwen3-ASR-0.6B model weights (~2.7 GB total):

```bash
docker compose build
```

### 3. Run

```bash
# Test with the built-in sample audio
docker compose run --rm qwen3-asr

# Transcribe your own file — drop it in the audio/ folder first
docker compose run --rm qwen3-asr /audio/your_file.wav
```

**Expected output:**

```
Language: English
Text: Thank you for your contribution to the most recent issue of Computer. We sincerely appreciate your work, and we hope you enjoy the entire issue.
```

---

## Usage

Drop any audio file into the `audio/` folder, then:

```bash
# Auto-detect language
docker compose run --rm qwen3-asr /audio/input.wav

# Force a specific language
docker compose run --rm qwen3-asr /audio/input.wav english
docker compose run --rm qwen3-asr /audio/input.mp3 chinese

# Enable debug logging
docker compose run --rm -e RUST_LOG=debug qwen3-asr /audio/input.wav
```

**Output format:**

```
Language: English
Text: <transcribed text here>
```

---

## Supported Languages

30 languages: Chinese, English, Cantonese, Arabic, German, French, Spanish, Portuguese, Indonesian, Italian, Korean, Russian, Thai, Vietnamese, Japanese, Turkish, Hindi, Malay, Dutch, Swedish, Danish, Finnish, Polish, Czech, Filipino, Persian, Greek, Romanian, Hungarian, Macedonian.

---

## Models

| Model | Size | Download | Notes |
|-------|------|----------|-------|
| Qwen3-ASR-0.6B | ~1.2 GB | [HuggingFace](https://huggingface.co/Qwen/Qwen3-ASR-0.6B) | Default — recommended |
| Qwen3-ASR-1.7B | ~3.5 GB | [HuggingFace](https://huggingface.co/Qwen/Qwen3-ASR-1.7B) | Higher accuracy, ~2× slower |

---

## Performance

| Hardware | 8s audio | 1 hour audio |
|----------|----------|--------------|
| CPU (any) | ~8s | ~60–70 min |
| NVIDIA GPU (CUDA) | ~0.5–1s | ~3–6 min |

---

## GPU Upgrade (NVIDIA)

When you have an NVIDIA GPU, switching is one command:

### Prerequisites

Install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) so Docker can access your GPU.

### Build the CUDA image

```bash
docker compose build qwen3-asr-cuda
```

> First-time build downloads libtorch CUDA 12.8 (~2.5 GB extra).

### Run on GPU

```bash
docker compose run --rm qwen3-asr-cuda /audio/your_file.wav
```

That's it — same workflow, 10–20× faster.

---

## Project Structure

```
rustscribe/
├── Dockerfile            # CPU build (Ubuntu 22.04 + prebuilt Rust binary)
├── Dockerfile.cuda       # GPU build (CUDA 12.8 + prebuilt Rust binary)
├── docker-compose.yml    # CPU and GPU services
├── audio/                # Drop your audio files here
└── src/                  # Rust source (upstream qwen3_asr_rs)
    ├── main.rs           # CLI entry point
    ├── audio.rs          # FFmpeg audio loading
    ├── mel.rs            # Whisper-style mel spectrogram
    ├── audio_encoder.rs  # Conv2d + Transformer encoder
    ├── text_decoder.rs   # Qwen3 decoder with KV cache
    ├── inference.rs      # End-to-end ASR pipeline
    └── ...
```

---

## Architecture

RustScribe uses the Qwen3-ASR encoder-decoder architecture fully implemented in Rust:

- **Audio Encoder** (Whisper-style): Conv2d downsampling → sinusoidal positional embeddings → 18 transformer layers → output projection
- **Text Decoder** (Qwen3): 28 transformer layers with Grouped Query Attention, QK-normalization, MRoPE, and SwiGLU MLP
- **Audio pipeline**: FFmpeg → mono 16kHz f32 → 128-bin log-mel spectrogram

---

## Credits

- [second-state/qwen3_asr_rs](https://github.com/second-state/qwen3_asr_rs) — upstream Rust ASR engine
- [QwenLM/Qwen3-ASR](https://github.com/QwenLM/Qwen3-ASR) — model architecture and weights

---

## License

Apache-2.0
