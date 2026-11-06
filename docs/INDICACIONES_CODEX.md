# Instrucción para Codex local

Integra este paquete como una tarea transversal explícitamente autorizada:
“Infraestructura académica paso a paso”. No tiene como condición cerrar RS-009.
No intentes completar automáticamente los otros 22 issues.

1. Lee AGENTS.md y el estado ACTUAL del repo. Compara estos scripts independientes
   con los existentes. No sobrescribas el código actual de RS-009 ni reemplaces
   configuración por la versión base del ZIP.
2. Usa Bash + gcloud + Python simple. Conserva un archivo de configuración y
   scripts numerados, ejecutables manualmente uno por uno. No añadas Terraform,
   Kubernetes ni un framework de despliegue.
3. Reutiliza contratos RS-002 y nombres vigentes cuando la configuración coincida.
   Ante divergencia, explica exactamente qué campo difiere. Un permiso denegado
   nunca significa que el recurso deba crearse.
4. Separa creación de recursos de ejecución de procesos. Los pasos de Dataflow,
   Workflows y Dataproc deben ser explícitos; no iniciarlos al crear buckets.
5. Mantén dos suscripciones al mismo tópico para Bronze y Dataflow. Nunca uses
   una sola suscripción con consumidores competidores para simular bifurcación.
6. Registra archimate_id en un mapeo script → componente. Registra la simplificación
   de Silver JSON por evento para esta demo y el alcance limitado del fixture.
7. Añade la guía al repo y ejecuta las pruebas locales ya requeridas por el proyecto
   además de las de este paquete. No afirmes validación GCP sin haberla ejecutado.
8. Entrega un commit revisable en español con archivos, pruebas y comandos.
   El usuario ejecutará los scripts GCP uno a uno. No despliegues ni actives
   cómputo automáticamente como parte de esta integración.
9. No cierres RS-009 por haber creado infraestructura. Para cerrarlo exige el
   evento leído en Silver y Bronze, job cancelado, contrato actual validado,
   runbook y commit publicado según reglas del repo.
10. Mantén explícita la lista de componentes pendientes: Workflow batch funcional,
    segundo procesamiento streaming, forecast, mart, API y catálogo. Looker no
    se implementa; la recomendación futura es una aplicación externa de consumo.
    Crear una API hello-world o habilitar un API no satisface esos componentes.

Resultado esperado: el usuario puede ejecutar un comando, ver un recurso o un
resultado en GCP, verificarlo y decidir cuándo pasar al siguiente. Sin bucles
autónomos entre issues ni nueva plataforma de automatización.
