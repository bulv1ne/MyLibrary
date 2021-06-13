FROM swift:latest as builder
WORKDIR /project
COPY . .
RUN swift build -c release

FROM swift:slim
WORKDIR /project
COPY --from=builder /project .
CMD [".build/release/MyLibraryExec"]
