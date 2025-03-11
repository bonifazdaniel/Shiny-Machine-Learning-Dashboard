const url = 'https://raw.githubusercontent.com/bonifazdaniel/Shiny-Machine-Learning-Dashboard/main/visitas.json';
const updateUrl = 'https://api.github.com/repos/bonifazdaniel/Shiny-Machine-Learning-Dashboard/contents/visitas.json';

async function actualizarVisitas() {
    try {
        // Obtener el archivo JSON
        let response = await fetch(url);
        let data = await response.json();

        // Incrementar el contador
        data.visitas += 1;

        // Obtener SHA del archivo actual (necesario para actualizar en GitHub)
        let fileResponse = await fetch(updateUrl, {
            headers: {
                "Authorization": "token SECRETO"
            }
        });
        let fileData = await fileResponse.json();
        let sha = fileData.sha;

        // Preparar la actualización del archivo
        let updateData = {
            message: "Actualizar contador de visitas",
            content: btoa(JSON.stringify(data, null, 2)), // Convertir JSON a Base64
            sha: sha
        };

        // Enviar actualización a GitHub
        await fetch(updateUrl, {
            method: "PUT",
            headers: {
                "Authorization": "token SECRETO",
                "Content-Type": "application/json"
            },
            body: JSON.stringify(updateData)
        });

        // Mostrar visitas en el sitio
        document.getElementById('contador').innerText = `Visitas: ${data.visitas}`;
    } catch (error) {
        console.error("Error actualizando visitas:", error);
    }
}

// Ejecutar la función al cargar la página
actualizarVisitas();
