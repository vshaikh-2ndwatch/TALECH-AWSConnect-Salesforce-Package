account_id = "139967329992" #"142293370047"
region = "us-east-1"
runtime = "python3.7"

SalesforceCredentialsSecretsManagerARN = "arn:aws:secretsmanager:us-east-1:142293370047:secret:SalesforceCredentials-YKLVPR" #"arn:aws:secretsmanager:us-east-1:139967329992:secret:SalesforceCredentials-lePUks"
SalesforceCredentialsKMSKeyARN         = "arn:aws:kms:us-east-1:142293370047:key/9f0a5f05-bcdd-4817-a774-5763d1d43a3c" #"arn:aws:kms:us-east-1:139967329992:key/aeaa99cf-d4ed-4793-aac6-361596f76cf8"
SalesforceHost                         =  "https://talech--tscdev.my.salesforce.com/"
SalesforceProduction                   = false
SalesforceUsername                     = "acinegration@talech.com.tscdev"
SalesforceVersion                      = "v52.0"
SalesforceAdapterNamespace             = "amazonconnect"
LambdaLoggingLevel                     = "INFO"

CTRKinesisARN                             =  "arn:aws:kinesis:us-east-1:139967329992:stream/ctr-salesforce-stream" #"arn:aws:kinesis:us-east-1:142293370047:stream/USBCognizantITUSEast1CTR"
CTREventSourceMappingMaximumRetryAttempts = 100

PrivateVpcEnabled    = "true"
VpcSecurityGroupList = ["sg-e54cf6fd"]
VpcSubnetList        = ["subnet-9b1b8baa"]

HistoricalReportingImportEnabled = true
PostcallTranscribeEnabled        = true
RealtimeReportingImportEnabled   = true
ContactLensImportEnabled         = true
PostcallRecordingImportEnabled   = false # true
PostcallCTRImportEnabled         = true

AmazonConnectInstanceId = "i-1234567890abcdef0"

ConnectReportingS3BucketName = "testreportingbucket"
ConnectRecordingS3BucketName = "" # "testrecordingbucket"
TranscribeOutputS3BucketName = "transcribeoutputbucket"