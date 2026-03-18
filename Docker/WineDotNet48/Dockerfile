FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99
ENV WINEARCH=win32
ENV WINEPREFIX=/root/.wine
ENV WINEDEBUG=-all

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y ca-certificates curl gnupg software-properties-common \
    && mkdir -pm755 /etc/apt/keyrings \
    && curl -fsSL https://dl.winehq.org/wine-builds/winehq.key \
       | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.gpg] https://dl.winehq.org/wine-builds/ubuntu/ jammy main" \
       > /etc/apt/sources.list.d/winehq.list \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable \
    && apt-get install -y cabextract xvfb winbind xdotool \
    && curl -fsSL https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
       -o /usr/local/bin/winetricks \
    && chmod +x /usr/local/bin/winetricks \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY install-dotnet.sh /install-dotnet.sh
RUN sed -i 's/\r$//' /install-dotnet.sh && chmod +x /install-dotnet.sh && /install-dotnet.sh

COPY verify-dotnet.sh /verify-dotnet.sh
RUN sed -i 's/\r$//' /verify-dotnet.sh && chmod +x /verify-dotnet.sh && /verify-dotnet.sh

CMD ["wine", "cmd", "/c", "echo", ".NET 4.8 ready"]
