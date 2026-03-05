$apiBase = $env:OPENAI_BASE_URL
if (-not $apiBase) { $apiBase = 'http://192.168.1.97:4000/v1' }

$apiKey = $env:OPENAI_API_KEY
if (-not $apiKey) { $apiKey = $env:LITELLM_MASTER_KEY }
if (-not $apiKey) { $apiKey = '12345' }

$headers = @{ Authorization = "Bearer $apiKey" }

$body = @{
    model    = 'gpt-4'
    messages = @(
        @{ role = 'user'; content = 'Hello!' }
    )
} | ConvertTo-Json -Depth 10

$result =Invoke-RestMethod `
    -Method Post `
    -Uri "$apiBase/chat/completions" `
    -Headers $headers `
    -ContentType 'application/json' `
    -Body $body | ConvertTo-Json -Depth 10
    $result