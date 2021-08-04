account_id = "uat-aws-account-id"
region = "us-east-1"
runtime = "python3.7"

SalesforceCredentialsSecretsManagerARN = "arn:aws:secretsmanager:us-east-1:142293370047:secret:SalesforceCredentials-YKLVPR"
SalesforceCredentialsKMSKeyARN         = "arn:aws:kms:us-east-1:142293370047:key/9f0a5f05-bcdd-4817-a774-5763d1d43a3c"
SalesforceHost                         =  "https://talech--tscdev.my.salesforce.com/"
SalesforceProduction                   = false
SalesforceUsername                     = "acinegration@talech.com.tscdev"
SalesforceVersion                      = "v52.0"
SalesforceAdapterNamespace             = "amazonconnect"
LambdaLoggingLevel                     = "INFO"

CTRKinesisARN                             =  "arn:aws:kinesis:us-east-1:142293370047:stream/USBCognizantITUSEast1CTR"
CTREventSourceMappingMaximumRetryAttempts = 100

PrivateVpcEnabled    = "true"
VpcSecurityGroupList = ["sg-list"]
VpcSubnetList        = ["subnet-list"]

HistoricalReportingImportEnabled = true
PostcallTranscribeEnabled        = false
RealtimeReportingImportEnabled   = true
ContactLensImportEnabled         = false
PostcallRecordingImportEnabled   = false
PostcallCTRImportEnabled         = true

AmazonConnectInstanceId = "i-1234567890abcdef0"

ConnectReportingS3BucketName = "testreportingbucket"
ConnectRecordingS3BucketName = ""
TranscribeOutputS3BucketName = "transcribeoutputbucket"