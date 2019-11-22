FROM swift:5.1.1 as builder

# For local build, add `--build-arg env=docker`
# In your application, you can use `Environment.custom(name: "docker")` to check if you're in this env
ARG env

RUN apt-get -qq update && apt-get install -y \
  libssl-dev zlib1g-dev
WORKDIR /app
COPY . .
RUN swift build -c release && mkdir /build && mv `swift build -c release --show-bin-path` /build/bin

# Production image
FROM ubuntu:18.04
ARG env
# DEBIAN_FRONTEND=noninteractive for automatic UTC configuration in tzdata
RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y \ 
  libatomic1 libicu60 libxml2 libcurl4 libz-dev libbsd0 tzdata \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /build/bin/Run .
COPY --from=builder /usr/lib/swift/linux/*.so* /usr/lib/swift/linux/
COPY --from=builder /app/Public ./Public
ENV ENVIRONMENT=$env

ENTRYPOINT ./Run serve --env $ENVIRONMENT --hostname 0.0.0.0 --port $PORT
