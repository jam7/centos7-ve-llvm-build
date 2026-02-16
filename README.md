# centos7-ve-llvm-build

CentOS 7ベースのLLVM（VEターゲット）ビルド環境のDockerイメージ。

## 特徴

- **高速リンク**: mold linkerを導入済み。LLVMのような大規模プロジェクトのリンク時間を大幅に短縮できる。
- **VEクロスビルド対応**: VE用のヘッダ（kheaders-ve1）やライブラリ（glibc-ve1, binutils-ve）を導入済み。実機がない通常のLinux環境からでもVE用ランタイムライブラリをクロスビルドできる。

## ビルド

```bash
docker build -t jam7/centos7-ve-llvm-build .
```

## 使い方

```bash
docker run --rm -it jam7/centos7-ve-llvm-build bash
```

## Appendix: 設計メモ

### ベースイメージ

CentOS 7はEOL（2024年6月）のため、`vault.centos.org`にミラーを切り替えてパッケージをインストールしている。

### コンパイラ

`devtoolset-11`（GCC 11系）を使用。CentOS 7 SCLで確実に利用可能な最新版。
devtoolset-12がSCL vaultリポジトリに存在すれば、Dockerfile中の`11`を`12`に置換するだけで切り替え可能。

### ubuntu-ve-apptainer との対応

参考元: `../ubuntu-ve-apptainer/ubuntu-ve-llvm-build.def`（Ubuntu 24.04 / Apptainer）

| Ubuntu (参考元) | CentOS 7 (本リポジトリ) | 備考 |
|---|---|---|
| `g++` | `devtoolset-11-gcc-c++` | SCL経由でモダンなGCCを導入 |
| `cmake` | CMake 3.28.3 バイナリ直接DL | yumのcmakeはLLVMに必要なバージョンを満たさない |
| `ninja-build` | Ninja 1.11.1 バイナリ直接DL | EPEL版が古いためバイナリを使用 |
| `python3`, `python3-dev` | `python3`, `python3-devel` | パッケージ名の差異のみ |
| `python3-pygments`, `python3-yaml` | `pip3 install pygments pyyaml` | CentOS 7のyumパッケージが古い/不足のためpipで導入 |
| `mold` | mold 2.35.1 静的バイナリ直接DL | GitHubリリースのstatic binary。`libatomic`パッケージが別途必要 |
| `rpm2cpio`, `cpio` | `rpm -ivh --nodeps` | CentOS 7ネイティブのrpmコマンドで直接インストール（`rpm2cpio \| cpio`だと0バイトになる問題を回避） |
| VE RPMs (rpm2cpio展開) | el7用RPMを使用 | binutils-ve, glibc-ve1, kheaders-ve1 |
