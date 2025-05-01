Hashcat-Trial

A customized build of Hashcat, the world's fastest and most advanced password recovery tool. This repository focuses on experimenting with and modifying OpenCL kernels and associated cryptographic modules used in GPU-accelerated password cracking.

🔍 Project Purpose

This project serves as a testbed for:

Understanding and modifying Hashcat's OpenCL implementation

Learning how various cryptographic algorithms are offloaded to the GPU

Exploring kernel optimizations for performance

Educating students or professionals on GPU-based parallel computing

📁 Directory Overview

The key directory in this repository is:

Hashcat-Trial/

├── OpenCL/                 # All OpenCL (.cl) and associated headers (.h) used in cracking algorithms

│   ├── inc_*               # Common includes for ciphers, hashes, etc.

│   ├── m0XXXX_*            # Optimized and pure kernel implementations for different hash modes

│   └── ...                 # Full kernel coverage for a wide range of modes

├── .travis.yml            # CI configuration for Travis CI

├── .editorconfig          # Editor and formatting preferences

├── BUILD*.md              # Platform-specific build instructions

└── *.Zone.Identifier      # (Optional) Metadata files from Windows; can be safely ignored

🛠️ Features

Hundreds of OpenCL kernels across various password cracking modes

Modular include files for:

AES, Camellia, Serpent, Twofish, RC4, GCM, XTS, etc.

SHA-1, SHA-2 family, BLAKE2, RIPEMD160, Whirlpool, SM3, Streebog

ECC (secp256k1), ZIP, TrueCrypt, VeraCrypt, LUKS, and more

Original Hashcat build structure retained for compatibility

🚀 Getting Started

To use or test this project, follow these steps:

# Clone the repository
git clone https://github.com/Nailo27/HashCat.git
cd HashCat/Hashcat-Trial

# Build instructions will vary by platform; see relevant BUILD_*.md files

💡 For kernel debugging or development, use hashcat -D 2 to target OpenCL devices.

📚 Build Guides

Platform-specific build guides are included:

BUILD.md — General

BUILD_CYGWIN.md, BUILD_MSYS2.md — Windows environments

BUILD_macOS.md — Apple devices

BUILD_WSL.md — Windows Subsystem for Linux

⚠️ Disclaimer

This project is intended for educational and ethical research purposes only. Unauthorized access, password cracking, or system tampering without explicit permission is illegal and unethical.

📄 License

Hashcat is released under the MIT License. Refer to the upstream repository for license details regarding the base implementation.

🙋‍♂️ Contributing

Contributions, performance benchmarks, and kernel experiments are welcome. Please open an issue or pull request with a detailed description of your changes.

🔗 Upstream Repository

This repository is based on the original Hashcat GitHub repository.

🧠 Author

Maintained by @Nailo27, @LocoBunny04, and @nathanwright18, cybersecurity students exploring OpenCL, GPU acceleration, and reverse engineering in password cracking.

