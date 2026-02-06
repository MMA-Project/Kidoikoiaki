using './main.bicep'

param actionGroups_Application_Insights_Smart_Detection_name = 'Application Insights Smart Detection'
param components_app_backend_kidoikoiaki_name = 'app-backend-kidoikoiaki'
param components_app_frontend_kidoikoiaki_name = 'app-frontend-kidoikoiaki'
param serverfarms_ASP_SQLGrp_ac58_name = 'ASP-SQLGrp-ac58'
param servers_ynov_sql_server_msimon_name = 'ynov-sql-server-msimon'
param sites_app_backend_kidoikoiaki_name = 'app-backend-kidoikoiaki'
param sites_app_frontend_kidoikoiaki_name = 'app-frontend-kidoikoiaki'
param storageAccounts_msimonblob_name = 'msimonblob'
param userAssignedIdentities_oidc_msi_982b_name = 'oidc-msi-982b'
@secure()
param vulnerabilityAssessments_Default_storageContainerPath = readEnvironmentVariable('VULNERABILITY_ASSESSMENTS_STORAGE_CONTAINER_PATH', '')
param workspaces_DefaultWorkspace_2ce35cbb_52a5_4a7c_962a_570844f51275_PAR_externalid = readEnvironmentVariable('LOG_ANALYTICS_WORKSPACE_RESOURCE_ID', '')
