# task.ps1

# 1. Визначення змінних
$targetVMSize = "Standard_B2pts_v2"
$resultFile = "./result.json"

# Створення порожнього масиву для зберігання знайдених регіонів
$availableRegions = @()

# 2. Отримання списку файлів у теці 'data' (Використовуємо .NET для стійкості)
$dataDirectory = Resolve-Path "./data"
# GetFiles повертає шляхи, Get-Item перетворює їх на об'єкти, щоб ForEach працював коректно
$regionFiles = [System.IO.Directory]::GetFiles($dataDirectory.Path, "*.json") | ForEach-Object { Get-Item $_ }

# 3. Ітерація по кожному файлу (кожному регіону)
foreach ($file in $regionFiles) {
    # 3.1. Видобування імені регіону з назви файлу
    $regionName = $file.BaseName

    # 3.2. Зчитування вмісту файлу та конвертація JSON у масив об'єктів
    # Використовуємо позиційний аргумент, щоб уникнути конфлікту -Path
    $vmSizes = Get-Content $file.FullName | ConvertFrom-Json

    # 3.3. Фільтрація: пошук цільового SKU VM
    $foundVM = $vmSizes | Where-Object { $_.Name -eq $targetVMSize }

    # 3.4. Перевірка наявності та додавання регіону до результату
    if ($foundVM) {
        $availableRegions += $regionName
    }
}

# 4. Експорт результату у форматі JSON
# Використовуємо позиційний аргумент для Out-File
$availableRegions | ConvertTo-Json -Depth 10 | Out-File $resultFile -Encoding UTF8