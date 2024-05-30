# Путь к папке, содержащей файлы для загрузки
$publicFolder = "C:\path\to\public"

# Устанавливаем порт для HTTP-сервера
$port = 9090

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://*:9090/")
$listener.Start()
Write-Output "HTTP сервер запущен. Слушаем на порту $port..."

# Основной цикл для обработки запросов
while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        # Получаем имя запрашиваемого файла
        $requestedFile = $request.Url.AbsolutePath.TrimStart('/')
        $filePath = Join-Path $publicFolder $requestedFile

        if (Test-Path $filePath -PathType Leaf) {
            # Если файл существует, отправляем его клиенту
            $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentType = "application/octet-stream"
            $response.ContentLength64 = $fileBytes.Length
            $response.OutputStream.Write($fileBytes, 0, $fileBytes.Length)
            $response.OutputStream.Close()
            Write-Output "Отправлен файл: $requestedFile"
        } else {
            # Если файл не найден, отправляем 404
            $response.StatusCode = 404
            $response.StatusDescription = "Not Found"
            $response.OutputStream.Close()
            Write-Output "Файл не найден: $requestedFile"
        }
    } catch {
        Write-Output "Ошибка: $_"
    }
}

# Останавливаем сервер при выходе
$listener.Stop()
