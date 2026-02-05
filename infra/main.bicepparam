using './main.bicep'

param location = 'westeurope'
param projectName = 'kidoikoiaki'
param sqlAdminLogin = 'sqladmin'
param sqlAdminPassword = readEnvironmentVariable('SQL_ADMIN_PASSWORD', '')
