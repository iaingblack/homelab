FROM python:3.10-bookworm

ENV ANSIBLE_JINJA2_NATIVE True
RUN apt-get update && apt-get upgrade -y
RUN pip install --upgrade pip
RUN pip install ansible pywinrm
WORKDIR /app
CMD ["bash"]

# docker container run --mount type=bind,source="$(pwd)",target=/app --rm -it ansible-homelab