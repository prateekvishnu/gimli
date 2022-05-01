# Build Stage
FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install -f cargo-fuzz

## Add source code to the build stage.
ADD . /gimli
WORKDIR /gimli

RUN cd fuzz && ${HOME}/.cargo/bin/cargo fuzz build

# Package Stage
FROM ubuntu:20.04

COPY --from=builder gimli/fuzz/target/x86_64-unknown-linux-gnu/release/debug_abbrev /
COPY --from=builder gimli/fuzz/target/x86_64-unknown-linux-gnu/release/debug_aranges /
COPY --from=builder gimli/fuzz/target/x86_64-unknown-linux-gnu/release/debug_info /
COPY --from=builder gimli/fuzz/target/x86_64-unknown-linux-gnu/release/debug_line /
COPY --from=builder gimli/fuzz/target/x86_64-unknown-linux-gnu/release/eh_frame /
COPY --from=builder gimli/fuzz/target/x86_64-unknown-linux-gnu/release/eh_frame_hdr /




