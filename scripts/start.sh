#!/bin/bash

# Iniciar Apache en segundo plano
echo "Iniciando Apache..."
/usr/sbin/apachectl start

# Ejecutar Code Server
# --auth none es solo para testing; se recomienda usar --auth password
echo "Iniciando Code Server en http://0.0.0.0:8080"
/usr/bin/code-server --bind-addr 0.0.0.0:8080 --auth none .
#