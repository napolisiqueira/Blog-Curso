FROM python:3.13-alpine3.22
LABEL mantainer="imfelipenapoli@gmail.com"

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY djangoapp /djangoapp
COPY scripts /scripts

WORKDIR /djangoapp

EXPOSE 8000

RUN \
    # Instala as dependências de build do PostgreSQL e outras ferramentas necessárias
    # E TAMBÉM a biblioteca de runtime 'libpq' que é necessária após o build
    apk add --no-cache \
        build-base \
        postgresql-dev \
        python3-dev \
        libpq && \
    \
    # Cria e ativa o ambiente virtual
    python -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install -r /djangoapp/requirements.txt && \
    \
    # Remove SOMENTE as dependências de build (mantendo o libpq, que é essencial)
    apk del \
        build-base \
        postgresql-dev \
        python3-dev && \
    \
    # Cria o usuário não-root para segurança
    adduser --disabled-password --no-create-home duser && \
    \
    # Cria diretórios para arquivos estáticos e de mídia
    mkdir -p /data/web/static && \
    mkdir -p /data/web/media && \
    \
    # Define a propriedade dos diretórios e do venv para o novo usuário
    chown -R duser:duser /venv && \
    chown -R duser:duser /data/web/static && \
    chown -R duser:duser /data/web/media && \
    \
    # Define permissões nos diretórios
    chmod -R 755 /data/web/static && \
    chmod -R 755 /data/web/media && \
    \
    # Garante que os scripts sejam executáveis
    chmod -R +x /scripts

ENV PATH="/scripts:/venv/bin:$PATH"

USER duser

CMD ["commands.sh"]