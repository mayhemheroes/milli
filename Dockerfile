FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install -f cargo-fuzz

ADD . /repo
WORKDIR /repo

## TODO: ADD YOUR BUILD INSTRUCTIONS HERE.
# RUN ${HOME}/.cargo/bin/cargo build --all
RUN cd filter-parser/fuzz && ${HOME}/.cargo/bin/cargo fuzz build
RUN cd flatten-serde-json/fuzz && ${HOME}/.cargo/bin/cargo fuzz build
RUN cd json-depth-checker/fuzz && ${HOME}/.cargo/bin/cargo fuzz build
RUN cd milli/fuzz && ${HOME}/.cargo/bin/cargo fuzz build

# Package Stage
FROM ubuntu:20.04


## TODO: Change <Path in Builder Stage>
COPY --from=builder repo/filter-parser/fuzz/target/x86_64-unknown-linux-gnu/release/parse /
COPY --from=builder repo/flatten-serde-json/fuzz/target/x86_64-unknown-linux-gnu/release/flatten /
COPY --from=builder repo/json-depth-checker/fuzz/target/x86_64-unknown-linux-gnu/release/depth /
COPY --from=builder repo/milli/fuzz/target/x86_64-unknown-linux-gnu/release/indexing /